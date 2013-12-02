card_bag_sort = {}
local p = card_bag_sort;
local ui = ui_card_bag_sort_view;

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
	LoadUI("card_bag_sort_view.xui",layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
	card_bag_mian.sortBtnMark = MARK_ON;
end

function p.SetDelegate()
	local byLevelBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SOTR_LEVEL );
	byLevelBtn:SetLuaDelegate( p.OnBtnClick );

	local byStarBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SORT_STAR );
	byStarBtn:SetLuaDelegate( p.OnBtnClick );

	local byItemBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SOTR_ITEM );
	byItemBtn:SetLuaDelegate( p.OnBtnClick );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_SOTR_LEVEL == tag then
			WriteCon("**========byLevelBtn========**");
			card_bag_mian.sortByBtnEvent(CARD_BAG_SORT_BY_LEVEL);
		elseif ui.ID_CTRL_BUTTON_SORT_STAR == tag then
			WriteCon("**=======byStarBtn=======**");
			card_bag_mian.sortByBtnEvent(CARD_BAG_SORT_BY_STAR);
		elseif ui.ID_CTRL_BUTTON_SOTR_ITEM == tag then
			WriteCon("**========byItemBtn========**");
			card_bag_mian.sortByBtnEvent(CARD_BAG_SORT_BY_TIME);
		end
		p.CloseUI();
	end
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		card_bag_mian.sortBtnMark = MARK_OFF;
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
		card_bag_mian.sortBtnMark = MARK_OFF;
	end
end
