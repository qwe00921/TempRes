--------------------------------------------------------------
-- FileName: 	dlg_item_equip_detail.lua
-- author:		hst, 2013年7月24日
-- purpose:		可装备的道具
--------------------------------------------------------------

dlg_card_equip_detail = {}
local p = dlg_card_equip_detail;



p.SHOW_ALL = 1; --显示
p.SHOW_DRESS = 2;  -- 显示穿戴
p.SHOW_EQUIP_ROOM = 3; --显示装备屋装备

p.layer = nil;
p.item = nil;
p.showType = 1; 
p.equipId = nil;
p.cardInfo = nil;
p.equip = nil;
--p.itemCommInfo = nil;
p.dressEquip = nil;
p.callback = nil;

p.redirectCallback = nil; --当

--[[
		---以下为p.equip的字段
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
		,preItemUid="xxxx"  --穿戴装备id
	}
]]--

local ui = ui_dlg_card_equip_detail


---------显示UI----------
function p.ShowUI( equip ,callback, redirectCallback)
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
	GetUIRoot():AddChild( layer );
    LoadDlg("dlg_card_equip_detail.xui", layer, nil);
	
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	--p.LoadEquipDetail(itemId);
	
	WriteConErr("ShowUI4CardEquip2  ");
	p.callback = callback;
	p.redirectCallback = redirectCallback;
	
	p.ShowItem();
end

function p.ShowUI4CardEquip(equip,callback,redirectCallback)
	WriteConErr("ShowUI4CardEquip  ");
	p.showType = p.SHOW_ALL;
	p.ShowUI(equip ,callback,redirectCallback);
end

function p.ShowUI4Dress(equip,callback,redirectCallback)
	p.showType = p.SHOW_DRESS
	p.ShowUI(equip ,callback,redirectCallback);
end

function p.ShouUI4EquipRoom(equip,callback,redirectCallback)
	p.showType = p.SHOW_EQUIP_ROOM 
	p.ShowUI(equip ,callback,redirectCallback);
end

