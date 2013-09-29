--------------------------------------------------------------
-- FileName:    back_pack_mgr.lua
-- author:      hst, 2013/07/23
-- purpose:     背包管理器--负责加载道具数据
--------------------------------------------------------------

back_pack_mgr = {}
local p = back_pack_mgr;
p.itemList = nil;
p.layer = nil;

p.selectItem = nil;
p.selectItemList = {};

--加载用户所有的道具列表
function p.LoadAllItem( layer )
    p.ClearData()
    if layer ~= nil then
        p.layer = layer;
    end
    WriteCon("**请求背包数据**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
     SendReq("Equip","GetUserItems",uid,"");
    
end

--出售道具请求
function p.SellUserItem( itemId, num )
	if itemId == nil or num == nil then
        return ;
    end
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    num = 1;-- 默认先卖1个
    local param = string.format("&item_id=%d&num=%d", itemId, num);
    SendReq("Equip","SellUserItem",uid,param);
end

--出售道具请求回调
function p.RefreshUIBySell( result )
    --dump_obj( result );
	if result.for_sale == true then
	   dlg_msgbox.ShowOK(ToUtf8( "提示" ), ToUtf8( "出售完成" ), p.OnMsgBoxCallback, dlg_back_pack.layer);
	end
end

--刷新道具列表
function p.OnMsgBoxCallback( result )
    p.LoadAllItem( p.layer );
end

--物品整理
function p.SortItemList()
    if p.itemList == nil or #p.itemList <= 0 then
    	return ;
    end
	table.sort(p.itemList, p.sortList);
	p.ShowAllItems();
end


--清空数据
function p.ClearData()
    p.itemList = nil;
    p.layer = nil;
    p.selectItem = nil;
    p.selectItemList = {};
end

--获取己选择的道具
function p.GetselectItem()
    return p.GetItemById( p.selectItem:GetId() );
end

--获取己选择的道具列表
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

--请求回调，显示道具列表
function p.RefreshUI( dataList )
    p.itemList = dataList;
    dlg_back_pack.ShowItemList( p.itemList );
end

--显示所有道具
function p.ShowAllItems()
    dlg_back_pack.ShowItemList( p.itemList );
end

--加载某一分类的道具
function p.LoadItemByType( type )
    if type == nil then
        WriteCon("LoadItemByType():type is null");
        return ;
    end
    local itemList = p.GetItemList( type );
    dlg_back_pack.ShowItemList( itemList );
end

--获取某一分类道具
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

-- 道具整理
function p.sortList(a,b)
    if tonumber(a.type) == tonumber(b.type) then
        return tonumber(a.id) < tonumber(b.id);
    else
        return tonumber(a.type) < tonumber(b.type);
    end
end
