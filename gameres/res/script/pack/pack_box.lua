ITEM_TYPE_TOOL = 1000;	--0
ITEM_TYPE_EQUIP = 1001;	--123
ITEM_TYPE_OTHER = 1002;	--56
ITEM_TYPE_EQUIP_1 = 1003;	--1
ITEM_TYPE_EQUIP_2 = 1004;	--2
ITEM_TYPE_EQUIP_3 = 1005;	--3

pack_box = {}
local p = pack_box;
local ui = ui_bag_main;
local ui_list = ui_bag_list;
local packLimit = nil; --获取玩家背包格子数量
p.layer = nil;
p.curBtnNode = nil;
p.allItemNumber = nil;
p.itemBtnNode = nil;

function p.ShowUI()
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		PlayMusic_ShopUI();
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
	p.Init();
	PlayMusic_ShopUI();
end

function p.Init()
	dlg_menu.SetNewUI( p );
	packLimit = msg_cache.msg_player.Storage
	WriteCon("packLimit========="..packLimit);
	--加载背包数据
    pack_box_mgr.LoadAllItem( p.layer );
end

--主界面设置事件处理
function p.SetDelegate(layer)
	--整理,暂时去掉
	local sortBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SORT);
	sortBtn:SetVisible(false);
	--sortBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local returnBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	returnBtn:SetLuaDelegate(p.OnUIClickEvent);

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
	--隐藏装备分类按钮
	p.HideEquipTypeBtn();
end

function p.ShowEquipTypeBtn()
	--装备全部
	local allEquipBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB1);
	allEquipBtn:SetLuaDelegate(p.OnUIClickEvent);
	allEquipBtn:SetVisible( true );
	--装备武器
	local armsBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB2);
	armsBtn:SetLuaDelegate(p.OnUIClickEvent);
	armsBtn:SetVisible( true );
	--装备防具
	local armorBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB3);
	armorBtn:SetLuaDelegate(p.OnUIClickEvent);
	armorBtn:SetVisible( true );
	--装备鞋子
	local shoesBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB4);
	shoesBtn:SetLuaDelegate(p.OnUIClickEvent);
	shoesBtn:SetVisible( true );
	
	local TextPic1 = GetImage(p.layer,ui.ID_CTRL_PICTURE_22);
	local TextPic2 = GetImage(p.layer,ui.ID_CTRL_PICTURE_23);
	local TextPic3 = GetImage(p.layer,ui.ID_CTRL_PICTURE_24);
	local TextPic4 = GetImage(p.layer,ui.ID_CTRL_PICTURE_25);
	TextPic1:SetVisible( true );
	TextPic2:SetVisible( true );
	TextPic3:SetVisible( true );
	TextPic4:SetVisible( true );
end

function p.HideEquipTypeBtn()
	--装备全部
	local allEquipBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB1);
	allEquipBtn:SetLuaDelegate(p.OnUIClickEvent);
	allEquipBtn:SetVisible( false );
	--装备武器
	local armsBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB2);
	armsBtn:SetLuaDelegate(p.OnUIClickEvent);
	armsBtn:SetVisible( false );
	--装备防具
	local armorBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB3);
	armorBtn:SetLuaDelegate(p.OnUIClickEvent);
	armorBtn:SetVisible( false );
	--装备鞋子
	local shoesBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ITEM_SUB4);
	shoesBtn:SetLuaDelegate(p.OnUIClickEvent);
	shoesBtn:SetVisible( false );
	
	local TextPic1 = GetImage(p.layer,ui.ID_CTRL_PICTURE_22);
	local TextPic2 = GetImage(p.layer,ui.ID_CTRL_PICTURE_23);
	local TextPic3 = GetImage(p.layer,ui.ID_CTRL_PICTURE_24);
	local TextPic4 = GetImage(p.layer,ui.ID_CTRL_PICTURE_25);
	TextPic1:SetVisible( false );
	TextPic2:SetVisible( false );
	TextPic3:SetVisible( false );
	TextPic4:SetVisible( false );
end

