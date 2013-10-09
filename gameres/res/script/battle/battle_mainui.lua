--------------------------------------------------------------
-- FileName: 	battle_mainui.lua
-- author:		hst, 2013/05/31
-- purpose:		对战主UI
--------------------------------------------------------------

battle_mainui = {}
local p = battle_mainui;

p.layer = nil;
p.imageMask = nil;

local useSkill = false;  --当前回合是否用技能攻击
local isHeroAutoAtk = false; --是否托管（自动攻击）
local waitingInput = true;

local atkBtn = nil;
local autoBtn = nil;
local bossHpBar = nil;

--重置
function p.Reset()
	useSkill = false;
	isHeroAutoAtk = false;
	waitingInput = true;
end

--显示UI
function p.ShowUI()
	p.Reset();
		
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return true;
	end
	
	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddChild(layer);
	
    LoadUI("battle_mainui.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	p.InitBossHpBar();
	
	--添加蒙版图片
	p.AddMaskImage();
	
	--添加战斗开启光效
	local id = AddHudEffect( "lancer.enter_battle" );
	--local id = AddHudEffect( "lancer_cmb.enter_battle" );
	RegAniEffectCallBack( id, p.OnAniEffectCallBack );
	
    --注册战斗表现结束的回调
    RegCallBack_BattleShowFinished( p.OnBattleShowFinished );	
end

--隐藏
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--关闭
function p.CloseUI()
	if p.layer ~= nil then	
		p.layer:LazyClose();
		p.layer = nil;
	end
end

--设置事件处理
function p.SetDelegate(layer)
	--攻击按钮
	atkBtn = GetButton( layer, ui_battle_mainui.ID_CTRL_BUTTON_10 );
    atkBtn:SetLuaDelegate( p.OnBtnClicked_Atk );
	
	--托管按钮
	autoBtn = GetButton( layer, ui_battle_mainui.ID_CTRL_BUTTON_11 );
	autoBtn:SetLuaDelegate( p.OnBtnClicked_Auto );
end

--初始化boss血条
function p.InitBossHpBar()
	bossHpBarNode = GetExp( p.layer, ui_battle_mainui.ID_CTRL_EXP_13 );
	if bossHpBarNode == nil then return end;
	
	local boss = battle_mgr.GetBoss();
	boss:SetLife(1000);
	boss:SetLifeMax(1000);	
	
	local hpbar = boss:GetHpBar();
	if hpbar ~= nil and bossHpBarNode~= nil then
		hpbar:SetNode( bossHpBarNode );
		hpbar:InitForBoss( bossHpBarNode, boss:GetLife(), boss:GetLifeMax());
	end
end

--取boss血条
function p.GetBossHpBar()
	return p.bossHpBar;
end

--添加蒙版图片
function p.AddMaskImage()
	imageMask = createNDUIImage();
	imageMask:Init();
	imageMask:SetFrameRectFull();
	
	local pic = GetPictureByAni("lancer.mask", 0); 
	imageMask:SetPicture( pic );
	p.layer:AddChildZ( imageMask, 1 );
end

--Ani特效播放完毕
function p.OnAniEffectCallBack(id)
	local s = string.format( "OnAniEffectCallBack(): id = %d", id);
	WriteCon(s);
	
	--蒙版渐变，播放结束后删除蒙版
	if imageMask ~= nil then
		local id = imageMask:AddActionEffect( "lancer.fadeout" );	
		RegActionEffectCallBack( id, p.OnActionEffectCallBack );
	end
end

--Action特效播放完毕
function p.OnActionEffectCallBack(id)
	local s = string.format( "OnActionEffectCallBack(): id = %d", id);
	WriteCon(s);
	
	if imageMask ~= nil then
		imageMask:SetVisible(false);
	end
end

--攻击按钮点击事件
function p.OnBtnClicked_Atk(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then

		--屏蔽按钮
		atkBtn:SetEnabled( false );
		
		--对打
		if useSkill then
			battle_mgr.HeroAtkSkill();
			battle_mgr.BossAtkSkill();
		else
			battle_mgr.HeroAtk();
			battle_mgr.BossAtk();
		end
		
		useSkill = not useSkill;
		waitingInput = false;
	end
end

--自动按钮点击事件
function p.OnBtnClicked_Auto(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
		isHeroAutoAtk = not isHeroAutoAtk;
		
		if waitingInput then
			p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK, 0 );
		end
	end
end

--战斗表现结束的回调
function p.OnBattleShowFinished()
	WriteCon( "OnBattleShowFinished()" );
	
	waitingInput = true;
	--atkBtn:SetEnabled( true );
	atkBtn:SetEnabled( not isHeroAutoAtk );
	
    if not battle_mgr.IsBattleEnd() then
	    if isHeroAutoAtk then
		    p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK );
        end        
	end
end