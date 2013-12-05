ITEM_TYPE_TOOL = 1000;	--0
ITEM_TYPE_EQUIP = 1001;	--123
ITEM_TYPE_OTHER = 1002;	--56
ITEM_TYPE_EQUIP_1 = 1003;	--1
ITEM_TYPE_EQUIP_2 = 1004;	--2
ITEM_TYPE_EQUIP_3 = 1005;	--3

pack_box = {}
local p = pack_box;

local ui = ui_bag_main;
local packLimit = nil; --��ȡ��ұ�����������
p.allItemNumber = nil;
p.layer = nil;
p.curBtnNode = nil;
--p.itemUsedId = nil;

function p.ShowUI()
	packLimit = msg_cache.msg_player.Storage
	WriteCon("packLimit========="..packLimit);

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
    LoadDlg("bag_main.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
	
	--���ر�������
    pack_box_mgr.LoadAllItem( p.layer );
end

--�����������¼�����
function p.SetDelegate(layer)
	local returnBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	returnBtn:SetLuaDelegate(p.OnUIClickEvent);
	--����,��ʱȥ��
	local sortBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SORT);
	sortBtn:SetVisible(false);
	--sortBtn:SetLuaDelegate(p.OnUIClickEvent);

	local useBtn = GetButton(layer, ui.ID_CTRL_BUTTON_USE);
	useBtn:SetVisible(false);
	
	local allItemBtn = GetButton(layer, ui.ID_CTRL_BUTTON_ITEM1);
	allItemBtn:SetLuaDelegate(p.OnUIClickEvent);
	p.SetBtnCheckedFX( allItemBtn )
	
	local debrisItemBtn = GetButton(layer, ui.ID_CTRL_BUTTON_ITEM2);
	debrisItemBtn:SetLuaDelegate(p.OnUIClickEvent);

	local equipItemBtn = GetButton(layer, ui.ID_CTRL_BUTTON_TIEM3);
	equipItemBtn:SetLuaDelegate(p.OnUIClickEvent);

	local otherItemBtn = GetButton(layer, ui.ID_CTRL_BUTTON_ITEM4);
	otherItemBtn:SetLuaDelegate(p.OnUIClickEvent);
	--����װ�����ఴť
	p.HideEquipTypeBtn();
end

--�¼�����
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --����
			pack_box_equip.CloseUI();
			p.CloseUI();
			maininterface.BecomeFirstUI();
			maininterface.CloseAllPanel();
		--elseif(ui.ID_CTRL_BUTTON_SORT == tag) then --����
		elseif(ui.ID_CTRL_BUTTON_ITEM1 == tag) then --ȫ��
			WriteCon("=====allItemBtn");
			p.SetBtnCheckedFX( uiNode );
			p.HideEquipTypeBtn();
			pack_box_mgr.ShowAllItems();
		elseif(ui.ID_CTRL_BUTTON_ITEM2 == tag) then --����
			WriteCon("=====debrisItemBtn");
			p.SetBtnCheckedFX( uiNode );
			p.HideEquipTypeBtn();
			pack_box_mgr.ShowItemByType(ITEM_TYPE_TOOL);
		elseif(ui.ID_CTRL_BUTTON_TIEM3 == tag) then --װ��
			WriteCon("=====equipItemBtn");
			p.SetBtnCheckedFX( uiNode );
			--��ʾ����װ��  �� 4����ť
			p.ShowEquipTypeBtn();
			pack_box_mgr.ShowItemByType(ITEM_TYPE_EQUIP);
		elseif(ui.ID_CTRL_BUTTON_ITEM4 == tag) then --����
			WriteCon("=====otherItemBtn");
			p.SetBtnCheckedFX( uiNode );
			p.HideEquipTypeBtn();
			pack_box_mgr.ShowItemByType(ITEM_TYPE_OTHER);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB1 == tag) then --װ��ȫ��
			WriteCon("=====allEquipBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(ITEM_TYPE_EQUIP);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB2 == tag) then --װ������
			WriteCon("=====armsBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(ITEM_TYPE_EQUIP_1);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB3 == tag) then --װ������
			WriteCon("=====armorBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(ITEM_TYPE_EQUIP_2);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB4 == tag) then --װ��Ь��
			WriteCon("=====shoesBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(ITEM_TYPE_EQUIP_3);
		end
	end
end

function p.ShowEquipTypeBtn()
	--װ��ȫ��
	local allEquipBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB1);
	allEquipBtn:SetLuaDelegate(p.OnUIClickEvent);
	allEquipBtn:SetVisible( true );
	--װ������
	local armsBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB2);
	armsBtn:SetLuaDelegate(p.OnUIClickEvent);
	armsBtn:SetVisible( true );
	--װ������
	local armorBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB3);
	armorBtn:SetLuaDelegate(p.OnUIClickEvent);
	armorBtn:SetVisible( true );
	--װ��Ь��
	local shoesBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB4);
	shoesBtn:SetLuaDelegate(p.OnUIClickEvent);
	shoesBtn:SetVisible( true );
