--------------------------------------------------------------
-- FileName: 	map_helper.lua
-- author:		hst, 2013年8月20日
-- purpose:		地图的辅助类
---------------------------------------------------------------

-------------------------------------
--获取地图名称
--@param {number}    travel_id          [no null]
--@return {string}
-------------------------------------

function GetMapName( travel_id )
	if travel_id == nil then
		return nil;
	end
	local isDungeonMap = false;
    if travel_id > 999999 then
    	isDungeonMap = true;
    end
    local mapName;
    local chapterId;
    local stageId;
    local travelId;
    
    if isDungeonMap then
    	mapName = "dungeon_";
    	chapterId = math.floor(travel_id/1000000) - 99;
		stageId = math.floor((travel_id%1000000)/10000)
		travelId = math.floor((travel_id%10000)/100)
    else	
    	mapName = "travel_";  
    	chapterId = math.floor(travel_id/10000);
    	stageId = math.floor((travel_id%10000)/100);
    	travelId = travel_id%100;
    end
    mapName = mapName..chapterId.."_"..stageId.."_"..travelId..".tmx";
    return mapName;
end

-------------------------------------
--获取旅行地图ID
--用途：如果是用户正在进行中旅行，返回该旅行地图ID。否则返回该章节的第一个旅行地图。
--@param {number}    chapter_id         [no null]
--@param {number}    stage_id           [no null]
--@param {number}    difficulty         副本地图使用，默认值为：1
--@return {number}   travel_id
-------------------------------------
function GetTravelId( chapterId, stageId, difficulty )
    local travelId = nil;
    if chapterId == nil or stageId == nil then
    	return nil;
    else
        chapterId = tonumber( chapterId );
        stageId =  tonumber( stageId );
    end
    local isDungeon = false;
    if chapterId > 999999 then
        if difficulty ==  nil then
        	difficulty = 1;
        end
        isDungeon = true;
    end    
    --获取用户当前的任务或副本进度
	if msg_cache ~=nil and msg_cache.msg_world_info ~= nil then
	   local curr_chapter_id;
	   local curr_stage_id;
	   local curr_travel_id;
	   if isDungeon then
	       curr_chapter_id = tonumber( msg_cache.msg_world_info.user_status.dungeon_chapter_id );
           curr_stage_id = tonumber( msg_cache.msg_world_info.user_status.dungeon_stage_id );
           curr_travel_id = tonumber( msg_cache.msg_world_info.user_status.dungeon_travel_id );
	   else
	       curr_chapter_id = tonumber( msg_cache.msg_world_info.user_status.chapter_id );
           curr_stage_id = tonumber( msg_cache.msg_world_info.user_status.stage_id );
           curr_travel_id = tonumber( msg_cache.msg_world_info.user_status.travel_id );
	   end
	   if chapterId == curr_chapter_id and stageId == curr_stage_id then
	       travelId = curr_travel_id;
	   end
	end 
	if travelId == nil then
	   if isDungeon then
	       travelId = (stageId + 1)*100 +tonumber( difficulty );
	   else
	       travelId = stageId + 1;
	   end
	end
	return travelId;
end