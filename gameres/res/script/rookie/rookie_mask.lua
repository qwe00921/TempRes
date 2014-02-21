
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

p.onCallFlag = false;

local uiList = {
	[3]={
		[2]= ui_learning_3_2,
		[3]= ui_learning_3_3,
		[4]= ui_learning_3_4,
		[5]= ui_learning_3_5,
		[6]= ui_learning_3_6,
		[7]= ui_learning_3_7,
		[8]= ui_learning_3_8,
		[9]= ui_learning_3_9,
		[10]= ui_learning_3_10,
		[11]= ui_learning_3_11,
		[12]= ui_learning_3_12,
		[13]= ui_learning_3_13,
	},
	[9] = {
		[2] = ui_learning_9_2,
		[3] = ui_learning_9_3,
		[4] = ui_learning_9_4,
		[5] = ui_learning_9_5,
		[6] = ui_learning_9_6,
		[7] = ui_learning_9_7,
		[8] = ui_learning_9_8,
	},
	
	[11] = {
		[2] = ui_learning_11_2,
		[3] = ui_learning_11_3,
		[4] = ui_learning_11_4,
		[5] = ui_learning_11_5,
		[6] = ui_learning_11_6,
	},
};

local ui = ui_learning;

function p.ShowUI( step, substep )
	p.step = step;
	p.substep = substep;
	
	if p.layer ~= nil and p.maskLayer ~= nil then
		p.maskLayer:SetVisible( true );
		p.layer:SetVisible( true );
		p.ShowRookieText();
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

	p.maskLayer = maskLayer;
	LoadUI( "learning_"..step.."_"..substep..".xui", maskLayer, nil );
	GetUIRoot():AddChildZ( maskLayer, 999999 );

	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	layer:NoMask();            
	layer:Init();
	layer:SetSwallowTouch( false );
	layer:SetFrameRectFull();
	
	LoadUI( "learning.xui", layer, nil );
	GetUIRoot():AddChildZ( layer, 999999 );
	p.layer = layer;
	
	p.InitControllers();
	
	p.ShowRookieText();
end

function p.InitControllers()
	p.faceImage = GetImage( p.layer, ui.ID_CTRL_PICTURE_51 );
	p.colorLabel = GetColorLabel( p.layer, ui.ID_CTRL_COLOR_LABEL_52 );
	
	p.colorLabel:SetHorzAlign( 0 );
	p.colorLabel:SetVertAlign( 1 );

	local index = 1;
	local list = uiList[p.step] or {};	
	local maskUI = list[p.substep] or {};
	while maskUI["ID_CTRL_BUTTON_CALLBACK_"..index] do
		local btn = GetButton( p.maskLayer, maskUI["ID_CTRL_BUTTON_CALLBACK_"..index] );
		btn:SetLuaDelegate( p.OnTouchHightLight );
		btn:SetId( index );
		
		index = index + 1;
	end
end

--设置高亮按钮位置
function p.ShowRookieText()
	p.textList = SelectRowList( T_ROOKIE_GUIDE, "guide_id", p.step );

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

function p.OnTouchHightLight( uiNode, uiEventType, param )
	--通信中无法操作
	if p.onCallFlag then
		return;
	end
	
	WriteConWarning( "step:"..p.step.."substep:"..p.substep );
	
	if IsClickEvent( uiEventType ) then
		local id = uiNode:GetId();
		rookie_main.MaskTouchCallBack( p.step, p.substep, id );
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
		p.maskLayer:LazyClose();
		p.maskLayer = nil;
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
	
	if p.maskLayer ~= nil then
		p.maskLayer:SetVisible( false );
	end
end


