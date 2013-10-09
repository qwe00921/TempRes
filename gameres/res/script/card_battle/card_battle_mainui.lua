--------------------------------------------------------------
-- FileName: 	card_battle_mainui.lua
-- author:		zhangwq, 2013/08/14
-- purpose:		���ƶ�ս��������
--------------------------------------------------------------

card_battle_mainui = {}
local p = card_battle_mainui;

p.layer = nil;
p.imageMask = nil;
p.turnNumNode = nil;
p.heroRage = nil;
p.enemyRage = nil;
p.heroSkillBtn = nil;
p.enemySkillBtn = nil;

local useSkill = false;  --��ǰ�غ��Ƿ��ü��ܹ���
local isHeroAutoAtk = false; --�Ƿ��йܣ��Զ�������
local waitingInput = true;

local atkBtn = nil;
local autoBtn = nil;
--local bossHpBar = nil;


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
	
    LoadUI("card_battle_mainui.xui", layer, nil);
	
	p.layer = layer;
	
	--��ʼ���ؼ�
	p.initWidget();
    
	p.SetDelegate(layer);
	p.SetTouchEnabled(false);
	--p.InitBossHpBar();
	
	if false then
	    --����ɰ�ͼƬ
	    p.AddMaskImage();
    	
	    --���ս��������Ч
	    local id = AddHudEffect( "lancer.enter_battle" );
	    RegAniEffectCallBack( id, p.OnAniEffectCallBack );
	end
	
	--ע��ս�����ֽ����Ļص�
	RegCallBack_BattleShowFinished( p.OnBattleShowFinished );
end

--��ʼ���ؼ�
function p.initWidget()
	p.turnNumNode = GetImage( p.layer,ui_card_battle_mainui.ID_CTRL_PICTURE_TURN_NUM );
	p.heroRage = GetExp( p.layer, ui_card_battle_mainui.ID_CTRL_EXP_HERO_RAGE);
    p.enemyRage = GetExp( p.layer, ui_card_battle_mainui.ID_CTRL_EXP_ENEMY_RAGE);
    p.heroRage:SetVertical();
    p.heroRage:SetNoText();
    p.enemyRage:SetVertical();
    p.enemyRage:SetNoText();
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
		card_battle_zorder.ResetZOrder();
		p.layer:LazyClose();
		p.layer = nil;
	end
end

