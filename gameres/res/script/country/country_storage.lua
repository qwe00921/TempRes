

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

local ui = ui_item_list;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		local user = msg_cache.msg_player;
		dlg_userinfo.ShowUI( user );
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddChild(layer);

	LoadUI( "item_list.xui" , layer, nil );
	
	p.layer = layer;
	
	--���ô���
	p.SetDelegate();
	
	--��ʼ���ؼ�
	p.InitController();
	
	local flag = country_collect.SendCollectMsg();
	if not flag then
		p.RequestData();
	end
	local user = msg_cache.msg_player;
	dlg_userinfo.ShowUI( user );
end

function p.SetDelegate()
	--����
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RETURN );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--��Ʒ�༭
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_75 );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--ȫ��
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_11 );
	btn:SetLuaDelegate( p.OnBtnClick );
	table.insert( p.btnList, btn );
	
	--ҩˮ
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_12 );
	btn:SetLuaDelegate( p.OnBtnClick );
	table.insert( p.btnList, btn );
	
	--����
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_13 );
	btn:SetLuaDelegate( p.OnBtnClick );
	table.insert( p.btnList, btn);
end

function p.InitController()
	p.numText = GetLabel( p.layer, ui.ID_CTRL_TEXT_16 );
	p.materialList = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_VIEW );
end

function p.RequestData()
	if p.layer == nil then
		--UI�����ڣ�����������
		return;
	end
	
	local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end
	--�ٻ�����������
    SendReq("Collect", "Material", uid, "");
end

--ˢ���б�����
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
			
			local flag = data ~= nil;
			itemPic:SetVisible( flag );
			itemNameBG:SetVisible( flag );
			itemName:SetVisible( flag );
			itemNum:SetVisible( flag );
			itemDelegate:SetVisible( flag );
			
			if flag then
				itemName:SetText( SelectCell( T_MATERIAL, data.material_id, "name" ) or "" );
				itemNum:SetText( tostring(data.num) or "" );
				
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
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_RETURN == tag then
			p.CloseUI()
		elseif ui.ID_CTRL_BUTTON_75 == tag then
			WriteCon( "��Ʒ�༭" );
			
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
		end
	end
end

--�����Ʒ
function p.OnItemClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local id = uiNode:GetId();
		WriteCon( "itemIndex:".. tostring(id) );
		
		local dataSource = msg_cache.msg_material_list or {};
		local data = dataSource[id];
		if data then
			
		end
	end
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
		dlg_userinfo.HideUI();
	end
end