--设置事件处理
function p.SetDelegate(layer)
	if p.showType and p.showType == p.SHOW_DRESS then
		
		local upgradeLb = GetLabel( p.layer,ui.ID_CTRL_TEXT_UPGRADE );
		upgradeLb:SetVisible(false);
		local pBtn01 = GetButton(layer,ui.ID_CTRL_BUTTON_UPGRADE);
		pBtn01:SetVisible(false);
		
		
		local pBtn03 = GetButton(layer,ui.ID_CTRL_BUTTON_UNLOAD);
		pBtn03:SetVisible(false);
		
		local btn3Lb = GetLabel( p.layer,ui.ID_CTRL_TEXT_UNLOAD );
		btn3Lb:SetVisible(false);
		
	elseif p.showType == p.SHOW_EQUIP_ROOM then
		
		if  p.equip and p.equip.isDress ~= 1 then
			local upgradeLb = GetLabel( p.layer,ui.ID_CTRL_TEXT_UPGRADE );
			upgradeLb:SetVisible(false);
			local pBtn01 = GetButton(layer,ui.ID_CTRL_BUTTON_UPGRADE);
			pBtn01:SetVisible(false);
		
			local upgradeLb = GetLabel( p.layer,ui.ID_CTRL_TEXT_INSTALL);
			upgradeLb:SetText(GetStr("card_equip_bt_upgrade"));
			
			local pBtn03 = GetButton(layer,ui.ID_CTRL_BUTTON_UNLOAD);
			pBtn03:SetVisible(false);
			local btn3Lb = GetLabel( p.layer,ui.ID_CTRL_TEXT_UNLOAD );
			btn3Lb:SetVisible(false);
			
		elseif p.equip then
			
			local bt = GetButton(layer,ui.ID_CTRL_BUTTON_UPGRADE);
			bt:SetLuaDelegate(p.OnUIEvent);
		
			local lb = GetLabel(layer,ui.ID_CTRL_TEXT_INSTALL);
			lb:SetVisible(false);
			local pBtn02 = GetButton(layer,ui.ID_CTRL_BUTTON_CHANGE);
			pBtn02:SetVisible(false);
			
			local pBtn03 = GetButton(layer,ui.ID_CTRL_BUTTON_UNLOAD);
			pBtn03:SetLuaDelegate(p.OnUIEvent);
		end
		
	else
		
		local pBtn01 = GetButton(layer,ui.ID_CTRL_BUTTON_UPGRADE);
		pBtn01:SetLuaDelegate(p.OnUIEvent);
		
		local upgradeLb = GetLabel( p.layer,ui.ID_CTRL_TEXT_INSTALL);
		upgradeLb:SetText(GetStr("card_equip_change"));
		
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

	--武器名称
	local labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME );
	local itemNamestr = p.SelectItemName(item.itemId);
	labelV:SetText(itemNamestr or "");
	--labelV:SetText(item.Name or "");
	
	--武器类型
	--labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_TYP);
	--WriteConErr("item.Type  "..GetStr("card_equip_type"..item.Type));
	--local str = GetStr("card_equip_type"..item.itemType)
	--labelV:SetText(GetStr("card_equip_type"..item.itemType));
	
	--武器主要属性值
	labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTR);
	local str = GetStr("card_equip_attr"..item.attrType)
	labelV:SetText(GetStr("card_equip_attr"..item.attrType) .. "+" .. item.attrValue);
	
	--副属性值
	if tonumber(item.exType1) > 0 then
		labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTR2);
		local str = GetStr("card_equip_attr"..item.exType1)
		labelV:SetText(GetStr("card_equip_attr"..item.exType1) .. "+" .. item.exValue1);
	end
	
	--经验
	
	--当前的经验值条 ID_CTRL_EXP_CARDEXP
	local lCardLeveInfo= SelectRowInner( T_EQUIP_LEVEL, "level", tostring(item.itemLevel));
	if lCardLeveInfo then
		local lCardExp = GetExp(p.layer, ui.ID_CTRL_EXP_EQUIPEXP);
		lCardExp:SetTotal(tonumber(lCardLeveInfo.exp));
		lCardExp:SetProcess(tonumber(item.itemExp));
		lCardExp:SetNoText();
			
	--经验值 ID_CTRL_TEXT_EXP
		local lTextExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_EXP);
		lTextExp:SetText(tostring(item.itemExp).."/"..tostring(lCardLeveInfo.exp));
	end
	
	
	
	--图片
	local itemPic = GetImage( p.layer,ui.ID_CTRL_PICTURE_IMAGE );
	itemPic:SetPicture( p.SelectImage(item.itemId) );
	
	--卡牌名称
	local pCardInfo= SelectRowInner( T_CARD, "id", item.cardId);
	local itemNamestr = GetStr("card_equip_undress");
	if pCardInfo then
		itemNamestr = pCardInfo.name;
	end
	local itemName = GetLabel( p.layer, ui.ID_CTRL_TEXT_CARD_NAME );
	itemName:SetText( itemNamestr or "");
	
	--说明
	--local description = GetLabel( p.layer, ui.ID_CTRL_TEXT_DES );
	--description:SetText( p.SelectItemDes(item.itemId) or "");
	
	--生命
	--local hp_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_9 );
	--local hp_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_10 );
	--hp_value:SetText( tostring( p.GetHP( item ) ) );
	
	--等级
	--local lv_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_11 );
    local lv_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_LEVEL );
    lv_value:SetText( tostring(item.itemLevel) or "0");
	
	--星级
	
	--local itemStar = GetImage( p.layer,ui.ID_CTRL_PICTURE_STAR );
	--itemStar:SetPicture( GetPictureByAni("ui.equip_star_"..(item.itemRank or 1) ,0));
	
	--攻击
	--local atk_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_13 );
    --local atk_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_14 );
   -- atk_value:SetText( tostring( p.GetAttack( item ) ) );
    
	--防御
	--local def_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_15 );
   -- local def_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_16 );
   -- def_value:SetText( tostring( p.GetDef( item ) ) );
    
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
       if ( ui.ID_CTRL_BUTTON_CHANGE == tag ) then
            --装备
			--if tonumber(p.item.level) == 7 then
			--	dlg_msgbox.ShowOK( ToUtf8( "提示" ), ToUtf8( "该装备已经满级无法强化" ), p.OnMsgBoxTip, p.layer );
				--return;
			--end
			--dlg_equip_upgrade.ShowUI( p.item );
			if p.showType == p.SHOW_DRESS then
				p.sendDress();
			elseif p.showType == p.SHOW_EQUIP_ROOM then
				equip_rein_list.ShowUI(p.equip,p.callback);
				--card_equip_select_list.ShowEquipRoomUpgrade( p.equip,p.callback);
				if (p.redirectCallback) then
					p.redirectCallback();
				end
				p.CloseUI(); 
			else
				equip_dress_select.ShowUI(p.equip.cardUid, p.equip.itemType,  p.callback, p.equip)
				--card_equip_select_list.ShowUI(card_equip_select_list.INTENT_UPDATE , p.equip.cardUid, p.equip.itemType, p.equip)
				if (p.redirectCallback) then
					p.redirectCallback();
				end
				p.CloseUI(); 
			end
        elseif ( ui.ID_CTRL_BUTTON_CLOSE == tag ) then  
			if p.callback then
				p.callback(false);
				p.callback = nil;
			end
            p.CloseUI(); 
		elseif (ui.ID_CTRL_BUTTON_UNLOAD == tag) then
			p.sendUnDress();
		elseif ui.ID_CTRL_BUTTON_UPGRADE == tag then
			--if p.showType == p.SHOW_EQUIP_ROOM then
				--card_equip_select_list.ShowEquipRoomUpgrade( p.equip,p.callback);
				--p.CloseUI(); 
			--else
				--card_equip_select_list.ShowUI(card_equip_select_list.INTENT_UPGRADE , p.equip.cardUid, p.equip.itemType, p.equip)
				
				--equip_dress_select.ShowUI(p.equip.cardUid, p.equip.itemType,  p.callback, p.equip)
				equip_rein_list.ShowUI(p.equip,p.callback);
				if (p.redirectCallback) then
					p.redirectCallback();
				end
				p.CloseUI(); 
			--end
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
	
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", tostring(id)); 
	if pEquipInfo then
		return GetPictureByAni(pEquipInfo.item_pic,0);
	end
	
