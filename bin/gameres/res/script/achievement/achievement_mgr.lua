--------------------------------------------------------------
-- FileName: 	achievement_mgr.lua
-- author:		zjj, 2013/09/16
-- purpose:		成就信息管理器
--------------------------------------------------------------

achievement_mgr = {}
local p = achievement_mgr;

--加载所有成就信息 
function p.LoadAllAchievement( )
	--WriteCon("**请求成就数据**");
	local uid = GetUID();
	if uid == 0 or uid == nil then return end;
	--发起请求
	SendReq("", "" , uid , "");
	
end

--成就请求回调，分类成就
function p.RefershUI( achievementlist )
	if #achievementlist == 0 then
		WriteCon(" equip_select_mgr:achievementlist is null");
		return
	end

end

--加载某一分类的成就
function p.LoadAchievementByCategory( category )
	--加载某一类型成就
end

--获取某一类型成就
function p.GetAchievementList( category )	
--    if p.equipList == nil or #p.equipList <= 0 then
--        return nil;
--    end
--    local t = {};
--    for k,v in ipairs(p.equipList) do
--        if tonumber(v.type) == category then
--            t[#t+1] = v;
--        end
--    end
--    return t;
end
