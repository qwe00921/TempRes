
rookie_mask = {};
local p = rookie_mask;

p.layer = nil;
p.faceImage = nil;
p.colorLabel = nil;
p.delegateBtn = nil;
p.step = 0;

local ui = ui_learning;

function p.ShowUI( step )
	p.step = step;
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		--设置高亮按钮位置
		p.ResetDelegate();
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	layer:Init();
	layer:SetSwallowTouch( true );
	layer:SetFrameRectFull();
	
	GetUIRoot():AddChild( layer );
	LoadUI( "learning.xui", layer, nil );
	
	p.InitControllers();
	
	--设置高亮按钮位置
	p.ResetDelegate();
end

function p.InitControllers()
	p.faceImage = GetImage( p.layer, ui.ID_CTRL_PICTURE_51 );
	p.colorLabel = GetColorLabel( p.layer, ui.ID_CTRL_COLOR_LABEL_52 );
	p.delegateBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_5 );
	
	p.delegateBtn:SetLuaDelegate( p.OnBtnClick );
	p.delegateBtn:SetEnabled( false );
end

--设置高亮按钮位置
function p.ResetDelegate()
	local rect = rookie_main.GetHighLightRect();
	if rect ~= nil then
		p.delegateBtn = p.delegateBtn or GetButton( p.layer, ui.ID_CTRL_BUTTON_5 );
		p.delegateBtn:SetFrameRect( rect );
		p.delegateBtn:SetEnabled( true );
	end
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_5 == tag then
			rookie_main.MaskTouchCallBack( p.step );
			p.HideUI();
			p.CloseUI();
		end
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.faceImage = nil;
		p.colorLabel = nil;
		p.delegateBtn = nil;
		p.step = 0;
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end


