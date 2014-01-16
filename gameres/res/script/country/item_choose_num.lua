
item_choose_num = {};
local p = item_choose_num;

p.layer = nil;
p.item = nil;
p.numText = nil;
p.callback = nil;

local ui = ui_pubulic_item_num;

local MAX_NUM = 10;

function p.ShowUI( item, callback )
	p.item = item;
	p.callback = callback;
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
	title:SetText( "药品配置" );
	
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
			p.CloseUI();
		elseif ui.ID_CTRL_BUTTON_15 == tag then
			p.ChooseNumCallBack();
			p.CloseUI();
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
		num = math.min( num, MAX_NUM );
	else
		local curNum = tonumber( p.numText:GetText() );
		num = curNum + num;
		num = math.max( 0, num);
		num = math.min( num, MAX_NUM );
	end
	p.numText:SetText( tostring( math.min( tonumber( p.item.num ),  num ) ) );
end

function p.ChooseNumCallBack()
	if p.callback == nil then
		return;
	end
	
	local num = tonumber( p.numText:GetText() );
	p.callback( p.item.material_id, num );
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
		p.callback = nil;
	end
end
