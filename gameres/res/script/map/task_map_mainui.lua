--------------------------------------------------------------
-- FileName: 	task_map_mainui.lua
-- author:		zjj, 2013/07/22
-- purpose:		���˵�����Ĺ���
--------------------------------------------------------------

task_map_mainui = {}
local p = task_map_mainui
local ui = ui_task_map_mainui;

p.RollButton = nil;	--�����ӵİ�ť�ؼ�
p.RollButtonBGPic = nil; --�����ӵİ�ť�ı���ͼƬ�ؼ�

p.mission_point_restore_time_lbl = nil;	--�ж����ָ�ʱ��ı�ǩ�ؼ�
p.mission_point_full_time = nil; --�ж�����ȫ�ָ���Ҫ��ʱ��

p.idTimerRefresh = nil; --��ʱid
p.layer = nil;

--��ʾUI
function p.ShowUI()
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		PlayMusic_Task();
		return;
	end
	
	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
    
	GetUIRoot():AddChild(layer);
    LoadUI("task_map_mainui.xui", layer, nil);
	
	p.Init();
	p.SetDelegate(layer);
	p.layer = layer;
	
	p.RollButton = GetButton(layer, ui.ID_CTRL_BUTTON_20);
	p.RollButton:SetEnabled( false );
	p.RollButtonBGPic = GetImage(layer, ui.ID_CTRL_PICTURE_ROLL_BTN_BG);
	p.SendHttpRequest();
	PlayMusic_Task();
end

function p.Init()	
end

