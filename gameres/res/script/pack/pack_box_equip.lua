pack_box_equip = {}
local p = pack_box_equip;

local ui = ui_bag_equip_view;
p.layer = nil;
p.equipPrice = nil;
p.equipUid = nil;
p.equipInfoTable = nil;	--װ����Ϣ
function p.ShowEquip(itemId,itemUniqueId,itemType)
	p.equipUid = itemUniqueId;
	local equipInfo = pack_box_mgr.getItemInfoTable(itemUniqueId)
	if equipInfo == nil then
		WriteCon("equipInfo error");
		return;
	end
	p.equipInfoTable = equipInfo;
	--װ���۸�
	p.equipPrice = tonumber(equipInfo.SellPrice);
	if p.layer ~= nil then
		p.layer:SetVisible(true);
		return;
	end
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
    layer:Init();   
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddDlg(layer);
    LoadDlg("bag_equip_view.xui", layer, nil);

    p.layer = layer;
	p.SetDelegate(layer);
	
	p.ShowEquipInfo(equipInfo)
end

function p.SetDelegate(layer)
	local closeBtn = GetButton(layer, ui.ID_CTRL_BUTTON_CLOSE);
	closeBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local strengthenBtn = GetButton(layer, ui.ID_CTRL_BUTTON_STRENGTHEN);
	strengthenBtn:SetLuaDelegate(p.OnUIClickEvent);

	local sellBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SELL);
	sellBtn:SetLuaDelegate(p.OnUIClickEvent);
end

--�¼�����
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_CLOSE == tag) then --�ر�
			WriteCon("============�ر�===========");
			p.CloseUI()
		elseif(ui.ID_CTRL_BUTTON_STRENGTHEN == tag) then --ǿ��
			WriteCon("============ǿ��===========");
		elseif(ui.ID_CTRL_BUTTON_SELL == tag) then --����
			WriteCon("============����===========");
			local equipInformation = p.equipInfoTable
			if tonumber(equipInformation.Is_dress) > 0 then
				dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),ToUtf8("�������ϵ�װ�����޷����ۡ�"),nil,p.layer);
			elseif tonumber(equipInformation.Issell) > 0 then
				dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),ToUtf8("��װ���޷����ۡ�"),nil,p.layer);
			else
				dlg_msgbox.ShowYesNo(ToUtf8("ȷ����ʾ��"),ToUtf8("��ȷ��Ҫ�������װ�������װ����ֵ��"..tostring(p.equipPrice).."��ң���ȷ��Ҫ������Щ������"),p.OnSellEquipMsgBoxCallback,p.layer);
			end
		end
	end
end
--�Ƿ����װ��
function p.OnSellEquipMsgBoxCallback(result)
	if result == true then
		WriteCon("ȷ�ϳ���");
		pack_box_mgr.SendSellEquipRequest(p.equipUid);
	elseif result == false then
		WriteCon("ȡ������");
	end
end

function p.ShowEquipInfo(equipInfo)
	local item_id = tonumber(equipInfo.Item_id);
	WriteCon("item_id == "..item_id);
	local itemTable = SelectRowInner(T_ITEM,"id",item_id);
	if itemTable == nil then
		WriteConErr("itemTable error ");
		return;
	end

	local equipNameText = GetLabel(p.layer, ui.ID_CTRL_TEXT_EQUIP_NAME);	--װ������
	equipNameText:SetText(ToUtf8(itemTable.name));

	local equipPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_EQUIP);					--װ��ͼƬ
	equipPic:SetPicture( GetPictureByAni(itemTable.item_pic, 0) );
	
	local equipStarPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_STAR);				--װ���Ǽ�ͼƬ
	local starNum = tonumber(equipInfo.Rare);
	starNum = starNum -1;
	equipStarPic:SetPicture( GetPictureByAni("item.equipStar", starNum) );
	
	local equipLevelText = GetLabel(p.layer, ui.ID_CTRL_TEXT_LEVEL);				--װ���ȼ�
	equipLevelText:SetText(ToUtf8(equipInfo.Equip_level));
		
	local equipTypePic = GetImage(p.layer,ui.ID_CTRL_PICTURE_TYPE);	
	if tonumber(equipInfo.Item_type) == 1 then
		equipTypePic:SetPicture( GetPictureByAni("item.equipType", 0) );
	elseif tonumber(equipInfo.Item_type) == 2 then
		equipTypePic:SetPicture( GetPictureByAni("item.equipType", 1) );
	elseif tonumber(equipInfo.Item_type) == 3 then
		equipTypePic:SetPicture( GetPictureByAni("item.equipType", 2) );
	else
		WriteConErr("Iequip type error");
	end
		
	local mainProText = GetLabel(p.layer, ui.ID_CTRL_TEXT_MAIN_PRO1);				--������
	if tonumber(equipInfo.Attribute_type) ~= 0 then
		local AttType = equipInfo.Attribute_type;
		local AttValue = equipInfo.Attribute_value;
		p.equipAttByType(mainProText,AttType,AttValue)
	end
	local subPro1Text = GetLabel(p.layer, ui.ID_CTRL_TEXT_SUB_PRO1);				--������1
	if tonumber(equipInfo.Extra_type1) ~= 0 then
		local AttType = equipInfo.Extra_type1;
		local AttValue = equipInfo.Extra_value1;
		p.equipAttByType(subPro1Text,AttType,AttValue)
	end
	local subPro2Text = GetLabel(p.layer, ui.ID_CTRL_TEXT_SUB_PRO2);				--������2
	if tonumber(equipInfo.Extra_type2) ~= 0 then
		local AttType = equipInfo.Extra_type2;
		local AttValue = equipInfo.Extra_value2;
		p.equipAttByType(subPro2Text,AttType,AttValue)
	end
	local subPro3Text = GetLabel(p.layer, ui.ID_CTRL_TEXT_SUB_PRO3);				--������3
	if tonumber(equipInfo.Extra_value3) ~= 0 then
		local AttType = equipInfo.Extra_type3;
		local AttValue = equipInfo.Extra_value3;
		p.equipAttByType(subPro3Text,AttType,AttValue)
	end

	
	
	local infoText = GetLabel(p.layer, ui.ID_CTRL_TEXT_INFO);						--������Ϣ
	infoText:SetText(ToUtf8(itemTable.description));

	local modePic = GetImage(p.layer,ui.ID_CTRL_PICTURE_MODE);						--�Ƿ�װ��ͼƬ
	local dressIndex = tonumber(equipInfo.Is_dress)
	modePic:SetPicture( GetPictureByAni("item.equipMode", dressIndex));
end

function p.equipAttByType(nodeUI,AttType,AttValue)
	local AttName = nil
	if tonumber(AttType) == 1 then
		AttName = "����"
	elseif tonumber(AttType) == 2 then
		AttName = "����"
	elseif tonumber(AttType) == 3 then
		AttName = "Ѫ��"
	elseif tonumber(AttType) == 4 then
		AttName = "�ٶ�"
	elseif tonumber(AttType) == 5 then
		AttName = "����"
	end
	local text = AttName..AttValue
	nodeUI:SetText(ToUtf8(text));
end



function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end

function p.CloseUI()
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		p.ClearData();
    end
end

function p.ClearData()
	p.equipPrice = nil;
	p.equipUid = nil;
	p.equipInfoTable = nil;
end