end

function p.SelectItemName(id)
	local itemTable = SelectRowList(T_EQUIP,"id",id);
	if #itemTable >= 1 then
		local text = itemTable[1].name;
		return text;
	else
		WriteConErr("itemTable error ");
	end
end

function p.SelectItemDes(id)
	local itemTable = SelectRowList(T_EQUIP,"id",tostring(id));
	if #itemTable >= 1 then
		local text = itemTable[1].description;
		return text;
	else
		WriteConErr("itemTable error ");
	end
end

function p.SelectItem(id)
	local itemTable = SelectRowList(T_EQUIP,"id",tonumber(id));
	if #itemTable == 1 then
		local item = itemTable[1];
		return item;
	else
		WriteConErr("itemTable error ");
	end
end

-------------------------------网络------------------------------------------------------
--读取装备细信息
function p.LoadEquipDetail(equidId)
	local uid = GetUID();

		
	--uid=123456
	if uid == 0 or uid == nil or equidId == nil then
		return ;
	end;
	
	local param = string.format("&item_unique_id=%s",equidId)
	WriteConErr("send req ");
	SendReq("Equip","EquipmentDetailShow",uid,param);		
	
end
--网络返回卡详细信息
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
	--[[ 数据结构
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
		Name: "屠龙刀",
		Description: "武林至尊，宝刀屠龙，号令天下，莫敢不从！熔玄铁剑及加入西方精金所铸。",
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
	
	local param = string.format("&item_unique_id=%s&card_unique_id=%s&item_position=%s",tostring(equip.itemUid), tostring(equip.cardUid),tostring(equip.itemType));
	--param = param .. "" .. 
	if equip.preItemUid then
		param = param .. "&item_unique_id_old=" ..equip.preItemUid;
	end
	
	WriteConErr("send req ");
	SendReq("Equip","ReplaceEquipment",uid,param);	
end

function p.sendUnDress()
	
	--http://fanta2.sb.dev.91.com/index.php?command=Item&action=&user_id=123456&card_unique_id=10000272&item_unique_id=33451&item_position=2
	
	local uid = GetUID();
	local equip = p.equip;
	if uid == 0 or uid == nil or equip == nil then
		return ;
	end;
	local pos = p.equip.ItemType
	local param = string.format("&item_unique_id=%s&card_unique_id=%s&item_position=%s",tostring(equip.itemUid), tostring(equip.cardUid),tostring(equip.itemType));
	
	WriteConErr("send req ");
	SendReq("Equip","TakeoffEquipment",uid,param);	
end

function p.OnDress(msg)
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		p.CloseUI();
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
		p.CloseUI();
		dlg_msgbox.ShowOK(GetStr("card_equip_net_suc_titel"),GetStr("card_equip_undress_suc"),p.OnOk);
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
	--p.CloseUI();
	
	if p.callback then
		p.callback(true);
		p.callback = nil;
	else
		--card_equip_select_list.CloseUI();
		dlg_card_attr_base.RefreshCardDetail();
	end


	
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