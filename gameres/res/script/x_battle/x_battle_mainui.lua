--------------------------------------------------------------
-- FileName: 	x_battle_mainui.lua
-- author:		zhangwq, 2013/06/25
-- purpose:		��ս��UI (demo v2.0)
--------------------------------------------------------------

x_battle_mainui = {}
local p = x_battle_mainui;

p.layer = nil;
p.imageMask = nil;
p.m_nBattleRound = 0;

local useSkill = false;  --��ǰ�غ��Ƿ��ü��ܹ���
local isHeroAutoAtk = false; --�Ƿ��йܣ��Զ�������
local waitingInput = true;

local atkBtn = nil;
local autoBtn = nil;
--local bossHpBar = nil;
local idTimer_SortZOrder = 0; --��ʱ����ZOrder

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
	
    LoadUI("x_battle_mainui.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	--p.InitBossHpBar();
	
	--����ɰ�ͼƬ
--	p.AddMaskImage();
end

function p.StartBattleEffect()
		--���ս��������Ч
	local id = AddHudEffect( "lancer.enter_battle" );
	--local id = AddHudEffect( "lancer_cmb.enter_battle" );
	RegAniEffectCallBack( id, p.OnAniEffectCallBack );
	
	--ע��ս�����ֽ����Ļص�
	RegCallBack_BattleShowFinished( p.OnBattleShowFinished );
	--SetTimerOnce(p.OnBattleShowFinished,1.0f);
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
		p.ResetZOrder();
		p.layer:LazyClose();
		p.layer = nil;
	end
end

--�����¼�����
function p.SetDelegate(layer)
	--������ť
	--atkBtn = GetButton( layer, ui_x_battle_mainui.ID_CTRL_BUTTON_17 );
   -- atkBtn:SetLuaDelegate( p.OnBtnClicked_Atk );
	
	--�йܰ�ť
	autoBtn = GetButton( layer, ui_x_battle_mainui.ID_CTRL_BUTTON_11 );
	autoBtn:SetLuaDelegate( p.OnBtnClicked_Auto );
end

--[[
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

--]]

--����ɰ�ͼƬ
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
		--���ΰ�ť
		--atkBtn:SetEnabled( false );
	x_battle_mgr.HeroTurn();
	x_battle_mgr.EnemyTurn();
		
	waitingInput = false;
		
		--��ʱ����Z�� (every tick)
	if idTimer_SortZOrder == 0 then
		idTimer_SortZOrder = SetTimer( p.OnTimer_SortZOrder, 0.04f );
	end
end

--�Զ���ť����¼�
function p.OnBtnClicked_Auto(uiNode, uiEventType, param)
	isHeroAutoAtk = true;
	p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK, 0 );
end

--ս�����ֽ����Ļص�
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

--�Զ�����
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

--��ʱ����Z��
function p.OnTimer_SortZOrder()
	--WriteCon( "x_battle_mainui: OnTimer_SortZOrder" );
	local layer = x_battle_mgr.GetBattleLayer();
	if layer ~= nil then
		layer:SortZOrder();
	end
end

--����Z��
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