pack_box_mgr = {}
local p = pack_box_mgr;
p.itemList = nil;
p.layer = nil;

-- p.selectItem = nil;
-- p.selectItemList = {};

--�����û����е����б�
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

--�������
function p.ClearData()
    p.itemList = nil;
    p.layer = nil;
    --p.selectItem = nil;
    --p.selectItemList = {};
end

--����ص�����ʾ�����б�
function p.RefreshUI(dataList)
	p.itemList = dataList;
	pack_box.ShowItemList(p.itemList);
end

--��ʾ���е���
function p.ShowAllItems()
	WriteCon("pack_box_mgr.ShowAllItems();");
	pack_box.ShowItemList(p.itemList);
end

--���ط������
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

function p.UseItemEvent(itemId,itemUniqueId,itemType)
	WriteCon("pack_box_mgr.UseItemEvent();");
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	if itemId == nil or itemId == 0 or itemUniqueId == nil or itemUniqueId == 0 then
		WriteConErr("used item id error ");
		return
	end
	local param = "MachineType=Android&item_id="..itemId.."&id="..itemUniqueId;
	if itemId == 1001 then
		SendReq("Item","UseHealItem",uid,param);
	elseif itemId == 1002 then
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

function p.UseItemCallBack(self)
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	WriteCon("=======UseItemCallBack()");
	if self.result == true then
		dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),ToUtf8("ʹ����Ʒ�ɹ���"),nil,p.layer);
		SendReq("Item","List",uid,"");
	elseif self.result == false then
		local messageText = self.message
		dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),messageText,nil,p.layer);
	end
end

--������ص�
function p.UseGiftItemCallBack(self)
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	if self.result == true then
		pack_gift_box.ShowGiftBox(self);
	elseif self.result == false then
		local messageText = self.message
		dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),messageText,nil,p.layer);
	end
end




function p.getItemInfoTable(uniqueid)
	local allItemList = pack_box_mgr.itemList;
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

--����װ��
function p.SendSellEquipRequest(EquipUid)
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	if EquipUid == nil or EquipUid == 0 then
		WriteConErr("sell equip EquipUid error ");
		return
	end
	local param = "&id="..EquipUid;
	SendReq("Item","Sell",uid,param);
end

--����װ���ص�
function p.sellEquipCallBack(self)
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	if self.result == true then 
		dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),ToUtf8("���۳ɹ���"),nil,p.layer);
		pack_box_equip.CloseUI();
		SendReq("Item","List",uid,"");
	elseif self.result == false then
		local messageText = self.message;
		dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),messageText,nil,p.layer);
	end
end

-- UseHealItem //�ж����ָ�����ʹ��
-- UseQuickItem //�����ָ�����ʹ��
-- UseStorageItem //������չ����
-- UseGiftItem//���
-- UseTreasureItem//����  

