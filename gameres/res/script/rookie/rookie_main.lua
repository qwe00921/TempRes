
--新手引导

rookie_main = {};
local p = rookie_main;

p.layer = nil;
p.faceImage = nil;
p.colorLabel = nil;

local ui = ui_learning;

function p.ShowUI( step )
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.ShowLearningStep( step );
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch( true );
	
	GetUIRoot():AddDlg( layer );
	LoadDlg("learning.xui", layer, nil);
	
	p.layer = layer;
	
	p.InitControllers();
	
	p.ShowLearningStep( step );
end

function p.InitControllers()
	p.faceImage = GetImage( p.layer, ui.ID_CTRL_PICTURE_51 );
	p.colorLabel = GetColorLabel( p.layer, ui.ID_CTRL_COLOR_LABEL_52 );
end

function p.ShowLearningStep( step )
	
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.faceImage = nil;
		p.colorLabel = nil;
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end