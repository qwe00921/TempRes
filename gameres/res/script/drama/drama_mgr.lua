--------------------------------------------------------------
-- FileName: 	drama_mgr.lua
-- author:		
-- purpose:		剧情管理器（数据）
--------------------------------------------------------------

drama_mgr = {}
local p = drama_mgr;
p.dramaList = {};--剧情对话内容列表
p.index = nil;--对话位置索引
p.currentStageId = 0;
p.openView =nil;

--载入剧情对话内容
function p.LoadDramaInfo( stageId,dramaId,openViewId )
	if openViewId == nil then
		openViewId = after_drama_data.FIGHT 
	end
	p.openView = openViewId;
	
    if dramaId == nil then
    	return;
    end

	p.currentStageId = stageId;
	
    local dramaList = SelectRowList( T_STORY_INFO, "story_id", dramaId );
    if dramaList == nil or #dramaList == 0 then
    	WriteConWarning("story_id not find!");
    	return;
    end
    for k, v in ipairs(dramaList) do
    	local dramaInfo = drama_page:new();
    	dramaInfo:LoadPage(v);
    	p.dramaList[#p.dramaList + 1] = dramaInfo;
    end
    --dump_obj( p.dramaList[1] );
    if #p.dramaList > 0 then
    	p.ShowFirstDramaInfo();
    end
end

--显示剧情的第一个对话
function p.ShowFirstDramaInfo()
	p.index = 1;
	p.dramaList[p.index]:ShowPage();
end

--显示下一个剧情对话
function p.NextDramaInfo()
    if (p.index == nil) or (p.dramaList == nil) then return end;
    
	p.index = p.index + 1;
	if #p.dramaList < p.index then
		dlg_drama.CloseUI();
		p.ClearData();
		after_drama.DoAfterDrama(p.currentStageId,p.openView);
	else
	   p.dramaList[p.index]:ShowPage();	
	end
end

function p.ClearData()
	p.dramaList = {};
    p.index = nil;
end
