--------------------------------------------------------------
-- FileName: 	dlg_item_equip_detail.lua
-- author:		hst, 2013��7��24��
-- purpose:		��װ���ĵ���
--------------------------------------------------------------

dlg_card_equip_detail = {}
local p = dlg_card_equip_detail;



p.SHOW_ALL = 1; --��ʾ
p.SHOW_DRESS = 2;  -- ��ʾ����

p.layer = nil;
p.item = nil;
p.showType = 1; 
p.equipId = nil;
p.cardInfo = nil;
p.equip = nil;
--p.itemCommInfo = nil;
p.dressEquip = nil;

--[[
		---����Ϊp.equip���ֶ�
	p.item{
		cardId = "xxx"
		,cardUid = "xxx"
		,cardName="xxx"
		,itemId ="xxxx"
		,itemUid="xxxx"
		,itemType="xxxx"
		,itemLevel="";
		,itemExp=xxx;
		attrType: "1",
		attrValue: "300",
		attrGrow: "20",
exType1: "0",
exValue1: "0",
exType2: "0",
exValue2: "0",
exType3: "0",
exValue3: "0",
		,preItemUid="xxxx"  --����װ��id
	}
]]--

local ui = ui_dlg_card_equip_detail


---------��ʾUI----------
function p.ShowUI( equip )
	p.equip = equip;
	
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
	
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	--p.LoadEquipDetail(itemId);
	
	WriteConErr("ShowUI4CardEquip2  ");
	
	p.ShowItem();
end

function p.ShowUI4CardEquip(equip)
	WriteConErr("ShowUI4CardEquip  ");
	p.showType = p.SHOW_ALL;
	p.ShowUI(equip );
end

function p.ShowUI4Dress(equip)
	p.showType = p.SHOW_DRESS
	p.ShowUI(equip );
end

--�����¼�����
function p.SetDelegate(layer)
	if p.showType and p.showType == p.SHOW_DRESS then
		
		local upgradeLb = GetLabel( p.layer,ui.ID_CTRL_TEXT_UPGRADE );
		upgradeLb:SetVisible(false);
		local pBtn01 = GetButton(layer,ui.ID_CTRL_BUTTON_UPGRADE);
		pBtn01:SetVisible(false);
		
		local upgradeLb = GetLabel( p.layer,ui.ID_CTRL_TEXT_LABEL_CHANGE );
		upgradeLb:SetVisible(false);
		
		local pBtn03 = GetButton(layer,ui.ID_CTRL_BUTTON_UNLOAD);
		pBtn03:SetVisible(false);
		
	else
		
		local pBtn01 = GetButton(layer,ui.ID_CTRL_BUTTON_UPGRADE);
		pBtn01:SetLuaDelegate(p.OnUIEvent);
		
		local upgradeLb = GetLabel( p.layer,ui.ID_CTRL_TEXT_INSTALL);
		upgradeLb:SetVisible(false);
		
		local pBtn03 = GetButton(layer,ui.ID_CTRL_BUTTON_UNLOAD);
		pBtn03:SetLuaDelegate(p.OnUIEvent);
	end
	
    
    local pBtn02 = GetButton(layer,ui.ID_CTRL_BUTTON_CHANGE);
    pBtn02:SetLuaDelegate(p.OnUIEvent);
	
	pBtn02 = GetButton(layer,ui.ID_CTRL_BUTTON_CLOSE);
    pBtn02:SetLuaDelegate(p.OnUIEvent);
	
	
    
    
end

function p.InitView()

end

function p.ShowItem(  )
	
	local item = p.equip;
	if item == nil then 
		return;
	end

	--��������
	local labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME );
	local itemNamestr = p.SelectItemName(item.itemId);
	labelV:SetText(itemNamestr or "");
	--labelV:SetText(item.Name or "");
	
	--��������
	labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_TYP);
	--WriteConErr("item.Type  "..GetStr("card_equip_type"..item.Type));
	local str = GetStr("card_equip_type"..item.itemType)
	labelV:SetText(GetStr("card_equip_type"..item.itemType));
	
	--������Ҫ����ֵ
	labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTR);
	local str = GetStr("card_equip_attr"..item.attrType)
	labelV:SetText(GetStr("card_equip_attr"..item.attrType) .. "+" .. item.attrValue);
	
	--ͼƬ
	local itemPic = GetImage( p.layer,ui.ID_CTRL_PICTURE_IMAGE );
	itemPic:SetPicture( p.SelectImage(item.itemId) );
	
	--��������
	local itemName = GetLabel( p.layer, ui.ID_CTRL_TEXT_CARD_NAME );
	itemName:SetText( itemNamestr or "");
	
	--˵��
	local description = GetLabel( p.layer, ui.ID_CTRL_TEXT_DES );
	local str 
	description:SetText( p.SelectItemDes(item.itemId) or "");
	
	--����
	--local hp_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_9 );
	--local hp_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_10 );
	--hp_value:SetText( tostring( p.GetHP( item ) ) );
	
	--�ȼ�
	--local lv_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_11 );
    local lv_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_LEVEL );
    lv_value:SetText( item.itemLevel or "0");
	
	--����
	--local atk_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_13 );
    --local atk_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_14 );
   -- atk_value:SetText( tostring( p.GetAttack( item ) ) );
    
	--����
	--local def_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_15 );
   -- local def_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_16 );
   -- def_value:SetText( tostring( p.GetDef( item ) ) );
    
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
       if ( ui.ID_CTRL_BUTTON_CHANGE == tag ) then
            --װ��
			--if tonumber(p.item.level) == 7 then
			--	dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), ToUtf8( "��װ���Ѿ������޷�ǿ��" ), p.OnMsgBoxTip, p.layer );
				--return;
			--end
			--dlg_equip_upgrade.ShowUI( p.item );
			if p.showType == p.SHOW_DRESS then
				p.sendDress();
			else
				card_equip_select_list.ShowUI(card_equip_select_list.INTENT_UPDATE , p.equip.cardId, p.equip.itemType, p.equip)
				p.CloseUI(); 
			end
        elseif ( ui.ID_CTRL_BUTTON_CLOSE == tag ) then  
            p.CloseUI(); 
		elseif (ui.ID_CTRL_BUTTON_UNLOAD == tag) then
			p.sendUnDress();
		elseif ui.ID_CTRL_BUTTON_UPGRADE == tag then
			card_equip_select_list.ShowUI(card_equip_select_list.INTENT_UPGRADE , p.equip.cardId, p.equip.itemType, p.equip)
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
        p.equip = nil;
		
    end
