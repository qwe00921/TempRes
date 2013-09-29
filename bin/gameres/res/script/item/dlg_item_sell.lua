--------------------------------------------------------------
-- FileName:    dlg_item_sell.lua
-- author:      hst, 2013年9月5日
-- purpose:     道具出售
--------------------------------------------------------------

dlg_item_sell = {}
local p = dlg_item_sell;
local ui = ui_dlg_item_sell;
p.layer = nil;
p.item = nil;
p.sellNumber = 1;
p.maxNumber = 0;

---------显示UI----------
function p.ShowUI( item )
    if item == nil then
        return ;
    end
    p.item = item;
    p.maxNumber = tonumber( item.num );
    if p.layer ~= nil then
        p.layer:SetVisible( true );
        return ;
    end
    
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
    layer:Init();
    GetUIRoot():AddDlg( layer );
    LoadDlg("dlg_item_sell.xui", layer, nil);
    
    p.SetDelegate(layer);
    p.layer = layer;    
    p.ShowItem( item );
end


--设置事件处理
function p.SetDelegate(layer)
    local confirmBtn = GetButton(layer,ui.ID_CTRL_BUTTON_CONFIRM);
    confirmBtn:SetLuaDelegate(p.OnUIEvent);
    
    local cancelBtn = GetButton(layer,ui.ID_CTRL_BUTTON_CANCEL);
    cancelBtn:SetLuaDelegate(p.OnUIEvent);
    
    local subBtn = GetButton(layer,ui.ID_CTRL_BUTTON_SUBNUMBER);
    subBtn:SetLuaDelegate(p.OnUIEvent);
    
    local addBtn = GetButton(layer,ui.ID_CTRL_BUTTON_ADDNUMBER);
    addBtn:SetLuaDelegate(p.OnUIEvent);
    
    local closeBtn = GetButton(layer,ui.ID_CTRL_BUTTON_CLOSEUI);
    closeBtn:SetLuaDelegate(p.OnUIEvent);
end

--事件处理
function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        --确认出售
        if ( ui.ID_CTRL_BUTTON_CONFIRM == tag ) then
            back_pack_mgr.SellUserItem( p.item.id, p.sellNumber );
            p.CloseUI();
            dlg_item_detail.CloseUI();
            dlg_item_equip_detail.CloseUI();
            
        elseif ( ui.ID_CTRL_BUTTON_CANCEL == tag ) then
            p.CloseUI();
            
        elseif ( ui.ID_CTRL_BUTTON_SUBNUMBER == tag ) then 
            p.SubSellNumber();
            
        elseif ( ui.ID_CTRL_BUTTON_ADDNUMBER == tag ) then
            p.AddSellNumber();
            
        elseif ( ui.ID_CTRL_BUTTON_CLOSEUI == tag ) then
            p.CloseUI();
            
        end     
    end
end

function p.ShowItem( item )
    --道具图片
    local pic = 9;
    --[[
    if tonumber( item.type ) == ITEM_TYPE_3 then
        pic = math.random(0,2);
    elseif tonumber( item.type ) ==ITEM_TYPE_2 then
        pic = math.random(3,5); 
    else
        pic = math.random(6,8);     
    end
    --]]
    local itemPic = GetImage( p.layer,ui.ID_CTRL_PICTURE_ITEM );
    itemPic:SetPicture( GetPictureByAni("item.item_db", pic) );
    
    --道具名称
    local itemName = GetLabel( p.layer, ui.ID_CTRL_TEXT_ITEM_NAME );
    itemName:SetText( item.name );
    
    --出售数量
    local sellNumber = GetLabel( p.layer, ui.ID_CTRL_TEXT_SELLNUMBER );
    sellNumber:SetText( p.sellNumber.."/"..p.maxNumber );
    
    --价格
    local allSellPrice = GetLabel( p.layer, ui.ID_CTRL_TEXT_ITEM_SELLPRICE );
    allSellPrice:SetText( item.sellprice );
    
end

function p.AddSellNumber()
    if p.sellNumber < p.maxNumber then
    	p.sellNumber = p.sellNumber + 1;
    	p.UpdataUI();
    end
end

function p.SubSellNumber()
    if p.sellNumber > 1 then
        p.sellNumber = p.sellNumber - 1;
        p.UpdataUI()
    end
end

function p.UpdataUI()
    local allPrice = tonumber( p.item.sellprice ) * p.sellNumber;
    
	--出售数量
    local sellNumber = GetLabel( p.layer, ui.ID_CTRL_TEXT_SELLNUMBER );
    sellNumber:SetText( p.sellNumber.."/"..p.maxNumber );
    
    --价格
    local allSellPrice = GetLabel( p.layer, ui.ID_CTRL_TEXT_ITEM_SELLPRICE );
    allSellPrice:SetText( tostring( allPrice ) );
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
        p.item = nil
        p.sellNumber = 1;
        p.maxNumber = 0;
    end
end