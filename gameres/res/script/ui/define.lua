--------------------------------------------------------------
-- FileName: 	define.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		加载所有UI定义
--------------------------------------------------------------

--主界面
DoFile("ui/ui_main_ui.lua")
DoFile("ui/ui_main_interface.lua")
DoFile("ui/ui_main_menu.lua")
--DoFile("ui/ui_main_userinfo.lua")
--DoFile("ui/ui_main_userinfo2.lua")
--DoFile("ui/ui_main_actandad.lua")

DoFile("ui/ui_main_btn_list.lua")
DoFile("ui/ui_main_btn_node.lua")
DoFile("ui/ui_main_battlearray.lua")
DoFile("ui/ui_main_battlearray_bg.lua")
DoFile("ui/ui_main_scrolllist_node.lua")
DoFile("ui/ui_marquee_led.lua")

--登录界面
DoFile("ui/ui_login_back.lua")
DoFile("ui/ui_login_createid.lua")
DoFile("ui/ui_login_main.lua")
DoFile("ui/ui_login_severselect.lua")
DoFile("ui/ui_login_severselect_option.lua")

--任务
DoFile("ui/ui_quest_main_view.lua")
DoFile("ui/ui_quest_list_view.lua")
DoFile("ui/ui_quest_reward_view.lua")

--背包
DoFile("ui/ui_bag_main.lua")
DoFile("ui/ui_bag_list.lua")
DoFile("ui/ui_bag_equip_view.lua")
DoFile("ui/ui_bag_gift_box.lua")
DoFile("ui/ui_bag_treasure_view.lua")
DoFile("ui/ui_bag_item_select.lua")

--卡牌背包
DoFile("ui/ui_card_main_view.lua")
DoFile("ui/ui_card_list_view.lua")
DoFile("ui/ui_card_bag_sort_view.lua")
DoFile("ui/ui_card_bag_select.lua")
DoFile("ui/ui_card_bag_sell_veiw.lua")

--加载所有UI
DoFile("ui/ui_battle_boss.lua")
DoFile("ui/ui_battle_vs.lua")

DoFile("ui/ui_test_button.lua")

DoFile("ui/ui_boss_out.lua")
DoFile("ui/ui_boss_out_info.lua")

DoFile("ui/ui_dlg_mission_exit.lua")
DoFile("ui/ui_get_card.lua")
DoFile("ui/ui_get_card_info.lua")

DoFile("ui/ui_dlg_battle_lose.lua")
DoFile("ui/ui_dlg_battle_win.lua")
DoFile("ui/ui_task_map_mainui.lua")
DoFile("ui/ui_world_map_mainui.lua")

--奖励：从宝箱里出来卡片动画
DoFile("ui/ui_open_box.lua")
DoFile("ui/ui_open_box_info.lua")

--奖励：遭遇货币
DoFile("ui/ui_dlg_encounter_props.lua")

--奖励：遭遇物品
DoFile("ui/ui_dlg_encounter_goods.lua")

--对战按钮
DoFile("ui/ui_battle_mainui.lua")

--PVP对战的站位 demo 2.0
DoFile("ui/ui_x_battle_pvp.lua")

--对战demo 2.0，pvp主界面
DoFile("ui/ui_x_battle_mainui.lua")

--卡牌战斗：PVP站位
DoFile("ui/ui_card_battle_pvp.lua")

--卡牌战斗：主界面
DoFile("ui/ui_card_battle_mainui.lua")

--卡箱UI
DoFile("ui/ui_dlg_card_box_mainui.lua")
DoFile("ui/ui_card_box_view.lua")
--卡牌强化
DoFile("ui/ui_card_rein.lua")
DoFile("ui/ui_card_intensify2.lua")
DoFile("ui/ui_card_list_intensify_view.lua")


--加载角色创建界面
DoFile("ui/ui_dlg_create_player.lua")

--加载世界地图界面
DoFile("ui/ui_dlg_stage_map.lua")

--卡牌强化与进化
DoFile("ui/ui_dlg_card_evolution.lua")
DoFile("ui/ui_dlg_card_evolution_result.lua")
DoFile("ui/ui_dlg_card_intensify.lua")
DoFile("ui/ui_dlg_card_intensify_result.lua")

--卡牌融合
DoFile("ui/ui_dlg_card_fuse.lua")
DoFile("ui/ui_dlg_card_fuse_result.lua")

--卡牌详细信息
DoFile("ui/ui_dlg_card_attr.lua")
DoFile("ui/ui_dlg_card_attr_base.lua")

--卡牌强化
DoFile("ui/ui_card_intensify.lua")
DoFile("ui/ui_card_intensify_succeed.lua")
--队伍
DoFile("ui/ui_team_list_view.lua")
DoFile("ui/ui_team_cardlist_view.lua")
DoFile("ui/ui_team_skilllist_view.lua")
DoFile("ui/ui_dlg_team_list.lua")
DoFile("ui/ui_dlg_team_member.lua")

--卡组
DoFile("ui/ui_dlg_card_group.lua")
DoFile("ui/ui_group_list_view.lua")


--背包
DoFile("ui/ui_dlg_back_pack.lua")
DoFile("ui/ui_dlg_item_detail.lua")
DoFile("ui/ui_dlg_item_equip_detail.lua")
DoFile("ui/ui_back_pack_view.lua")

--技能碎片合成
DoFile("ui/ui_dlg_skill_piece_combo.lua")
DoFile("ui/ui_skill_piece_list_view.lua")
DoFile("ui/ui_dlg_skill_piece_combo_result.lua")