--�����¼�����
function p.SetDelegate(layer)

	local pQuestButton = GetButton(layer, ui.ID_CTRL_BUTTON_3);
    pQuestButton:SetLuaDelegate(p.OnBtnClick);
	pQuestButton:SetVisible(false);
	
	local pBattleButton = GetButton(layer, ui.ID_CTRL_BUTTON_4);
    pBattleButton:SetLuaDelegate(p.OnBtnClick);
	pBattleButton:SetVisible(false);
	
	local pCardButton = GetButton(layer, ui.ID_CTRL_BUTTON_5);
    pCardButton:SetLuaDelegate(p.OnBtnClick);
	pCardButton:SetVisible(false);
	
	local pGachaButton = GetButton(layer, ui.ID_CTRL_BUTTON_6);
    pGachaButton:SetLuaDelegate(p.OnBtnClick);
	pGachaButton:SetVisible(false);
	
	local pGuideButton = GetButton(layer, ui.ID_CTRL_BUTTON_7);
    pGuideButton:SetLuaDelegate(p.OnBtnClick);
	pGuideButton:SetVisible(false);
	
	local pItemButton = GetButton(layer, ui.ID_CTRL_BUTTON_8);
    pItemButton:SetLuaDelegate(p.OnBtnClick);
	pItemButton:SetVisible(false);
	
	local pElseButton = GetButton(layer, ui.ID_CTRL_BUTTON_9);
    pElseButton:SetLuaDelegate(p.OnBtnClick);
	pElseButton:SetVisible(false);

	--Roll�㰴ť
	local pRollButton = GetButton(layer, ui.ID_CTRL_BUTTON_20);
    pRollButton:SetLuaDelegate(p.OnBtnClickRoll);
	
	local pIntensifyButton = GetButton(layer, ui.ID_CTRL_BUTTON_71);
    pIntensifyButton:SetLuaDelegate(p.OnBtnClick);
	pIntensifyButton:SetVisible(false);
	
	local pEvolutionButton = GetButton(layer, ui.ID_CTRL_BUTTON_67);
    pEvolutionButton:SetLuaDelegate(p.OnBtnClick);
	pEvolutionButton:SetVisible(false);
	
	local pTeamButton = GetButton(layer, ui.ID_CTRL_BUTTON_68);
    pTeamButton:SetLuaDelegate(p.OnBtnClick);
	pTeamButton:SetVisible(false);
	
	local pComboButton = GetButton(layer, ui.ID_CTRL_BUTTON_69);
    pComboButton:SetLuaDelegate(p.OnBtnClick);
	pComboButton:SetVisible(false);
	
	local pCardFuseButton = GetButton(layer, ui.ID_CTRL_BUTTON_70);
    pCardFuseButton:SetLuaDelegate(p.OnBtnClick);
	pCardFuseButton:SetVisible(false);
	
	local Btn1 = GetButton(layer, ui.ID_CTRL_BUTTON_29);
    Btn1:SetLuaDelegate(p.OnBtnClick);
	Btn1:SetVisible(false);
	
	local cardSkillBtn = GetButton(layer, ui.ID_CTRL_BUTTON_28);
    cardSkillBtn:SetLuaDelegate(p.OnBtnClick);
	cardSkillBtn:SetVisible(false);
	
	local Btn3 = GetButton(layer, ui.ID_CTRL_BUTTON_FRIEND);
    Btn3:SetLuaDelegate(p.OnBtnClick);
	Btn3:SetVisible(false);
    
    local watchPlayerInfoBtn = GetButton(layer, ui.ID_CTRL_BUTTON_PLAYER_INFO);
    watchPlayerInfoBtn:SetLuaDelegate(p.OnBtnClick);
	watchPlayerInfoBtn:SetVisible(false);
    
    local shopBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SHOP);
    shopBtn:SetLuaDelegate(p.OnBtnClick);
	shopBtn:SetVisible(false);
    
    local Btn6 = GetButton(layer, ui.ID_CTRL_BUTTON_34);
    Btn6:SetLuaDelegate(p.OnBtnClick);
	Btn6:SetVisible(false);
    
    local Btn7 = GetButton(layer, ui.ID_CTRL_BUTTON_36);
    Btn7:SetLuaDelegate(p.OnBtnClick);
	Btn7:SetVisible(false);
    
    local Btn8 = GetButton(layer, ui.ID_CTRL_BUTTON_37);
    Btn8:SetLuaDelegate(p.OnBtnClick);
	Btn8:SetVisible(false);
    
    local Btn9 = GetButton(layer, ui.ID_CTRL_BUTTON_38);
    Btn9:SetLuaDelegate(p.OnBtnClick);
	Btn9:SetVisible(false);
    
    local Btn10 = GetButton(layer, ui.ID_CTRL_BUTTON_35);
    Btn10:SetLuaDelegate(p.OnBtnClick);
	Btn10:SetVisible(false);
    
	--���ذ�ť
    local exitBtn = GetButton(layer ,ui.ID_CTRL_BUTTON_BACK);
    exitBtn:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode, uiEventType, param)
	--p.layer:RemoveFromParent(true);

	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
	    	
        if ( ui.ID_CTRL_BUTTON_3 == tag ) then	
			WriteCon("����ð��");
		elseif ( ui.ID_CTRL_BUTTON_4 == tag ) then
			WriteCon("����ս��");

		elseif ( ui.ID_CTRL_BUTTON_5 == tag ) then
			WriteCon("���뿨��");
			dlg_card_box_mainui.ShowUI( CARD_INTENT_PREVIEW );
			
		elseif ( ui.ID_CTRL_BUTTON_6 == tag ) then
			WriteCon("����Ť��");
			dlg_gacha.ShowUI( SHOP_GACHA );
		elseif ( ui.ID_CTRL_BUTTON_7 == tag ) then
			WriteCon("���빫��");
			
		elseif ( ui.ID_CTRL_BUTTON_8 == tag ) then
			WriteCon("�������");
			dlg_back_pack.ShowUI();	
			
		elseif ( ui.ID_CTRL_BUTTON_9== tag ) then
			WriteCon("�����˵�");	

		elseif ( ui.ID_CTRL_BUTTON_71== tag ) then
			WriteCon("ǿ������");	
			dlg_card_box_mainui.ShowUI( CARD_INTENT_INTENSIFY );
			
		elseif ( ui.ID_CTRL_BUTTON_67== tag ) then
			WriteCon("��������");	
			dlg_card_box_mainui.ShowUI( CARD_INTENT_EVOLUTION );

		elseif ( ui.ID_CTRL_BUTTON_68== tag ) then
			WriteCon("�������");	
			dlg_team_list.ShowUI();
		
		elseif ( ui.ID_CTRL_BUTTON_69== tag ) then
			WriteCon("������Ƭ�ϳɽ���");	
			dlg_skill_piece_combo.ShowUI();
		
		elseif ( ui.ID_CTRL_BUTTON_70== tag ) then
			WriteCon("�����ںϽ���");	
			dlg_card_fuse.ShowUI();
		
		elseif ( ui.ID_CTRL_BUTTON_29== tag ) then
		    WriteCon("���Ʋֿ�");   
            dlg_card_depot.ShowUI();
		
		elseif ( ui.ID_CTRL_BUTTON_28== tag ) then
			WriteCon("���ܿ���");	
			dlg_user_skill.ShowUI(SKILL_INTENT_PREVIEW);
		
		elseif ( ui.ID_CTRL_BUTTON_FRIEND== tag ) then
			WriteCon("���ѽ���");
		    dlg_friend.ShowUI();
		    
		elseif ( ui.ID_CTRL_BUTTON_PLAYER_INFO == tag ) then
            WriteCon("�����Ϣ");
            dlg_watch_player.ShowUI( SELF_INFO );
            
        elseif ( ui.ID_CTRL_BUTTON_SHOP== tag ) then
             WriteCon("�����̵�");
             dlg_gacha.ShowUI(SHOP_ITEM);
            
        elseif ( ui.ID_CTRL_BUTTON_34== tag ) then
             WriteCon("����4");
             dlg_card_group.ShowUI();
             
        elseif ( ui.ID_CTRL_BUTTON_36== tag ) then
             WriteCon("����5");
        
        elseif ( ui.ID_CTRL_BUTTON_37== tag ) then
             WriteCon("����6");
        
        elseif ( ui.ID_CTRL_BUTTON_38== tag ) then
             WriteCon("����7");
             
		elseif ( ui.ID_CTRL_BUTTON_35== tag ) then
             WriteCon("����8");	
             
        elseif ( ui.ID_CTRL_BUTTON_BACK== tag ) then
             WriteCon("�뿪");        
             p.AskToLeave();
		end				
	end
