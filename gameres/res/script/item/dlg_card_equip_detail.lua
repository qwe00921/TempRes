--------------------------------------------------------------
-- FileName: 	dlg_item_equip_detail.lua
-- author:		hst, 2013��7��24��
-- purpose:		��װ���ĵ���
--------------------------------------------------------------

dlg_card_equip_detail = {}
local p = dlg_card_equip_detail;



p.layer = nil;
p.item = nil;
p.showType = 1; 
p.itemId = nil;
p.cardDetail = nil;

local ui = ui_dlg_card_equip_detail


---------��ʾUI----------
function p.ShowUI( itemId )
   -- if item == nil then
    --	return ;
    --end
   -- p.item = item;
	p.itemId = itemId;
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return ;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:NoMask();
	layer:Init();	
	GetUIRoot():AddDlg( layer );
    LoadDlg("dlg_card_equip_detail.xui", layer, nil);
	
	--p.SetDelegate(layer);
	p.layer = layer;
	
	--p.ShowItem( item );
end

function p.ShowUI4CardEquip(itemId)
	p.showType = 1
	p.ShowUI( itemId );
end


--�����¼�����
function p.SetDelegate(layer)
	local pBtn01 = GetButton(layer,ui.ID_CTRL_BUTTON_UPGRADE);
    pBtn01:SetLuaDelegate(p.OnUIEvent);
    
    local pBtn02 = GetButton(layer,ui.ID_CTRL_BUTTON_CHANGE);
    pBtn02:SetLuaDelegate(p.OnUIEvent);
    
    local pBtn03 = GetButton(layer,ui.ID_CTRL_BUTTON_UNLOAD);
    pBtn03:SetLuaDelegate(p.OnUIEvent);
	
	pBtn03 = GetButton(layer,ui.ID_CTRL_BUTTON_CLOSE);
    pBtn03:SetLuaDelegate(p.OnUIEvent);
	
    
end

function p.InitView()
end

function p.ShowItem( item )
	--�Ƿ�װ��
	local isUse = GetLabel( p.layer, ui.ID_CTRL_TEXT_8 );
	if tonumber( item.card_id ) == 0 then
	   isUse:SetText( GetStr( "item_unused" ) );
	else
	   isUse:SetText( GetStr( "item_used" ) );
	end
	
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
	local itemPic = GetImage( p.layer,ui.ID_CTRL_PICTURE_3 );
	itemPic:SetPicture( GetPictureByAni("item.item_db", pic) );
	
	--��������
	local itemName = GetLabel( p.layer, ui.ID_CTRL_TEXT_4 );
	itemName:SetText( item.name );
	
	--����˵��
	local description = GetLabel( p.layer, ui.ID_CTRL_TEXT_5 );
	description:SetText( item.description );
	
	--����
	local hp_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_9 );
	local hp_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_10 );
	hp_value:SetText( tostring( p.GetHP( item ) ) );
	
	--�ȼ�
	local lv_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_11 );
    local lv_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_12 );
    lv_value:SetText( item.level );
	
	--����
	local atk_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_13 );
    local atk_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_14 );
    atk_value:SetText( tostring( p.GetAttack( item ) ) );
    
	--����
	local def_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_15 );
    local def_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_16 );
    def_value:SetText( tostring( p.GetDef( item ) ) );
    
	--��������
	local skill = GetLabel( p.layer, ui.ID_CTRL_TEXT_17 );
	local skillName;
	if tonumber( item.skill ) == 0 then
		skillName = GetStr( "item_no_skill" );
	else
	   	skillName = SelectCell( T_SKILL, item.skill, "name" );
	end
	skill:SetText( GetStr( "item_skill")..":"..skillName );
end

--��ȡ���ߵ�ǰ������ֵ
function p.GetHP( item )
	return p.GetCurrentValue( item.add_hp_max, item.add_hp_min, item.level_max, item.level  );
end

--��ȡ���ߵ�ǰ�Ĺ�����
function p.GetAttack( item )
    return p.GetCurrentValue( item.add_attack_max, item.add_attack_min, item.level_max, item.level  );
end

--��ȡ���ߵ�ǰ�ķ�����
function p.GetDef( item )
    return p.GetCurrentValue( item.add_defence_max, item.add_defence_min, item.level_max, item.level  );
end

--��ȡ���������Ϣ�Ĺ�ʽ
function p.GetCurrentValue( maxValue, minValue, maxLv, lv)
	local maxv = tonumber( maxValue );
	local minv = tonumber( minValue );
	local maxLv = tonumber( maxLv )
	local lv = tonumber( lv );
	local cur_value = minValue + (maxv - minv)/(maxLv - 1) * ( lv - 1)
	return math.floor( cur_value );
end

--�¼�����
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_6 == tag ) then
            --����	
            dlg_item_sell.ShowUI( p.item );
            --dlg_msgbox.parent = p.layer;
            --dlg_msgbox.ShowYesNo( ToUtf8( "ȷ����ʾ��" ), ToUtf8( "���ۼ�"..p.item.sellprice ), p.OnMsgBoxCallback, p.layer );
            
        elseif ( ui.ID_CTRL_BUTTON_9 == tag ) then
            --װ��
			if tonumber(p.item.level) == 7 then
				dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), ToUtf8( "��װ���Ѿ������޷�ǿ��" ), p.OnMsgBoxTip, p.layer );
				return;
			end
			dlg_equip_upgrade.ShowUI( p.item );
        elseif ( ui.ID_CTRL_BUTTON_CLOSE == tag ) then  
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

-------------------------------����------------------------------------------------------
--��ȡװ��ϸ��Ϣ
function p.LoadEquipDetail(equidId)
	local uid = GetUID();
	if uid == 0 or uid == nil or equidId == nil then
		return ;
	end;
	
	local param = string.format("&item_unique_id=%s",equidId)
	SendReq("Item","EquipmentDetailShow",uid,param);		
	
end
--���緵�ؿ���ϸ��Ϣ
function p.OnLoadEquitDetail(msg)
	
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		p.cardDetail = msg.item_info or {};
		p.ShowItem(p.cardDetail);
	else
		--local str = mail_main.GetNetResultError(msg);
		--if str then
			--dlg_msgbox.ShowOK(GetStr("mail_erro_title"), str,nil);
		--else
		--	WriteCon("**======mail_write_mail.NetCallback error ======**");
		--end
		--TODO...
	end
	--[[ ���ݽṹ
		item_info: {
		id: "33451",
		User_id: "123456",
		Item_id: "10002",
		Item_type: "2",
		Num: "3",
		Rare: "1",
		Equip_level: "1",
		Equip_exp: "0",
		Atk: "0",
		Def: "0",
		Hp: "0",
		Speed: "0",
		Is_dress: "1",
		Time: "2013-11-30 14:47:34"
		},
		item_common_info: {
		id: "10002",
		Type: "1",
		Name: "������",
		Description: "�������𣬱����������������£�Ī�Ҳ��ӣ�����������������������������",
		Exp: "100",
		NumMax: "0",
		Issell: "1",
		Sellprice: "5000",
		Rare: "5",
		Attribute_type: "1",
		Attribute_value: "300",
		Attribute_grow: "20",
		Extra_type1: "0",
		Extra_value1: "0",
		Extra_type2: "0",
		Extra_value2: "0",
		Extra_type3: "0",
		Extra_value3: "0",
		Skill: "0"
		}
		]]--
end