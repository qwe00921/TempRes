
w_battle_useitem = {};
local p = w_battle_useitem;

local ui = ui_n_battle_itemuse;

p.layer = nil;
p.itemid = nil;
p.index = nil;
p.posList = nil;

local role = {
	{ ui.ID_CTRL_BUTTON_POS1, ui.ID_CTRL_PICTURE_POS1, ui.ID_CTRL_PICTURE_49 },
	{ ui.ID_CTRL_BUTTON_POS2, ui.ID_CTRL_PICTURE_POS2, ui.ID_CTRL_PICTURE_52 },
	{ ui.ID_CTRL_BUTTON_POS3, ui.ID_CTRL_PICTURE_POS3, ui.ID_CTRL_PICTURE_53 },
	{ ui.ID_CTRL_BUTTON_POS4, ui.ID_CTRL_PICTURE_POS4, ui.ID_CTRL_PICTURE_50 },
	{ ui.ID_CTRL_BUTTON_POS5, ui.ID_CTRL_PICTURE_POS5, ui.ID_CTRL_PICTURE_51 },
	{ ui.ID_CTRL_BUTTON_POS6, ui.ID_CTRL_PICTURE_POS6, ui.ID_CTRL_PICTURE_54 },
};

function p.ShowUI( itemid, index )
	p.itemid = itemid;
	p.index = index;
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.RefreshUI( );
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
	GetUIRoot():AddChild( layer );
	
	LoadDlg( "n_battle_itemuse.xui", layer, nil );
	
	layer:SetVisible( true );
	p.layer = layer;
	
	p.SetDelegate();
	p.RefreshUI( );
end

function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_18 );
	if btn then
		btn:SetLuaDelegate( p.OnBtnClick );
	end
end

function p.RefreshUI( )
	local itempic = GetImage( p.layer , ui.ID_CTRL_PICTURE_ITEMPIC );
	local picData = GetPictureByAni( SelectCell( T_MATERIAL, p.itemid, "item_pic" ) or "", 0 );
	if itempic and picData then
		itempic:SetPicture( picData );
	end
	
	local itemname = GetLabel( p.layer, ui.ID_CTRL_TEXT_ITEMNAME );
	itemname:SetText( SelectCell( T_MATERIAL, p.itemid, "name" ) or "" );
	
	local iteminfo = GetLabel( p.layer, ui.ID_CTRL_TEXT_ITEMINFO );
	iteminfo:SetText( SelectCell( T_MATERIAL, p.itemid, "description" ) or "" );
	
	local itemnum = GetLabel( p.layer, ui.ID_CTRL_TEXT_17 );
	
	local itemList = w_battle_db_mgr.GetItemList() or {};
	local item = itemList[p.index] or {};
	if itemnum and item then
		local useItemTable = w_battle_db_mgr.GetBattleItem();
		local useNum = 0;
		for _,v in ipairs( useItemTable ) do
			if v.id == p.itemid then
				useNum = v.num or 0;
				break;
			end
		end
		
		--物品数为0，直接关闭界面
		if item.num-useNum <= 0 then
			p.HideUI();
			p.CloseUI();
			w_battle_pve.EndUseItem();
			return;
		end
		itemnum:SetText( tostring( math.max( item.num-useNum , 0)) );
	end
	
	p.ShowCanUseItemRole();
end

function p.ShowCanUseItemRole()
	p.posList = w_battle_mgr.GetItemCanUsePlayer( p.index );
	for i = 1, 6 do
		local btn = GetButton( p.layer, role[i][1] );
		if btn then
			btn:SetLuaDelegate( p.OnBtnClick );
			btn:SetId( i );
		end
		
		local image = GetImage( p.layer, role[i][2] );
		local useTag = GetImage( p.layer, role[i][3] );
		local bflag = true;
		if p.posList ~= nil then
			for _, v in pairs( p.posList ) do
				if v == i then
					bflag = false;
					break;
				end
			end
		end
		image:SetVisible( bflag );
		useTag:SetVisible( not bflag );
		
		if not useTag:FindActionEffect( "lancer_cmb.battle_move" ) then
			useTag:AddActionEffect( "lancer_cmb.battle_move" );
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
		p.itemid = nil;
		p.index = nil;
		p.posList = nil;
	end
end

function p.CheckUseItem( tag )
	for i = 1, 6 do
		if tag == role[i][1] then
			return true;
		end
	end
	return false;
end

--按钮交互
function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_18 == tag then
			WriteCon( "**关闭物品使用菜单**" );
			p.HideUI();
			p.CloseUI();
			w_battle_pve.EndUseItem();
		elseif p.CheckUseItem( tag ) then
			WriteCon( "指定使用物品" );
			p.UseItem( uiNode:GetId() );
		end
	end
end

function p.UseItem( index )
	p.posList = w_battle_mgr.GetItemCanUsePlayer( p.index );
	if p.posList ~= nil then
		for _, v in pairs(p.posList) do
			if v == index then
				w_battle_mgr.UseItem( p.index, index );
				
				w_battle_pve.RefreshItemInfo( false );
				break;
			end
		end
	end
end