
dlg_battlearray = {};
local p = dlg_battlearray;

local ui = ui_main_battlearray;
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
    
	GetUIRoot():AddChild(layer);
	LoadUI("main_battlearray.xui", layer, nil);
    
	p.layer = layer;
	--p.SetDelegate();
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

