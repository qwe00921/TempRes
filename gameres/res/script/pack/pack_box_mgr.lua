pack_box_mgr = {}
local p = pack_box_mgr;
p.layer = nil;
p.itemList = nil;

--加载用户所有道具列表
function p.LoadAllItem(layer)
	p.ClearData();
	if layer ~= nil then
		p.layer = layer;
	end
	WriteCon("====request back_box");
	local uid = GetUID();
	SendReq("Item","List",uid,"");
end
--请求卡牌列表回调，显示道具列表
function p.RefreshUI(self)
	if self.result == true then
		local amount = tonumber(self.amount);
		local items = self.user_items;
		local equips = self.user_equips;
		local allItemTable = {};
		if items ~= nil then
			allItemTable = items;
		end
		if equips ~= nil then
			for k,v in pairs(equips) do
				allItemTable[#allItemTable+1] = v;
			end
		end
		
		if #allItemTable == amount then
			p.itemList = allItemTable
			pack_box.ShowItemList(p.itemList);
		else
			WriteConWarning( "** allItemTable num error" );
		end
	elseif self.result == false then
		WriteConWarning( "** msg_pack_box error" );
	end
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
			if tonumber(v.Item_type) == 5 or tonumber(v.Item_type) == 6 or tonumber(v.Item_type) == 4 then
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

--使用物品
function p.UseItemEvent(itemId,itemUniqueId,itemType)
	WriteCon("pack_box_mgr.UseItemEvent();");
	local uid = GetUID();
	if itemId == nil or itemId == 0 or itemUniqueId == nil or itemUniqueId == 0 then
		WriteConErr("used item id error ");
		return
	end
	local param = "MachineType=Android&item_id="..itemId.."&id="..itemUniqueId;
	if itemId == 1001 or itemId == 1002  or itemId == 1003 then
		SendReq("Item","UseHealItem",uid,param);
	elseif itemId == 2001 or itemId == 2002 then
		SendReq("Item","UseQuickItem",uid,param);
	elseif itemId == 3001 then
		SendReq("Item","UseStorageItem",uid,param);
	elseif itemType == G_ITEMTYPE_GIFT then
		local itemTable = p.GetItemByID( itemUniqueId );
		if itemTable then
			local level_limit = tonumber(itemTable.Level_limit) or 0;
			local level = tonumber(msg_cache.msg_player.Level) or 0;
			WriteCon( tostring( level_limit) .. "   ".. tostring(level) );
			if level < level_limit then
				dlg_msgbox.ShowOK( "提示", "你的等级不足，无法使用！" , nil, pack_box.layer );
				return;
			end
		end
		SendReq("Item","UseGiftItem",uid,param);
	elseif itemType == G_ITEMTYPE_TREASURE then
		local keyItem = tonumber(SelectCell( T_ITEM, itemId, "param" )) or 0;
		if keyItem ~= 0 then
			local item = p.GetItemByItemID( keyItem );
			if item == nil then
				dlg_msgbox.ShowOK( "提示", "没有钥匙，无法打开宝箱！" , nil, pack_box.layer );
				return;
			end
		end
		SendReq("Item","UseTreasureItem",uid,param);
	else
		--使用钥匙，找到对应宝箱
		local tempItemId = tonumber(SelectRowInner( T_ITEM, "param", itemId, "id" ));
		if tempItemId == nil then
			WriteConErr("used item id error ");
			dlg_msgbox.ShowOK( "提示", "该物品无法使用！" , nil, pack_box.layer );
		else
			local item = p.GetItemByItemID( tempItemId );
			if item == nil then
				dlg_msgbox.ShowOK( "提示", "没有宝箱，无法使用！" , nil, pack_box.layer );
			else
				local paramEx = "MachineType=Android&item_id="..item.Item_id.."&id="..item.id;
				SendReq("Item","UseTreasureItem",uid,paramEx);
			end
		end
	end
end

function p.GetItemByItemID( itemid )
	local cache = msg_cache.msg_pack_item or {};
	local bagitem = cache.user_items;
	if itemid == nil or bagitem == nil or #bagitem == 0 then
		return nil;
	end
	
	for _,item in pairs( bagitem ) do
		if tonumber(itemid) == tonumber(item.Item_id) then
			return item;
		end
	end
	return nil;
end

--使用物品回调
function p.UseItemCallBack(self)
	local uid = GetUID();
	WriteCon("=======UseItemCallBack()");
	if self.result == true then
		dlg_msgbox.ShowOK("确认提示框","使用物品成功。",p.reOpenPackBox(),p.layer);
	elseif self.result == false then
		local messageText = self.message
		dlg_msgbox.ShowOK("确认提示框",messageText,nil,p.layer);
	end
end

--打开礼包回调
function p.UseGiftItemCallBack(self)
	if self.result == true then
		pack_gift_box.ShowGiftBox(self);
	elseif self.result == false then
		local messageText = self.message
		dlg_msgbox.ShowOK("确认提示框",messageText,nil,p.layer);
	end
end

--打开宝箱回调
function p.UseTreasureCallBack(self)
	if self.result == true then
		pack_box_treasure.ShowTreasureView(self);
	elseif self.result == false then
		local messageText = self.message
		dlg_msgbox.ShowOK("确认提示框",messageText,nil,p.layer);
	end
end

--出售装备
function p.SendSellEquipRequest(EquipUid)
	local uid = GetUID();
	if EquipUid == nil or EquipUid == 0 then
		WriteConErr("sell equip EquipUid error ");
		return
	end
	local param = "&id="..EquipUid;
	SendReq("Equip","Sell",uid,param);
end

--出售装备回调
function p.sellEquipCallBack(self)
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	local uid = GetUID();
	if self.result == true then 
		dlg_msgbox.ShowOK("确认提示框","出售成功。",p.reOpenPackBox(),p.layer);
		--p.reOpenPackBox();
	elseif self.result == false then
		local messageText = self.message;
		dlg_msgbox.ShowOK("确认提示框",messageText,nil,p.layer);
	end
end

function p.reOpenPackBox()
	pack_box_equip.CloseUI();
	--pack_box.CloseUI();
	--pack_box.ShowUI();
	dlg_gacha.ShowUI(SHOP_BAG, true);
end

function p.getItemInfoTable(uniqueid)
	local allItemList = p.itemList;
	if allItemList == nil then
		WriteCon("allItemList table error");
		return;
	end
	local itemInfoTable = {};
	for k,v in pairs(allItemList) do
		if tonumber(v.id) == uniqueid then
			if tonumber(v.Item_type) == 1 or tonumber(v.Item_type) == 2 or tonumber(v.Item_type) == 3 then
				itemInfoTable = v
				break;
			end
		end
	end
	return itemInfoTable;
end

function p.GetItemByID( uniqueid )
	local allItemList = p.itemList;
	if allItemList == nil then
		WriteCon("allItemList table error");
		return;
	end
	
	local itemInfoTable = {};
	for k,v in pairs(allItemList) do
		if tonumber(v.id) == uniqueid then
			if not (tonumber(v.Item_type) == 1 or tonumber(v.Item_type) == 2 or tonumber(v.Item_type) == 3) then
				itemInfoTable = v
				break;
			end
		end
	end
	return itemInfoTable;
end

--清空数据
function p.ClearData()
    p.itemList = nil;
    p.layer = nil;
end
