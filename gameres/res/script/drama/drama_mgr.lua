--------------------------------------------------------------
-- FileName: 	drama_mgr.lua
-- author:		
-- purpose:		��������������ݣ�
--------------------------------------------------------------

drama_mgr = {}
local p = drama_mgr;
p.dramaList = {};--����Ի������б�
p.index = nil;--�Ի�λ������

--�������Ի�����
function p.LoadDramaInfo( dramaId )
    if dramaId == nil then
    	return;
    end
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

--��ʾ����ĵ�һ���Ի�
function p.ShowFirstDramaInfo()
	p.index = 1;
	p.dramaList[p.index]:ShowPage();
end

--��ʾ��һ������Ի�
function p.NextDramaInfo()
    if (p.index == nil) or (p.dramaList == nil) then return end;
    
	p.index = p.index + 1;
	if #p.dramaList < p.index then
		dlg_drama.CloseUI();
		p.ClearData();
		after_drama.DoAfterDrama();
	else
	   p.dramaList[p.index]:ShowPage();	
	end
end

function p.ClearData()
	p.dramaList = nil;
    p.index = nil;
end
