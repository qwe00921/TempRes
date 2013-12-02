card_equip_select_list = {}
local p = card_equip_select_list;

local ui = ui_card_equip_select_list;
local packLimit = 100; --获取玩家背包格子数量
p.layer = nil;
p.curBtnNode = nil;
--p.itemUsedId = nil;

function p.ShowUI()
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
    LoadDlg("card_equip_select_list.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
	
	--加载背包数据
   -- pack_box_mgr.LoadAllItem( p.layer );
	--p.ShowItemList( itemList )
end

--主界面设置事件处理
function p.SetDelegate(layer)
	local returnBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	returnBtn:SetLuaDelegate(p.OnUIClickEvent);
	--整理,暂时去掉
	--local sortBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SORT);
	--sortBtn:SetVisible(false);
	--sortBtn:SetLuaDelegate(p.OnUIClickEvent);

	local useBtn = GetButton(layer, ui.ID_CTRL_BUTTON_USE);
	useBtn:SetVisible(false);
	
	local allItemBtn = GetButton(layer, ui.ID_CTRL_BUTTON_ITEM1);
	allItemBtn:SetLuaDelegate(p.OnUIClickEvent);

	local debrisItemBtn = GetButton(layer, ui.ID_CTRL_BUTTON_ITEM2);
	debrisItemBtn:SetLuaDelegate(p.OnUIClickEvent);

	local equipItemBtn = GetButton(layer, ui.ID_CTRL_BUTTON_TIEM3);
	equipItemBtn:SetLuaDelegate(p.OnUIClickEvent);

	local otherItemBtn = GetButton(layer, ui.ID_CTRL_BUTTON_ITEM4);
	otherItemBtn:SetLuaDelegate(p.OnUIClickEvent);
	--隐藏装备分类按钮
	p.HideEquipTypeBtn();
end

--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			p.CloseUI();
			--maininterface.CloseAllPanel();
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
			pack_box_mgr.ShowItemByType(1);
		elseif(ui.ID_CTRL_BUTTON_TIEM3 == tag) then --装备
			WriteCon("=====equipItemBtn");
			p.SetBtnCheckedFX( uiNode );
			--显示所有装备  和 4个按钮
			p.ShowEquipTypeBtn();
			pack_box_mgr.ShowItemByType(2);
		elseif(ui.ID_CTRL_BUTTON_ITEM4 == tag) then --其他
			WriteCon("=====otherItemBtn");
			p.SetBtnCheckedFX( uiNode );
			p.HideEquipTypeBtn();
			pack_box_mgr.ShowItemByType(3);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB1 == tag) then --装备全部
			WriteCon("=====allEquipBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(2);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB2 == tag) then --装备武器
			WriteCon("=====armsBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(4);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB3 == tag) then --装备防具
			WriteCon("=====armorBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(5);
		elseif(ui.ID_CTRL_BUTTON_ITEM_SUB4 == tag) then --装备鞋子
			WriteCon("=====shoesBtn");
			p.SetBtnCheckedFX( uiNode );
			pack_box_mgr.ShowItemByType(6);
		end
	end
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
end


--显示物品列表
function p.ShowItemList(itemList)
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_ITEM);
	list:ClearView();
	
	local itemCountText = GetLabel(p.layer,ui.ID_CTRL_TEXT_COUNT );

	if itemList == nil or #itemList <= 0 then
		local countText = "0/"..packLimit;
		itemCountText:SetText(ToUtf8(countText));
		
		WriteCon("ShowItemList():itemList is null");
		return
	end
	WriteCon("itemCount ===== "..#itemList);
	local itemNum = #itemList;
	
	local countText = itemNum.."/"..packLimit;
	itemCountText:SetText(ToUtf8(countText));
		
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

--单个物品显示
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
	--显示物品图片
	local itemButton = GetButton(view, itemBtn);
	local item_id = tonumber(item.Item_id);
	WriteCon("item_id == "..item_id);
	local aniIndex = "item.itemPic_"..item_id;
    itemButton:SetImage( GetPictureByAni(aniIndex,0) );
    itemButton:SetId(item_id);
	
	--显示物品名字
	local itemNameText = GetLabel(view,itemName );
	local itemTable = SelectRowList(T_ITEM,"item_id",item_id);
	if #itemTable == 1 then
		local text = itemTable[1].item_name;
		itemNameText:SetText(ToUtf8(text));
	else
		WriteConErr("itemTable error ");
	end
	
	local itemNumText = GetLabel(view,itemNum );	--物品数量
	local equipStarPic = GetImage(view,equipStarPic);	--装备星级
	local equipLevelText = GetLabel(view,equipLevel);	--装备等级
	local isUsePic = GetImage(view,isUse);			--是否装备
	itemNumText:SetVisible( false );
	equipStarPic:SetVisible( false );
	equipLevelText:SetVisible( false );
	isUsePic:SetVisible( false );

	local itemType = tonumber(item.Item_type)
	WriteCon("itemType == "..itemType);

	if itemType == 1 or itemType == 2 or itemType == 3 then
	--普通可叠加物品，显示数量
		itemNumText:SetVisible(true);
		itemNumText:SetText(ToUtf8(item.Num));
	elseif itemType == 5 or itemType == 6 then 
		--装备，显示星级
		equipStarPic:SetVisible(true);
		local starNum = tonumber(item.Rare);
		starNum = starNum -1;
		equipStarPic:SetPicture( GetPictureByAni("item.equipStar", starNum) );
		--显示装备等级
		equipLevelText:SetVisible(true);
		equipLevelText:SetText(ToUtf8(item.Equip_level));
		
		--是否装备
		if item.Is_dress == 1 or item.Is_dress == "1" then
			isUsePic:SetVisible(true);
			isUsePic:SetPicture( GetPictureByAni("item.equipUse", 0) );
		end
	end
	
	--设置物品按钮事件
	itemButton:SetLuaDelegate(p.OnItemClickEvent);

end

--点击物品事件
function p.OnItemClickEvent(uiNode, uiEventType, param)
	local itemId = uiNode:GetId();
	WriteCon("Use itemId = "..itemId);
	--p.itemUsedId = itemId;
	
	local itemDescribeText = GetLabel(p.layer,ui.ID_CTRL_TEXT_ITEM_INFO );
	local itemData = SelectRowList(T_ITEM,"item_id",itemId);
	if #itemData == 1 then
		local text = itemData[1].describe;
		itemDescribeText:SetText(ToUtf8(text));
	else
		WriteConErr("itemTable error ");
	end
	
	local useBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_USE);
	useBtn:SetLuaDelegate(p.OnUseItemClickEvent);
	useBtn:SetVisible(true);
	useBtn:SetId(itemId);
end

--点击使用物品事件
function p.OnUseItemClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_USE == tag) then --使用
			local useBtnId = uiNode:GetId();
			if useBtnId == 0 or useBtnId == nil then
				WriteConErr("used Button id error ");
				return
			end
			WriteCon("useBtn == "..useBtnId);
			pack_box_mgr.UseItemEvent(useBtnId);
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
        pack_box_mgr.ClearData();
    end
end


