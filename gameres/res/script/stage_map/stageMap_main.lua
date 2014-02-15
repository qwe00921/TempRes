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

function p.getChapterListCallBack(data)

	if data.result == true then
		if data.chapters.S2 then
			p.chapterId = tonumber(data.chapters.S2)
		elseif data.chapters.S1 then
			p.chapterId = tonumber(data.chapters.S1)
		end
		
		p.startPlayKey = tonumber(data.chapters.StoryId)
	end
	
	if p.startPlayKey == 0 then
		p.openChapter(p.chapterId)
	elseif p.startPlayKey == 1 then
	--获取storyID
		local storyId = 1;
		dlg_drama.ShowUI(storyId,after_drama_data.CHAPTER,p.chapterId);
	end

end


function p.openChapter(mapId)
	WriteCon("to mapId == "..mapId);
	if mapId == 1 then
		--打开世界地图
		stageMap_1.ShowUI();
	elseif mapId == 2 then
		stageMap_2.ShowUI();
	else
		stageMap_1.ShowUI();
		WriteConErr("mapId err == "..mapId);
	end
end

--关闭UI
function p.CloseWorldMap()
	stageMap_1.CloseUI();
end
