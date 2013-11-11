--------------------------------------------------------------
-- FileName: 	msg_factory.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		消息工厂（单例）
--------------------------------------------------------------

msg_factory = {}
local p = msg_factory;

--根据消息号创建消息
function CreateMsg( idmsg )
	local msg = nil;
	
	if idmsg == 1 then
		msg = msg_test:new();
	elseif idmsg == MSG_PLAYER then
	    msg = msg_player:new();
	elseif idmsg == MSG_CREATE_PLAYER then
		msg = msg_create_player:new();
		
	elseif idmsg == MSG_CARDBOX_USER_CARDS then
		msg = msg_card_box:new();	

	elseif idmsg == MSG_TRAVEL_INFO then
		msg = msg_travel_info:new();

	elseif idmsg == MSG_TRAVEL_ITEM then
		msg = msg_travel_item:new();

	elseif idmsg == MSG_WORLD_INFO then
		msg = msg_world_info:new();

	elseif idmsg == MSG_TRAVEL_EXPLORE then
		msg = msg_travel_explore:new();
	
	elseif idmsg == MSG_CARDBOX_INTENSIFY then	
		msg = msg_card_intensify:new();

	elseif idmsg == MSG_CARDBOX_EVOLUTION then	
		msg = msg_card_evolution:new();
		
	elseif idmsg == MSG_TEAM_LIST then	
		msg = msg_teamlist:new();
	
	elseif idmsg == MSG_TEAM_UPDATE then	
		msg = msg_team_update:new();

	elseif idmsg == MSG_EQUIP_BACK_PACK then 	
		msg = msg_back_pack:new();
		
	elseif idmsg == MSG_EQUIP_SELL_ITEM then   	
		msg = msg_sell_user_item:new();
		
	elseif idmsg == MSG_CARDBOX_DEPOT then       
        msg = msg_card_depot:new();	
    
    elseif idmsg == MSG_DEPOT_STORE then       
        msg = msg_card_depot_store:new(); 
    
    elseif idmsg == MSG_DEPOT_TAKEOUT then       
        msg = msg_card_depot_takeout:new(); 
	
	elseif idmsg == MSG_SKILLPIECE then       
        msg = msg_skillpiece:new(); 
	
	elseif idmsg == MSG_SKILLPIECE_RESULT then    
        msg = msg_skillpiece_result:new(); 
    
	elseif idmsg == MSG_CARD_EQUIP then       
        msg = msg_card_equip:new(); 
	
	elseif idmsg == MSG_CARD_FUSE_ITEM then       
        msg = msg_card_fuse_item:new(); 
		
	elseif idmsg == MSG_CARD_FUSE_RESULT then   
        msg = msg_card_fuse_result:new();    
		
	elseif idmsg == MSG_EQUIP_LIST then       
        msg = msg_equiplist:new();   
		
	elseif idmsg == MSG_CHANGE_EQUIP_RESULT then       
        msg = msg_change_equip_result:new();  
    
    elseif idmsg == MSG_MISSION_ROLL then       
        msg = msg_mission_roll:new();                 
		
	elseif idmsg == MSG_EQUIP_UPGRADE_RESULT then                   
        msg = msg_equip_upgrade_result:new();
        
    elseif idmsg == MSG_USER_SKILL then       
        msg = msg_user_skill:new();
        
    elseif idmsg == MSG_GACHA then       
        msg = msg_gacha:new();
        
    elseif idmsg == MSG_GACHA_RESULT then       
        msg = msg_gacha_result:new();
        
    elseif idmsg == MSG_USER_SKILL_INTENSIFY then       
        msg = msg_user_skill_intensify:new(); 
        
    elseif idmsg == MSG_DUNGEON_PROGRESS then       
        msg = msg_dungeon_progress:new();  
        
    elseif idmsg == MSG_DUNGEON then       
        msg = msg_dungeon:new();
        
    elseif idmsg == MSG_DUNGEON_EXPLORE then          
        msg = msg_dungeon_explore:new();               
        
    elseif idmsg == MSG_MISC_BILLBOARD then       
        msg = msg_billboard:new();    
    
    elseif idmsg == MSG_TRAVEL_BATTLE then       
        msg = msg_travel_battle:new();              

    elseif idmsg == MSG_FRIEND_LIST then       
        msg = msg_friend_list:new();              

    elseif idmsg == MSG_FRIEND_APPLY_LIST then       
        msg = msg_friend_apply_list:new();  
     
    elseif idmsg == MSG_FRIEND_RECOMMEND_LIST then       
        msg = msg_friend_recommend_list:new();  
      
    elseif idmsg == MSG_FRIEND_ACTION_RESULT then       
        msg = msg_friend_action_result:new(); 
    
    elseif idmsg == MSG_FRIEND_CHAT_LOG then       
        msg = msg_friend_chat_log:new(); 
	
	elseif idmsg == MSG_FRIEND_SEND_CHAT_RESULT then       
        msg = msg_friend_sendchat_result:new(); 
    
    elseif idmsg == MSG_BATTLE then       
        msg = msg_battle:new();
    
    elseif idmsg == MSG_BATTLE_FIGHTERS then   
        msg = msg_battle_fighters:new();

    elseif idmsg == MSG_BATTLE_HAND then       
        msg = msg_battle_stage_hand:new();
                
    elseif idmsg == MSG_BATTLE_TURN_DOT then       
        msg = msg_battle_turn_dot:new();
   
    elseif idmsg == MSG_BATTLE_TURN_SKILL then       
        msg = msg_battle_turn_skill:new();
    
    elseif idmsg == MSG_BATTLE_TURN_ATK then       
        msg = msg_battle_turn_atk:new();
    
    elseif idmsg == MSG_BATTLE_TURN_END then       
        msg = msg_battle_turn_end:new();

    elseif idmsg == MSG_WATCH_PLAYER then       
        msg = msg_watch_player:new(); 

    elseif idmsg == MSG_MISC_ERR then
    	msg = msg_err:new();
    	
    elseif idmsg == MSG_MISC_MAINUI then
    	msg = msg_mainui:new();
    	
    elseif idmsg == MSG_SHOP_ITEM then
        msg = msg_shop_item:new();
    
    elseif idmsg == MSG_SHOP_BUY_RESULT then
        msg = msg_shop_buy_result:new();
        
    elseif idmsg == MSG_COLLECT_START then
        msg = msg_collect:new();
        
    elseif idmsg == MSG_ACHIEVEMENT then
        msg = msg_achievement:new();    
		
	elseif idmsg == MSG_SERVER_LIST then
		msg = msg_server_list:new();
		
    elseif idmsg == MSG_PLAYER_HANDSHAKE then
		msg = msg_check_exist_role:new();
		
	elseif idmsg == MSG_QUEST_LIST then
		msg = msg_quest_list:new();
		
	elseif idmsg == MSG_PLAYER_CREATEROLE then
		msg = msg_createrole:new();
		
	elseif idmsg == MSG_PLAYER_USERINFO then
		msg = msg_maininterface:new();
		
	end
	
	if msg ~= nil then
		WriteConWarning( string.format("CreateMsg() ok, idmsg=%d", idmsg));
	else
		WriteConWarning( string.format("CreateMsg() failed, idmsg=%d", idmsg));
	end
	return msg;
end
