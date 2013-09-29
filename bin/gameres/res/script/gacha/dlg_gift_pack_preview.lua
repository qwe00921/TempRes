--------------------------------------------------------------
-- FileName: 	dlg_gift_pack_preview.lua
-- author:		zjj, 2013/09/11
-- purpose:		礼包预览、购买成功界面
--------------------------------------------------------------

dlg_gift_pack_preview = {}
local p = dlg_gift_pack_preview;

p.layer = nil;
p.item = nil;
p.maxNum = nil;

--显示UI
function p.ShowUI( item )
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_gift_pack_preview.xui", layer, nil);
	
	if item ~= nil then
	   p.item = item;
	end
	
	p.layer = layer;
    WriteCon( "libao id" ..item.item_id );
    
	p.SetDelegate();
	p.Init( item );
end

function p.Init( item )
    local giftId = item.item_id;
    local row_item1_num = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num1"));
    local row_item2_num = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num2"));
    local row_item3_num = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num3"));
    local row_item4_num = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num4"));
    local row_item5_num = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num5"));
    local row_item6_num = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num6"));

    if row_item1_num ~= 0 then
        --名称 
        local row_item1_id = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_id1"));
        local row_name = SelectCell( T_ITEM, row_item1_id, "name" );
        local nameLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME1 );
        nameLab:SetText( tostring( row_name));
        --数量
        local numLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM1 );
        local row_num =  tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num1"));
        numLab:SetText( tostring( row_item1_num ));
    end
    
    if row_item2_num ~= 0 then
        --名称 
        local row_item2_id = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_id2"));
        local row_name = SelectCell( T_ITEM, row_item2_id, "name" );
        local nameLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME2 );
        nameLab:SetText( tostring( row_name));
        --数量
        local numLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM2 );
        local row_num =  tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num2"));
        numLab:SetText( tostring( row_item2_num ));
    end  
      
	if row_item3_num ~= 0 then
        --名称 
        local row_item3_id = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_id3"));
        local row_name = SelectCell( T_ITEM, row_item3_id, "name" );
        local nameLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME3 );
        nameLab:SetText( tostring( row_name));
        --数量
        local numLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM3 );
        local row_num =  tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num3"));
        numLab:SetText( tostring( row_item3_num ));
    end
    
    if row_item4_num ~= 0 then
        --名称 
        local row_item4_id = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_id4"));
        WriteCon("--------"..row_item4_id );
        local row_name = SelectCell( T_ITEM, row_item4_id, "name" );
        local nameLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME4 );
        nameLab:SetText( tostring( row_name));
        --数量
        local numLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM4 );
        local row_num =  tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num4"));
        numLab:SetText( tostring( row_item4_num ));
    end
        
   if row_item5_num ~= 0 then
        --名称 
        local row_item5_id = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_id5"));
        local row_name = SelectCell( T_ITEM, row_item5_id, "name" );
        local nameLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME5 );
        nameLab:SetText( tostring( row_name));
        --数量
        local numLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM5 );
        local row_num =  tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num5"));
        numLab:SetText( tostring( row_item5_num ));
    end
        
    if row_item6_num ~= 0 then
        --名称 
        local row_item6_id = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_id6"));
        local row_name = SelectCell( T_ITEM, row_item6_id, "name" );
        local nameLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME6 );
        nameLab:SetText( tostring( row_name));
        --数量
        local numLab = GetLabel( p.layer, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM6 );
        local row_num =  tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num6"));
        numLab:SetText( tostring( row_item6_num ));
    end
end


--设置事件处理
function p.SetDelegate()
    local okBtn =  GetButton(p.layer,ui_dlg_gift_pack_preview.ID_CTRL_BUTTON_OK);
    okBtn:SetLuaDelegate(p.OnGitfPreviewUIEvent);
end



function p.OnGitfPreviewUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
	    --确定
		if( ui_dlg_gift_pack_preview.ID_CTRL_BUTTON_OK == tag ) then
		    p.CloseUI();
		end
	end
end


--设置可见
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

