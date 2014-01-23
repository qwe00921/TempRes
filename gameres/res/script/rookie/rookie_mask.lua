
rookie_mask = {};
local p = rookie_mask;

p.layer = nil;
p.faceImage = nil;
p.colorLabel = nil;
p.delegateBtn = nil;
p.step = 0;
p.substep = 0;
p.contentStr = "";
p.contentStrLn = 0;
p.contentIndex = 1;
p.timerId = nil;

local ui = ui_learning;

function p.ShowUI( step, substep )
	p.step = step;
	p.substep = substep;
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		--设置高亮按钮位置
		p.ShowRookieStep();
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
	p.layer = layer;
	
	p.InitControllers();
	
	--设置高亮按钮位置
	p.ShowRookieStep();
end

function p.InitControllers()
	p.faceImage = GetImage( p.layer, ui.ID_CTRL_PICTURE_51 );
	p.colorLabel = GetColorLabel( p.layer, ui.ID_CTRL_COLOR_LABEL_52 );
	
	p.colorLabel:SetHorzAlign( 0 );
	p.colorLabel:SetVertAlign( 1 );
	
	p.delegateBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_5 );
	
	p.delegateBtn:SetLuaDelegate( p.OnBtnClick );
	p.delegateBtn:SetEnabled( false );
	
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_56 );
	btn:SetLuaDelegate( p.OnBtnClick );
end

--设置高亮按钮位置
function p.ShowRookieStep()
	local rect = rookie_main.GetHighLightRect( p.step, p.substep );
	if rect ~= nil then
		p.delegateBtn = p.delegateBtn or GetButton( p.layer, ui.ID_CTRL_BUTTON_5 );
		p.delegateBtn:SetFrameRect( rect );
		p.delegateBtn:SetEnabled( true );
	end
	
	p.contentStr = "测试文字1测试文字1测试文字1测试文字1测试文字1测试文字1测试文字1测试文字1测试文字1";
	p.contentStrLn = GetCharCountUtf8( p.contentStr );	
	p.contentIndex = 1;

	if p.timerId ~= nil then
		KillTimer( p.timerId );
		p.timerId = nil;
	end
	
	--p.timerId = SetTimer( p.DoEffectContent, 0.1f );
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_5 == tag then
			rookie_main.MaskTouchCallBack( p.step, p.substep );
			p.HideUI();
			p.CloseUI();
		elseif ui.ID_CTRL_BUTTON_56 == tag then
			WriteConWarning( "立即显示全部文字" );
			--立即显示全部文字
			p.ShowTextAtOnce();
		end
	end
end

function p.DoEffectContent()
	if p.colorLabel == nil then
    	return ;
    end

	local strText = GetSubStringUtf8( p.contentStr, p.contentIndex );
	--WriteCon(strText);
	p.colorLabel:SetText(strText);

	p.contentIndex = p.contentIndex + 1;
	if p.contentIndex > p.contentStrLn and p.timerId ~= nil then
		KillTimer( p.timerId );
		p.timerId = nil;
	end
end

function p.ShowTextAtOnce()
	if p.colorLabel == nil then
    	return ;
    end
	
	local strText = p.contentStr;
	p.colorLabel:SetText( strText );
	
	p.contentIndex = 1;
	if p.timerId ~= nil then
		KillTimer( p.timerId );
		p.timerId = nil;
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
		p.contentStr = "";
		p.contentStrLn = 0;
		p.timerId = nil;
		p.contentIndex = 1;
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end


