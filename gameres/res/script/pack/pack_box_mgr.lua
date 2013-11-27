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
	WriteCon("====request back_box");
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	SendReq("Item","List",10001,"");
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

--显示所有道具
function p.ShowAllItems()
	WriteCon("pack_box_mgr.ShowAllItems();");
	pack_box.ShowItemList(p.itemList);
end

--加载分类道具
function p.ShowItemByType(sortType)
	if sortType == nil then 
		WriteCon("ShowItemByType():sortType is null");
		return;
	end 
	local itemListByType = p.GetItemList(sortType);
	pack_box.ShowItemList(itemListByType);
end

function p.GetItemList(sortType)
    if p.itemList == nil then
    	return nil;
    end
    local t = {};
	if sortType == 1 then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 0 then
				t[#t+1] = v;
			end
		end
	elseif sortType == 2 then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 3 or tonumber(v.Item_type) == 4 or tonumber(v.Item_type) == 5 then
				t[#t+1] = v;
			end
		end
	elseif sortType == 3 then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 2 or tonumber(v.Item_type) == 6 then
				t[#t+1] = v;
			end
		end
	elseif sortType == 4 then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 3 then
				t[#t+1] = v;
			end
		end
	elseif sortType == 5 then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 4 then
				t[#t+1] = v;
			end
		end
	elseif sortType == 6 then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 5 then
				t[#t+1] = v;
			end
		end
	end
    return t;
end





