--------------------------------------------------------------
-- FileName: 	task_map_mainui.lua
-- author:		zjj, 2013/07/22
-- purpose:		主菜单界面的功能
--------------------------------------------------------------

task_map_mainui = {}
local p = task_map_mainui
local ui = ui_task_map_mainui;

p.RollButton = nil;	--扔骰子的按钮控件
p.RollButtonBGPic = nil; --扔骰子的按钮的背景图片控件

p.mission_point_restore_time_lbl = nil;	--行动力恢复时间的标签控件
p.mission_point_full_time = nil; --行动力完全恢复需要的时间

p.idTimerRefresh = nil; --定时id
p.layer = nil;

--显示UI
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

--设置事件处理
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

	--Roll点按钮
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
    
	--返回按钮
    local exitBtn = GetButton(layer ,ui.ID_CTRL_BUTTON_BACK);
    exitBtn:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode, uiEventType, param)
	--p.layer:RemoveFromParent(true);

	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
	    	
        if ( ui.ID_CTRL_BUTTON_3 == tag ) then	
			WriteCon("进入冒险");
		elseif ( ui.ID_CTRL_BUTTON_4 == tag ) then
			WriteCon("进入战斗");

		elseif ( ui.ID_CTRL_BUTTON_5 == tag ) then
			WriteCon("进入卡牌");
			dlg_card_box_mainui.ShowUI( CARD_INTENT_PREVIEW );
			
		elseif ( ui.ID_CTRL_BUTTON_6 == tag ) then
			WriteCon("进入扭蛋");
			dlg_gacha.ShowUI( SHOP_GACHA );
		elseif ( ui.ID_CTRL_BUTTON_7 == tag ) then
			WriteCon("进入公会");
			
		elseif ( ui.ID_CTRL_BUTTON_8 == tag ) then
			WriteCon("进入道具");
			dlg_back_pack.ShowUI();	
			
		elseif ( ui.ID_CTRL_BUTTON_9== tag ) then
			WriteCon("其他菜单");	

		elseif ( ui.ID_CTRL_BUTTON_71== tag ) then
			WriteCon("强化界面");	
			dlg_card_box_mainui.ShowUI( CARD_INTENT_INTENSIFY );
			
		elseif ( ui.ID_CTRL_BUTTON_67== tag ) then
			WriteCon("进化界面");	
			dlg_card_box_mainui.ShowUI( CARD_INTENT_EVOLUTION );

		elseif ( ui.ID_CTRL_BUTTON_68== tag ) then
			WriteCon("队伍界面");	
			dlg_team_list.ShowUI();
		
		elseif ( ui.ID_CTRL_BUTTON_69== tag ) then
			WriteCon("技能碎片合成界面");	
			dlg_skill_piece_combo.ShowUI();
		
		elseif ( ui.ID_CTRL_BUTTON_70== tag ) then
			WriteCon("卡牌融合界面");	
			dlg_card_fuse.ShowUI();
		
		elseif ( ui.ID_CTRL_BUTTON_29== tag ) then
		    WriteCon("卡牌仓库");   
            dlg_card_depot.ShowUI();
		
		elseif ( ui.ID_CTRL_BUTTON_28== tag ) then
			WriteCon("技能卡牌");	
			dlg_user_skill.ShowUI(SKILL_INTENT_PREVIEW);
		
		elseif ( ui.ID_CTRL_BUTTON_FRIEND== tag ) then
			WriteCon("好友界面");
		    dlg_friend.ShowUI();
		    
		elseif ( ui.ID_CTRL_BUTTON_PLAYER_INFO == tag ) then
            WriteCon("玩家信息");
            dlg_watch_player.ShowUI( SELF_INFO );
            
        elseif ( ui.ID_CTRL_BUTTON_SHOP== tag ) then
             WriteCon("进入商店");
             dlg_gacha.ShowUI(SHOP_ITEM);
            
        elseif ( ui.ID_CTRL_BUTTON_34== tag ) then
             WriteCon("备用4");
             dlg_card_group.ShowUI();
             
        elseif ( ui.ID_CTRL_BUTTON_36== tag ) then
             WriteCon("备用5");
        
        elseif ( ui.ID_CTRL_BUTTON_37== tag ) then
             WriteCon("备用6");
        
        elseif ( ui.ID_CTRL_BUTTON_38== tag ) then
             WriteCon("备用7");
             
		elseif ( ui.ID_CTRL_BUTTON_35== tag ) then
             WriteCon("备用8");	
             
        elseif ( ui.ID_CTRL_BUTTON_BACK== tag ) then
             WriteCon("离开");        
             p.AskToLeave();
		end				
	end
