
maininterface = {}
local p = maininterface;

p.layer = nil;

local ui = ui_main_interface

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		dlg_userinfo2.ShowUI();
		dlg_actAndad.ShowUI();
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
	p.SetDelegate(layer);
	
	dlg_userinfo2.ShowUI();
	dlg_actAndad.ShowUI();
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	--btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate(layer)
	--礼包
	local gift = GetButton(layer, ui.ID_CTRL_MAIN_BUTTON_GIFT);
	p.SetBtn(gift);
	
	--进入世界地图
	local enterMap = GetButton(layer, ui.ID_CTRL_TEMP_BUTTON_MAP);
	p.SetBtn(enterMap);
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_MAIN_BUTTON_GIFT == tag then
			WriteCon("**礼包**");

			p.CloseAllPanel();
		elseif ui.ID_CTRL_TEMP_BUTTON_MAP == tag then
			p.HideUI();	
			p.CloseAllPanel();

			game_main.EnterWorldMap();
		end
	end
end

--关闭子面板
function p.CloseAllPanel()
	dlg_userinfo.CloseUI();
	--dlg_menu.CloseUI();
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		dlg_actAndad.HideUI();
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

--重新显示菜单按钮
function p.ShowMenuBtn()
	local menu = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_MEMU);
	if menu then
		menu:SetVisible(true);
	end
end
