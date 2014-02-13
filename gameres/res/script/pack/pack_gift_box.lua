pack_gift_box = {}
local p = pack_gift_box;

local ui = ui_bag_gift_box;
p.layer = nil;

function p.ShowGiftBox(self)
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
	--layer:SetSwallowTouch(false);

	GetUIRoot():AddDlg(layer);
    LoadDlg("bag_gift_box.xui", layer, nil);

    p.layer = layer;
	p.SetDelegate(layer);
	
	p.ShowGiftBoxInfo(self)
end

function p.SetDelegate(layer)
	local OKBtn = GetButton(layer, ui.ID_CTRL_BUTTON_OK);
	OKBtn:SetLuaDelegate(p.OnUIClickEvent);
end

--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_OK == tag) then --关闭
			WriteCon("确认");
			p.CloseUI();
			--SendReq("Item","List",uid,"");
			pack_box_mgr.reOpenPackBox()
			-- pack_box.CloseUI();
			-- pack_box.ShowUI();
		end
	end
end

--
function p.ShowGiftBoxInfo(self)
	local giftBoxText = GetLabel(p.layer, ui.ID_CTRL_TEXT_GIFT_HEAD);
	giftBoxText:SetText("恭喜您，打开礼包获得以下物品。");
	
	local giftTable = {}
	giftTable["giftPic_1"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_GIFT_1);
	giftTable["giftPic_2"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_GIFT_2);
	giftTable["giftPic_3"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_GIFT_3);
	giftTable["giftPic_4"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_GIFT_4);
	giftTable["giftPic_5"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_GIFT_5);
	giftTable["giftPic_6"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_GIFT_6);
	
	giftTable["giftNum_1"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_GIFT_NUM_1);
	giftTable["giftNum_2"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_GIFT_NUM_2);
	giftTable["giftNum_3"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_GIFT_NUM_3);
	giftTable["giftNum_4"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_GIFT_NUM_4);
	giftTable["giftNum_5"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_GIFT_NUM_5);
	giftTable["giftNum_6"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_GIFT_NUM_6);
	
	giftTable["giftNumBG_1"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_23);
	giftTable["giftNumBG_2"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_24);
	giftTable["giftNumBG_3"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_25);
	giftTable["giftNumBG_4"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_26);
	giftTable["giftNumBG_5"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_27);
	giftTable["giftNumBG_6"] = GetImage(p.layer,ui.ID_CTRL_PICTURE_28);
	
	giftTable["giftName_1"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_1);
	giftTable["giftName_2"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_2);
	giftTable["giftName_3"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_3);
	giftTable["giftName_4"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_4);
	giftTable["giftName_5"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_5);
	giftTable["giftName_6"] = GetLabel(p.layer,ui.ID_CTRL_TEXT_6);
	


	local itemInfoTable = nil;
	local cardTable = nil;
	for i = 1, 6 do
		itemId = tonumber(self.gift["Reward_id"..i]);
		WriteCon("itemId==="..itemId);
		itemNum = tostring(self.gift["Reward_num"..i]);
		WriteCon("itemNum==="..itemNum);
		local giftType = tonumber(self.gift["Reward_type"..i]);
		--[[
		if giftType == 1 then		--卡片
			itemInfoTable = SelectRowInner(T_CARD,"id",itemId);
			giftTable["giftName_"..i]:SetText(itemInfoTable.name);
			
			cardTable = SelectRowInner(T_CHAR_RES,"card_id",itemId);
			giftTable["giftPic_"..i]:SetPicture( GetPictureByAni(cardTable.head_pic, 0) );
		elseif giftType == 2 then	--物品
			itemInfoTable = SelectRowInner(T_ITEM,"id",itemId);
			giftTable["giftName_"..i]:SetText(itemInfoTable.name);
			giftTable["giftPic_"..i]:SetPicture( GetPictureByAni(itemInfoTable.item_pic, 0) );
			giftTable["giftNumBG_"..i]:SetPicture( GetPictureByAni("common_ui.levelBg", 0) );
			giftTable["giftNum_"..i]:SetText(itemNum);
		elseif giftType == 3 then	--元宝
			itemInfoTable = SelectRowInner(T_MONEY,"id",1);
			giftTable["giftName_"..i]:SetText(itemInfoTable.name);
			giftTable["giftPic_"..i]:SetPicture( GetPictureByAni(itemInfoTable.item_pic, 0) );
			giftTable["giftNumBG_"..i]:SetPicture( GetPictureByAni("common_ui.levelBg", 0) );
			giftTable["giftNum_"..i]:SetText(itemNum);
		elseif giftType == 4 then	--金币
			itemInfoTable = SelectRowInner(T_MONEY,"id",2);
			giftTable["giftName_"..i]:SetText(itemInfoTable.name);
			giftTable["giftPic_"..i]:SetPicture( GetPictureByAni(itemInfoTable.item_pic, 0) );
			giftTable["giftNumBG_"..i]:SetPicture( GetPictureByAni("common_ui.levelBg", 0) );
			giftTable["giftNum_"..i]:SetText(itemNum);
		elseif giftType == 5 then	--装备
			itemInfoTable = SelectRowInner(T_EQUIP,"id",itemId);
			giftTable["giftName_"..i]:SetText(itemInfoTable.name);
			giftTable["giftPic_"..i]:SetPicture( GetPictureByAni(itemInfoTable.item_pic, 0) );
		end
		--]]
		local itemname = GetItemName( itemId, giftType );
		local picData = GetItemPic( itemId, giftType );
		giftTable["giftName_"..i]:SetText( itemname );
		giftTable["giftPic_"..i]:SetPicture( picData );
		
		if tonumber(itemNum) >= 1 then
			giftTable["giftNum_"..i]:SetText(itemNum);
			giftTable["giftNumBG_"..i]:SetPicture( GetPictureByAni("common_ui.levelBg", 0) );
		end
	end
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
    end
end
