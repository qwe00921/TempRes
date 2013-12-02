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
	SendReq("Item","List",uid,"");
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
	if sortType == ITEM_TYPE_TOOL then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 0 then
				t[#t+1] = v;
			end
		end
	elseif sortType == ITEM_TYPE_EQUIP then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 1 or tonumber(v.Item_type) == 2 or tonumber(v.Item_type) == 3 then
				t[#t+1] = v;
			end
		end
	elseif sortType == ITEM_TYPE_OTHER then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 5 or tonumber(v.Item_type) == 6 then
				t[#t+1] = v;
			end
		end
	elseif sortType == ITEM_TYPE_EQUIP_1 then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 1 then
				t[#t+1] = v;
			end
		end
	elseif sortType == ITEM_TYPE_EQUIP_2 then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 2 then
				t[#t+1] = v;
			end
		end
	elseif sortType == ITEM_TYPE_EQUIP_3 then 
		for k,v in ipairs(p.itemList) do		
			if tonumber(v.Item_type) == 3 then
				t[#t+1] = v;
			end
		end
	end
    return t;
end

function p.UseItemEvent(itemId)
	WriteCon("pack_box_mgr.UseItemEvent();");
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	if itemId == nil or itemId == 0 then
		WriteConErr("used item id error ");
		return
	end
	local param = "MachineType=Android&item_id=".."1001";
	if itemId == 1 then
		SendReq("Item","UseHealItem",uid,param);
	elseif itemId == 2 then
		SendReq("Item","UseQuickItem",uid,param);
	elseif itemId == 3 then
		SendReq("Item","UseStorageItem",uid,param);
	elseif itemId == 4 then
		SendReq("Item","UseGiftItem",uid,param);
	elseif itemId == 5 then
		SendReq("Item","UseTreasureItem",uid,param);
	elseif itemId == 6 then
		SendReq("Item","UseHealItem ",uid,param);
	else
		WriteConErr("used item id error ");
	end
end

-- UseHealItem //行动力恢复道具使用
-- UseQuickItem //活力恢复道具使用
-- UseStorageItem //背包扩展道具
-- UseGiftItem//礼包
-- UseTreasureItem//宝箱  

