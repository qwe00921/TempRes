
dlg_menu = {};
local p = dlg_menu;

local ui = ui_main_menu;
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
    
	--GetUIRoot():AddChild(layer);
	GetUIRoot():AddDlg(layer);
	LoadUI("main_menu.xui", layer, nil);
	layer:SetZOrder(9);
    
	p.layer = layer;
	p.SetDelegate();
end

function p.SetDelegate()
	local gashapon = GetButton( p.layer, ui.ID_CTRL_BUTTON_GASHAPON );
	gashapon:SetLuaDelegate( p.OnBtnClick );
	
	local pvp = GetButton( p.layer, ui.ID_CTRL_BUTTON_PVP );
	pvp:SetLuaDelegate( p.OnBtnClick );
	
	local bag = GetButton( p.layer, ui.ID_CTRL_BUTTON_BAG );
	bag:SetLuaDelegate( p.OnBtnClick );
	
	local card_group = GetButton( p.layer, ui.ID_CTRL_BUTTON_CARD_GROUP );
	card_group:SetLuaDelegate( p.OnBtnClick );
	
	local quest = GetButton( p.layer, ui.ID_CTRL_BUTTON_QUEST );
	quest:SetLuaDelegate( p.OnBtnClick );
	
	local home_page = GetButton( p.layer, ui.ID_CTRL_BUTTON_HOME_PAGE );
	home_page:SetLuaDelegate( p.OnBtnClick );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		--maininterface.CloseAllPanel();
		
		if ui.ID_CTRL_BUTTON_GASHAPON == tag then
			WriteCon("**========Ť��========**");
			dlg_gacha.ShowUI( SHOP_ITEM );
			maininterface.BecomeBackground();
			
		elseif ui.ID_CTRL_BUTTON_PVP == tag then
			WriteCon("**=======������=======**");
		elseif ui.ID_CTRL_BUTTON_BAG == tag then
			WriteCon("**========����========**");
			pack_box.ShowUI();
			--������UI
			--maininterface.CloseAllPanel();
			--maininterface.HideUI();
		elseif ui.ID_CTRL_BUTTON_CARD_GROUP == tag then
			WriteCon("**========����========**");
			--card_bag_mian.ShowUI();
			dlg_card_group_main.ShowUI();
			
		elseif ui.ID_CTRL_BUTTON_QUEST == tag then
			WriteCon("**========����========**");
			stageMap_main.OpenWorldMap();
			--������UI
			--maininterface.CloseAllPanel();
			maininterface.HideUI();
		elseif ui.ID_CTRL_BUTTON_HOME_PAGE == tag then
			WriteCon("**========��ҳ========**");
			
			world_map.CheckToCloseMap();
		end
		maininterface.CloseAllPanel();
	end
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

