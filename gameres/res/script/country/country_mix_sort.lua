
country_mix_sort = {};
local p = country_mix_sort;

p.layer = nil;
p.callback = nil;
local ui = ui_card_bag_sort_view;


function p.ShowUI( callback )
	p.callback = callback;
	
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
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
	GetUIRoot():AddDlg(layer);

	LoadDlg( "card_bag_sort_view.xui" , layer, nil );
	
	p.layer = layer;
	
	p.SetDelegate();
end

function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SOTR_LEVEL );
	btn:SetLuaDelegate( p.OnBtnClick );
	btn:SetId( CHOOSE_TYPE_TREAT );
	--btn:SetText( "恢复类" );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SORT_STAR );
	btn:SetLuaDelegate( p.OnBtnClick );
	btn:SetId( CHOOSE_TYPE_STATUS );
	--btn:SetText( "状态类" );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SOTR_ITEM );
	btn:SetLuaDelegate( p.OnBtnClick );
	btn:SetId( CHOOSE_TYPE_ATTR );
	--btn:SetText( "属性类" );
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local id = uiNode:GetId();
		if p.callback then
			p.callback( id );
		end
		p.HideUI();
		p.CloseUI();
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose( false );
		p.layer = nil;
		p.callback = nil;
	end
end
