--------------------------------------------------------------
-- FileName: 	battle_mainui.lua
-- author:		hst, 2013/05/31
-- purpose:		��ս��UI
--------------------------------------------------------------

battle_mainui = {}
local p = battle_mainui;

p.layer = nil;
p.imageMask = nil;

local useSkill = false;  --��ǰ�غ��Ƿ��ü��ܹ���
local isHeroAutoAtk = false; --�Ƿ��йܣ��Զ�������
local waitingInput = true;

local atkBtn = nil;
local autoBtn = nil;
local bossHpBar = nil;

--����
function p.Reset()
	useSkill = false;
	isHeroAutoAtk = false;
	waitingInput = true;
end

--��ʾUI
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
	
	--�����ɰ�ͼƬ
	p.AddMaskImage();
	
	--����ս��������Ч
	local id = AddHudEffect( "lancer.enter_battle" );
	--local id = AddHudEffect( "lancer_cmb.enter_battle" );
	RegAniEffectCallBack( id, p.OnAniEffectCallBack );
	
    --ע��ս�����ֽ����Ļص�
    RegCallBack_BattleShowFinished( p.OnBattleShowFinished );	
end

--����
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--�ر�
function p.CloseUI()
	if p.layer ~= nil then	
		p.layer:LazyClose();
		p.layer = nil;
	end
end

--�����¼�����
function p.SetDelegate(layer)
	--������ť
	atkBtn = GetButton( layer, ui_battle_mainui.ID_CTRL_BUTTON_10 );
    atkBtn:SetLuaDelegate( p.OnBtnClicked_Atk );
	
	--�йܰ�ť
	autoBtn = GetButton( layer, ui_battle_mainui.ID_CTRL_BUTTON_11 );
	autoBtn:SetLuaDelegate( p.OnBtnClicked_Auto );
end

--��ʼ��bossѪ��
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

--ȡbossѪ��
function p.GetBossHpBar()
	return p.bossHpBar;
end

--�����ɰ�ͼƬ
function p.AddMaskImage()
	imageMask = createNDUIImage();
	imageMask:Init();
	imageMask:SetFrameRectFull();
	
	local pic = GetPictureByAni("lancer.mask", 0); 
	imageMask:SetPicture( pic );
	p.layer:AddChildZ( imageMask, 1 );
end

--Ani��Ч�������
function p.OnAniEffectCallBack(id)
	local s = string.format( "OnAniEffectCallBack(): id = %d", id);
	WriteCon(s);
	
	--�ɰ潥�䣬���Ž�����ɾ���ɰ�
	if imageMask ~= nil then
		local id = imageMask:AddActionEffect( "lancer.fadeout" );	
		RegActionEffectCallBack( id, p.OnActionEffectCallBack );
	end
end

--Action��Ч�������
function p.OnActionEffectCallBack(id)
	local s = string.format( "OnActionEffectCallBack(): id = %d", id);
	WriteCon(s);
	
	if imageMask ~= nil then
		imageMask:SetVisible(false);
	end
end

--������ť����¼�
function p.OnBtnClicked_Atk(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then

		--���ΰ�ť
		atkBtn:SetEnabled( false );
		
		--�Դ�
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

--�Զ���ť����¼�
function p.OnBtnClicked_Auto(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
		isHeroAutoAtk = not isHeroAutoAtk;
		
		if waitingInput then
			p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK, 0 );
		end
	end
end

--ս�����ֽ����Ļص�
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