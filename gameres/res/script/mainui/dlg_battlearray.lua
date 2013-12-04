
dlg_battlearray = {};
local p = dlg_battlearray;

local ui = ui_main_battlearray;
p.layer = nil;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
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
	LoadUI("main_battlearray.xui", layer, nil);
    
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
	end
end

function p.RefreshUI(user_team)
	if user_team == nil then
		return;
	end
	
	for i = 1, 6 do
		local id = user_team["Pos_card"..i]
		if id ~= nil and tonumber(id) ~= 0 then
			local btn = GetButton( p.layer, ui["ID_CTRL_BUTTON_ROLE_"..i] );
			if btn ~= nil then
				btn:SetImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", tostring(id), "head_pic" ), 0 ) );
				btn:SetTouchDownImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", tostring(id), "head_pic" ), 0 ) );
				btn:SetDisabledImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", tostring(id), "head_pic" ), 0 ) );
			end
		end
	end
end

