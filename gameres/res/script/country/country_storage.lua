

country_storage = {};
local p = country_storage;

p.layer = nil;

local ui = ui_item_list;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddChild(layer);

	LoadUI( "item_list.xui" , layer, nil );
	
	p.layer = layer;
	
	--设置代理
	p.SetDelegate();
	
	--初始化控件
	p.InitController();
end

function p.SetDelegate()
end

function p.InitController()
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