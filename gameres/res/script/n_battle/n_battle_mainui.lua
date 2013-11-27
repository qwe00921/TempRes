--------------------------------------------------------------
-- FileName: 	n_battle_mainui.lua
-- author:		zhangwq, 2013/06/25
-- purpose:		��ս��UI (demo v2.0)
--------------------------------------------------------------

n_battle_mainui = {}
local p = n_battle_mainui;

p.layer = nil;
p.imageMask = nil;
p.m_kPower = nil;
p.m_nPowerTimer = 0;
p.m_fPowerPercent = 100.0f;

local useSkill = false;  --��ǰ�غ��Ƿ��ü��ܹ���
local isHeroAutoAtk = true; --�Ƿ��йܣ��Զ�������
local waitingInput = true;

local atkBtn = nil;
local autoBtn = nil;
--local bossHpBar = nil;
local idTimer_SortZOrder = 0; --��ʱ����ZOrder

--����
function p.Reset()
	useSkill = false;
	isHeroAutoAtk = true;
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
	
    LoadUI("n_battle_mainui.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	--[[
	p.m_kPower = GetExp(p.layer,ui_n_battle_mainui.ID_CTRL_HOR3SLICES_POWER);

	if nil == p.m_kPower then
		WriteCon("Power process bar is nil");
		return false;
	end
	
	if false == p.InitialisePowerProcessBar() then
		WriteCon("InitialisePowerProcessBar failed");
		return false;
	end
	--]]
	--p.InitBossHpBar();
	
	--����ɰ�ͼƬ
--	p.AddMaskImage();

	return true;
end

function p.ShowRoundNum( roundNum )
	local roundNumNode = GetLabel( p.layer, ui_n_battle_mainui.ID_CTRL_TEXT_ROUNDNUM );
	roundNumNode:SetText( roundNum.."/"..N_BATTLE_MAX_ROUND );
end

function p.InitialisePowerProcessBar()
	if nil == p.m_kPower then
		return false;
	end
	
	local kFgImage = GetPictureByAni("lancer.power_process",0);
	local kBgImage = GetPictureByAni("lancer.power_process",1);
	
	if nil == kFgImage or nil == kBgImage then
		WriteCon("Can't find lancer.power_process images!");
		return false;
	end
	
	p.m_kPower:SetPicture(kBgImage,kFgImage);
	p.m_kPower:SetUse3Slices(true,false);
	p.m_kPower:SetTotal(100);
	p.m_kPower:SetProcess(1000.0f);
--	p.m_kPower:SetFramePosXY(200,200);
	p.m_kPower:SetReverseExp(true);
	
	return true;
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
	--atkBtn = GetButton( layer, ui_n_battle_mainui.ID_CTRL_BUTTON_17 );
   -- atkBtn:SetLuaDelegate( p.OnBtnClicked_Atk );
	
	--�йܰ�ť
	autoBtn = GetButton( layer, ui_n_battle_mainui.ID_CTRL_BUTTON_11 );
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
	n_battle_mgr.HeroTurn();
	n_battle_mgr.EnemyTurn();
		
	waitingInput = false;
		
		--��ʱ����Z�� (every tick)
	if idTimer_SortZOrder == 0 then
		idTimer_SortZOrder = SetTimer( p.OnTimer_SortZOrder, 0.04f );
	end
end

--�Զ���ť����¼�
function p.OnBtnClicked_Auto(uiNode, uiEventType, param)	
	if isHeroAutoAtk == true then
		p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK, 0 );
	end
end

function p.OnKoRound()
	n_battle_ko.ShowUI();
end

