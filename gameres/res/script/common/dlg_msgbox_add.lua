

dlg_msgbox_add = {};
local p = dlg_msgbox_add;

p.layer = nil;
p.callback = nil;
p.msgText = nil;
p.str = nil;

local ui = ui_dlg_msgbox_add;

function p.ShowUI( str, callback )
	p.callback = callback;
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.ShowText();
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return;
	end
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch( true );
	layer:SetFrameRectFull();
	
	GetUIRoot():AddChildZ( layer, 999999 );
	p.layer = layer;
	
	LoadUI( "dlg_msgbox_add.xui", layer, nil );

	p.InitControllers();
	p.SetDelegate();
	
	p.ShowText();
end

function p.InitControllers()
	p.msgText = GetLabel( p.layer, ui.ID_CTRL_TEXT_20 );
end

function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_YES );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_NO );
	btn:SetLuaDelegate( p.OnBtnClick );
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_YES == tag then
			if p.callback then
				p.callback( true );
			end
		elseif ui.ID_CTRL_BUTTON_NO == tag then
			if p.callback then
				p.callback( false );
			end
		end
		p.CloseUI();
	end
end

function p.ShowText()
	if p.str and p.msgText then
		p.msgText:SetText( p.str );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.callback = nil;
		p.msgText = nil;
		p.str = nil;
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end


