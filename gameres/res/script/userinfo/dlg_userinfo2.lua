
dlg_userinfo2 = {};
local p = dlg_userinfo2;

local ui = ui_main_userinfo2;
p.layer = nil;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.SendReqUserInfo();
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
	LoadUI("main_userinfo2.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
end

function p.SendReqUserInfo()
	--===============================--
	WriteCon("**请求玩家状态数据**");
	--===============================--
end

function p.SetDelegate()
	--玩家信息
	local userinfo = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_USERINFO);
	userinfo:SetLuaDelegate(p.OnBtnClick);
	
	--菜单
	local menu = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_MENUUP);
	menu:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_MAIN_BUTTON_USERINFO == tag then
			WriteCon("**玩家信息**");
			dlg_userinfo.ShowUI();
			p.showUserinfo = true;
		elseif ui.ID_CTRL_MAIN_BUTTON_MENUUP == tag then
			WriteCon("**菜单按钮**");
			maininterface.CloseAllPanel();
			
			dlg_menu.ShowUI();
		end
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
	end
end

