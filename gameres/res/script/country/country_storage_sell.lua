
country_storage_sell = {};
local p = country_storage_sell;

p.layer = nil;
p.item = nil;

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
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_RETURN == tag then
			p.CloseUI();
		elseif ui.ID_CTRL_BUTTON_15 == tag then
			p.SellItem();
		end
	end
end

--卖出物品
function p.SellItem()
	
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
	end
end
