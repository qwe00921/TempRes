--------------------------------------------------------------
-- FileName: 	stage_main.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		������Ϸ�������
--------------------------------------------------------------

stageMap_main = {}
local p = stageMap_main;

--���������ͼ
function p.OpenWorldMap()
	--�������ͼ
    WriteCon("to stageMap_main");
	stageMap_1.OpenStageMap();

end

--�ر�UI
function p.CloseWorldMap()
	stageMap_1.CloseStageMap();
end
