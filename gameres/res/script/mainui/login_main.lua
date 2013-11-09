--------------------------------------------------------------
-- FileName: 	login_mainui.lua
-- author:		mk, 2013/10/12
-- purpose:		登录界面
--------------------------------------------------------------

login_main = {}
local p = login_main;

p.layer = nil;

local ui = ui_login_back;

--显示UI
function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible(true);
		--p.SendReqUserInfo();
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	--GetUIRoot():AddChild(layer); --测试战斗要关掉 @郭浩
	LoadUI("login_back.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
	
end

function p.SetDelegate()
	local start = GetButton(p.layer, ui.ID_CTRL_BUTTON_102);
	start:SetLuaDelegate(p.OnBtnClick);
	--start:AddActionEffect( "ui_cmb.mainui_btn_scale" );
	start:AddFgEffect("ui.TapToStart");
	start:AddActionEffect( "ui_cmb.mainui_btn_scale" );

end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_102 == tag then
			uiNode:SetVisible(false);
			--login_ui.ShowUI();
			--暂时去除登录界面
			p.CloseUI();
			maininterface.ShowUI();
		end
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
		
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end

