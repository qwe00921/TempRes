equip_sell_statistics = {}
local p = equip_sell_statistics;
local ui = ui_equip_sell_list_statistics;
p.layer = nil;

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
	LoadUI("equip_sell_list_statistics.xui",layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
	p.setSellCardNum(0)
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
			--card_bag_mian.clearSellClick();
			p.Init();
			equip_sell.clearDate();
		elseif ui.ID_CTRL_BUTTON_SELL == tag then
			--card_bag_mian.sellCardClick();
			if equip_sell.selectNum == 0 then
				dlg_msgbox.ShowOK(GetStr("equip_sell_title"),GetStr("equip_sell_nul"),equip_sell.OnMsgCallback,p.layer);
			else
				dlg_msgbox.ShowYesNo(GetStr("equip_sell_title"),GetStr("equip_sell_cont")..tostring(equip_sell.selectNum)..GetStr("equip_sell_cont_2"),equip_sell.OnMsgBoxCallback,p.layer);
			end
		end
	end
end

function p.setSellMoney(num)
	if num == 0 or num == nil then
		num = 0
	end
	local equipSellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_SELL_GOLD);
	equipSellMoney:SetText(tostring(num)); 
end

function p.setSellCardNum(num)
	if num == 0 or num == nil then
		num = 0
	end
	local equipCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_MATTER_NUM);
	equipCount:SetText(tostring(num).."/10"); 
	

end

function p.Init()
	p.setSellCardNum(0)
	p.setSellMoney(0)
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