--�����¼�����
function p.SetDelegate(layer)
	--������ť
	atkBtn = GetButton( layer, ui_card_battle_mainui.ID_CTRL_BUTTON_10 );
    atkBtn:SetLuaDelegate( p.OnBtnClicked_Atk );
	
	--�йܰ�ť
	autoBtn = GetButton( layer, ui_card_battle_mainui.ID_CTRL_BUTTON_11 );
	autoBtn:SetLuaDelegate( p.OnBtnClicked_Auto );
	
	p.heroSkillBtn = GetButton( layer, ui_card_battle_mainui.ID_CTRL_BUTTON_HERO_SKILL );
    p.enemySkillBtn = GetButton( layer, ui_card_battle_mainui.ID_CTRL_BUTTON_ENEMY_SKILL );
    
    p.heroSkillBtn:SetLuaDelegate( card_battle_mgr.HeroTeamSkill );
    p.enemySkillBtn:SetLuaDelegate( card_battle_mgr.EnemyTeamSkill );
    
    p.enemySkillBtn:SetEnabled( false );
    
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
	if IsClickEvent( uiEventType ) then
        
        --�����ӻغϽ׶�->ATK
        card_battle_stage.EnterBattle_SubTurnStage_Atk();
        
        --����Atk����
        card_battle_mgr.EnterBattle_SubTurnStage_Atk();
        
        --ֹͣ�û�����
        p.SetTouchEnabled( false );
        
        --[[
		--���ΰ�ť
		atkBtn:SetEnabled( false );
		
		card_battle_mgr.HeroTurn();
		card_battle_mgr.EnemyTurn();
		--]]
		waitingInput = false;
		
		--����Z����
		card_battle_zorder.SortZOrder();
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
    --ս���׶�->����
    if card_battle_stage.IsBattle_Stage_Hand() then
    
    	--����->��ս�غϽ׶�
    	card_battle_stage.EnterBattle_Stage_Turn();
    	
    	--�غϽ׶ο�ʼ�������ϰ볡->Ӣ�ۻغ�
    	card_battle_stage.EnterBattle_TurnStage_Hero();
    	
    	--�����ӻغϽ׶�->DOT
    	card_battle_stage.EnterBattle_SubTurnStage_Dot();
    	
    	--����DOT����->Ӣ�۷�
    	card_battle_mgr.EnterBattle_SubTurnStage_Dot();
    
    --ս���׶�->�غ�
    elseif card_battle_stage.IsBattle_Stage_Turn() then
        --dot�׶ν���->Ӣ�۷�
        if card_battle_stage.IsBattleTurnHeroDot() then
        
        	--�����ӻغϽ׶�->SKILL
        	card_battle_stage.EnterBattle_SubTurnStage_Skill();
        	
        	--������Ӧ�û�����
        	p.SetTouchEnabled( true )
        
        --dot�׶ν���->�з�
        elseif card_battle_stage.IsBattleTurnEnemyDot() then
        
            --�����ӻغϽ׶�->SKILL
            card_battle_stage.EnterBattle_SubTurnStage_Skill();
            
            --����SKILL����->�з��Զ�����
            card_battle_mgr.EnemyTriggerSkills();
            
        --SKILL�׶ν���->�з�
        elseif card_battle_stage.IsBattleTurnEnemySkill() then
            
            --�����ӻغϽ׶�->atk�з�  
            card_battle_stage.EnterBattle_SubTurnStage_Atk();
            
            --����ATK����->�з��Զ�����
            card_battle_mgr.EnterBattle_SubTurnStage_Atk();
        
        --stk�׶ν���->Ӣ�۷�
        elseif card_battle_stage.IsBattleTurnHeroAtk() then
            --�����°볡->�з��غ�
            card_battle_stage.EnterBattle_TurnStage_Enemy();
            
            --�����ӻغϽ׶�->DOT�з�
            card_battle_stage.EnterBattle_SubTurnStage_Dot();
            
            --����DOT����->�з�
            card_battle_mgr.EnterBattle_SubTurnStage_Dot();
        
        --stk�׶ν���->�з�    
        elseif card_battle_stage.IsBattleTurnEnemyAtk() then
            --�غϽ���
            card_battle_stage.EnterBattle_TurnStage_End();
            
            --����غϴ���
            card_battle_mgr.EnterBattle_TurnStage_End();
        end
        --card_battle_mgr.TurnStageBegin();
        --WriteCon( "OnBattleShowFinished()" );
        --SetTimerOnce( p.CheckAutoAtk, 0.1f );	
    end
end	

--�Զ�����
function p.CheckAutoAtk()
	waitingInput = true;
	atkBtn:SetEnabled( not isHeroAutoAtk );
	
	if card_battle_mgr.IsBattleEnd() then
	    card_battle_zorder.ResetZOrder();
	else
		if isHeroAutoAtk then
			p.OnBtnClicked_Atk( nil, NUIEventType.TE_TOUCH_CLICK );
        else
            card_battle_zorder.ResetZOrder();			
		end
	end
end

--�Ƿ�����û�����
function p.SetTouchEnabled( flag )
    --������ť
	local atkBtn = GetButton( p.layer, ui_battle_mainui.ID_CTRL_BUTTON_10 );
	
    --�йܰ�ť
    local autoBtn = GetButton( p.layer, ui_battle_mainui.ID_CTRL_BUTTON_11 );
    atkBtn:SetEnabled( flag );
    autoBtn:SetEnabled( flag );
end