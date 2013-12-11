
dlg_battlearray = {};
local p = dlg_battlearray;

local ui = ui_main_battlearray_bg;
p.layer = nil;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_13 );
		if list  then
			list:SetVisible(true);
		end
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init(layer);
	layer:SetSwallowTouch(false);
    
	GetUIRoot():AddChild(layer);
	LoadUI("main_battlearray_bg.xui", layer, nil);
    
	p.layer = layer;
	--p.SetDelegate();
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
		local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_13 );
		if list  then
			list:SetVisible(false);
		end
	end
end

function p.RefreshUI(user_team)
	user_team = user_team or {};
	local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_13 );
	if list == nil then
		return;
	end
	list:ClearView();
	
	local view = createNDUIXView();
	view:Init();
	LoadUI( "main_battlearray.xui", view, nil );
	
	local bg = GetUiNode( view, ui_main_battlearray.ID_CTRL_PICTURE_BG );
    view:SetViewSize( bg:GetFrameSize());
	
	for i = 1, 6 do
		local id = user_team["Pos_card"..i]
		local btn = GetButton( view, ui_main_battlearray["ID_CTRL_BUTTON_ROLE_"..i] );
		local frameBtn = GetButton( view, ui_main_battlearray["ID_CTRL_BUTTON_"..(i+9)] );
		frameBtn:SetLuaDelegate( p.OnBtnClick );
		
		if id ~= nil and tonumber(id) ~= 0 then
			if btn ~= nil then
				btn:SetImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", tostring(id), "head_pic" ), 0 ) );
				btn:SetTouchDownImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", tostring(id), "head_pic" ), 0 ) );
				btn:SetDisabledImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", tostring(id), "head_pic" ), 0 ) );
			end
		else
			if btn ~= nil then
				btn:SetVisible( false );
			end
			
			if frameBtn ~= nil then
				frameBtn:SetImage( GetPictureByAni( "ui.default_card_btn", 0 ) );
				frameBtn:SetTouchDownImage( GetPictureByAni( "ui.default_card_btn", 1 ) );
			end
		end
	end
	
	for i = 1, 2 do
		local id = user_team["Pet_card"..i];
		local btn = GetButton( view, ui_main_battlearray["ID_CTRL_BUTTON_ROLE_"..(i+6)] );
		local frameBtn = GetButton( view, ui_main_battlearray["ID_CTRL_BUTTON_"..(i+6+9)] );
		frameBtn:SetLuaDelegate( p.OnBtnClick );
		
		if id ~= nil and tonumber(id) ~= 0 then
			if btn ~= nil then
				btn:SetImage( GetPictureByAni( SelectCell( T_PET_RES, tostring( id ), "face_pic" ), 0 ) );
				btn:SetTouchDownImage( GetPictureByAni( SelectCell( T_PET_RES, tostring( id ), "face_pic" ), 0 ) );
				btn:SetDisabledImage( GetPictureByAni( SelectCell( T_PET_RES, tostring( id ), "face_pic" ), 0 ) );
			end
		else
			if btn ~= nil then
				btn:SetVisible( false );
			end
			
			if frameBtn ~= nil then
				frameBtn:SetImage( GetPictureByAni( "ui.default_pet_btn", 0 ) );
				frameBtn:SetTouchDownImage( GetPictureByAni( "ui.default_pet_btn", 1 ) );
			end
		end
	end
	
	list:AddView( view );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    --local tag = uiNode:GetTag();
		dlg_card_group_main.ShowUI();
	end	
end