end

--询问是否离开
function p.AskToLeave()   
	dlg_msgbox.ShowYesNo( 
		ToUtf8( "询问" ), ToUtf8( "是否离开当前地图，返回世界地图？" ), 
		p.OnMsgBoxCallback, p.layer );
end
				
--提示框回调处理
function p.OnMsgBoxCallback( result )
	if result then
		game_main.EnterWorldMap();
	end
end

--点击摇骰子按钮
function p.OnBtnClickRoll(uiNode, uiEventType, param)	
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
	
		--按钮灰掉
		p.RollButton:SetEnabled(false);
		if( p.RollState == p.STATE_READY )then
			
			--改变为Rolling状态
			task_map_roll_state.SetRollState_Rolling();
					
			--播放扔骰子特效
			local ani = string.format("%s%d","combo.playdice", task_map_roll_state.GetRollNumber());
			local fxid = AddHudEffect( ani );
			if RegAniEffectCallBack( fxid, p.OnRollComplete ) then
				PlayEffectSoundByName( "sk_dice.mp3" );--音效
			end
		end
	end
end

--进入旅行地图时，发送请求玩家数据
function p.SendHttpRequest()
	local uid = GetUID();
	if uid == 0 then uid = 100 end; --和服务端约定一个id，临时用
	SendReq("User","GetUserInfo",uid,"");
	
	--设置为禁止状态
	task_map_roll_state.SetRollState_Disabled();
end

--扔骰子表现完毕
function p.OnRollComplete()

	--设置为等待点击寻路状态
	task_map_roll_state.SetRollState_ClickPath();
	
	--显示路径供玩家选择
	FindTilePath( task_map_roll_state.GetRollNumber());
	
	--清空这次的点数
	task_map_roll_state.ClearRollNumber();
end

--[[
--重新设置定时，显示行动力恢复时间
function p.RefreshMissionPointTimer()
    if p.idTimerRefresh ~= nil then
        KillTimer( p.idTimerRefresh );
        p.idTimerRefresh = nil;
    end
    p.idTimerRefresh = SetTimer( p.onTimer_UpdateMissionPointTime, 1.0f );   
end

--更新行动力恢复时间
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

--主界面信息回调刷新界面
function p.RefreshUI(msg_player)
    if p.layer == nil then
    	return ;
    end
	if p.layer:IsVisible() then

		--人物名称
--		local pNameLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_2);
--		pNameLbl:SetText(tostring(msg_player.user_name));
		
		--等级
		local pLvLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_10);
		pLvLbl:SetText(tostring(msg_player.level));
		
		--经验
		local pExpLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_11);
		pExpLbl:SetText(tostring(msg_player.exp));
		
		--战斗力
