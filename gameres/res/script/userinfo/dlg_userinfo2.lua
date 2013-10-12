
dlg_userinfo2 = {};
local p = dlg_userinfo2;

local ui = ui_main_userinfo2;
p.layer = nil;
p.showUserinfo = false;

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
	WriteCon("**�������״̬����**");
	--===============================--
end

function p.SetDelegate()
	--�����Ϣ
	local userinfo = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_USERINFO);
	userinfo:SetLuaDelegate(p.OnBtnClick);
	
	--�˵�
	local menu = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_MENUUP);
	menu:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_MAIN_BUTTON_USERINFO == tag then
				WriteCon("**�����Ϣ**");
			if p.showUserinfo then
				p.showUserinfo = false;
				dlg_userinfo.CloseUI();
			else
				dlg_userinfo.ShowUI();
				p.showUserinfo = true;
			end
		elseif ui.ID_CTRL_MAIN_BUTTON_MENUUP == tag then
			WriteCon("**�˵���ť**");
			maininterface.CloseAllPanel();
			
			dlg_menu.ShowUI();
			uiNode:SetVisible(false);
		end
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
	end
end

