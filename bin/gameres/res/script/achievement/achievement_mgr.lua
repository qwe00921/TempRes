--------------------------------------------------------------
-- FileName: 	achievement_mgr.lua
-- author:		zjj, 2013/09/16
-- purpose:		�ɾ���Ϣ������
--------------------------------------------------------------

achievement_mgr = {}
local p = achievement_mgr;

--�������гɾ���Ϣ 
function p.LoadAllAchievement( )
	--WriteCon("**����ɾ�����**");
	local uid = GetUID();
	if uid == 0 or uid == nil then return end;
	--��������
	SendReq("", "" , uid , "");
	
end

--�ɾ�����ص�������ɾ�
function p.RefershUI( achievementlist )
	if #achievementlist == 0 then
		WriteCon(" equip_select_mgr:achievementlist is null");
		return
	end

end

--����ĳһ����ĳɾ�
function p.LoadAchievementByCategory( category )
	--����ĳһ���ͳɾ�
end

--��ȡĳһ���ͳɾ�
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
