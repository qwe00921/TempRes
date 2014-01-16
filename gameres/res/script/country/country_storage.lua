

country_storage = {};
local p = country_storage;

E_LIST_TYPE_ALL = 1;
E_LIST_TYPE_POTION = 2;
E_LIST_TYPE_MATERIAL = 3;

p.layer = nil;
p.numText = nil;
p.materialList = nil;
p.showListType = E_LIST_TYPE_ALL;
p.btnList = {};
p.curItem = nil;

--p.selectItem = false;

p.itemCtrllers = {};

local BGIMAGE_INDEX = 1;
local ITEMIMAGE_INDEX = 2;
local NAMETEXT_INDEX = 3;
local INFOTEXT_INDEX = 4;
local SELLBTN_INDEX = 5;
local SELLTEXT_INDEX = 6;
local HIDEBTN_INDEX = 7;

local ui = ui_item_list;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		local user = msg_cache.msg_player;
		dlg_userinfo.ShowUI( user );
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddDlg(layer);

	LoadDlg( "item_list.xui" , layer, nil );
	
	p.layer = layer;
	
	--设置代理
	p.SetDelegate();
	
	--初始化控件
	p.InitController();
	
--	local flag = country_collect.SendCollectMsg();
--	if not flag then
	p.RequestData();
--	end
	local user = msg_cache.msg_player;
	dlg_userinfo.ShowUI( user );
end

function p.SetDelegate()
	--返回
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RETURN );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--物品编辑
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_75 );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--全局
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_11 );
	btn:SetLuaDelegate( p.OnBtnClick );
	table.insert( p.btnList, btn );
	
	--药水
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_12 );
	btn:SetLuaDelegate( p.OnBtnClick );
	table.insert( p.btnList, btn );
	
	--材料
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_13 );
	btn:SetLuaDelegate( p.OnBtnClick );
	table.insert( p.btnList, btn);
end

function p.InitController()
	p.numText = GetLabel( p.layer, ui.ID_CTRL_TEXT_16 );
	p.materialList = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_VIEW );
	
	local ctrller = GetImage( p.layer, ui.ID_CTRL_PICTURE_112 );	
	p.itemCtrllers[BGIMAGE_INDEX] = ctrller;
	ctrller:SetZOrder(9999);

	ctrller = GetImage( p.layer, ui.ID_CTRL_PICTURE_113 );
	p.itemCtrllers[ITEMIMAGE_INDEX] = ctrller;
	ctrller:SetZOrder(9999);

	ctrller = GetLabel( p.layer, ui.ID_CTRL_TEXT_114 );
	p.itemCtrllers[NAMETEXT_INDEX] = ctrller;
	ctrller:SetZOrder(9999);

	ctrller = GetLabel( p.layer, ui.ID_CTRL_TEXT_115 );
	p.itemCtrllers[INFOTEXT_INDEX] = ctrller;
	ctrller:SetZOrder(9999);

	ctrller = GetButton( p.layer, ui.ID_CTRL_BUTTON_116 );
	p.itemCtrllers[SELLBTN_INDEX] = ctrller;
	ctrller:SetLuaDelegate( p.OnBtnClick );
	ctrller:SetZOrder(9999);

	ctrller = GetLabel( p.layer, ui.ID_CTRL_TEXT_117 );
	p.itemCtrllers[SELLTEXT_INDEX] = ctrller;
	ctrller:SetZOrder(9999);

	ctrller = GetButton( p.layer, ui.ID_CTRL_BUTTON_118 );
	p.itemCtrllers[HIDEBTN_INDEX] = ctrller;
	ctrller:SetLuaDelegate( p.OnBtnClick );
	ctrller:SetZOrder(9999);
	
	p.SetCtrllersVisible( p.itemCtrllers, false );
end

function p.SetCtrllersVisible( ctrllers, bFlag )
	for i,v in pairs( ctrllers ) do
		v:SetVisible( bFlag );
	end
end

function p.RequestData()
	if p.layer == nil then
		--UI不存在，不请求数据
		return;
	end
	
	local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end
	--材料仓库材料列表
    SendReq("Collect", "Material", uid, "");
end

