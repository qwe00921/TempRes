--------------------------------------------------------------
-- FileName: 	x_battle_mainui.lua
-- author:		zhangwq, 2013/06/25
-- purpose:		对战主UI (demo v2.0)
--------------------------------------------------------------

x_battle_mainui = {}
local p = x_battle_mainui;

p.layer = nil;
p.imageMask = nil;
p.m_nBattleRound = 0;

local useSkill = false;  --当前回合是否用技能攻击
local isHeroAutoAtk = false; --是否托管（自动攻击）
local waitingInput = true;

local atkBtn = nil;
local autoBtn = nil;
--local bossHpBar = nil;
local idTimer_SortZOrder = 0; --定时更新ZOrder

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
	
    LoadUI("x_battle_mainui.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	--p.InitBossHpBar();
	
	--添加蒙版图片
--	p.AddMaskImage();
end

function p.StartBattleEffect()
		--添加战斗开启光效
	local id = AddHudEffect( "lancer.enter_battle" );
	--local id = AddHudEffect( "lancer_cmb.enter_battle" );
	RegAniEffectCallBack( id, p.OnAniEffectCallBack );
	
	--注册战斗表现结束的回调
	RegCallBack_BattleShowFinished( p.OnBattleShowFinished );
	--SetTimerOnce(p.OnBattleShowFinished,1.0f);
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
		p.ResetZOrder();
		p.layer:LazyClose();
		p.layer = nil;
	end
end

--设置事件处理
function p.SetDelegate(layer)
	--攻击按钮
	--atkBtn = GetButton( layer, ui_x_battle_mainui.ID_CTRL_BUTTON_17 );
   -- atkBtn:SetLuaDelegate( p.OnBtnClicked_Atk );
	
	--托管按钮
	autoBtn = GetButton( layer, ui_x_battle_mainui.ID_CTRL_BUTTON_11 );
	autoBtn:SetLuaDelegate( p.OnBtnClicked_Auto );
end

--[[
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

--]]

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
		--屏蔽按钮
		--atkBtn:SetEnabled( false );
	x_battle_mgr.HeroTurn();
	x_battle_mgr.EnemyTurn();
		
	waitingInput = false;
		
		--定时更新Z序 (every tick)
	if idTimer_SortZOrder == 0 then
		idTimer_SortZOrder = SetTimer( p.OnTimer_SortZOrder, 0.04f );
	end
end

--自动按钮点击事件
function p.OnBtnClicked_Auto(uiNode, uiEventType, param)
	isHeroAutoAtk = true;
	p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK, 0 );
end

--战斗表现结束的回调
function p.OnBattleShowFinished()
	WriteCon( "OnBattleShowFinished()" );
	
	if 1 < p.m_nBattleRound then
		battle_ko.ShowUI();
		--p.m_nBattleRound = 0;
		return;
	end
	
	isHeroAutoAtk = true;
		
	p.OnBtnClicked_Auto( nil, NUIEventType.TE_TOUCH_CLICK, 0 );
	
	p.m_nBattleRound = p.m_nBattleRound + 1;
	--SetTimer( p.CheckAutoAtk, 0.5f );
end	

--自动攻击
function p.CheckAutoAtk()
	--waitingInput = true;
	--atkBtn:SetEnabled( not isHeroAutoAtk );
	
	if x_battle_mgr.IsBattleEnd() or p.m_nBattleRound > 1 then
	    p.ResetZOrder();
    else
		if isHeroAutoAtk then
			p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK );
		else
		    p.ResetZOrder();
		end
	end
end

--定时更新Z序
function p.OnTimer_SortZOrder()
	--WriteCon( "x_battle_mainui: OnTimer_SortZOrder" );
	local layer = x_battle_mgr.GetBattleLayer();
	if layer ~= nil then
		layer:SortZOrder();
	end
end

--重置Z序
function p.ResetZOrder()
	--WriteCon( "x_battle_mainui: ResetZOrder" );
	local layer = x_battle_mgr.GetBattleLayer();
	if layer ~= nil then 
		layer:ResetZOrder();
	end
	
	if idTimer_SortZOrder > 0 then
		KillTimer( idTimer_SortZOrder );
		idTimer_SortZOrder = 0;	
	end
end