--通用提示对话框
DoFile("ui/ui_dlg_msgbox.lua")

--装备
DoFile("ui/ui_dlg_card_equip.lua")
DoFile("ui/ui_dlg_equip_select.lua")
DoFile("ui/ui_equip_list_view.lua")
DoFile("ui/ui_dlg_equip_upgrade.lua")
DoFile("ui/ui_dlg_equip_upgrade_result.lua")
DoFile("ui/ui_dlg_item_select.lua")
DoFile("ui/ui_equip_item_view.lua")
DoFile("ui/ui_dlg_card_equip_select.lua")
DoFile("ui/ui_card_equip_select_view.lua")  
DoFile("ui/ui_dlg_item_sell.lua")

--卡牌仓库
DoFile("ui/ui_dlg_card_depot.lua")
DoFile("ui/ui_dlg_card_depot_check.lua")

--技能强化
DoFile("ui/ui_dlg_user_skill.lua")
DoFile("ui/ui_user_skill_view.lua")
DoFile("ui/ui_dlg_user_skill_detail.lua")
DoFile("ui/ui_dlg_user_skill_exp_detail.lua")
DoFile("ui/ui_dlg_user_skill_intensify.lua")
DoFile("ui/ui_dlg_user_skill_intensify_result.lua")

--副本
DoFile("ui/ui_dlg_dungeon_enter.lua")
DoFile("ui/ui_dlg_dungeon_result.lua")

--loading
DoFile("ui/ui_dlg_loading.lua")

--扭蛋
DoFile("ui/ui_dlg_gacha.lua")
DoFile("ui/ui_dlg_gacha_result.lua")
DoFile("ui/ui_gacha_list_view.lua")
DoFile("ui/ui_gacha_ad_view.lua")

--商城
DoFile("ui/ui_shop_item_view.lua")
DoFile("ui/ui_shop_gift_pack_view.lua")
DoFile("ui/ui_dlg_buy_num.lua")
DoFile("ui/ui_dlg_gift_pack_preview.lua")

--好友
DoFile("ui/ui_dlg_friend.lua")
DoFile("ui/ui_friend_list_view.lua")
DoFile("ui/ui_friend_apply_list_view.lua")
DoFile("ui/ui_friend_recommend_list_view.lua")
DoFile("ui/ui_dlg_friend_chat.lua")
DoFile("ui/ui_friend_chat_me_view.lua")
DoFile("ui/ui_friend_chat_friend_view.lua")
DoFile("ui/ui_chat_friend_list_view.lua")
DoFile("ui/ui_dlg_pk_result.lua")

--玩家信息
DoFile("ui/ui_dlg_watch_player.lua")
DoFile("ui/ui_combox_view.lua")

--卡牌按钮子菜单
DoFile("ui/ui_dlg_card_panel.lua")
DoFile("ui/ui_dlg_card_forge_panel.lua")

--图鉴
DoFile("ui/ui_dlg_collect_mainui.lua")
DoFile("ui/ui_collect_item_view.lua")
DoFile("ui/ui_collect_pet_view.lua")
DoFile("ui/ui_collect_skill_view.lua")
DoFile("ui/ui_collect_pet_detail.lua")
DoFile("ui/ui_collect_item_detail.lua")
DoFile("ui/ui_collect_skill_detail.lua")

--成就
DoFile("ui/ui_dlg_achievement.lua")
DoFile("ui/ui_achievement_view.lua")

--剧情
DoFile("ui/ui_dlg_drama.lua")

--剧情界面
--DoFile("ui/ui_dlg_drama_new.lua");

DoFile("ui/ui_main_userinfo.lua");
--创建角色界面
DoFile("ui/ui_createrole.lua");
DoFile("ui/ui_x_battle_ko.lua");


--召唤兽系统
DoFile("ui/ui_beast_mainui.lua");
DoFile("ui/ui_beast_main_list.lua");
DoFile("ui/ui_beast_incubate_list.lua");
DoFile("ui/ui_beast_incubate.lua");--培养

--邮件系统
DoFile("ui/ui_mail_main.lua");
DoFile("ui/ui_mail_write_mail.lua");
DoFile("ui/ui_mail_gm_mail.lua");
DoFile("ui/ui_mail_list_item_sys.lua");
DoFile("ui/ui_mail_list_item_user.lua");
DoFile("ui/ui_mail_detail_sys.lua");
DoFile("ui/ui_mail_detail_user.lua");
DoFile("ui/ui_mail_list_item_gm.lua");
DoFile("ui/ui_mail_list_item_user_history.lua");

--对战正式版本
DoFile("ui/ui_n_battle_ko.lua");
DoFile("ui/ui_n_battle_mainui.lua");
DoFile("ui/ui_n_battle_pvp.lua");
DoFile("ui/ui_n_battle_pve.lua");
DoFile("ui/ui_n_battle_itemuse.lua");
DoFile("ui/ui_n_battle_pass.lua");
DoFile("ui/ui_n_battle_pass_bg.lua");

--卡牌
DoFile("ui/ui_dlg_card_equip_detail.lua");
DoFile("ui/ui_card_equip_select_list.lua");
DoFile("ui/ui_card_equip_select_list_item.lua");

--卡牌编辑
DoFile("ui/ui_card_group.lua");
DoFile("ui/ui_card_group_node.lua");
DoFile("ui/ui_card_group_select_pet.lua");