end

--ѯ���Ƿ��뿪
function p.AskToLeave()   
	dlg_msgbox.ShowYesNo( 
		ToUtf8( "ѯ��" ), ToUtf8( "�Ƿ��뿪��ǰ��ͼ�����������ͼ��" ), 
		p.OnMsgBoxCallback, p.layer );
end
				
--��ʾ��ص�����
function p.OnMsgBoxCallback( result )
	if result then
		game_main.EnterWorldMap();
	end
end

--���ҡ���Ӱ�ť
function p.OnBtnClickRoll(uiNode, uiEventType, param)	
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
	
		--��ť�ҵ�
		p.RollButton:SetEnabled(false);
		if( p.RollState == p.STATE_READY )then
			
			--�ı�ΪRolling״̬
			task_map_roll_state.SetRollState_Rolling();
					
			--������������Ч
			local ani = string.format("%s%d","combo.playdice", task_map_roll_state.GetRollNumber());
			local fxid = AddHudEffect( ani );
			if RegAniEffectCallBack( fxid, p.OnRollComplete ) then
				PlayEffectSoundByName( "sk_dice.mp3" );--��Ч
			end
		end
	end
end

--�������е�ͼʱ�����������������
function p.SendHttpRequest()
	local uid = GetUID();
	if uid == 0 then uid = 100 end; --�ͷ����Լ��һ��id����ʱ��
	SendReq("User","GetUserInfo",uid,"");
	
	--����Ϊ��ֹ״̬
	task_map_roll_state.SetRollState_Disabled();
end

--�����ӱ������
function p.OnRollComplete()

	--����Ϊ�ȴ����Ѱ·״̬
	task_map_roll_state.SetRollState_ClickPath();
	
	--��ʾ·�������ѡ��
	FindTilePath( task_map_roll_state.GetRollNumber());
	
	--�����εĵ���
	task_map_roll_state.ClearRollNumber();
end

--[[
--�������ö�ʱ����ʾ�ж����ָ�ʱ��
function p.RefreshMissionPointTimer()
    if p.idTimerRefresh ~= nil then
        KillTimer( p.idTimerRefresh );
        p.idTimerRefresh = nil;
    end
    p.idTimerRefresh = SetTimer( p.onTimer_UpdateMissionPointTime, 1.0f );   
end

--�����ж����ָ�ʱ��
function p.onTimer_UpdateMissionPointTime()
    local timetext = nil;
    if p.mission_point_full_time <= 0 then
         timetext = GetStr( "play_actiont_max" );
         p.mission_point_restore_time_lbl:SetText(timetext);
         KillTimer( p.idTimerRefresh );
         p.idTimerRefresh = nil;
    else
		timetext = GetStr( "play_actiontomax" ) .. os.date("%H:%M:%S ",p.mission_point_full_time);
		p.mission_point_restore_time_lbl:SetText(timetext);
		p.mission_point_full_time = p.mission_point_full_time - 1;
	end
end
--]]

--��������Ϣ�ص�ˢ�½���
function p.RefreshUI(msg_player)
    if p.layer == nil then
    	return ;
    end
	if p.layer:IsVisible() then

		--��������
--		local pNameLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_2);
--		pNameLbl:SetText(tostring(msg_player.user_name));
		
		--�ȼ�
		local pLvLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_10);
		pLvLbl:SetText(tostring(msg_player.level));
		
		--����
		local pExpLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_11);
		pExpLbl:SetText(tostring(msg_player.exp));
		
		--ս����
