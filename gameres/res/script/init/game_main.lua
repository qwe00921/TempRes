--------------------------------------------------------------
-- FileName: 	game_main.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		卡牌游戏的主入口
--------------------------------------------------------------

game_main = {}
local p = game_main;

math.randomseed(os.time());

--main入口
function p.main()
	WriteCon( "*** game_main.main() ***\r\n")
	
	if true and GetUID() == 0 then
		dlg_create_player:ShowUI();--新建角色
	else
	    if false then
	        --这是资本主义邪路
		    --p.EnterWorldMap();
		    p.EnterTaskMap( "travel_1_1_1.tmx", 1, 1, 1 );
		    task_map_mainui.HideUI();
		else
		    --这是社会主义宇宙真理
		    --显示主界面
		    mainui.ShowUI();
        end
	end
	
	--测试
	test.test();
end

--进入世界地图
function p.EnterWorldMap()	

	--隐藏任务主界面
	task_map_mainui.HideUI();
	
	--关闭任务地图
	task_map.CloseMap();
	
	--打开世界地图
	world_map.OpenMap();
	
	--关闭背景音乐
	StopMusic();
end

--进入任务地图
function p.EnterTaskMap( mapName, chapterId, stageId, stageType, difficulty )
    
    if chapterId == nil then
    	WriteCon("chapterId is nil");
    end
    
    if stageId == nil then
        WriteCon("stageId is nil");
    end
    
	--关闭世界地图
	world_map.CloseMap();
	
	--打开任务地图
	task_map.OpenMap( mapName, chapterId, stageId, stageType, difficulty );
	
	--播放任务音乐
	PlayMusic_Task();
	
	--显示主菜单
	task_map_mainui.ShowUI();
	
	--显示左侧菜单
	--test_button.ShowUI();

	--直接进战斗
	if true then
--[[		if E_DEMO_VER == 2 then
			x_battle_mgr.EnterBattle();
		elseif E_DEMO_VER == 3 then	
			card_battle_mgr.EnterBattle();
		elseif E_DEMO_VER == 1 then
			battle_mgr.EnterBattle();
		end--]]
		
		x_battle_mgr.EnterBattle();
	end
end
