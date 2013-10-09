-----------------------------------------------------------
-- FileName: 	define.lua
-- author:		zhangwq, 2013/08/15
-- purpose:		加载脚本：任务相关（mission）
--------------------------------------------------------------

--任务
DoFile("mission/dlg_mission_exit.lua");
DoFile("mission/get_card.lua"); 			--加载获得卡片界面
DoFile("mission/open_box.lua");  			--开箱子（奖励动画）
DoFile("mission/boss_out.lua");  			--遇敌
DoFile("mission/dlg_encounter_money.lua");  --获取货币
DoFile("mission/dlg_encounter_goods.lua");  --获取物品
DoFile("mission/fly_num_exp.lua");

--副本
DoFile("mission/dlg_dungeon_enter.lua");
DoFile("mission/dlg_dungeon_result.lua");