--ս�����ֽ����Ļص�
function p.OnBattleShowFinished()
	WriteCon( "OnBattleShowFinished()" );
	
	if N_BATTLE_MAX_ROUND < tonumber( n_battle_stage.GetRoundNum() ) then
        p.HideUI();
        local id = AddHudEffect( "lancer.enter_battle" );
        --local id = AddHudEffect( "lancer_cmb.enter_battle" );
        RegAniEffectCallBack( id, p.OnKoRound );
        isHeroAutoAtk = false;
        --p.m_nBattleRound = 0;
        return;
    end
    
    --ս���׶�->�������
    if n_battle_stage.IsBattle_Stage_Loading() then
        n_battle_stage.EnterBattle_Stage_Permanent_Buff();--ս���׶�->����BUFF����
        n_battle_mgr.EnterBattle_Stage_Permanent_Buff();--����BUFF����Ч��
    
	--ս���׶�->����BUFF����
	elseif n_battle_stage.IsBattle_Stage_Permanent_Buff() then
		n_battle_stage.EnterBattle_Stage_Round();--����غϽ׶�
		n_battle_stage.EnterBattle_RoundStage_Pet();--����غϽ׶�->�ٻ��ޱ��� 
		n_battle_mgr.EnterBattle_RoundStage_Pet();--�ٻ��ޱ���Ч��
		
	--ս���׶�->�غ�
    elseif n_battle_stage.IsBattle_Stage_Round() then
    	
    	--�ٻ��ޱ������
    	if n_battle_stage.IsBattle_RoundStage_Pet() then
    		n_battle_stage.EnterBattle_RoundStage_Buff();--�غϽ׶�->BUFF����
    		n_battle_mgr.EnterBattle_RoundStage_Buff();--BUFF����Ч��
    	
    	--BUFF�������	
    	elseif n_battle_stage.IsBattle_RoundStage_Buff() then	
    	   n_battle_stage.EnterBattle_RoundStage_Atk();--�غϽ׶�->��Ź
           n_battle_mgr.EnterBattle_RoundStage_Atk();--��Ź����Ч��
        
        --��Ź�������  
        elseif n_battle_stage.IsBattle_RoundStage_Atk() then   
           n_battle_stage.EnterBattle_RoundStage_Clearing();--�غϽ׶�->����
           n_battle_mgr.EnterBattle_RoundStage_Clearing();--��Ź����Ч��
        
        --�������  
        elseif n_battle_stage.IsBattle_RoundStage_Clearing() then   
           n_battle_stage.EnterBattle_RoundStage_Pet();--����غϽ׶�->�ٻ��ޱ��� 
           n_battle_mgr.EnterBattle_RoundStage_Pet();--�ٻ��ޱ���Ч��
                 
    	end
	end
	
	--[[
	if isHeroAutoAtk == true then
		p.OnBtnClicked_Auto( nil, NUIEventType.TE_TOUCH_CLICK, 0 );
		p.m_nBattleRound = p.m_nBattleRound + 1;
		
		if 0 == p.m_nPowerTimer then
			p.m_nPowerTimer = SetTimer(p.OnPowerProcessBarTimer,0.1f);
		end
	else
		if idTimer_SortZOrder ~= 0 then
			KillTimer(idTimer_SortZOrder);
			idTimer_SortZOrder = 0;
		end
		
		if p.m_nPowerTimer ~= 0 then
			KillTimer(p.m_nPowerTimer);
			p.m_nPowerTimer = 0;
		end
	end
	--]]
	--SetTimer( p.CheckAutoAtk, 0.5f );
end

function p.OnPowerProcessBarTimer()
	p.m_fPowerPercent = p.m_fPowerPercent - 1.5f;
	p.m_kPower:SetProcess(p.m_fPowerPercent);
end

--�Զ�����
function p.CheckAutoAtk()
	--waitingInput = true;
	--atkBtn:SetEnabled( not isHeroAutoAtk );
	
	if n_battle_mgr.IsBattleEnd() or p.m_nBattleRound > 1 then
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
	--WriteCon( "n_battle_mainui: OnTimer_SortZOrder" );
	local layer = n_battle_mgr.GetBattleLayer();
	if layer ~= nil then
		layer:SortZOrder();
	end
end

--����Z��
function p.ResetZOrder()
	--WriteCon( "n_battle_mainui: ResetZOrder" );
	local layer = n_battle_mgr.GetBattleLayer();
	if layer ~= nil then 
		layer:ResetZOrder();
	end
	
	if idTimer_SortZOrder > 0 then
		KillTimer( idTimer_SortZOrder );
		idTimer_SortZOrder = 0;	
	end
end