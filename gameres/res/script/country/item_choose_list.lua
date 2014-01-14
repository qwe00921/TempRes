

item_choose_list = {};
local p = item_choose_list;

p.layer = nil;
p.itemList = {};
p.itemid = nil;

local ui = ui_item_choose_list;

function p.ShowUI( itemid )
	p.itemid = itemid;
	if p.layer ~= nil then
		p.layer:SetVisible( true );
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

	LoadDlg( "item_choose_list.xui" , layer, nil );
	
	p.layer = layer;
	
	p.SetDelegate();
	
	p.ShowItems();
end

function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RETURN );
	btn:SetLuaDelegate( p.OnBtnClick );
end

function p.ShowItems()
	local cache = msg_cache.msg_material_list or {};
	local materials = cache.Material;
	if materials == nil then
		return;
	end
	p.itemList = {};
	
	if p.itemid ~= 0 then
		table.insert( p.itemList, { removeFlag = true, material_id = 0 } );--占用一个位置，表示添加为移除功能
	end
	
	for i = 1, #materials do
		local material = materials[i];
		local material_id = material.material_id or 0;
		local nType = tonumber( SelectCell( T_MATERIAL, material_id, "type" ) ) or 0;
		if nType == 1 then
			table.insert( p.itemList, material );
		end
	end
	
	local list = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_VIEW );
	if list == nil then
		return;
	end

	local row = math.ceil( #p.itemList/5 );
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI( "item_list_1.xui", view, nil );
		
		local bg = GetUiNode( view, ui_item_list_1.ID_CTRL_PICTURE_BG );
		view:SetViewSize( bg:GetFrameSize() );
		
		for j = 1, 5 do
			local item = p.itemList[(i-1)*5+j];
			local itemPic = GetImage( view, ui_item_list_1["ID_CTRL_PICTURE_ITEM" .. j] );
			local itemNameBG = GetImage( view, ui_item_list_1["ID_CTRL_PICTURE_ITEMNAMEBG" .. j] );
			local itemName = GetLabel( view, ui_item_list_1["ID_CTRL_TEXT_ITEMNAME" .. j] );
			local itemNum = GetLabel( view, ui_item_list_1["ID_CTRL_TEXT_ITEMNUM" .. j] );
			local itemDelegate = GetButton( view, ui_item_list_1["ID_CTRL_BUTTON_ITEM" .. j] );
			local mask = GetImage( view, ui_item_list_1["ID_CTRL_PICTURE_MASK" .. j] );
			
			local flag = item ~= nil;
			itemPic:SetVisible( flag and (not item.removeFlag) );
			itemNameBG:SetVisible( flag and (not item.removeFlag) );
			itemName:SetVisible( flag and (not item.removeFlag) );
			itemNum:SetVisible( flag and (not item.removeFlag) );
			itemDelegate:SetVisible( flag and (not item.removeFlag) );
			mask:SetVisible( false );
			
			if flag then
				if item.removeFlag then
					--添加移除按钮
					local btn = createNDUIButton();
					btn:Init();
					btn:SetLuaDelegate( p.RemovePostion );
					btn:SetFrameRect( CCRectMake( 0, 10, 100, 100 ) );
					btn:SetImage( GetPictureByAni( "ui.card_edit_remove", 0) );
					view:AddChildZ( btn, 9 );
				else
					itemName:SetText( SelectCell( T_MATERIAL, item.material_id, "name" ) or "" );
					itemNum:SetText( tostring("X " .. item.num) or "" );
					
					local path = SelectCell( T_MATERIAL, item.material_id, "item_pic" );
					local picData = nil;
					if path then
						picData = GetPictureByAni( path, 0 );
					end
					if picData then
						itemPic:SetPicture( picData );
					end
					
					itemDelegate:SetId( item.material_id );
					itemDelegate:SetLuaDelegate( p.OnItemClick );
					--mask:SetVisible( not item_choose.CheckEnabled( item.material_id ) );

					local bEnabled = p.itemid == item.material_id or item_choose.CheckEnabled( item.material_id );
					itemDelegate:SetEnabled( bEnabled );
					itemPic:SetMaskColor(bEnabled and ccc4(255,255,255,255) or ccc4(100,100,100,255));
				end
			end
		end
		list:AddView( view );
	end
end

function p.OnItemClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local id = uiNode:GetId();
		local item = nil;
		for i = 1,#p.itemList do
			if tonumber(p.itemList[i].material_id) and tonumber(p.itemList[i].material_id) == id then
				item = p.itemList[i];
				break;
			end
		end
		if item then
			item_choose_num.ShowUI( item, p.ChooseNumCallBack );
		end
	end
end

function p.ChooseNumCallBack( itemid, num )
	item_choose.ChooseItemCallBack( itemid, num )
	p.CloseUI();
end

function p.RemovePostion( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		item_choose.ClearPostion();
		p.CloseUI();
	end
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_RETURN == tag then
			p.CloseUI();
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



