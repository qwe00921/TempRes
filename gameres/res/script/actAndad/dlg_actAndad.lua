

dlg_actAndad = {};
local p = dlg_actAndad;

local ui = ui_main_actandad;

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
	LoadUI("main_actANDad.xui", layer, nil);
    
	p.layer = layer;
	--p.SetDelegate();
end

function p.HideUI()
	if p.layer then
		p.layer:SetVisible(false);
	end
end