--		local pArenaPointLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_14);
--		pArenaPointLbl:SetText( GetStr("play_arenaPoint")..string.format(": %d / %d ", msg_player.arena_point, msg_player.arena_point_max ));
		
		--卡片数
		local pCardNumberLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_15);
		pCardNumberLbl:SetText( string.format("%d/%d ", msg_player.card_num, msg_player.card_max_num));
		
		--金币
		local pMoneyLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_16);
		pMoneyLbl:SetText(tostring(msg_player.gold ));
		
		--行动力
		local pArenaPointLbl = GetLabel( p.layer, ui.ID_CTRL_TEXT_ACTION_POINT);
		pArenaPointLbl:SetText( string.format("%d/%d ", msg_player.mission_point, msg_player.mission_point_max ));
		
		local pActionPointExp = GetExp( p.layer, ui.ID_CTRL_EXP_ACTION_POINT);
		pActionPointExp:SetVertical();
        pActionPointExp:SetValue( 0, tonumber( msg_player.mission_point_max ), tonumber( msg_player.mission_point ) );
		

		--需要行动力值
		local pNeedMissionPointLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_NEED_MISSION_POINT );
		pNeedMissionPointLab:SetText( tostring( task_map.needMissionPoint));
		
		--行动力恢复时间
--		p.mission_point_restore_time_lbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_18);
--		p.mission_point_restore_time_lbl:SetText( GetStr("play_actiontomax").." "..os.date("%H:%M",msg_player.mission_point_full_time));
--		p.mission_point_full_time = msg_player.mission_point_full_time;
--		p.RefreshMissionPointTimer();
		
		--任务名
		local pMissionNameLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_12);
		pMissionNameLbl:SetText(tostring(msg_player.stage_name));
		
		--旅行数
		local pMissionNumLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_13);
		if (msg_player.travel_num ~= nil) and (msg_player.travel_max ~= nil) then
		    local travel_num = tonumber(msg_player.travel_num);
		    local travel_max = tonumber(msg_player.travel_max);
		    if travel_num ~= nil and travel_max ~= nil then
                local text = string.format( "%d/%d", travel_num, travel_max );
		        pMissionNumLbl:SetText( text );
            end
        end
		
		--人物头像
--		local pIconImg = GetImage(p.layer,ui.ID_CTRL_PICTURE_1);
		
	end
end

--刷新旅行数
function p.RefreshTravelNum( travelNum )
    if p.layer == nil then
        return ;
    end
	local pMissionNumLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_13);
	local text = string.format("%d/%d", travelNum, tonumber(msg_cache.msg_player.travel_max));
	pMissionNumLbl:SetText( text );
end

--刷新金币
function p.RefreshMoney( money )
    if p.layer == nil then
    	return ;
    end
    local pMoneyLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_16);
    pMoneyLbl:SetText(tostring( money ));
end

--刷新经验值
function p.RefreshExp( exp )
    if p.layer == nil then
        return ;
    end
    local pExpLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_11);
    pExpLbl:SetText(tostring(exp));
end

--刷新等级
function p.RefreshLevel( level )
    if p.layer == nil then
        return ;
    end
    local pLvLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_10);
	pLvLbl:SetText(tostring(level));
end

--刷新行动力
function p.RefreshActionPoint( point )
    if p.layer == nil then
        return ;
    end
	
	--文本
    local pArenaPointLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_ACTION_POINT);
    pArenaPointLbl:SetText( string.format("%d/%d ", point, msg_cache.msg_player.mission_point_max ));
    
	--原条
    local pActionPointExp = GetExp( p.layer, ui.ID_CTRL_EXP_ACTION_POINT);
    pActionPointExp:SetVertical();
    pActionPointExp:SetValue( 0, tonumber( msg_cache.msg_player.mission_point_max ), tonumber( point ) );

	--设置行动力action特效提示	
	p.SetActionPointHint();
end

--设置行动力action特效提示
function p.SetActionPointHint()
	local widget = p.RollButtonBGPic;
	
	--如若不足则用action特效提示
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

--刷新行动力完全恢复时间
--function p.RefreshPointFullTime( time )
--    local missionPointUpTimeLbl = GetLabel(p.layer, ui.ID_CTRL_TEXT_18);
--    missionPointUpTimeLbl:SetText( GetStr("play_actiontomax").." "..os.date("%H:%M",time) );
--end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

--设置扔骰子按钮状态
function p.SetRollBtnState( isEnabled )
	if p.layer ~= nil then
		p.RollButton:SetEnabled( isEnabled );
	end
end