--------------------------------------------------------------
-- FileName: 	dlg_item_detail.lua
-- author:		hst, 2013��7��24��
-- purpose:		��������
--------------------------------------------------------------

dlg_item_detail = {}
local p = dlg_item_detail;
p.layer = nil;
p.item = nil;

---------��ʾUI----------
function p.ShowUI( item )
    --dlg_back_pack.CloseUI();
    if item == nil then
    	return ;
    end
    p.item = item;
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
    LoadDlg("dlg_item_detail.xui", layer, nil);
	
	p.SetDelegate(layer);
	p.layer = layer;	
	p.ShowItem( item );
end


--�����¼�����
function p.SetDelegate(layer)
    --����
	local pBtn01 = GetButton(layer,ui_dlg_item_detail.ID_CTRL_BUTTON_6);
    pBtn01:SetLuaDelegate(p.OnUIEvent);
    --�ϳ�
    local pBtn02 = GetButton(layer,ui_dlg_item_detail.ID_CTRL_BUTTON_9);
    pBtn02:SetLuaDelegate(p.OnUIEvent);
    --�ر�
    local pBtn03 = GetButton(layer,ui_dlg_item_detail.ID_CTRL_BUTTON_7);
    pBtn03:SetLuaDelegate(p.OnUIEvent);
end

--�¼�����
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui_dlg_item_detail.ID_CTRL_BUTTON_6 == tag ) then
            --WriteCon("����");
            dlg_item_sell.ShowUI( p.item );
            --dlg_msgbox.ShowYesNo( ToUtf8( "ȷ����ʾ��" ), ToUtf8( "���ۼ�"..p.item.sellprice ), p.OnMsgBoxCallback, p.layer);
            
        elseif ( ui_dlg_item_detail.ID_CTRL_BUTTON_9 == tag ) then
            --WriteCon("�ϳ�");
        elseif ( ui_dlg_item_detail.ID_CTRL_BUTTON_7 == tag ) then  
            --WriteCon("�ر�");
            p.CloseUI();
		end		
	end
end

function p.OnMsgBoxCallback( result )
    if result then
        back_pack_mgr.SellUserItem( p.item.id, p.item.num );
        p.CloseUI();
    end
end

function p.ShowItem( item )
    p.InitBtn( item.type );
    
    --����ͼƬ
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
    local itemPic = GetImage( p.layer,ui_dlg_item_detail.ID_CTRL_PICTURE_3 );
    itemPic:SetPicture( GetPictureByAni("item.item_db", pic) );
    
    --��������
    local itemName = GetLabel( p.layer, ui_dlg_item_detail.ID_CTRL_TEXT_4 );
    itemName:SetText( item.name );
    
    --����˵��
    local description = GetLabel( p.layer, ui_dlg_item_detail.ID_CTRL_TEXT_5 );
    description:SetText( item.description );
end

--��ʹ������
function p.InitBtn( itemType )
    --ʹ��/�ϳɰ�ť
    local pBtn01 = GetButton(p.layer,ui_dlg_item_detail.ID_CTRL_BUTTON_9);
    
    if tonumber( itemType ) == ITEM_TYPE_1 then
        pBtn01:SetText( GetStr( "item_consume" ) );
    elseif tonumber( itemType ) == ITEM_TYPE_2 then
        pBtn01:SetText( GetStr( "item_assemble" ) );
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
        p.item = nil
    end
end