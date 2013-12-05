--------------------------------------------------------------
-- FileName: 	stage_main.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		卡牌游戏的主入口
--------------------------------------------------------------

stageMap_main = {}
local p = stageMap_main;

--进入世界地图
function p.OpenWorldMap()
	--打开世界地图
    WriteCon("to stageMap_main");
	stageMap_1.OpenStageMap();

end

--关闭UI
function p.CloseWorldMap()
	stageMap_1.CloseStageMap();
end
