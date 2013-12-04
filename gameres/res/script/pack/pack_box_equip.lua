pack_box_equip = {}
local p = pack_box_equip;

local ui = ui_bag_equip_view;

function p.ShowEquip(itemId,itemUniqueId,itemType)
	local equipInfo = pack_box_mgr.getItemInfoTable(itemUniqueId)
			WriteConErr(tostring(equipInfo));

	if p.layer ~= nil then
		p.layer:SetVisible(true);
		return;
	end
	local loayer = createNDUIDialog();
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

function p.SetDelegate()
	local closeBtn = GetButton(layer, ui.ID_CTRL_BUTTON_CLOSE);
	returnBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local strengthenBtn = GetButton(layer, ui.ID_CTRL_BUTTON_STRENGTHEN);
	returnBtn:SetLuaDelegate(p.OnUIClickEvent);

	local sellBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SELL);
	returnBtn:SetLuaDelegate(p.OnUIClickEvent);
end

--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_CLOSE == tag) then --关闭
			WriteCon("=====ID_CTRL_BUTTON_CLOSE");
		elseif(ui.ID_CTRL_BUTTON_STRENGTHEN == tag) then --强化
			WriteCon("=====ID_CTRL_BUTTON_STRENGTHEN");
		elseif(ui.ID_CTRL_BUTTON_SELL == tag) then --出售
			WriteCon("=====ID_CTRL_BUTTON_SELL");
		end
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
	
	local equipNameText = GetLabel(p.layer, ui.ID_CTRL_COLOR_LABEL_EQUIP_NAME);	--装备名字
	equipNameText:SetText(ToUtf8(itemTable.Name));

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
	infoText:SetText(ToUtf8(itemTable.Description));
	
	local modePic = GetImage(p.layer,ui.ID_CTRL_PICTURE_MODE);						--是否装备图片
	modePic:SetPicture( GetPictureByAni("item.equipMode", tonumber(equipInfo.Is_dress)));
end
