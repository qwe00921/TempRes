--------------------------------------------------------------
-- FileName:    back_pack_mgr.lua
-- author:      hst, 2013/07/23
-- purpose:     ����������--������ص�������
--------------------------------------------------------------

back_pack_mgr = {}
local p = back_pack_mgr;
p.itemList = nil;
p.layer = nil;

p.selectItem = nil;
p.selectItemList = {};

--�����û����еĵ����б�
function p.LoadAllItem( layer )
    p.ClearData()
    if layer ~= nil then
        p.layer = layer;
    end
    WriteCon("**���󱳰�����**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
     SendReq("Equip","GetUserItems",uid,"");
    
end

--���۵�������
function p.SellUserItem( itemId, num )
	if itemId == nil or num == nil then
        return ;
    end
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    num = 1;-- Ĭ������1��
    local param = string.format("&item_id=%d&num=%d", itemId, num);
    SendReq("Equip","SellUserItem",uid,param);
end

--���۵�������ص�
function p.RefreshUIBySell( result )
    --dump_obj( result );
	if result.for_sale == true then
	   dlg_msgbox.ShowOK(ToUtf8( "��ʾ" ), ToUtf8( "�������" ), p.OnMsgBoxCallback, dlg_back_pack.layer);
	end
end

--ˢ�µ����б�
function p.OnMsgBoxCallback( result )
    p.LoadAllItem( p.layer );
end

--��Ʒ����
function p.SortItemList()
    if p.itemList == nil or #p.itemList <= 0 then
    	return ;
    end
	table.sort(p.itemList, p.sortList);
	p.ShowAllItems();
end


--�������
function p.ClearData()
    p.itemList = nil;
    p.layer = nil;
    p.selectItem = nil;
    p.selectItemList = {};
end

--��ȡ��ѡ��ĵ���
function p.GetselectItem()
    return p.GetItemById( p.selectItem:GetId() );
end

--��ȡ��ѡ��ĵ����б�
function p.GetSelectItemList()
    if p.selectItemList == nil then
    	return nil;
    end
    local t = {};
    for k, v in ipairs(p.selectItemList) do
        t[#t+1] = p.GetItemById( v:GetId() );
    end
    return t;
end

--����ص�����ʾ�����б�
function p.RefreshUI( dataList )
    p.itemList = dataList;
    dlg_back_pack.ShowItemList( p.itemList );
end

--��ʾ���е���
function p.ShowAllItems()
    dlg_back_pack.ShowItemList( p.itemList );
end

--����ĳһ����ĵ���
function p.LoadItemByType( type )
    if type == nil then
        WriteCon("LoadItemByType():type is null");
        return ;
    end
    local itemList = p.GetItemList( type );
    dlg_back_pack.ShowItemList( itemList );
end

--��ȡĳһ�������
function p.GetItemList( type )
    if p.itemList == nil then
    	return nil;
    end
    local t = {};
    for k,v in ipairs(p.itemList) do
        if tonumber(v.type) == type then
            t[#t+1] = v;
        end
    end
    return t;
end

function p.GetItemById( itemId )
    if itemId == nil then
        return ;
    end
    if p.itemList == nil then
        return nil;
    end
    for i=1, #p.itemList do
        local item = p.itemList[i];
        if tonumber( item.id ) == itemId then
            return item;
        end
    end
end

-- ��������
function p.sortList(a,b)
    if tonumber(a.type) == tonumber(b.type) then
        return tonumber(a.id) < tonumber(b.id);
    else
        return tonumber(a.type) < tonumber(b.type);
    end
end
