pack_box_equip = {}
local p = pack_box_equip;

local ui = ui_bag_equip_view;
p.layer = nil;
p.equipPrice = nil;
p.equipUid = nil;
p.equipInfoTable = nil;	--装备信息
function p.ShowEquip(itemId,itemUniqueId,itemType)
	p.equipUid = itemUniqueId;
	local equipInfo = pack_box_mgr.getItemInfoTable(itemUniqueId)
	if equipInfo == nil then
		WriteCon("equipInfo error");
		return;
	end
	p.equipInfoTable = equipInfo;
	--装备价格
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

--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_CLOSE == tag) then --关闭
			WriteCon("============关闭===========");
			p.CloseUI()
		elseif(ui.ID_CTRL_BUTTON_STRENGTHEN == tag) then --强化
			WriteCon("============强化===========");
		elseif(ui.ID_CTRL_BUTTON_SELL == tag) then --出售
			WriteCon("============出售===========");
			local equipInformation = p.equipInfoTable
			if tonumber(equipInformation.Is_dress) > 0 then
				dlg_msgbox.ShowOK(ToUtf8("确认提示框"),ToUtf8("穿在身上的装备，无法出售。"),nil,p.layer);
			elseif tonumber(equipInformation.Issell) > 0 then
				dlg_msgbox.ShowOK(ToUtf8("确认提示框"),ToUtf8("此装备无法出售。"),nil,p.layer);
			else
				dlg_msgbox.ShowYesNo(ToUtf8("确认提示框"),ToUtf8("你确定要出售这件装备吗？这件装备价值："..tostring(p.equipPrice).."金币，你确定要卖出这些卡牌吗？"),p.OnSellEquipMsgBoxCallback,p.layer);
			end
		end
	end
end
--是否出售装备
function p.OnSellEquipMsgBoxCallback(result)
	if result == true then
		WriteCon("确认出售");
		pack_box_mgr.SendSellEquipRequest(p.equipUid);
	elseif result == false then
		WriteCon("取消出售");
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

	local equipNameText = GetColorLabel(p.layer, ui.ID_CTRL_COLOR_LABEL_EQUIP_NAME);	--装备名字
	equipNameText:SetText(ToUtf8(itemTable.name));

	local equipPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_EQUIP);					--装备图片
	equipPic:SetPicture( GetPictureByAni(itemTable.item_pic, 0) );
	
	local equipStarPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_STAR);				--装备星级图片
	local starNum = tonumber(equipInfo.Rare);
	starNum = starNum -1;
	equipStarPic:SetPicture( GetPictureByAni("item.equipStar", starNum) );
	
	local equipLevelText = GetLabel(p.layer, ui.ID_CTRL_TEXT_LEVEL);				--装备等级
	equipLevelText:SetText(ToUtf8(equipInfo.Equip_level));
		
	local mainProText = GetLabel(p.layer, ui.ID_CTRL_TEXT_MAIN_PRO1);				--主属性
	local subPro1Text = GetLabel(p.layer, ui.ID_CTRL_TEXT_SUB_PRO1);				--副属性1
	local subPro2Text = GetLabel(p.layer, ui.ID_CTRL_TEXT_SUB_PRO2);				--副属性2
	local subPro3Text = GetLabel(p.layer, ui.ID_CTRL_TEXT_SUB_PRO3);				--副属性3
	
	local infoText = GetLabel(p.layer, ui.ID_CTRL_TEXT_INFO);						--介绍信息
	infoText:SetText(ToUtf8(itemTable.description));

	local modePic = GetImage(p.layer,ui.ID_CTRL_PICTURE_MODE);						--是否装备图片
	local dressIndex = tonumber(equipInfo.Is_dress)
	modePic:SetPicture( GetPictureByAni("item.equipMode", dressIndex));
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
