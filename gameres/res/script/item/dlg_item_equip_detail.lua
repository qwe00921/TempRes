--------------------------------------------------------------
-- FileName: 	dlg_item_equip_detail.lua
-- author:		hst, 2013年7月24日
-- purpose:		可装备的道具
--------------------------------------------------------------

dlg_item_equip_detail = {}
local p = dlg_item_equip_detail;
p.layer = nil;
p.item = nil;

---------显示UI----------
function p.ShowUI( item )
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
    LoadDlg("dlg_item_equip_detail.xui", layer, nil);
	
	p.SetDelegate(layer);
	p.layer = layer;
	
	p.ShowItem( item );
end


--设置事件处理
function p.SetDelegate(layer)
	local pBtn01 = GetButton(layer,ui_dlg_item_equip_detail.ID_CTRL_BUTTON_6);
    pBtn01:SetLuaDelegate(p.OnUIEvent);
    
    local pBtn02 = GetButton(layer,ui_dlg_item_equip_detail.ID_CTRL_BUTTON_9);
    pBtn02:SetLuaDelegate(p.OnUIEvent);
    
    local pBtn03 = GetButton(layer,ui_dlg_item_equip_detail.ID_CTRL_BUTTON_17);
    pBtn03:SetLuaDelegate(p.OnUIEvent);
    
end

function p.ShowItem( item )
	--是否己装备
	local isUse = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_8 );
	if tonumber( item.card_id ) == 0 then
	   isUse:SetText( GetStr( "item_unused" ) );
	else
	   isUse:SetText( GetStr( "item_used" ) );
	end
	
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
	local itemPic = GetImage( p.layer,ui_dlg_item_equip_detail.ID_CTRL_PICTURE_3 );
	itemPic:SetPicture( GetPictureByAni("item.item_db", pic) );
	
	--道具名称
	local itemName = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_4 );
	itemName:SetText( item.name );
	
	--道具说明
	local description = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_5 );
	description:SetText( item.description );
	
	--生命
	local hp_label = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_9 );
	local hp_value = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_10 );
	hp_value:SetText( tostring( p.GetHP( item ) ) );
	
	--等级
	local lv_label = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_11 );
    local lv_value = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_12 );
    lv_value:SetText( item.level );
	
	--攻击
	local atk_label = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_13 );
    local atk_value = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_14 );
    atk_value:SetText( tostring( p.GetAttack( item ) ) );
    
	--防御
	local def_label = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_15 );
    local def_value = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_16 );
    def_value:SetText( tostring( p.GetDef( item ) ) );
    
	--技能名称
	local skill = GetLabel( p.layer, ui_dlg_item_equip_detail.ID_CTRL_TEXT_17 );
	local skillName;
	if tonumber( item.skill ) == 0 then
		skillName = GetStr( "item_no_skill" );
	else
	   	skillName = SelectCell( T_SKILL, item.skill, "name" );
	end
	skill:SetText( GetStr( "item_skill")..":"..skillName );
end

--获取道具当前的生命值
function p.GetHP( item )
	return p.GetCurrentValue( item.add_hp_max, item.add_hp_min, item.level_max, item.level  );
end

--获取道具当前的攻击力
function p.GetAttack( item )
    return p.GetCurrentValue( item.add_attack_max, item.add_attack_min, item.level_max, item.level  );
end

--获取道具当前的防御力
function p.GetDef( item )
    return p.GetCurrentValue( item.add_defence_max, item.add_defence_min, item.level_max, item.level  );
end

--获取道具相关信息的公式
function p.GetCurrentValue( maxValue, minValue, maxLv, lv)
	local maxv = tonumber( maxValue );
	local minv = tonumber( minValue );
	local maxLv = tonumber( maxLv )
	local lv = tonumber( lv );
	local cur_value = minValue + (maxv - minv)/(maxLv - 1) * ( lv - 1)
	return math.floor( cur_value );
end

--事件处理
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui_dlg_item_equip_detail.ID_CTRL_BUTTON_6 == tag ) then
            --卖出	
            dlg_item_sell.ShowUI( p.item );
            --dlg_msgbox.parent = p.layer;
            --dlg_msgbox.ShowYesNo( ToUtf8( "确认提示框" ), ToUtf8( "出售价"..p.item.sellprice ), p.OnMsgBoxCallback, p.layer );
            
        elseif ( ui_dlg_item_equip_detail.ID_CTRL_BUTTON_9 == tag ) then
            --装备
			if tonumber(p.item.level) == 7 then
				dlg_msgbox.ShowOK( ToUtf8( "提示" ), ToUtf8( "该装备已经满级无法强化" ), p.OnMsgBoxTip, p.layer );
				return;
			end
			dlg_equip_upgrade.ShowUI( p.item );
        elseif ( ui_dlg_item_equip_detail.ID_CTRL_BUTTON_17 == tag ) then  
            p.CloseUI(); 
			
		end		
	end
end

function p.OnMsgBoxTip(result)
	
end

function p.OnMsgBoxCallback( result )
    if result then
        back_pack_mgr.SellUserItem( p.item.id, p.item.num );
        p.CloseUI();
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
        p.item = nil;
    end
end