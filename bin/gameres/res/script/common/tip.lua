--------------------------------------------------------------
-- FileName: 	tip.lua
-- author:		zjj, 2013/09/17
-- purpose:		提示效果
--------------------------------------------------------------

tip = {}
local p = tip;

p.layer = nil;

p.TIPTYPE_NORMAL  = 1; --正常
p.TIPTYPE_MOVE_IN = 2; --飞进

--显示UI 
function p.ShowTip( Str , tipType )

    tipType = tipType or p.TIPTYPE_NORMAL;
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.ShowEffect( Str , tipType );
		return;
	end
	
	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	layer:SetSwallowTouch(true);
    layer:SetFrameRectFull();
	layer:SetName("tip_layer");
    
	GetUIRoot():AddChildZ( layer, GetUIRoot():GetZOrderForNextDlg());
    LoadUI("tip.xui", layer, nil);
	
	p.layer = layer;
    p.ShowEffect( Str , tipType );
    
    local closeBtn =  GetButton(p.layer,ui_tip.ID_CTRL_BUTTON_CLOSE);
    closeBtn:SetLuaDelegate(p.OnUIEvent);
end

function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_tip.ID_CTRL_BUTTON_CLOSE == tag ) then
            p.CloseTip();
        end
    end
end

function p.ShowEffect( Str , tipType)
	
	local bg = GetImage( p.layer,ui_tip.ID_CTRL_PICTURE_BG );
	local label = GetColorLabel( p.layer, ui_tip.ID_CTRL_COLOR_LABEL_TIP );
	
	bg:ClearAllActionEffect();
	label:ClearAllActionEffect();
	
	bg:SetVisible( false );
	label:SetVisible( false );
	
	--设置文本
	if Str ~= nil then
	   label:SetText( Str );
	end
	
	local id = nil;
	
	--播放特效
	
	if tipType == p.TIPTYPE_NORMAL then 
	   
	   id = bg:AddActionEffect("ui.tip_effect_normal");
       label:AddActionEffect("ui.tip_effect_normal");
       
    elseif tipType == p.TIPTYPE_MOVE_IN then
       id = bg:AddActionEffect("ui.tip_effect_move_in");
       label:AddActionEffect("ui.tip_effect_move_in");
	end
	
	RegActionEffectCallBack( id, p.CloseUI );
end

--点击关闭tip
function p.CloseTip()
    if p.layer ~= nil then
        local closeBtn =  GetButton(p.layer,ui_tip.ID_CTRL_BUTTON_CLOSE);
        closeBtn:SetVisible( false );
        p.layer:SetSwallowTouch( false );
        
        local bg = GetImage( p.layer,ui_tip.ID_CTRL_PICTURE_BG );
        local label = GetColorLabel( p.layer, ui_tip.ID_CTRL_COLOR_LABEL_TIP );
        local id = bg:AddActionEffect("ui.tip_effect_close");
        label:AddActionEffect("ui.tip_effect_close");
        
        RegActionEffectCallBack( id, p.CloseUI );
    end
end

--设置可见
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