--		local pArenaPointLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_14);
--		pArenaPointLbl:SetText( GetStr("play_arenaPoint")..string.format(": %d / %d ", msg_player.arena_point, msg_player.arena_point_max ));
		
		--��Ƭ��
		local pCardNumberLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_15);
		pCardNumberLbl:SetText( string.format("%d/%d ", msg_player.card_num, msg_player.card_max_num));
		
		--���
		local pMoneyLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_16);
		pMoneyLbl:SetText(tostring(msg_player.gold ));
		
		--�ж���
		local pArenaPointLbl = GetLabel( p.layer, ui.ID_CTRL_TEXT_ACTION_POINT);
		pArenaPointLbl:SetText( string.format("%d/%d ", msg_player.mission_point, msg_player.mission_point_max ));
		
		local pActionPointExp = GetExp( p.layer, ui.ID_CTRL_EXP_ACTION_POINT);
		pActionPointExp:SetVertical();
        pActionPointExp:SetValue( 0, tonumber( msg_player.mission_point_max ), tonumber( msg_player.mission_point ) );
		

		--��Ҫ�ж���ֵ
		local pNeedMissionPointLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_NEED_MISSION_POINT );
		pNeedMissionPointLab:SetText( tostring( task_map.needMissionPoint));
		
		--�ж����ָ�ʱ��
--		p.mission_point_restore_time_lbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_18);
--		p.mission_point_restore_time_lbl:SetText( GetStr("play_actiontomax").." "..os.date("%H:%M",msg_player.mission_point_full_time));
--		p.mission_point_full_time = msg_player.mission_point_full_time;
--		p.RefreshMissionPointTimer();
		
		--������
		local pMissionNameLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_12);
		pMissionNameLbl:SetText(tostring(msg_player.stage_name));
		
		--������
		local pMissionNumLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_13);
		if (msg_player.travel_num ~= nil) and (msg_player.travel_max ~= nil) then
		    local travel_num = tonumber(msg_player.travel_num);
		    local travel_max = tonumber(msg_player.travel_max);
		    if travel_num ~= nil and travel_max ~= nil then
                local text = string.format( "%d/%d", travel_num, travel_max );
		        pMissionNumLbl:SetText( text );
            end
        end
		
		--����ͷ��
--		local pIconImg = GetImage(p.layer,ui.ID_CTRL_PICTURE_1);
		
	end
end

--ˢ��������
function p.RefreshTravelNum( travelNum )
    if p.layer == nil then
        return ;
    end
	local pMissionNumLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_13);
	local text = string.format("%d/%d", travelNum, tonumber(msg_cache.msg_player.travel_max));
	pMissionNumLbl:SetText( text );
end

--ˢ�½��
function p.RefreshMoney( money )
    if p.layer == nil then
    	return ;
    end
    local pMoneyLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_16);
    pMoneyLbl:SetText(tostring( money ));
end

--ˢ�¾���ֵ
function p.RefreshExp( exp )
    if p.layer == nil then
        return ;
    end
    local pExpLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_11);
    pExpLbl:SetText(tostring(exp));
end

--ˢ�µȼ�
function p.RefreshLevel( level )
    if p.layer == nil then
        return ;
    end
    local pLvLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_10);
	pLvLbl:SetText(tostring(level));
end

--ˢ���ж���
function p.RefreshActionPoint( point )
    if p.layer == nil then
        return ;
    end
	
	--�ı�
    local pArenaPointLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_ACTION_POINT);
    pArenaPointLbl:SetText( string.format("%d/%d ", point, msg_cache.msg_player.mission_point_max ));
    
	--ԭ��
    local pActionPointExp = GetExp( p.layer, ui.ID_CTRL_EXP_ACTION_POINT);
    pActionPointExp:SetVertical();
    pActionPointExp:SetValue( 0, tonumber( msg_cache.msg_player.mission_point_max ), tonumber( point ) );

	--�����ж���action��Ч��ʾ	
	p.SetActionPointHint();
end

--�����ж���action��Ч��ʾ
function p.SetActionPointHint()
	local widget = p.RollButtonBGPic;
	
	--������������action��Ч��ʾ
	local actFx = "ui_cmb.action_point_lack";
	local hasFx = widget:FindActionEffect(actFx);
	if not task_map.IsActionPointOK() then
		--add fx
		if not hasFx then
			widget:AddActionEffect( actFx );
		end
	else
		--del fx
		if hasFx then
			widget:DelActionEffect( actFx );
		end
	end
end

--ˢ���ж�����ȫ�ָ�ʱ��
--function p.RefreshPointFullTime( time )
--    local missionPointUpTimeLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_18);
--    missionPointUpTimeLbl:SetText( GetStr("play_actiontomax").." "..os.date("%H:%M",time) );
--end

--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

--���������Ӱ�ť״̬
function p.SetRollBtnState( isEnabled )
	if p.layer ~= nil then
		p.RollButton:SetEnabled( isEnabled );
	end
end