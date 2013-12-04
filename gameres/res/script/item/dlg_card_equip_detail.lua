--------------------------------------------------------------
-- FileName: 	dlg_item_equip_detail.lua
-- author:		hst, 2013年7月24日
-- purpose:		可装备的道具
--------------------------------------------------------------

dlg_card_equip_detail = {}
local p = dlg_card_equip_detail;



p.layer = nil;
p.item = nil;
p.showType = 1; 
p.equipId = nil;
p.cardInfo = nil;
p.equip = nil;
--p.itemCommInfo = nil;
p.dressEquip = nil;

local ui = ui_dlg_card_equip_detail


---------显示UI----------
function p.ShowUI( equip, cardInfo)
   -- if item == nil then
    --	return ;
    --end
   -- p.item = item;
	--p.equipId = equipId;
	p.equip = equip;
	p.cardInfo = cardInfo;
	
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
	
	p.ShowItem(p.equip.itemInfo);
end

function p.ShowUI4CardEquip(equip,cardInfo)
	WriteConErr("ShowUI4CardEquip  ");
	p.showType = 1
	p.ShowUI(equip,cardInfo );
end

function p.ShowUI4Dress(equip,dressEquip)
	p.showType = 2
	p.dressEquip = dressEquip;
	p.ShowUI(equip );
end

--设置事件处理
function p.SetDelegate(layer)
	if p.showType and p.showType == 2 then
		
		local upgradeLb = GetLabel( p.layer,ui.ID_CTRL_TEXT_UPGRADE );
		upgradeLb:SetVisible(false);
		local pBtn01 = GetButton(layer,ui.ID_CTRL_BUTTON_UPGRADE);
		pBtn01:SetVisible(false);
		
		local upgradeLb = GetLabel( p.layer,ui.ID_CTRL_TEXT_LABEL_CHANGE );
		upgradeLb:SetVisible(false);
		
		local pBtn03 = GetButton(layer,ui.ID_CTRL_BUTTON_UNLOAD);
		pBtn03:SetVisible(false);
		
	elseif p.equip.intent == card_equip_select_list.INTENT_UPDATE then
		
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

function p.ShowItem( item )
	
	if item == nil then 
		return;
	end

	--武器名称
	local labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME );
	--labelV:SetText(p.SelectItemName(item.Item_id));
	labelV:SetText(item.Name or "");
	
	--武器类型
	labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_TYP);
	--WriteConErr("item.Type  "..GetStr("card_equip_type"..item.Type));
	labelV:SetText(GetStr("card_equip_type"..item.Type));
	
	--武器主要属性值
	labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTR);
	labelV:SetText(GetStr("card_equip_attr"..item.Attribute_type) .. "+" .. item.Attribute_value);
	
	--图片
	local itemPic = GetImage( p.layer,ui.ID_CTRL_PICTURE_IMAGE );
	itemPic:SetPicture( p.SelectImage(item.id) );
	
	--卡牌名称
	local itemName = GetLabel( p.layer, ui.ID_CTRL_TEXT_CARD_NAME );
	itemName:SetText( item.Name or "");
	
	--说明
	local description = GetLabel( p.layer, ui.ID_CTRL_TEXT_DES );
	description:SetText( item.Description or "");
	
	--生命
	--local hp_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_9 );
	--local hp_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_10 );
	--hp_value:SetText( tostring( p.GetHP( item ) ) );
	
	--等级
	--local lv_label = GetLabel( p.layer, ui.ID_CTRL_TEXT_11 );
    local lv_value = GetLabel( p.layer, ui.ID_CTRL_TEXT_LEVEL );
    lv_value:SetText( item.Equip_level or "0");
	
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
        if ( ui.ID_CTRL_BUTTON_6 == tag ) then
            --卖出	
            dlg_item_sell.ShowUI( p.item );
            --dlg_msgbox.parent = p.layer;
            --dlg_msgbox.ShowYesNo( ToUtf8( "确认提示框" ), ToUtf8( "出售价"..p.item.sellprice ), p.OnMsgBoxCallback, p.layer );
            
        elseif ( ui.ID_CTRL_BUTTON_CHANGE == tag ) then
            --装备
			--if tonumber(p.item.level) == 7 then
			--	dlg_msgbox.ShowOK( ToUtf8( "提示" ), ToUtf8( "该装备已经满级无法强化" ), p.OnMsgBoxTip, p.layer );
				--return;
			--end
			--dlg_equip_upgrade.ShowUI( p.item );
			if p.showType == 2 then
				p.sendDress();
			else
				p.cardEquipment = {};
				p.cardEquipment.cardUniqueId = p.cardInfo.UniqueId;
				p.cardEquipment.equipPos = 2
				p.cardEquipment.intent = card_equip_select_list.INTENT_UPDATE;--表示更换
				p.cardEquipment.dressedItem = p.equip;
				card_equip_select_list.ShowUI(p.cardEquipment);
				p.CloseUI(); 
			end
        elseif ( ui.ID_CTRL_BUTTON_CLOSE == tag ) then  
            p.CloseUI(); 
		elseif (ui.ID_CTRL_BUTTON_UNLOAD == tag) then
			p.sendUnDress();
			
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
		p.dressEquip = nil;
    end
end

function p.SelectImage(id)
	local aniIndex = "item."..id;
	return GetPictureByAni(aniIndex,0);
end

function p.SelectItemName(id)
	local itemTable = SelectRowList(T_ITEM,"id",tonumber(id));
	if #itemTable == 1 then
		local text = itemTable[1].Name;
		return ToUtf8(text);
	else
		WriteConErr("itemTable error ");
	end
end

-------------------------------网络------------------------------------------------------
--读取装备细信息
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
	local equid = p.equip;
	if uid == 0 or uid == nil or equid == nil then
		return ;
	end;
	local pos = (p.equip.Item_type) or (p.equip.ItemInfo.Item_type);
	local param = string.format("&item_unique_id=%s&card_unique_id=%s&item_position=%s",equid.equipId, equid.cardUniqueId,tostring(pos));
	--param = param .. "" .. 
	if p.dressEquip and p.dressEquip.equipId then
		param = param .. "&item_unique_id_old" .. p.dressEquip.equipId;
	end
	
	WriteConErr("send req ");
	SendReq("Item","ReplaceEquipment",uid,param);	
end

function p.sendUnDress()
	
	--http://fanta2.sb.dev.91.com/index.php?command=Item&action=&user_id=123456&card_unique_id=10000272&item_unique_id=33451&item_position=2
	
	local uid = GetUID();
		
	--uid=123456
	local equid = p.equip;
	if uid == 0 or uid == nil or equid == nil then
		return ;
	end;
	
	local param = string.format("&item_unique_id=%s&card_unique_id=%s&item_position=%s",equid.equipId, equid.cardUniqueId,tostring(p.equip.Item_type));
	
	WriteConErr("send req ");
	SendReq("Item","TakeoffEquipment",uid,param);	
end

function p.OnDress(msg)
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		dlg_msgbox.ShowOK(" ",GetStr("card_equip_dress_suc"),p.OnOk);
	else
		--local str = mail_main.GetNetResultError(msg);
		--if str then
			--dlg_msgbox.ShowOK(GetStr("mail_erro_title"), str,nil);
		--else
		--	WriteCon("**======mail_write_mail.NetCallback error ======**");
		--end
		--TODO...
	end
end

function p.OnOk()
	p.CloseUI();
	card_equip_select_list.CloseUI();
end