--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			pack_box_equip.CloseUI();
			p.CloseUI();
			maininterface.BecomeFirstUI();
			maininterface.CloseAllPanel();
		--elseif(ui.ID_CTRL_BUTTON_SORT == tag) then --整理
		elseif(ui.ID_CTRL_BUTTON_ITEM1 == tag) then --全部
			WriteCon("=====allItemBtn");
			p.SetBtnCheckedFX( uiNode );
			p.HideEquipTypeBtn();
			pack_box_mgr.ShowAllItems();
		elseif(ui.ID_CTRL_BUTTON_ITEM2 == tag) then --道具
			WriteCon("=====debrisItemBtn");
			p.SetBtnCheckedFX( uiNode );
			p.HideEquipTypeBtn();
			pack_box_mgr.ShowItemByType(ITEM_TYPE_TOOL);
		elseif(ui.ID_CTRL_BUTTON_TIEM3 == tag) then --装备
			WriteCon("=====equipItemBtn");
			p.SetBtnCheckedFX( uiNode );
			--显示所有装备  和 4个按钮
			p.ShowEquipTypeBtn();
			pack_box_mgr.ShowItemByType(ITEM_TYPE_EQUIP);
		elseif(ui.ID_CTRL_BUTTON_ITEM4 == tag) then --其他
			WriteCon("=====otherItemBtn");
			p.SetBtnCheckedFX( uiNode );
			p.HideEquipTypeBtn();
			pack_box_mgr.ShowItemByType(ITEM_TYPE_OTHER);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB1 == tag) then --装备全部
			WriteCon("=====allEquipBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(ITEM_TYPE_EQUIP);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB2 == tag) then --装备武器
			WriteCon("=====armsBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(ITEM_TYPE_EQUIP_1);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB3 == tag) then --装备防具
			WriteCon("=====armorBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(ITEM_TYPE_EQUIP_2);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB4 == tag) then --装备鞋子
			WriteCon("=====shoesBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(ITEM_TYPE_EQUIP_3);
		end
	end
end

-- 显示物品列表
function p.ShowItemList(itemList)
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_ITEM);
	list:ClearView();

	local itemCountText = GetLabel(p.layer,ui.ID_CTRL_TEXT_COUNT );
	local itemNum = nil;
	if itemList == nil or #itemList <= 0 then
		if p.allItemNumber == nil or p.allItemNumber == 0 then
			local countText = "0/"..packLimit;
			itemCountText:SetText(countText);
		end
		WriteCon("ShowItemList():itemList is null");
		return
	else
		itemNum = #itemList;
		WriteCon("itemNum ===== "..itemNum);
		if p.allItemNumber == nil or p.allItemNumber == 0 then
			p.allItemNumber = itemNum;
			local countText = itemNum.."/"..packLimit;
			itemCountText:SetText(countText);
		end
	end

	local row = math.ceil(itemNum / 5);
	
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("bag_list.xui",view,nil);
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
		local row_index = i;
		local start_index = (row_index-1)*5+1
        local end_index = start_index + 4;

		--设置列表项信息，一行4个道具
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

function p.ShowItemInfo( view, item, itemIndex )
    local itemBtn = nil;
    local itemNum = nil;
    local itemName = nil;
	local equipStarPic = nil;
	local subTitleBg = nil;
    local isUse = nil;
	
	if itemIndex == 1 then
        itemBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
        itemNum = ui_list.ID_CTRL_TEXT_ITEMNUM1;
		equipLevel = ui_list.ID_CTRL_TEXT_EQUIP_LEV1
        isUse = ui_list.ID_CTRL_PICTURE_EQUIP1;
		boxFrame = ui_list.ID_CTRL_PICTURE_91;
		numBg = ui_list.ID_CTRL_PICTURE_NUM_BG1;
		--subTitleBg = ui_list.ID_CTRL_PICTURE_22;
        --itemName = ui_list.ID_CTRL_TEXT_ITEMNAME1;
		--equipStarPic = ui_list.ID_CTRL_PICTURE_STAR1;
	elseif itemIndex == 2 then
        itemBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
        itemNum = ui_list.ID_CTRL_TEXT_ITEMNUM2;
		equipLevel = ui_list.ID_CTRL_TEXT_EQUIP_LEV2
        isUse = ui_list.ID_CTRL_PICTURE_EQUIP2;
		boxFrame = ui_list.ID_CTRL_PICTURE_92;
		numBg = ui_list.ID_CTRL_PICTURE_NUM_BG2;
		--subTitleBg = ui_list.ID_CTRL_PICTURE_23;
        --itemName = ui_list.ID_CTRL_TEXT_ITEMNAME2;
		--equipStarPic = ui_list.ID_CTRL_PICTURE_STAR2;
	elseif itemIndex == 3 then
        itemBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
        itemNum = ui_list.ID_CTRL_TEXT_ITEMNUM3;
		equipLevel = ui_list.ID_CTRL_TEXT_EQUIP_LEV3
        isUse = ui_list.ID_CTRL_PICTURE_EQUIP3;
		boxFrame = ui_list.ID_CTRL_PICTURE_93;
		numBg = ui_list.ID_CTRL_PICTURE_NUM_BG3;
		--subTitleBg = ui_list.ID_CTRL_PICTURE_24;
        --itemName = ui_list.ID_CTRL_TEXT_ITEMNAME3;
		--equipStarPic = ui_list.ID_CTRL_PICTURE_STAR3;
	elseif itemIndex == 4 then
        itemBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
        itemNum = ui_list.ID_CTRL_TEXT_ITEMNUM4;

		equipLevel = ui_list.ID_CTRL_TEXT_EQUIP_LEV4
        isUse = ui_list.ID_CTRL_PICTURE_EQUIP4;
		boxFrame = ui_list.ID_CTRL_PICTURE_94;
		numBg = ui_list.ID_CTRL_PICTURE_NUM_BG4;
		--subTitleBg = ui_list.ID_CTRL_PICTURE_25;
        --itemName = ui_list.ID_CTRL_TEXT_ITEMNAME4;
		--equipStarPic = ui_list.ID_CTRL_PICTURE_STAR4;
	elseif itemIndex == 5 then
        itemBtn = ui_list.ID_CTRL_BUTTON_ITEM5;
		boxFrame = ui_list.ID_CTRL_PICTURE_95;
		numBg = ui_list.ID_CTRL_PICTURE_NUM_BG5;
        itemNum = ui_list.ID_CTRL_TEXT_ITEMNUM5;
        isUse = ui_list.ID_CTRL_PICTURE_EQUIP5;
		equipLevel = ui_list.ID_CTRL_TEXT_EQUIP_LEV5
	end
	--显示边框
	local boxFramePic = GetImage(view,boxFrame);
	boxFramePic:SetPicture( GetPictureByAni("common_ui.frame", 0) );
	--显示名字背景图片
	--local subTitleBgPic = GetImage(view,subTitleBg);
	--subTitleBgPic:SetPicture( GetPictureByAni("common_ui.levelBg", 0) );

	local item_id = tonumber(item.Item_id);
	local itemType = tonumber(item.Item_type);
	local itemUniqueId = tonumber(item.id);
	local itemTable = nil;
	if itemType == 1 or  itemType == 2 or itemType == 3 then
		itemTable = SelectRowInner(T_EQUIP,"id",item_id);
	elseif itemType == 0 or itemType == 4 or itemType == 5 or itemType == 6 then
		itemTable = SelectRowInner(T_ITEM,"id",item_id);
	end
	if itemTable == nil then
		WriteConErr("itemTable error ");
	end

	--显示物品图片
	local itemButton = GetButton(view, itemBtn);
    itemButton:SetImage( GetPictureByAni(itemTable.item_pic,0) );
	itemButton:SetId(item_id);
    itemButton:SetUID(itemUniqueId);
	itemButton:SetXID(itemType);
	
	--物品名字
	--local itemNameText = GetLabel(view,itemName );
	--itemNameText:SetText(itemTable.name);
	
	local itemNumText = GetLabel(view,itemNum );	--物品数量
	--local equipStarPic = GetImage(view,equipStarPic);	--装备星级
	local equipLevelText = GetLabel(view,equipLevel);	--装备等级
	local isUsePic = GetImage(view,isUse);			--是否装备
	itemNumText:SetVisible( false );
	--equipStarPic:SetVisible( false );
	equipLevelText:SetVisible( false );
	isUsePic:SetVisible( false );

	if itemType == 0 or itemType == 4 or itemType == 5 or itemType == 6 then
	--普通可叠加物品，显示数量
		itemNumText:SetVisible(true);
		itemNumText:SetText("X "..item.Num);
	--显示数量背景
		local numBgPic = GetImage(view,numBg);
		numBgPic:SetPicture( GetPictureByAni("common_ui.levelBg", 0) );
	elseif itemType == 1 or itemType == 2 or itemType == 3 then 
		--装备，显示星级
		-- equipStarPic:SetVisible(true);
		-- local starNum = tonumber(item.Rare);
		-- if starNum == 0 then
			-- equipStarPic:SetVisible(false);
		-- else
			-- equipStarPic:SetPicture( GetPictureByAni("common_ui.equipStar", starNum) );
		-- end
		--显示装备等级
		equipLevelText:SetVisible(true);
		equipLevelText:SetText("LV"..item.Equip_level);
		--是否装备
		if item.Is_dress == 1 or item.Is_dress == "1" then
			isUsePic:SetVisible(true);
			isUsePic:SetPicture( GetPictureByAni("common_ui.equipUse", 0) );
		end
	end
	
	--使用按钮
	local useBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_USE);
	useBtn:SetVisible(false);
	local useTextPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_26);
	useTextPic:SetVisible(false);
	local itemDescribeText = GetLabel(p.layer,ui.ID_CTRL_TEXT_ITEM_INFO );
	itemDescribeText:SetText(" ");
	
	--设置物品按钮事件
	itemButton:SetLuaDelegate(p.OnItemClickEvent);
end

--点击物品事件
function p.OnItemClickEvent(uiNode, uiEventType, param)
	local itemId = uiNode:GetId();
	local itemUniqueId = uiNode:GetUID();
	local itemType = uiNode:GetXID();

	if itemType == 1 or itemType == 2 or itemType == 3 then
		pack_box_equip.ShowEquip(itemId,itemUniqueId,itemType);
		local useBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_USE);
		useBtn:SetVisible(false);
		local useTextPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_26);
		useTextPic:SetVisible(false);
		local itemDescribeText = GetLabel(p.layer,ui.ID_CTRL_TEXT_ITEM_INFO );
		itemDescribeText:SetText(" ");
	else
		local itemDescribeText = GetLabel(p.layer,ui.ID_CTRL_TEXT_ITEM_INFO );
		local itemData = SelectRowInner(T_ITEM,"id",itemId);
		if itemData == nil then
			WriteConErr("itemTable error ");
		end
		itemDescribeText:SetText(itemData.description);
	
		local useBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_USE);
		useBtn:SetLuaDelegate(p.OnUseItemClickEvent);
		useBtn:SetVisible(true);
		useBtn:SetId(itemId);
		useBtn:SetUID(itemUniqueId);
		useBtn:SetXID(itemType);
		
		local useTextPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_26);
		useTextPic:SetVisible(true);
	end
	p.SetItemChechedFX(uiNode);
end

--设置选中物品
function p.SetItemChechedFX(uiNode)
	local itemNode = ConverToButton( uiNode );
	if p.itemBtnNode ~= nil then
		p.itemBtnNode:RemoveAllChildren(true);
	end
	p.ShowSelectEffect(itemNode)
	p.itemBtnNode = itemNode;
end

function p.ShowSelectEffect(uiNode)
	local view = createNDUIXView();
	view:Init();
	LoadUI("bag_item_select.xui",view,nil);
	local bg = GetUiNode( view, ui_bag_item_select.ID_CTRL_PICTURE_1);
	view:SetViewSize( bg:GetFrameSize());
	view:SetTag(ui_bag_item_select.ID_CTRL_PICTURE_1);
	uiNode:AddChild( view );
end

--点击使用物品事件
function p.OnUseItemClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_USE == tag) then --使用
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

--设置选中按钮
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
		p.Clear();
    end
end

function p.Clear()
	p.curBtnNode = nil;
	p.allItemNumber = nil;
	p.itemBtnNode = nil;
	pack_box_mgr.ClearData();
end

function p.UIDisappear()
	p.CloseUI();
end
