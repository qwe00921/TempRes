

item_choose_list = {};
local p = item_choose_list;

p.layer = nil;

local ui = ui_item_choose_list;

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
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddDlg(layer);

	LoadDlg( "item_choose_list.xui" , layer, nil );
	
	p.layer = layer;
	
	p.SetDelegate();
	p.InitController();
	
	p.ShowItems();
end

function p.SetDelegate()
end

function p.InitController()
end

function p.ShowItems()
end