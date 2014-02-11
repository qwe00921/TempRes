
rookie_mask = {};
local p = rookie_mask;

p.background = nil;
p.layer = nil;
p.maskLayer = nil;
p.faceImage = nil;
p.colorLabel = nil;
p.step = 0;
p.substep = 0;
p.contentStr = "";
p.contentStrLn = 0;
p.contentIndex = 1;
p.timerId = nil;
p.textList = nil;

local ui = ui_learning;

function p.ShowUI( step, substep )
	p.step = step;
	p.substep = substep;
	
	if p.layer ~= nil and p.maskLayer ~= nil then
		p.maskLayer:SetVisible( true );
		p.layer:SetVisible( true );
		--设置高亮按钮位置
		p.ShowRookieStep();
		return;
	end

	local maskLayer = createNDUIDialog();
	if maskLayer == nil then
		return false;
	end
	maskLayer:NoMask();
	maskLayer:Init();
	maskLayer:SetSwallowTouch( true );
	maskLayer:SetFrameRectFull();	
	maskLayer:SetLuaDelegate( p.OnTouchLayer );
	
	p.maskLayer = maskLayer;
	GetUIRoot():SetTrainingMode( true, maskLayer );  --设置为新手指导模式，传递新手指导的那个layer

	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch( true );
	layer:SetFrameRectFull();
	
	LoadDlg( "learning.xui", layer, nil );
	GetUIRoot():AddChildZ( p.layer, 20000 );
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
end

--设置高亮按钮位置
function p.ShowRookieStep()
	local rect = rookie_main.GetHighLightRectList( p.step, p.substep );
	rect = CCRectMake( 150,150,150,150 );
	GetUIRoot():SetHighLightArea( rect );
	
	p.textList = p.textList or SelectRowList( T_ROOKIE_GUIDE, "guide_id", p.step );
	
	--p.contentStr = "测试文字1测试文字1测试测试测试测试";
	p.contentStr = "";
	local picData = nil;
	if p.textList ~= nil and #p.textList > 0 then
		for i = 1, #p.textList do
			local data = p.textList[i] or {};
			if tonumber( data.talk_id ) == p.substep then
				p.contentStr = data.talk_text;
				picData = GetPictureByAni( data.head_pic, 0 );
				break;
			end
		end
	end
	
	p.faceImage:SetPicture( picData );
	
	p.contentStrLn = GetCharCountUtf8( p.contentStr );	
	p.contentIndex = 1;

	if p.timerId ~= nil then
		KillTimer( p.timerId );
		p.timerId = nil;
	end
	
	p.timerId = SetTimer( p.DoEffectContent, 0.04f );
end

function p.OnTouchLayer( uiNode, uiEventType, param )
	local rect = rookie_main.GetDelegateArea( p.step, p.substep );
	if ContainsPoint( rect, param ) then
		rookie_main.MaskTouchCallBack( p.step, p.substep );
	else
		
	end
end

function p.DoEffectContent()
	if p.colorLabel == nil then
    	return ;
    end

	local strText = GetSubStringUtf8( p.contentStr, p.contentIndex );
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
		p.step = 0;
		p.contentStr = "";
		p.contentStrLn = 0;
		p.timerId = nil;
		p.contentIndex = 1;
		p.textList = nil;
	end
	
	if p.maskLayer ~= nil then
		GetUIRoot():SetTrainingMode( false, p.maskLayer );
		p.maskLayer = nil;
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end


