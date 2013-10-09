-----------------------------------------------------------
-- FileName: 	define.lua
-- author:		zhangwq, 2013/08/15
-- purpose:		加载脚本：战斗相关
--------------------------------------------------------------

DoFile("battle/cmd_lua_callback.lua");
DoFile("battle/battle_inc.lua");
DoFile("battle/battle_util.lua");
DoFile("battle/battle_show.lua");
DoFile("battle/battle_camp.lua");
DoFile("battle/battle_mgr.lua");
DoFile("battle/battle_pvp.lua");
DoFile("battle/battle_pve.lua");
DoFile("battle/fighter.lua");
DoFile("battle/bullet.lua");
DoFile("battle/hp_bar.lua");
DoFile("battle/fly_num.lua");

--战斗UI
DoFile("battle/battle_mainui.lua");		--战斗主界面
DoFile("battle/dlg_battle_win.lua");	--战斗胜利UI
DoFile("battle/dlg_battle_lose.lua");	--战斗失败UI