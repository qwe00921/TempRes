--------------------------------------------------------------
-- FileName: 	login_mainui.lua
-- author:		mk, 2013/10/12
-- purpose:		��¼����
--------------------------------------------------------------

login_main = {}
local p = login_main;

p.layer = nil;

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
	LoadUI("login_back.xui", layer, nil);
	
	p.layer = layer;

	login_ui.ShowUI(); --����ս��Ҫ�ص� @����
	--login_ui.ShowUI();
	--p.InitExp();
	p.SetDelegate();
	
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end

function p.SetDelegate()
	local start = GetButton(p.layer, ui.ID_CTRL_BUTTON_102);
	start:SetLuaDelegate(p.OnBtnClick);
	start:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_102 == tag then
			uiNode:SetVisible(false);
			login_ui.ShowUI();
		end
	end
end



