-----------------------------------------------------------
-- FileName: 	define.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		加载卡牌所有脚本
--------------------------------------------------------------

--加载所有UI
DoFile("ui/define.lua");

--测试用
DoFile("test.lua");
DoFile("test_button.lua");

--通用
DoFile("common/func.lua");
DoFile("common/ui_func.lua");
DoFile("common/vector.lua");
DoFile("common/map.lua");
DoFile("common/util.lua");
DoFile("common/dlg_msgbox.lua");
DoFile("common/db_func.lua");
DoFile("common/http_func.lua");
DoFile("common/dlg_loading.lua");
DoFile("common/music_func.lua");
DoFile("common/card_func.lua");
DoFile("common/tip.lua");

--初始化
DoFile("init/load_ani.lua");            --加载Ani
DoFile("init/load_action_effect.lua");  --加载Action特效
DoFile("init/load_chara.lua");          --加载Chara配置
DoFile("init/load_db.lua");           	--加载数据库
DoFile("init/game_main.lua");           --加载card_main

--加载角色创建界面
DoFile("login/dlg_create_player.lua");

--加载主界面
DoFile("mainui/mainui.lua");
DoFile("mainui/hud.lua");
DoFile("mainui/billboard.lua"); --跑马灯
--主界面按钮子菜单
DoFile("mainui/dlg_card_panel.lua");
DoFile("mainui/dlg_card_forge_panel.lua");

--地图
DoFile("map/world_map.lua");
DoFile("map/world_map_mainui.lua");
DoFile("map/task_map.lua");
DoFile("map/task_map_inc.lua");
DoFile("map/task_map_roll_state.lua");
DoFile("map/task_map_mainui.lua");
DoFile("map/dlg_stage_map.lua");
DoFile("map/map_helper.lua");


--【加载战斗 (v1.0)】
DoFile("battle/define.lua");

--【加载战斗 (demo 2.0)】
DoFile("x_battle/define.lua");

--【加载战斗 (demo 3.0)】
DoFile("card_battle/define.lua");

--【任务和副本】
DoFile("mission/define.lua");

--【Http响应消息】
DoFile("http/define.lua");

--【卡牌】
DoFile("card_box/define.lua");

--队伍
DoFile("team/dlg_team_list.lua");
DoFile("team/dlg_team_member.lua");

--【物品相关】
DoFile("item/define.lua");


--技能强化、碎片合成
DoFile("skill/dlg_skill_piece_combo.lua");
DoFile("skill/dlg_skill_piece_combo_result.lua");
DoFile("skill/dlg_user_skill.lua");
DoFile("skill/user_skill_inc.lua");
DoFile("skill/user_skill_mgr.lua");
DoFile("skill/dlg_user_skill_detail.lua");
DoFile("skill/dlg_user_skill_exp_detail.lua");
DoFile("skill/dlg_user_skill_intensify.lua");
DoFile("skill/dlg_user_skill_intensify_result.lua");


--扭蛋
DoFile("gacha/dlg_gacha.lua");
DoFile("gacha/dlg_gacha_result.lua");

--商城
DoFile("gacha/dlg_buy_num.lua");
DoFile("gacha/dlg_gift_pack_preview.lua");

--好友
DoFile("friend/dlg_friend.lua");
DoFile("friend/dlg_friend_chat.lua");
DoFile("friend/dlg_pk_result.lua");
DoFile("friend/friend_mgr.lua");
DoFile("friend/friend_chat_log_mgr.lua");

--玩家信息
DoFile("watcher_player/dlg_watch_player.lua");

--图鉴
DoFile("collect/collect_inc.lua");
DoFile("collect/collect_mgr.lua");
DoFile("collect/dlg_collect_mainui.lua");
DoFile("collect/dlg_collect_pet_detail.lua");
DoFile("collect/dlg_collect_item_detail.lua");
DoFile("collect/dlg_collect_skill_detail.lua");
DoFile("collect/collect_star_menu.lua");

--成就
DoFile("achievement/dlg_achievement.lua");

--剧情
DoFile("drama/dlg_drama.lua");
DoFile("drama/drama_mgr.lua");
DoFile("drama/drama_page.lua");

--邮箱
DoFile("mailbox/dlg_mailbox_mainui.lua");
DoFile("mailbox/dlg_mailbox_kf.lua"); 
DoFile("mailbox/dlg_mailbox_person_write.lua"); 
DoFile("mailbox/dlg_mailbox_sys_detail.lua"); 
DoFile("mailbox/dlg_mailbox_person_detail.lua"); 
DoFile("mailbox/mailbox_mgr.lua"); 