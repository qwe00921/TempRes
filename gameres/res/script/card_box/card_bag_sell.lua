card_bag_sell = {}
local p = card_bag_sell;
local ui = ui_card_bag_sell_veiw;

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
	LoadUI("card_bag_sell_veiw.xui",layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
end

function p.SetDelegate()
	local clearBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_CLEAR );
	clearBtn:SetLuaDelegate( p.OnBtnClick );
	local sellBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_SELL );
	sellBtn:SetLuaDelegate( p.OnBtnClick );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_CLEAR == tag then
			--card_bag_mian.clear_sell_list();
		elseif ui.ID_CTRL_BUTTON_SELL == tag then
			--card_bag_mian.sell_card();
		end
	end
end

function p.setSellMoney(num)
	local sellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_SELL_MONEY );
	cardLevelText:SetText(tostring(num));
end

function p.setSellCardNum(num)
	local sellCardNum = GetLabel(p.layer,ui.ID_CTRL_TEXT_SELL_NUM );
	cardLevelText:SetText(tostring(num));
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
