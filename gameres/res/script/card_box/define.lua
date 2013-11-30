-----------------------------------------------------------
-- FileName: 	define.lua
-- author:		zhangwq, 2013/08/15
-- purpose:		加载脚本：卡牌相关（背包、仓库...）
--------------------------------------------------------------

--卡箱
DoFile("card_box/card_box_inc.lua");
DoFile("card_box/dlg_card_box_mainui.lua");
DoFile("card_box/card_box_mgr.lua");

--卡牌进化
DoFile("card_box/dlg_card_evolution.lua");
DoFile("card_box/dlg_card_evolution_result.lua");

--卡牌强化
DoFile("card_box/dlg_card_intensify.lua");
DoFile("card_box/dlg_card_intensify_result.lua");

--卡牌融合
DoFile("card_box/dlg_card_fuse.lua");
DoFile("card_box/dlg_card_fuse_result.lua");

--卡牌仓库
DoFile("card_box/dlg_card_depot.lua");
DoFile("card_box/card_depot_mgr.lua");
DoFile("card_box/dlg_card_depot_check.lua");

--卡组
DoFile("card_box/dlg_card_group.lua");
--卡详细信息
DoFile("card_box/dlg_card_attr.lua");
DoFile("card_box/dlg_card_attr_base.lua");