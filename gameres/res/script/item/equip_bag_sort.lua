equip_bag_sort = {}
local p = equip_bag_sort;
local ui = ui_equip_bag_sort_view;

p.id = nil;
function p.ShowUI(id)
	if p.layer ~= nil then
		p.layer:SetVisible(true);
		return;
	end
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	p.id = id;
	layer:NoMask();
	layer:Init(layer);
	layer:SetSwallowTouch(false);
	
	GetUIRoot():AddDlg(layer);
	LoadUI("equip_bag_sort_view.xui",layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
	if p.id == 1 then
		equip_room.sortBtnMark = MARK_ON;
	elseif p.id == 2 then
		equip_sell.sortBtnMark = MARK_ON;
	elseif p.id == 3 then
		equip_dress_select.sortBtnMark = MARK_ON;
	end
	
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
			
			
			if p.id == 1 then
				equip_room.sortByBtnEvent(CARD_BAG_SORT_BY_LEVEL);
			elseif p.id == 2 then
				equip_sell.sortByBtnEvent(CARD_BAG_SORT_BY_LEVEL);
			elseif p.id == 3 then
				equip_dress_select.sortByBtnEvent(CARD_BAG_SORT_BY_LEVEL);
			end
	
		elseif ui.ID_CTRL_BUTTON_SORT_STAR == tag then
			WriteCon("**=======byStarBtn=======**");
			if p.id == 1 then
				equip_room.sortByBtnEvent(CARD_BAG_SORT_BY_STAR);
			elseif p.id == 2 then
				equip_sell.sortByBtnEvent(CARD_BAG_SORT_BY_STAR);
			elseif p.id == 3 then
				equip_dress_select.sortByBtnEvent(CARD_BAG_SORT_BY_STAR);
			end
		end
		p.CloseUI();
	end
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		p.id = nil;
		if p.id == 1 then
			equip_room.sortBtnMark = MARK_OFF;
		elseif p.id == 2 then
			equip_sell.sortBtnMark = MARK_OFF;
		elseif p.id == 3 then
			equip_dress_select.sortBtnMark = MARK_OFF;
		end
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
		if p.id == 1 then
			equip_room.sortBtnMark = MARK_OFF;
		elseif p.id == 2 then
			equip_sell.sortBtnMark = MARK_OFF;
		elseif p.id == 3 then
			equip_dress_select.sortBtnMark = MARK_OFF;
		end
	end
end
