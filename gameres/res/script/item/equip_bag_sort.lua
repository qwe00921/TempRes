equip_bag_sort = {}
local p = equip_bag_sort;
local ui = ui_equip_bag_sort_view;
function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible(true);
		return;
	end
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init(layer);
	layer:SetSwallowTouch(false);
	
	GetUIRoot():AddDlg(layer);
	LoadUI("equip_bag_sort_view.xui",layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
	
	equip_room.sortBtnMark = MARK_ON;
end

function p.SetDelegate()
	local byLevelBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SOTR_LEVEL );
	byLevelBtn:SetLuaDelegate( p.OnBtnClick );

	local byStarBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SORT_STAR );
	byStarBtn:SetLuaDelegate( p.OnBtnClick );

end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_SOTR_LEVEL == tag then
			WriteCon("**========byLevelBtn========**");
			equip_room.sortByBtnEvent(CARD_BAG_SORT_BY_LEVEL);
			
		elseif ui.ID_CTRL_BUTTON_SORT_STAR == tag then
			WriteCon("**=======byStarBtn=======**");
			equip_room.sortByBtnEvent(CARD_BAG_SORT_BY_STAR);
		end
		p.CloseUI();
	end
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		equip_room.sortBtnMark = MARK_OFF;
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
		equip_room.sortBtnMark = MARK_OFF;
	end
end
