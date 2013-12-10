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
		p.itemList = self.user_items
		pack_box.ShowItemList(p.itemList);
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
	if itemId == 1001 or itemId == 2001 then
		SendReq("Item","UseHealItem",uid,param);
	elseif itemId == 1002 or itemId == 2002 then
		SendReq("Item","UseQuickItem",uid,param);
	elseif itemType == 4 then
		SendReq("Item","UseStorageItem",uid,param);
	elseif itemType == 5 then
		SendReq("Item","UseGiftItem",uid,param);
	elseif itemType == 6 then
		SendReq("Item","UseTreasureItem",uid,param);
	else
		WriteConErr("used item id error ");
	end
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
	SendReq("Item","Sell",uid,param);
end

--出售装备回调
function p.sellEquipCallBack(self)
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
	pack_box.CloseUI();
	pack_box.ShowUI();
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
			itemInfoTable = v
			break;
		end
	end
	return itemInfoTable;
end

--清空数据
function p.ClearData()
    p.itemList = nil;
    p.layer = nil;
end
