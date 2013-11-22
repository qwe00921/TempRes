
dlg_userinfo = {}
local p = dlg_userinfo;

p.layer = nil;

local ui = ui_main_userinfo

function p.ShowUI(userinfo)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		if userinfo ~= nil then
			p.RefreshUI(userinfo)
		else
			p.SendReqUserInfo();
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
	LoadUI("main_userinfo.xui", layer, nil);
	layer:SetZOrder(9);
    
	p.layer = layer;
	if userinfo ~= nil then
		p.RefreshUI(userinfo)
	else
		p.SendReqUserInfo();
	end
	p.SetDelegate();
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

function p.SendReqUserInfo()
	WriteCon("**请求玩家状态数据**");
    local uid = GetUID();
    if uid ~= nil and uid > 0 then
        SendReq("User","Update",uid,"");
	end
end

function p.RefreshUI(userinfo)
	local username = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME);
	username:SetText( userinfo.Name );
	
	local level = GetLabel(p.layer, ui.ID_CTRL_TEXT_LEVEL_NUM);
	level:SetText( userinfo.Level );
	
	local money = GetLabel(p.layer, ui.ID_CTRL_TEXT_MONEY_NUM);
	money:SetText( userinfo.Money );
	
	local emoney = GetLabel(p.layer, ui.ID_CTRL_TEXT_EMONEY_NUM);
	emoney:SetText( userinfo.Emoney );
	
	local strength = GetExp( p.layer, ui.ID_CTRL_PROGRESSBAR_STRENGTH );
	strength:SetValue( 0, tonumber( userinfo.Move ), tonumber( userinfo.MaxMove ));
	
	local energy = GetExp( p.layer, ui.ID_CTRL_PROGRESSBAR_ENERGY );
	energy:SetValue( 0, 50, 100 );
	
	local Exp = GetExp( p.layer, ui.ID_CTRL_PROGRESSBAR_EXP );
	Exp:SetValue( 0, 50, 100 );
end

function p.SetDelegate()
	local addEmoney = GetButton( p.layer, ui.ID_CTRL_BUTTON_ADD_EMONEY );
	addEmoney:SetLuaDelegate( p.OnBtnClick );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_ADD_EMONEY == tag then
			WriteCon("**========充值========**");
		end
	end
end
