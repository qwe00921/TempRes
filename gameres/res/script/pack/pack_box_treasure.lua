pack_box_treasure = {}
local p = pack_box_treasure;

local ui = ui_bag_treasure_view;
p.layer = nil;

function p.ShowTreasureView(self)
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
	
	GetUIRoot():AddDlg(layer);
    LoadDlg("bag_treasure_view.xui", layer, nil);

    p.layer = layer;
	p.SetDelegate(layer);
	
	p.ShowTreasureInfo(self)
end

function p.SetDelegate(layer)
	local OKBtn = GetButton(layer, ui.ID_CTRL_BUTTON_OK);
	OKBtn:SetLuaDelegate(p.OnUIClickEvent);
end

--�¼�����
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_OK == tag) then --�ر�
			WriteCon("ȷ��");
			p.CloseUI();
			--SendReq("Item","List",uid,"");
			pack_box.CloseUI();
			pack_box.ShowUI();
		end
	end
end

function p.ShowTreasureInfo(self)
	WriteCon("ShowTreasureInfo=========OK");
	local itemType = tonumber(self.treasure.Reward_type);
	local itemId = tonumber(self.treasure.Reward_id);
	local itemNumber = tonumber(self.treasure.Reward_num);
	
	local treasureBoxText = GetLabel(p.layer, ui.ID_CTRL_TEXT_76);
	treasureBoxText:SetText(ToUtf8("��ϲ�����򿪱�����������Ʒ��"));
	
	local treasureNum = GetLabel(p.layer,ui.ID_CTRL_TEXT_ITEM_NUM);
	treasureNum:SetText(ToUtf8(tostring(itemNumber)));
	
	local treasureName = GetLabel(p.layer,ui.ID_CTRL_TEXT_ITEM_NAME);
	local treasurePic = GetImage(p.layer,ui.ID_CTRL_PICTURE_ITEM);
	
	if itemType == 1 then		--��Ƭ
		itemInfoTable = SelectRowInner(T_CARD,"id",itemId);
		treasureName:SetText(ToUtf8(itemInfoTable.name));
		
		cardTable = SelectRowInner(T_CHAR_RES,"card_id",itemId);
		treasurePic:SetPicture( GetPictureByAni(cardTable.card_pic, 0) );
	elseif itemType == 2 then	--��Ʒ
		itemInfoTable = SelectRowInner(T_ITEM,"id",itemId);
		treasureName:SetText(ToUtf8(itemInfoTable.name));
		treasurePic:SetPicture( GetPictureByAni(itemInfoTable.item_pic, 0) );
	elseif itemType == 3 then	--Ԫ��
		itemInfoTable = SelectRowInner(T_ITEM,"id",1);
		treasureName:SetText(ToUtf8(itemInfoTable.name));
		treasurePic:SetPicture( GetPictureByAni(itemInfoTable.item_pic, 0) );
	elseif itemType == 4 then	--���
		itemInfoTable = SelectRowInner(T_ITEM,"id",2);
		treasureName:SetText(ToUtf8(itemInfoTable.name));
		treasurePic:SetPicture( GetPictureByAni(itemInfoTable.item_pic, 0) );
	end
end


--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
		
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end