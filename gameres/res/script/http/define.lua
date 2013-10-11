-----------------------------------------------------------
-- FileName: 	define.lua
-- author:		zhangwq, 2013/07/08
-- purpose:		Http消息响应的处理脚本
--------------------------------------------------------------

--消息类
DoFile("http/msg/msg_define.lua");
DoFile("http/msg/msg_base.lua");
DoFile("http/msg/msg_test.lua");
DoFile("http/msg/msg_err.lua");
DoFile("http/msg/msg_factory.lua");
DoFile("http/msg/msg_cache.lua");
DoFile("http/msg/msg_player.lua");
DoFile("http/msg/msg_create_player.lua");
DoFile("http/msg/msg_card_box.lua");
DoFile("http/msg/msg_travel_info.lua");
DoFile("http/msg/msg_travel_item.lua");
DoFile("http/msg/msg_world_info.lua");
DoFile("http/msg/msg_travel_explore.lua");
DoFile("http/msg/msg_card_intensify.lua");
DoFile("http/msg/msg_card_evolution.lua");
DoFile("http/msg/msg_teamlist.lua");
DoFile("http/msg/msg_team_update.lua");
DoFile("http/msg/msg_back_pack.lua");
DoFile("http/msg/msg_sell_user_item.lua");
DoFile("http/msg/msg_card_depot.lua");
DoFile("http/msg/msg_card_depot_store.lua");
DoFile("http/msg/msg_card_depot_takeout.lua");
DoFile("http/msg/msg_skillpiece.lua")
DoFile("http/msg/msg_skillpiece_result.lua")
DoFile("http/msg/msg_card_equip.lua")
DoFile("http/msg/msg_card_fuse_item.lua")
DoFile("http/msg/msg_card_fuse_result.lua")
DoFile("http/msg/msg_equiplist.lua")
DoFile("http/msg/msg_change_equip_result.lua")
DoFile("http/msg/msg_mission_roll.lua")
DoFile("http/msg/msg_equip_upgrade_result.lua")
DoFile("http/msg/msg_user_skill.lua")
DoFile("http/msg/msg_gacha.lua")
DoFile("http/msg/msg_gacha_result.lua")
DoFile("http/msg/msg_user_skill_intensify.lua")
DoFile("http/msg/msg_dungeon_progress.lua")
DoFile("http/msg/msg_dungeon.lua")
DoFile("http/msg/msg_dungeon_explore.lua")
DoFile("http/msg/msg_billboard.lua")
DoFile("http/msg/msg_travel_battle.lua")
DoFile("http/msg/msg_friend_list.lua")
DoFile("http/msg/msg_friend_apply_list.lua")
DoFile("http/msg/msg_friend_recommend_list.lua")
DoFile("http/msg/msg_friend_action_result.lua")
DoFile("http/msg/msg_friend_chat_log.lua")
DoFile("http/msg/msg_friend_sendchat_result.lua")
DoFile("http/msg/msg_watch_player.lua")
DoFile("http/msg/msg_mainui.lua")
DoFile("http/msg/msg_shop_item.lua")
DoFile("http/msg/msg_shop_buy_result.lua")
DoFile("http/msg/msg_collect.lua")
DoFile("http/msg/msg_achievement.lua")

--战斗消息类
DoFile("http/msg/msg_battle.lua");				--战斗消息
DoFile("http/msg/msg_battle_fighters.lua");		--fighter消息
DoFile("http/msg/msg_battle_stage_hand.lua");     --起手阶段消息
DoFile("http/msg/msg_battle_turn_dot.lua");		--回合DOT阶段消息
DoFile("http/msg/msg_battle_turn_skill.lua");	--回合技能阶段消息
DoFile("http/msg/msg_battle_turn_atk.lua");		--回合普通攻击阶段消息
DoFile("http/msg/msg_battle_turn_end.lua");		--回合阶段阶段消息

--响应类
DoFile("http/response/resp_base.lua");
DoFile("http/response/resp_test.lua");
DoFile("http/response/resp_factory.lua");
DoFile("http/response/json2lua_helper.lua");
