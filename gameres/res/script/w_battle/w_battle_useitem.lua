
w_battle_useitem = {};
local p = w_battle_useitem;

local ui = ui_n_battle_itemuse;

p.layer = nil;
p.itemid = nil;
p.index = nil;

local role = {
	{ ui.ID_CTRL_BUTTON_TARGET1, ui.CTRL_PICTURE_TARGET1},
	{ ui.ID_CTRL_BUTTON_TARGET2, ui.CTRL_PICTURE_TARGET2},
	{ ui.ID_CTRL_BUTTON_TARGET3, ui.CTRL_PICTURE_TARGET3},
	{ ui.ID_CTRL_BUTTON_TARGET4, ui.CTRL_PICTURE_TARGET4},
	{ ui.ID_CTRL_BUTTON_TARGET5, ui.CTRL_PICTURE_TARGET5},
	{ ui.ID_CTRL_BUTTON_TARGET6, ui.CTRL_PICTURE_TARGET6},
};

function p.ShowUI( itemid, posList, index )
	p.itemid = itemid;
	p.index = index;
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.RefreshUI( posList );
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init(layer);
	layer:SetSwallowTouch(false);
    
	layer:SetVisible( false );
	GetUIRoot():AddDlg( layer );
	
	LoadDlg( "n_battle_itemuse.xui", layer, nil );
	
	layer:SetVisible( true );
	p.layer = layer;
	
	p.SetDelegate();
	p.RefreshUI( posList );
end

function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_18 );
	if btn then
		btn:SetLuaDelegate( p.OnBtnClick );
	end
end

function p.RefreshUI( posList )
	local itempic = GetImage( p.layer , ui.ID_CTRL_PICTURE_ITEMPIC );
	if itempic then
		
	end
	
	local itemname = GetLabel( p.layer, ui.ID_CTRL_TEXT_ITEMNAME );
	
	local iteminfo = GetLabel( p.layer, ui.ID_CTRL_TEXT_ITEMINFO );
	
	local itemnum = GetLabel( p.layer, ui.ID_CTRL_TEXT_17 );
	
	p.ShowCanUseItemRole( posList );
end

function p.ShowCanUseItemRole( posList )
	
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

--按钮交互
function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_18 == tag then
			WriteCon( "**关闭物品使用菜单**" );
			p.HideUI();
			p.CloseUI();
		end
	end
end

