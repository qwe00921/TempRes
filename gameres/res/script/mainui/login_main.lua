--------------------------------------------------------------
-- FileName: 	login_mainui.lua
-- author:		mk, 2013/10/12
-- purpose:		��¼����
--------------------------------------------------------------

login_main = {}
local p = login_main;

p.layer = nul;

local ui = ui_login_back;

--��ʾUI
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

	login_ui.ShowUI(); --����ս��Ҫ�ص� @����
	--p.InitExp();
	--p.SetDelegate(layer);
	
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end