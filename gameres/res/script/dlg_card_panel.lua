--------------------------------------------------------------
-- FileName:    dlg_card_panel.lua
-- author:      hst, 2013/09/5
-- purpose:     主界面卡片模块子按钮组
--------------------------------------------------------------

dlg_card_panel = {}
local p = dlg_card_panel;
local ui = ui_dlg_card_panel;

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
        LoadDlg("dlg_card_panel.xui", layer, nil);
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
    --卡牌背包
    local btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_CARDBOX);
    btn:SetLuaDelegate(p.OnBtnClick);
    
    --卡牌仓库
    btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_CARDDEPOT);
    btn:SetLuaDelegate(p.OnBtnClick);
    
    --卡牌队伍
    btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_CARDTEAM);
    btn:SetLuaDelegate(p.OnBtnClick);
    
    --技能卡牌
    btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_CARDSKILL);
    btn:SetLuaDelegate(p.OnBtnClick);
    
    --技能碎片
    btn = GetButton(p.layer,ui.ID_CTRL_BUTTON_SKILLCHIP);
    btn:SetLuaDelegate(p.OnBtnClick);
end


--事件处理
function p.OnBtnClick(uiNode, uiEventType, param)   
    if IsClickEvent( uiEventType ) then
        local tag = uiNode:GetTag();
        
        if ( ui.ID_CTRL_BUTTON_CARDBOX == tag ) then  
                WriteCon( "卡牌背包");
                dlg_card_box_mainui.ShowUI( CARD_INTENT_PREVIEW );
                
        elseif ( ui.ID_CTRL_BUTTON_CARDDEPOT == tag ) then
                WriteCon( "卡牌仓库");
                dlg_card_depot.ShowUI();
                
        elseif ( ui.ID_CTRL_BUTTON_CARDTEAM == tag ) then
                WriteCon( "卡牌队伍");
                dlg_card_group.ShowUI();
                
        elseif ( ui.ID_CTRL_BUTTON_CARDSKILL == tag ) then
                WriteCon( "技能卡牌");
                dlg_user_skill.ShowUI(SKILL_INTENT_PREVIEW);
                
        elseif ( ui.ID_CTRL_BUTTON_SKILLCHIP == tag ) then
                WriteCon( "技能碎片");
                dlg_skill_piece_combo.ShowUI();
                
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