end

function p.HideEquipTypeBtn()
	--װ��ȫ��
	local allEquipBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB1);
	allEquipBtn:SetLuaDelegate(p.OnUIClickEvent);
	allEquipBtn:SetVisible( false );
	--װ������
	local armsBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB2);
	armsBtn:SetLuaDelegate(p.OnUIClickEvent);
	armsBtn:SetVisible( false );
	--װ������
	local armorBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB3);
	armorBtn:SetLuaDelegate(p.OnUIClickEvent);
	armorBtn:SetVisible( false );
	--װ��Ь��
	local shoesBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB4);
	shoesBtn:SetLuaDelegate(p.OnUIClickEvent);
	shoesBtn:SetVisible( false );
end


--��ʾ��Ʒ�б�
function p.ShowItemList(itemList)
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_ITEM);
	list:ClearView();
	
	local itemCountText = GetLabel(p.layer,ui.ID_CTRL_TEXT_COUNT );
	local itemNum = nil;
	if itemList == nil or #itemList <= 0 then
		if p.allItemNumber == nil or p.allItemNumber == 0 then
			local countText = "0/"..packLimit;
			itemCountText:SetText(ToUtf8(countText));
		end
		WriteCon("ShowItemList():itemList is null");
		return
	else
		itemNum = #itemList;
		WriteCon("itemCount ===== "..itemNum);
		if p.allItemNumber == nil or p.allItemNumber == 0 then
			p.allItemNumber = itemNum;
			local countText = itemNum.."/"..packLimit;
			itemCountText:SetText(ToUtf8(countText));
		end
	end
		
	local row = math.ceil(itemNum / 4);
	WriteCon("row ===== "..row);
	
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("bag_list.xui",view,nil);
		local bg = GetUiNode( view, ui_bag_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
		local row_index = i;
		local start_index = (row_index-1)*4+1
        local end_index = start_index + 3;

		--�����б�����Ϣ��һ��4������
		for j = start_index,end_index do
			if j <= itemNum then
				local item = itemList[j];
				local itemIndex = j - start_index + 1;
				p.ShowItemInfo( view, item, itemIndex );
			end
		end
		list:AddView( view );
	end
end

--������Ʒ��ʾ
function p.ShowItemInfo( view, item, itemIndex )
    local itemBtn = nil;
    local itemNum = nil;
    local itemName = nil;
	local equipStarPic = nil;
	local subTitleBg = nil;
    local isUse = nil;
	
	if itemIndex == 1 then
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_ITEM1;
        itemNum = ui_bag_list.ID_CTRL_TEXT_ITEMNUM1;
        itemName = ui_bag_list.ID_CTRL_TEXT_ITEMNAME1;
		equipStarPic = ui_bag_list.ID_CTRL_PICTURE_STAR1;
		equipLevel = ui_bag_list.ID_CTRL_TEXT_EQUIP_LEV1
		subTitleBg = ui_bag_list.ID_CTRL_PICTURE_22;
        isUse = ui_bag_list.ID_CTRL_PICTURE_EQUIP1;
	elseif itemIndex == 2 then
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_ITEM2;
        itemNum = ui_bag_list.ID_CTRL_TEXT_ITEMNUM2;
        itemName = ui_bag_list.ID_CTRL_TEXT_ITEMNAME2;
		equipStarPic = ui_bag_list.ID_CTRL_PICTURE_STAR2;
		equipLevel = ui_bag_list.ID_CTRL_TEXT_EQUIP_LEV2
		subTitleBg = ui_bag_list.ID_CTRL_PICTURE_23;
        isUse = ui_bag_list.ID_CTRL_PICTURE_EQUIP2;
	elseif itemIndex == 3 then
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_ITEM3;
        itemNum = ui_bag_list.ID_CTRL_TEXT_ITEMNUM3;
        itemName = ui_bag_list.ID_CTRL_TEXT_ITEMNAME3;
		equipStarPic = ui_bag_list.ID_CTRL_PICTURE_STAR3;
		equipLevel = ui_bag_list.ID_CTRL_TEXT_EQUIP_LEV3
		subTitleBg = ui_bag_list.ID_CTRL_PICTURE_24;
        isUse = ui_bag_list.ID_CTRL_PICTURE_EQUIP3;
	elseif itemIndex == 4 then
        itemBtn = ui_bag_list.ID_CTRL_BUTTON_ITEM4;
        itemNum = ui_bag_list.ID_CTRL_TEXT_ITEMNUM4;
        itemName = ui_bag_list.ID_CTRL_TEXT_ITEMNAME4;
		equipStarPic = ui_bag_list.ID_CTRL_PICTURE_STAR4;
		equipLevel = ui_bag_list.ID_CTRL_TEXT_EQUIP_LEV4
		subTitleBg = ui_bag_list.ID_CTRL_PICTURE_25;
        isUse = ui_bag_list.ID_CTRL_PICTURE_EQUIP4;
	end
	
	local item_id = tonumber(item.Item_id);
	WriteCon("item_id == "..item_id);
	local itemTable = SelectRowInner(T_ITEM,"id",item_id);
	if itemTable == nil then
		WriteConErr("itemTable error ");
	end
	--��ʾ��ƷͼƬ
	local itemButton = GetButton(view, itemBtn);
	local aniIndex = itemTable.item_pic;
    itemButton:SetImage( GetPictureByAni(aniIndex,0) );
	itemButton:SetId(item_id);
	local itemUniqueId = tonumber(item.id);
    itemButton:SetUID(itemUniqueId);
	local itemType = tonumber(item.Item_type);
	itemButton:SetXID(itemType);

	--��ʾ��Ʒ����
	local itemNameText = GetLabel(view,itemName );
	local text = itemTable.name;
	itemNameText:SetText(ToUtf8(text));
	local itemNumText = GetLabel(view,itemNum );	--��Ʒ����
	local equipStarPic = GetImage(view,equipStarPic);	--װ���Ǽ�
	local equipLevelText = GetLabel(view,equipLevel);	--װ���ȼ�
	local isUsePic = GetImage(view,isUse);			--�Ƿ�װ��
	itemNumText:SetVisible( false );
	equipStarPic:SetVisible( false );
	equipLevelText:SetVisible( false );
	isUsePic:SetVisible( false );

	--local itemType = tonumber(item.Item_type)
	WriteCon("itemType == "..itemType);

	if itemType == 0 or itemType == 4 or itemType == 5 or itemType == 6 then
	--��ͨ�ɵ�����Ʒ����ʾ����
		itemNumText:SetVisible(true);
		itemNumText:SetText(ToUtf8(item.Num));
	elseif itemType == 1 or itemType == 2 or itemType == 3 then 
		--װ������ʾ�Ǽ�
		equipStarPic:SetVisible(true);
		local starNum = tonumber(item.Rare);
		starNum = starNum -1;
		equipStarPic:SetPicture( GetPictureByAni("item.equipStar", starNum) );
		--��ʾװ���ȼ�
		equipLevelText:SetVisible(true);
		equipLevelText:SetText(ToUtf8(item.Equip_level));
		
		--�Ƿ�װ��
		if item.Is_dress == 1 or item.Is_dress == "1" then
			isUsePic:SetVisible(true);
			isUsePic:SetPicture( GetPictureByAni("item.equipUse", 0) );
		end
	end
	
	--������Ʒ��ť�¼�
	itemButton:SetLuaDelegate(p.OnItemClickEvent);

end

--�����Ʒ�¼�
function p.OnItemClickEvent(uiNode, uiEventType, param)
	local itemId = uiNode:GetId();
	local itemUniqueId = uiNode:GetUID();
	local itemType = uiNode:GetXID();
	
	if itemType == 1 or itemType == 2 or itemType == 3 then
		pack_box_equip.ShowEquip(itemId,itemUniqueId,itemType);
	else
		local itemDescribeText = GetLabel(p.layer,ui.ID_CTRL_TEXT_ITEM_INFO );
		local itemData = SelectRowList(T_ITEM,"id",itemId);
		if #itemData == 1 then
			local text = itemData[1].description;
			itemDescribeText:SetText(ToUtf8(text));
		else
			WriteConErr("itemTable error ");
		end
	
		local useBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_USE);
		useBtn:SetLuaDelegate(p.OnUseItemClickEvent);
		useBtn:SetVisible(true);
		useBtn:SetId(itemId);
		useBtn:SetUID(itemUniqueId);
		useBtn:SetXID(itemType);
	end
end

--���ʹ����Ʒ�¼�
function p.OnUseItemClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_USE == tag) then --ʹ��
			local itemId = uiNode:GetId();
			local itemUniqueId = uiNode:GetUID();
			local itemType = uiNode:GetXID();
			WriteCon("Use itemId = "..itemId);
			WriteCon("Use itemUniqueId = "..itemUniqueId);
			WriteCon("Use itemType = "..itemType);
			if itemId == 0 or itemId == nil then
				WriteConErr("used Button id error ");
				return
			end
			pack_box_mgr.UseItemEvent(itemId,itemUniqueId,itemType);
		end
	end
	
end

--����ѡ�а�ť
function p.SetBtnCheckedFX( node )
    local btnNode = ConverToButton( node );
    if p.curBtnNode ~= nil then
    	p.curBtnNode:SetChecked( false );
    end
	btnNode:SetChecked( true );
	p.curBtnNode = btnNode;
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
        pack_box_mgr.ClearData();
		p.allItemNumber = nil;
    end
end