end

function p.SelectImage(id)
	local aniIndex = "item."..id;
	return GetPictureByAni(aniIndex,0);
end

function p.SelectItemName(id)
	local itemTable = SelectRowList(T_ITEM,"id",id);
	if #itemTable >= 1 then
		local text = itemTable[1].Name;
		return text;
	else
		WriteConErr("itemTable error ");
	end
end

function p.SelectItemDes(id)
	local itemTable = SelectRowList(T_ITEM,"id",id);
	if #itemTable >= 1 then
		local text = itemTable[1].Description;
		return text;
	else
		WriteConErr("itemTable error ");
	end
end

function p.SelectItem(id)
	local itemTable = SelectRowList(T_ITEM,"id",tonumber(id));
	if #itemTable == 1 then
		local item = itemTable[1];
		return item;
	else
		WriteConErr("itemTable error ");
	end
end

-------------------------------����------------------------------------------------------
--��ȡװ��ϸ��Ϣ
function p.LoadEquipDetail(equidId)
	local uid = GetUID();

		
	uid=123456
	if uid == 0 or uid == nil or equidId == nil then
		return ;
	end;
	
	local param = string.format("&item_unique_id=%s",equidId)
	WriteConErr("send req ");
	SendReq("Item","EquipmentDetailShow",uid,param);		
	
end
--���緵�ؿ���ϸ��Ϣ
function p.OnLoadEquitDetail(msg)
	
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		p.itemInfo = msg.item_info or {};
		p.itemCommInfo = msg.item_common_info or {};
		p.ShowItem(p.itemInfo,p.itemCommInfo);
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

function p.sendDress()
	--http://fanta2.sb.dev.91.com/index.php?command=Item&action=&user_id=123456&=33450&item_unique_id=33461&item_position=1&card_unique_id=10000272
	local uid = GetUID();

		
	--uid=123456
	local equip = p.equip;
	if uid == 0 or uid == nil or equip == nil then
		return ;
	end;
	
	local param = string.format("&item_unique_id=%s&card_unique_id=%s&item_position=%s",equip.itemUid, equip.cardUid,tostring(equip.itemType));
	--param = param .. "" .. 
	if equip.preItemUid then
		param = param .. "&item_unique_id_old" ..equip.preItemUid;
	end
	
	WriteConErr("send req ");
	SendReq("Item","ReplaceEquipment",uid,param);	
end

function p.sendUnDress()
	
	--http://fanta2.sb.dev.91.com/index.php?command=Item&action=&user_id=123456&card_unique_id=10000272&item_unique_id=33451&item_position=2
	
	local uid = GetUID();
	local equip = p.equip;
	if uid == 0 or uid == nil or equip == nil then
		return ;
	end;
	local pos = p.equip.ItemType
	local param = string.format("&item_unique_id=%s&card_unique_id=%s&item_position=%s",equip.itemUid, equip.cardUid,tostring(equip.itemType));
	
	WriteConErr("send req ");
	SendReq("Item","TakeoffEquipment",uid,param);	
end

function p.OnDress(msg)
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		dlg_msgbox.ShowOK(GetStr("card_equip_net_suc_titel"),GetStr("card_equip_dress_suc"),p.OnOk);
	else
		local str = p.GetNetResultError(msg);
		if str then
			dlg_msgbox.ShowOK(GetStr("card_equip_net_err_titel"), str,nil);
		else
			WriteCon("**======mail_write_mail.NetCallback error ======**");
		end
	end
end

function p.OnUnDress(msg)
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		dlg_msgbox.ShowOK(GetStr("card_equip_net_suc_titel"),GetStr("card_equip_dress_suc"),p.OnOk);
	else
		local str = p.GetNetResultError(msg);
		if str then
			dlg_msgbox.ShowOK(GetStr("card_equip_net_err_titel"), str,nil);
		else
			WriteCon("**======mail_write_mail.NetCallback error ======**");
		end
		--TODO...
	end
end

function p.OnOk()
	p.CloseUI();
	card_equip_select_list.CloseUI();
	dlg_card_attr_base.RefreshCardDetail();
end

function p.GetNetResultError(msg)
	local str = nil;
	if msg and msg.callback_msg and msg.callback_msg.msg_id then
		local errCode = tonumber(msg.callback_msg.msg_id);
		str = GetStr("card_equip_net_err_" .. msg.callback_msg.msg_id);
		if str == nil or str == "" then
			str = msg.callback_msg.msg.."("..msg.callback_msg.msg_id..")";
		end
	end
	return str;
end