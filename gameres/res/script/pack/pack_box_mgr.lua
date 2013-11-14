pack_box_mgr = {}
local p = pack_box_mgr;
p.itemList = nil;
p.layer = nil;

p.selectItem = nil;
p.selectItemList = {};

--加载用户所有道具列表
function p.LoadAllItem(layer)
	p.ClearData();
	if layer ~= nil then
		p.layer = layer;
	end
	WriteCon("====请求背包数据====");
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	SendReq("Equip","List",uid,"");
end

--清空数据
function p.ClearData()
    p.itemList = nil;
    p.layer = nil;
    p.selectItem = nil;
    p.selectItemList = {};
end

--请求回调，显示道具列表
function p.RefreshUI(dataList)
	p.itemList = dataList;
	pack_box.ShowItemList(p.itemList);
end



