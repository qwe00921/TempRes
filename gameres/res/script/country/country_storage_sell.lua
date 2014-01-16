
country_storage_sell = {};
local p = country_storage_sell;

p.layer = nil;
p.item = nil;
p.numText = nil;
p.sellFlag = false;

local ui = ui_pubulic_item_num;

function p.ShowUI( item )
	p.item = item;
	if p.layer ~= nil then
		p.layer:SetVisible(true);
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return;
	end
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	LoadDlg( "pubulic_item_num.xui", layer, nil );
	GetUIRoot():AddDlg( layer );
	
	p.layer = layer;
	
	p.SetDelegate();
	
	p.InitControlelr();
end

function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RETURN );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_15 );
	btn:SetLuaDelegate( p.OnBtnClick );
	btn:SetZOrder( 99 );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_16 );
	btn:SetLuaDelegate( p.OnBtnClick );
	btn:SetZOrder( 99 );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_17 );
	btn:SetLuaDelegate( p.OnBtnClick );
	btn:SetZOrder( 99 );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_95 );
	btn:SetLuaDelegate( p.OnBtnClick );
	btn:SetZOrder( 99 );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_96 );
	btn:SetLuaDelegate( p.OnBtnClick );
	btn:SetZOrder( 99 );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_97 );
	btn:SetLuaDelegate( p.OnBtnClick );
	btn:SetZOrder( 99 );
	
	local img = GetImage( p.layer, ui.ID_CTRL_PICTURE_99 );
	img:SetZOrder( 99 );
	
	img = GetImage( p.layer, ui.ID_CTRL_PICTURE_100 );
	img:SetZOrder( 99 );
	
	img = GetImage( p.layer, ui.ID_CTRL_PICTURE_101 );
	img:SetZOrder( 99 );
end

function p.InitControlelr()
	local title = GetLabel( p.layer, ui.ID_CTRL_TEXT_6 );
	title:SetText( "材料卖出" );
	
	local itemPic = GetImage( p.layer, ui.ID_CTRL_PICTURE_8 );
	local path = SelectCell( T_MATERIAL, p.item.material_id, "item_pic" );
	if path then
		local picData = GetPictureByAni( path, 0 );
		itemPic:SetPicture( picData );
	end
	
	local nameText = GetLabel( p.layer, ui.ID_CTRL_TEXT_ITEMNAME );
	nameText:SetText( SelectCell( T_MATERIAL, p.item.material_id, "name" ) );
	
	local descText = GetLabel( p.layer, ui.ID_CTRL_TEXT_13 );
	descText:SetText( SelectCell( T_MATERIAL, p.item.material_id, "description" ) );
	
	local hasNum = GetLabel( p.layer, ui.ID_CTRL_TEXT_15 );
	hasNum:SetText( tostring(p.item.num) );
	
	p.numText = GetLabel( p.layer, ui.ID_CTRL_TEXT_18 );
	p.numText:SetText( tostring( math.min( 1, tonumber( p.item.num ) ) ) );
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_RETURN == tag then
			if p.sellFlag then
				country_storage.RequestData();
			end
			p.CloseUI();
		elseif ui.ID_CTRL_BUTTON_15 == tag then
			p.SellItem();
		elseif ui.ID_CTRL_BUTTON_16 == tag then
			p.AddNum( -1 );
		elseif ui.ID_CTRL_BUTTON_17 == tag then
			p.AddNum( 1 );
		elseif ui.ID_CTRL_BUTTON_95 == tag then
			p.AddNum( 2 );
		elseif ui.ID_CTRL_BUTTON_96 == tag then
			p.AddNum( 5 );
		elseif ui.ID_CTRL_BUTTON_97 == tag then
			p.AddNum( 999999 ); --表示最大
		end
	end
end

function p.AddNum( num )
	if num == 999999 then
		num = tonumber( p.item.num );
	else
		local curNum = tonumber( p.numText:GetText() );
		num = curNum + num;
		num = math.max( 0, num);
	end
	p.numText:SetText( tostring( math.min( tonumber( p.item.num ),  num ) ) );
end

--卖出物品
function p.SellItem()
	local num = tonumber( p.numText:GetText() );
	if num == 0 then
		dlg_msgbox.ShowOK( "提示" , "卖出数量为0！", nil, p.layer );
		return;
	end
	
	local uid = GetUID();
	if uid == nil or uid == 0 then
		return;
	end
	
	p.sellFlag = true;

	SendReq( "Collect", "Sell", uid, "&id=".. p.item.material_id .. "&num=".. num );
end

function p.SellCallBack()
	local num = p.numText:GetText();
	dlg_msgbox.ShowOK( "提示" , "成功卖出".. num .."个".. tostring( SelectCell( T_MATERIAL, p.item.material_id, "name" ) ), nil, p.layer );
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
		p.item = nil;
		p.sellFlag = false;
	end
end
