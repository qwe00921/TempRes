--------------------------------------------------------------
-- FileName: 	stage_main.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		卡牌游戏的主入口
--------------------------------------------------------------

stageMap_main = {}
local p = stageMap_main;

p.chapterId = nil;

--进入世界地图
function p.OpenWorldMap()
	
	local uid = GetUID();
	WriteCon("send getChapterList() request");
	SendReq("Mission","ChapterList",uid,"");
end

function p.getChapterListCallBack(self)

	if self.result == true then
		p.chapterId = tonumber(self.chapters.S1)
		p.startPlayKey = tonumber(self.chapters.StoryId)
	end
	
	if p.startPlayKey == 0 then
		p.openChapter()
	elseif p.startPlayKey == 1 then
	--获取storyID
		local storyId = 1;
		dlg_drama.ShowUI(0,storyId,after_drama_data.CHAPTER);
	end

end


function p.openChapter()
	--打开世界地图
	WriteCon("to stageMap_main");
	stageMap_1.OpenStageMap();
end

--关闭UI
function p.CloseWorldMap()
	stageMap_1.CloseStageMap();
end
