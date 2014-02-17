card_bag_sort = {}
local p = card_bag_sort;
local ui = ui_card_bag_sort_view;
p.id= nil;
function p.ShowUI(id)
	if p.layer ~= nil then
		p.layer:SetVisible(true);
		return;
	end
	p.id = id;
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init(layer);
	layer:SetSwallowTouch(false);
	
	GetUIRoot():AddDlg(layer);
	LoadUI("card_bag_sort_view.xui",layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
	
	if id == 0 then
		card_bag_mian.sortBtnMark = MARK_ON;
	elseif id == 1 then
		card_intensify.sortBtnMark = MARK_ON;
	elseif id == 2 then
		card_intensify2.sortBtnMark = MARK_ON;
	end
	--card_bag_mian.sortBtnMark = MARK_ON;
end

function p.SetDelegate()
	local byLevelBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SOTR_LEVEL );
	byLevelBtn:SetLuaDelegate( p.OnBtnClick );

	local byStarBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SORT_STAR );
	byStarBtn:SetLuaDelegate( p.OnBtnClick );

	local byTypeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SOTR_ITEM );
	byTypeBtn:SetLuaDelegate( p.OnBtnClick );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_SOTR_LEVEL == tag then
			--WriteCon("**========byLevelBtn========**");
			--card_bag_mian.sortByBtnEvent(CARD_BAG_SORT_BY_LEVEL);
			if p.id == 0 then
				card_bag_mian.sortByBtnEvent(CARD_BAG_SORT_BY_LEVEL);
			elseif p.id == 1 then
				card_intensify.sortByBtnEvent(CARD_BAG_SORT_BY_LEVEL);
			elseif p.id == 2 then
				card_intensify2.sortByBtnEvent(CARD_BAG_SORT_BY_LEVEL);
			end
		elseif ui.ID_CTRL_BUTTON_SORT_STAR == tag then
			--WriteCon("**=======byStarBtn=======**");
			--card_bag_mian.sortByBtnEvent(CARD_BAG_SORT_BY_STAR);
			
			if p.id == 0 then
				card_bag_mian.sortByBtnEvent(CARD_BAG_SORT_BY_STAR);
			elseif p.id == 1 then
				card_intensify.sortByBtnEvent(CARD_BAG_SORT_BY_STAR);
			elseif p.id == 2 then
				card_intensify2.sortByBtnEvent(CARD_BAG_SORT_BY_STAR);
			end
		elseif ui.ID_CTRL_BUTTON_SOTR_ITEM == tag then
			--WriteCon("**========byTypeBtn========**");
			--card_bag_mian.sortByBtnEvent(CARD_BAG_SORT_BY_TYPE);
			
			if p.id == 0 then
				card_bag_mian.sortByBtnEvent(CARD_BAG_SORT_BY_TYPE);
			elseif p.id == 1 then
				card_intensify.sortByBtnEvent(CARD_BAG_SORT_BY_TIME);
			elseif p.id == 2 then
				card_intensify2.sortByBtnEvent(CARD_BAG_SORT_BY_TIME);
			end
		end
		p.HideUI();
		p.CloseUI();
	end
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		if p.id == 0 then
			card_bag_mian.sortBtnMark = MARK_OFF;
		elseif p.id == 1 then
			card_intensify.sortBtnMark = MARK_OFF;
		elseif p.id == 2 then
			card_intensify2.sortBtnMark = MARK_OFF;
		end
		p.id = nil;
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
		if p.id == 0 then
			card_bag_mian.sortBtnMark = MARK_OFF;
		elseif p.id == 1 then
			card_intensify.sortBtnMark = MARK_OFF;
		elseif p.id == 2 then
			card_intensify2.sortBtnMark = MARK_OFF;
		end
	end
end
