--------------------------------------------------------------
-- FileName:    dlg_back_pack.lua
-- author:      hst, 2013/07/23
-- purpose:     背包主界面
--------------------------------------------------------------

dlg_back_pack = {}
local p = dlg_back_pack;
p.layer = nil;
p.curBtnNode = nil;

function p.ShowUI()
     
    if p.layer ~= nil then
        p.layer:SetVisible( true );
        return ;
    end
    
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
   
    layer:Init();    
    GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_back_pack.xui", layer, nil);

    p.SetDelegate(layer);
    p.layer = layer;

    --加载数据
    back_pack_mgr.LoadAllItem( p.layer );

end

function p.GetLayer() 
    return p.layer; 
end

--设置事件处理
function p.SetDelegate(layer)
    local pBtn01 = GetButton(layer,ui_dlg_back_pack.ID_CTRL_BUTTON_11);
    pBtn01:SetLuaDelegate(p.OnUIEvent);

    local pBtn03 = GetButton(layer,ui_dlg_back_pack.ID_CTRL_BUTTON_2);
    pBtn03:SetLuaDelegate(p.OnUIEvent);

    local pBtn04 = GetButton(layer,ui_dlg_back_pack.ID_CTRL_BUTTON_15);
    pBtn04:SetLuaDelegate(p.OnUIEvent);

    local pBtn05 = GetButton(layer,ui_dlg_back_pack.ID_CTRL_BUTTON_16);
    pBtn05:SetLuaDelegate(p.OnUIEvent);

    local pBtn06 = GetButton(layer,ui_dlg_back_pack.ID_CTRL_BUTTON_17);
    pBtn06:SetLuaDelegate(p.OnUIEvent);

    local pBtn07 = GetButton(layer,ui_dlg_back_pack.ID_CTRL_BUTTON_18);
    pBtn07:SetLuaDelegate(p.OnUIEvent);

    local pBtn08 = GetButton(layer,ui_dlg_back_pack.ID_CTRL_BUTTON_19);
    pBtn08:SetLuaDelegate(p.OnUIEvent);

    local pBtn10 = GetButton(layer,ui_dlg_back_pack.ID_CTRL_BUTTON_21);
    pBtn10:SetLuaDelegate(p.OnUIEvent);

    local pBtn13 = GetButton(layer,ui_dlg_back_pack.ID_CTRL_BUTTON_22);
    pBtn13:SetLuaDelegate(p.OnUIEvent);
end

--事件处理
function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_back_pack.ID_CTRL_BUTTON_22 == tag ) then
            --返回
            p.CloseUI();
            
        elseif ( ui_dlg_back_pack.ID_CTRL_BUTTON_11 == tag ) then
            --WriteCon("扩充");
            
        elseif ( ui_dlg_back_pack.ID_CTRL_BUTTON_2 == tag ) then
            --WriteCon("全部");
            p.SetBtnCheckedFX( uiNode );
            back_pack_mgr.ShowAllItems();

        elseif ( ui_dlg_back_pack.ID_CTRL_BUTTON_15 == tag ) then
            --WriteCon("普通道具");
            p.SetBtnCheckedFX( uiNode );
            back_pack_mgr.LoadItemByType( ITEM_TYPE_1 );

        elseif ( ui_dlg_back_pack.ID_CTRL_BUTTON_21 == tag ) then
            --WriteCon("卷轴");
            p.SetBtnCheckedFX( uiNode );
            back_pack_mgr.LoadItemByType( ITEM_TYPE_2 );

        elseif ( ui_dlg_back_pack.ID_CTRL_BUTTON_16 == tag ) then
            --WriteCon("武器");
            p.SetBtnCheckedFX( uiNode );
            back_pack_mgr.LoadItemByType( ITEM_TYPE_3 );

        elseif ( ui_dlg_back_pack.ID_CTRL_BUTTON_17 == tag ) then
            --WriteCon("防具");
            p.SetBtnCheckedFX( uiNode );
            back_pack_mgr.LoadItemByType( ITEM_TYPE_4 );

        elseif ( ui_dlg_back_pack.ID_CTRL_BUTTON_18 == tag ) then
            --WriteCon("饰品");
            p.SetBtnCheckedFX( uiNode );
            back_pack_mgr.LoadItemByType( ITEM_TYPE_5 );

        elseif ( ui_dlg_back_pack.ID_CTRL_BUTTON_19 == tag ) then
            --WriteCon("整理");
            p.SetBtnCheckedFX( uiNode );
			back_pack_mgr.SortItemList();
        end
    end
end

function p.SetBtnCheckedFX( node )
    local btnNode = ConverToButton( node );
    if p.curBtnNode ~= nil then
        p.curBtnNode:SetChecked( false );
    end
    btnNode:SetChecked( true );
    p.curBtnNode = btnNode;
end

--显示道具列表
function p.ShowItemList( itemList )
    local list = GetListBoxVert(p.layer ,ui_dlg_back_pack.ID_CTRL_VERTICAL_LIST_15);
    list:ClearView();
    
    if itemList == nil or #itemList <= 0 then
        WriteCon("ShowItemList():itemList is null");
        return ;
    end
    --list:SetFramePosXY(-200,100);
    
    local listLenght = #itemList;
    local row = math.ceil(listLenght / 5);

    for i = 1,row do
        local view = createNDUIXView();
        view:Init();
        LoadUI( "back_pack_view.xui", view, nil );
        local bg = GetUiNode( view, ui_back_pack_view.ID_CTRL_PICTURE_25 );
        view:SetViewSize( bg:GetFrameSize());

        local row_index = i;
        local start_index = (row_index-1)*5+1;
        local end_index = start_index + 4;

        --设置列表项信息，一行6个道具
        for j = start_index,end_index do
            if j <= listLenght then
                local item = itemList[j];
                local itemIndex = end_index - j;
                p.ShowItemInfo( view, item, itemIndex );
            end
        end
        list:AddView( view );
    end
