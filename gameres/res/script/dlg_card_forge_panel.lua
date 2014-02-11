--------------------------------------------------------------
-- FileName:    dlg_card_forge_panel.lua
-- author:      hst, 2013/09/5
-- purpose:     主界面卡片锻造子按钮组
--------------------------------------------------------------

dlg_card_forge_panel = {}
local p = dlg_card_forge_panel;
local ui = ui_dlg_card_forge_panel;

p.layer = nil;

--按钮标签
p.chapterTag = {};

--显示UI
function p.ShowUI( btnObj )
    if btnObj == nil then return false end;
    
    --显示或创建layer
    if p.layer ~= nil then
        p.layer:SetVisible( true );
    else
        local layer = createNDUIDialog();
        if layer == nil then
            return false;
        end
        
        layer:NoMask();
        layer:Init(layer);
        layer:SetSwallowTouch(false);

        GetUIRoot():AddChild(layer);    
        LoadDlg("dlg_card_forge_panel.xui", layer, nil);
        p.layer = layer;
        p.SetDelegate();
    end
    
    --设置位置和尺寸
    local pos = btnObj:GetCenterPos();
    local bgSize = p.GetBgSize();
    local x = pos.x - 0.5f * bgSize.w;
    local y = pos.y - 0.6f * bgSize.h;
    local rect = CCRectMake( x, y, bgSize.w, bgSize.h );
    p.layer:SetFrameRect( rect );
end

--初始化按钮
function p.SetDelegate( )
    --卡牌强化
    local btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_INTENSIFY);
    btn:SetLuaDelegate(p.OnBtnClick);
    
    --卡牌进化
    btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_EVOLUTION);
    btn:SetLuaDelegate(p.OnBtnClick);
    
    --卡牌融合
    btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_FUSE);
    btn:SetLuaDelegate(p.OnBtnClick);
end


--事件处理
function p.OnBtnClick(uiNode, uiEventType, param)   
    if IsClickEvent( uiEventType ) then
        local tag = uiNode:GetTag();
        
        if ( ui.ID_CTRL_BUTTON_INTENSIFY == tag ) then  
                --WriteCon( "卡牌强化");
                dlg_card_box_mainui.ShowUI( CARD_INTENT_INTENSIFY );
                
        elseif ( ui.ID_CTRL_BUTTON_EVOLUTION == tag ) then
                --WriteCon( "卡牌进化");
                dlg_card_box_mainui.ShowUI( CARD_INTENT_EVOLUTION );
                
        elseif ( ui.ID_CTRL_BUTTON_FUSE == tag ) then
                --WriteCon( "卡牌融合");
                dlg_card_fuse.ShowUI();
                
        end
    end
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

--获取底板尺寸
function p.GetBgSize()
    if p.layer ~= nil then
        local bg = GetImage( p.layer, ui.ID_CTRL_PICTURE_BG );
        if bg ~= nil then
            return bg:GetFrameSize();
        end
    end
    return SizeZero;
end