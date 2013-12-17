card_intensify2 = {}
local p = card_intensify2;
p.layer = nil;

local ui = ui_card_intensify2;

function p.ShowUI(baseCardInfo)
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		return;
	end
	
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	layer:NoMask();
    layer:Init();   
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddDlg(layer);
    LoadDlg("card_intensify2.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);	
	p.InitUI(baseCardInfo);
end

function p.InitUI(baseCardInfo)
	
	
end

function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end

function p.CloseUI()
    if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;	
    end
end

function p.SetDelegate(layer)
	local closeBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	closeBtn:SetLuaDelegate(p.OnUIClickEvent);

end
	
function p.OnUIClickEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --·µ»Ø
			p.CloseUI();
		else
		
		end;
	end
end		