--刷新列表数据
function p.RefreshUI( dataSource )
	local dataList = nil;
	if p.showListType == E_LIST_TYPE_ALL then
		dataList = dataSource.Material;
	elseif p.showListType == E_LIST_TYPE_POTION then
		local temp = {};
		if dataSource.Material ~= nil then
			for i = 1, #dataSource.Material do
				local materialId = dataSource.Material[i].material_id or 0;
				local materialType = tonumber(SelectCell( T_MATERIAL, materialId, "type" )) or 0;
				if materialType == 1 then
					table.insert( temp, dataSource.Material[i] );
				end
			end
		end
		dataList = temp;
	elseif p.showListType == E_LIST_TYPE_MATERIAL then
		local temp = {};
		if dataSource.Material ~= nil then
			for i = 1, #dataSource.Material do
				local materialId = dataSource.Material[i].material_id or 0;
				local materialType = tonumber(SelectCell( T_MATERIAL, materialId, "type" )) or 0;
				if materialType == 2 then
					table.insert( temp, dataSource.Material[i] );
				end
			end
		end
		dataList = temp;
	end
	
	if p.layer == nil or dataList == nil then
		return;
	end

	p.materialList = p.materialList or GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_VIEW );
	if p.materialList == nil then
		return;
	end
	p.materialList:ClearView();
	
	local maxNum = dataSource.MaxNum or 0;
	p.numText = p.numText or GetLabel( p.layer, ui.ID_CTRL_TEXT_16 );
	p.numText:SetText( string.format( "%d/%d", #dataList, dataSource.MaxNum ) );
	
	local row = math.ceil( #dataList/5 );
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI( "item_list_1.xui", view, nil );
		
		local bg = GetUiNode( view, ui_item_list_1.ID_CTRL_PICTURE_BG );
		view:SetViewSize( bg:GetFrameSize() );
		for j = 1, 5 do
			local data = dataList[(i-1)*5+j];
			local itemPic = GetImage( view, ui_item_list_1["ID_CTRL_PICTURE_ITEM" .. j] );
			local itemNameBG = GetImage( view, ui_item_list_1["ID_CTRL_PICTURE_ITEMNAMEBG" .. j] );
			local itemName = GetLabel( view, ui_item_list_1["ID_CTRL_TEXT_ITEMNAME" .. j] );
			local itemNum = GetLabel( view, ui_item_list_1["ID_CTRL_TEXT_ITEMNUM" .. j] );
			local itemDelegate = GetButton( view, ui_item_list_1["ID_CTRL_BUTTON_ITEM" .. j] );
			
			local mask = GetImage( view, ui_item_list_1["ID_CTRL_PICTURE_MASK" .. j] );
			
			local flag = data ~= nil;
			itemPic:SetVisible( flag );
			itemNameBG:SetVisible( flag );
			itemName:SetVisible( flag );
			itemNum:SetVisible( flag );
			itemDelegate:SetVisible( flag );
			mask:SetVisible( false );
			
			if flag then
				itemName:SetText( SelectCell( T_MATERIAL, data.material_id, "name" ) or "" );
				itemNum:SetText( tostring("X " .. data.num) or "" );
				
				local path = SelectCell( T_MATERIAL, data.material_id, "item_pic" );
				local picData = nil;
				if path then
					picData = GetPictureByAni( path, 0 );
				end
				if picData then
					itemPic:SetPicture( picData );
				end
				
				itemDelegate:SetId( data.id );
				itemDelegate:SetLuaDelegate( p.OnItemClick );
			end
		end
		
		p.materialList:AddView( view );
	end
end

function p.OnBtnClick( uiNode, uiEventType, param )
	WriteCon("asdasdasd");
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_RETURN == tag then
			p.CloseUI()
		elseif ui.ID_CTRL_BUTTON_75 == tag then
			WriteCon( "物品编辑" );
			item_choose.ShowUI();
		elseif ui.ID_CTRL_BUTTON_11 == tag then
			if p.showListType == E_LIST_TYPE_ALL then
				return;
			end
			p.showListType = E_LIST_TYPE_ALL;
			p.SetBtnHighLight( tag )
			local dataSource = msg_cache.msg_material_list;
			if dataSource then
				p.RefreshUI( dataSource );
			else
				p.RequestData();
			end
		elseif ui.ID_CTRL_BUTTON_12 == tag then
			if p.showListType == E_LIST_TYPE_POTION then
				return;
			end
			p.showListType = E_LIST_TYPE_POTION;
			p.SetBtnHighLight( tag )
			local dataSource = msg_cache.msg_material_list;
			if dataSource then
				p.RefreshUI( dataSource );
			else
				p.RequestData();
			end
		elseif ui.ID_CTRL_BUTTON_13 == tag then
			if p.showListType == E_LIST_TYPE_MATERIAL then
				return;
			end
			p.showListType = E_LIST_TYPE_MATERIAL;
			p.SetBtnHighLight( tag )
			local dataSource = msg_cache.msg_material_list;
			if dataSource then
				p.RefreshUI( dataSource );
			else
				p.RequestData();
			end
		elseif ui.ID_CTRL_BUTTON_118 == tag then
			WriteCon( "隐藏物品信息框" );
			p.SetCtrllersVisible( p.itemCtrllers, false );
--			p.selectItem = false;
		elseif ui.ID_CTRL_BUTTON_116 == tag then
			WriteCon( "卖出" );
			p.SetCtrllersVisible( p.itemCtrllers, false );
			country_storage_sell.ShowUI( p.curItem );
		end
	end
end

--点击物品
function p.OnItemClick( uiNode, uiEventType, param )
--	if p.selectItem then
--		return;
--	end
	
	if IsClickEvent( uiEventType ) then
		local id = uiNode:GetId();
		WriteCon( "itemIndex:".. tostring(id) );
		
		local source = msg_cache.msg_material_list or {};
		local materials = source.Material or {};
		
		local index = 0;
		for i, v in pairs( materials ) do
			if v.id == id then
				index = i;
				break;
			end
		end
		local data = materials[index];
		
		if data then
			p.ShowSelectItem( data );
		end
	end
end

function p.ShowSelectItem( data )
	if #p.itemCtrllers == 0 then
		return;
	end
--	p.selectItem = true;
	p.SetCtrllersVisible( p.itemCtrllers, true );
	p.curItem = data;
	
	local path = SelectCell( T_MATERIAL, data.material_id, "item_pic" );
	local picData = GetPictureByAni( path, 0 );
	if picData then
		p.itemCtrllers[ITEMIMAGE_INDEX]:SetPicture( picData );
	end
	
	p.itemCtrllers[NAMETEXT_INDEX]:SetText( SelectCell( T_MATERIAL, data.material_id, "name" ) );
	p.itemCtrllers[INFOTEXT_INDEX]:SetText( SelectCell( T_MATERIAL, data.material_id, "description" ) );
end

function p.SetBtnHighLight( tag )
	if #p.btnList == 0 then
		return;
	end
	
	for _,btn in pairs( p.btnList ) do
		btn:SetChecked( tag == btn:GetTag() );
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		dlg_userinfo.HideUI();
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.numText = nil;
		p.materialList = nil;
		p.showListType = E_LIST_TYPE_ALL;
--		p.selectItem = false;
		p.curItem = nil;
		dlg_userinfo.HideUI();
	end
end