--------------------------------------------------------------
-- FileName: 	login_mainui.lua
-- author:		mk, 2013/10/12
-- purpose:		登录界面
--------------------------------------------------------------

login_main = {}
local p = login_main;

p.layer = nul;

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
	
	GetUIRoot():AddChild(layer);
	--LoadUI("login_back.xui", layer, nil);
	
	p.layer = layer;

	login_ui.ShowUI(); --测试战斗要关掉 @郭浩
	--p.InitExp();
	--p.SetDelegate(layer);
	
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end