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

local PIC_INDEX = 1;
local NAME_INDEX = 2;
local COUNT_INDEX = 3;
local NUM_INDEX = 4;

p.nodeTag = {
	{ui_dlg_gift_pack_preview.ID_CTRL_PICTURE_5 , ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME1, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_21, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM1},
	{ui_dlg_gift_pack_preview.ID_CTRL_PICTURE_6 , ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME2, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_22, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM2},
	{ui_dlg_gift_pack_preview.ID_CTRL_PICTURE_7 , ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME3, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_23, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM3},
	{ui_dlg_gift_pack_preview.ID_CTRL_PICTURE_8 , ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME4, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_24, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM4},
	{ui_dlg_gift_pack_preview.ID_CTRL_PICTURE_9 , ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME5, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_25, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM5},
	{ui_dlg_gift_pack_preview.ID_CTRL_PICTURE_10, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NAME6, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_26, ui_dlg_gift_pack_preview.ID_CTRL_TEXT_NUM6},
};

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
	
	layer:NoMask();
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
	local itemList = {};
	for i = 1, 6 do
		local itemtype = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_type" ..i ) );
		local itemid = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_id" ..i) );
		local itemnum = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num" ..i) );
		--WriteCon( tostring(itemtype) .. " "..tostring(itemid).. " "..tostring(itemnum));
		--过滤礼包中物品的数量
		if itemtype ~= 0 then
			table.insert( itemList, {itemtype, itemid, itemnum} );
		end
	end
	
	if #itemList > 0 then
		for i = 1, #itemList do
			--local itemid = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_id" ..i) );
			--local itemnum = tonumber( SelectRowInner( T_GIFT, "gift_id", item.item_id , "reward_num" ..i) );
			local itemtype = itemList[i][1];
			local itemid = itemList[i][2];
			local itemnum = itemList[i][3];
			
			--WriteCon( "aaa"..tostring(itemtype) .. " "..tostring(itemid).. " "..tostring(itemnum));
			
			if itemtype ~= 0 then
				--显示名字
				local itemname;
				local pictureData;
				if itemtype == 1 then
					itemname = SelectCell( T_CARD, itemid, "name" );
					pictureData = GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id" , itemid, "head_pic" ), 0 );
					--pictureData = GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id" , itemid, "card_pic" ), 0 );
				elseif itemtype == 2 then
					itemname = SelectCell( T_ITEM, itemid, "name" );
					pictureData = GetPictureByAni( SelectCell( T_ITEM, itemid, "item_pic" ), 0 );
				elseif itemtype == 3 then
					itemname = ToUtf8("宝石");
					pictureData = GetPictureByAni( "item.item_emoney", 0 );
				elseif itemtype == 4 then
					itemname = ToUtf8("金币");
					pictureData = GetPictureByAni( "item.item_money", 0 );
				end
				
				--local itemname = SelectCell( T_ITEM, itemid, "name" );
				local nameLab = GetLabel( p.layer, p.nodeTag[i][NAME_INDEX] );
				nameLab:SetText( tostring(itemname) );
				
				--显示数量
				local numLab = GetLabel( p.layer, p.nodeTag[i][NUM_INDEX] );
				numLab:SetText( tostring(itemnum) );
				
				--图片显示
				local picture = GetImage( p.layer, p.nodeTag[i][PIC_INDEX] );
				if picture and pictureData then
					picture:SetPicture( pictureData );
				end
			end
		end
	end
	
	if #itemList+1 <= 6 then
		for i = #itemList+1, 6 do
			--礼包中物品数量为0，隐藏对应的控件
			for _, tag in pairs(p.nodeTag[i]) do
				local node = GetUiNode( p.layer,  tag);
				if node then
					node:SetVisible( false );
				end
			end
		end
	end
	
	--[[
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
	--]]
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

