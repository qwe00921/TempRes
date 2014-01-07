

country_main = {};
local p = country_main;

p.layer = nil;

local ui = ui_country;

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

	LoadUI( "country.xui" , layer, nil );
	
	p.layer = layer;
	
	--��ʼ���ؼ�
	p.InitController();
	
	--���ô���
	p.SetDelegate();
end

function p.InitController()
	
end

function p.SetDelegate()
	
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