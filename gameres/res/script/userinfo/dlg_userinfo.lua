
dlg_userinfo = {}
local p = dlg_userinfo;

p.layer = nil;

local ui = ui_main_userinfo

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
	LoadUI("main_userinfo.xui", layer, nil);
    
	p.layer = layer;
	--p.SetDelegate(layer);
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
    end
end

