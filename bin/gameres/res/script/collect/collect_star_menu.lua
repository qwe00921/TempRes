--------------------------------------------------------------
-- FileName:    collect_star_menu.lua
-- author:      xyd, 2013/09/16
-- purpose:     星级选择按钮
--------------------------------------------------------------

collect_star_menu = {}
local p = collect_star_menu;
local ui = ui_collect_star_menu;

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
        layer:SetSwallowTouch(true);

		GetUIRoot():AddDlg(layer);  
        LoadDlg("collect_star_menu.xui", layer, nil);
        p.layer = layer;
        p.SetDelegate();
    end
    
    --设置位置和尺寸
    local pos = btnObj:GetCenterPos();
    local bgSize = p.GetBgSize();
    local x = pos.x - 0.5f * bgSize.w;
    local y = pos.y - 0.6f * bgSize.h;
    local rect = CCRectMake( x-8, y+210, bgSize.w, bgSize.h );
    p.layer:SetFrameRect( rect );
end

--初始化按钮
function p.SetDelegate( )
    
    --1星
    local oneStarBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_1);
    oneStarBtn:SetLuaDelegate(p.OnBtnClick);
    
    --2星
    local twoStarBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_2);
    twoStarBtn:SetLuaDelegate(p.OnBtnClick);
    
    --3星
    local threeStarBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_3);
    threeStarBtn:SetLuaDelegate(p.OnBtnClick);
    
    --4星
    local fourStarBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_4);
    fourStarBtn:SetLuaDelegate(p.OnBtnClick);
    
    --5星
    local fiveStarBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_5);
    fiveStarBtn:SetLuaDelegate(p.OnBtnClick);
    
    --6星
    local sixStarBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_6);
    sixStarBtn:SetLuaDelegate(p.OnBtnClick);
end


--事件处理
function p.OnBtnClick(uiNode, uiEventType, param)   
    if IsClickEvent( uiEventType ) then
        local tag = uiNode:GetTag();
        
        if ( ui.ID_CTRL_BUTTON_1 == tag ) then  
                WriteCon( "一星");
                collect_mgr.LoadCardByStar(1);
                p.CloseUI();              
        elseif ( ui.ID_CTRL_BUTTON_2 == tag ) then
                WriteCon( "二星");
                collect_mgr.LoadCardByStar(2);
               	p.CloseUI();
        elseif ( ui.ID_CTRL_BUTTON_3 == tag ) then
                WriteCon( "三星");
                collect_mgr.LoadCardByStar(3);
                p.CloseUI();
        elseif ( ui.ID_CTRL_BUTTON_4 == tag ) then
                WriteCon( "四星");
                collect_mgr.LoadCardByStar(4);
                p.CloseUI(); 
        elseif ( ui.ID_CTRL_BUTTON_5 == tag ) then
                WriteCon( "五星");
                collect_mgr.LoadCardByStar(5);
                p.CloseUI(); 
        elseif ( ui.ID_CTRL_BUTTON_6 == tag ) then
                WriteCon( "六星");
                collect_mgr.LoadCardByStar(6);
                p.CloseUI();
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
        dlg_collect_mainui.starShow = false;
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