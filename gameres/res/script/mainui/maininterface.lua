
maininterface = {}
local p = maininterface;

p.layer = nil;

local ui = ui_main_interface

function p.ShowUI(userinfo)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		dlg_battlearray.ShowUI();
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
	LoadUI("main_interface.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
	
	dlg_userinfo.ShowUI(userinfo);
	dlg_menu.ShowUI();
	p.ShowBillboard();
	
end

--���ð�ť
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	--btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate()
	local shop = GetButton( p.layer, ui.ID_CTRL_BUTTON_SHOP );
	p.SetBtn( shop );
	
	local mail = GetButton( p.layer, ui.ID_CTRL_BUTTON_MAIL );
	p.SetBtn( mail );
	
	local activity = GetButton( p.layer, ui.ID_CTRL_BUTTON_ACTIVITY );
	p.SetBtn( activity );
	
	local more = GetButton( p.layer, ui.ID_CTRL_BUTTON_MORE );
	p.SetBtn( more );
	
	local bgBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_BG_BTN );
	p.SetBtn( bgBtn );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		p.CloseAllPanel();
		
		if ui.ID_CTRL_BUTTON_SHOP == tag then
			WriteCon("**========�̳�========**");
		elseif ui.ID_CTRL_BUTTON_MAIL == tag then
			WriteCon("**========�ʼ�========**");
		elseif ui.ID_CTRL_BUTTON_ACTIVITY == tag then
			WriteCon("**========�========**");
		elseif ui.ID_CTRL_BUTTON_MORE == tag then
			WriteCon("**======������ť======**");
			dlg_btn_list.ShowUI();
		end
	end
end

--�ر������
function p.CloseAllPanel()
	dlg_btn_list.CloseUI();
end

--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		dlg_battlearray.HideUI();
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
		dlg_battlearray.CloseUI();
    end
end

--������ʾ�˵���ť
function p.ShowMenuBtn()
	local menu = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_MEMU);
	if menu then
		menu:SetVisible(true);
	end
end

--�������ʾ
function p.ShowBillboard()
	billboard.ShowUIWithInit(layer); 
end