end

--单个道具显示
function p.ShowItemInfo( view, item, itemIndex )
    local isUse;
    local itemPic;
    local itemNumber;
    local itemName;
    local subTitleBg;
    if itemIndex == 4 then
        isUse = ui_back_pack_view.ID_CTRL_TEXT_19;
        itemPic = ui_back_pack_view.ID_CTRL_BUTTON_38;
        itemNumber = ui_back_pack_view.ID_CTRL_TEXT_17;
        itemName = ui_back_pack_view.ID_CTRL_TEXT_23;
        subTitleBg = ui_back_pack_view.ID_CTRL_9SLICES_165;
    elseif itemIndex == 3 then
        isUse = ui_back_pack_view.ID_CTRL_TEXT_29;
        itemPic = ui_back_pack_view.ID_CTRL_BUTTON_18;
        itemNumber = ui_back_pack_view.ID_CTRL_TEXT_18;
        itemName = ui_back_pack_view.ID_CTRL_TEXT_25;
        subTitleBg = ui_back_pack_view.ID_CTRL_9SLICES_166;
    elseif itemIndex == 2 then
        isUse = ui_back_pack_view.ID_CTRL_TEXT_30;
        itemPic = ui_back_pack_view.ID_CTRL_BUTTON_19;
        itemNumber = ui_back_pack_view.ID_CTRL_TEXT_20;
        itemName = ui_back_pack_view.ID_CTRL_TEXT_26;
        subTitleBg = ui_back_pack_view.ID_CTRL_9SLICES_167;
    elseif itemIndex == 1 then
        isUse = ui_back_pack_view.ID_CTRL_TEXT_31;
        itemPic = ui_back_pack_view.ID_CTRL_BUTTON_20;
        itemNumber = ui_back_pack_view.ID_CTRL_TEXT_21;
        itemName = ui_back_pack_view.ID_CTRL_TEXT_27;
        subTitleBg = ui_back_pack_view.ID_CTRL_9SLICES_168;
    elseif itemIndex == 0 then
        isUse = ui_back_pack_view.ID_CTRL_TEXT_32;
        itemPic = ui_back_pack_view.ID_CTRL_BUTTON_21;
        itemNumber = ui_back_pack_view.ID_CTRL_TEXT_22;
        itemName = ui_back_pack_view.ID_CTRL_TEXT_28;
        subTitleBg = ui_back_pack_view.ID_CTRL_9SLICES_169;
    end
	
	local itemType = tonumber( item.type );
	if itemType == ITEM_TYPE_3 or itemType == ITEM_TYPE_4 or itemType == ITEM_TYPE_5 then
		--是否己装备
	    local isUseNode = GetLabel( view, isUse );
	    if tonumber( item.card_id ) == 0 then
	        isUseNode:SetText( GetStr( "item_unused" ) );
	    else
	        isUseNode:SetText( GetStr( "item_used" ) );	
	    end
	else
	    local subTitleBgNode = Get9SlicesImage( view, subTitleBg );
	    subTitleBgNode:SetVisible( false );
	end

    --道具图片
    local itemPicNode = GetButton( view, itemPic );
    local pic = 9;
    --[[
    if tonumber( item.type ) == ITEM_TYPE_3 then
    	pic = math.random(0,2);
    elseif tonumber( item.type ) ==ITEM_TYPE_2 then
        pic = math.random(3,5);	
    else
        pic = math.random(6,8);     
    end
    --]]
    itemPicNode:SetImage( GetPictureByAni("item.item_db", pic) );
    itemPicNode:SetId( tonumber(item.id));
    
    --道具数量
    local itemNumberNode = GetLabel( view, itemNumber );
    itemNumberNode:SetText( string.format("%d", item.num) );

    --道具名称
    local itemNameNode = GetLabel( view, itemName );
    itemNameNode:SetText( item.name );

    --增加事件
    itemPicNode:SetLuaDelegate(p.OnBtnClicked);

end

--点选道具事件
function p.OnBtnClicked( uiNode, uiEventType, param )
    --[[
    if p.selectItem == nil then
        p.selectItem = uiNode;
        uiNode:AddFgEffect("lancer.item_select_fx");
    elseif p.selectItem:GetId()==uiNode:GetId() then
        p.selectItem:DelAniEffect("lancer.item_select_fx");
        p.selectItem = nil;
    else
        p.selectItem:DelAniEffect("lancer.item_select_fx");
        uiNode:AddFgEffect("lancer.item_select_fx");
        p.selectItem = uiNode;  
    end
    
    if p.selectItem == nil then
        dlg_back_pack.HideBtn();
    else
        dlg_back_pack.ShowBtn();
        local item = p.GetItemById( p.selectItem:GetId() );
        dlg_back_pack.SetBtnTextByType( item.itemtypeid );
    end
    --]]
    
    local item = back_pack_mgr.GetItemById( uiNode:GetId() );
    if tonumber( item.type ) == ITEM_TYPE_3 or tonumber( item.type ) == ITEM_TYPE_4 or tonumber( item.type ) == ITEM_TYPE_5 then
        dlg_item_equip_detail.ShowUI( item );
    else
        dlg_item_detail.ShowUI( item );
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
        back_pack_mgr.ClearData();
    end
end