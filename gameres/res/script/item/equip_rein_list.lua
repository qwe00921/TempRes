


equip_rein_list = {}
local p = equip_rein_list;
p.layer = nil;
p.baseCardInfo = nil;

p.itemListInfo = nil;

p.consumeMoney = 0;
p.userMoney = 0;
p.addExp = 0;
p.nowExp = 0;
p.item = ni;

local ui = ui_card_rein_item;
p.callback = nil;
p.isReined = nil;
p.reinedItem = nil;

function p.ShowUI(item,callback)
	
	p.item = item;
	p.reinedItem = {};
	p.callback = callback
	
	if p.item == nil then
		return;
	end
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		p.InitUI(item);
		return;
	end
	
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	layer:NoMask();
    layer:Init();   
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddDlg(layer);
    LoadDlg("card_rein_item.xui", layer, nil);

    p.layer = layer;
	p.InitUI(item);
	 p.SetDelegate(layer);	
end

function p.SetCardData(item)
	if p.layer ~= nil then 
		p.ShowUI(item);
		return;
	end	
end;	


function p.SetUserMoney(userMoney)
	p.userMoney	 = userMoney;
end;	


function p.copyTab(ori_tab)
    if (type(ori_tab) ~= "table") then  
        return nil  
    end  
	
    local new_tab = {}  
    for i,v in pairs(ori_tab) do  
        local vtyp = type(v)  
        if (vtyp == "table") then  
            new_tab[i] = p.copyTab(v)  
        elseif (vtyp == "thread") then  
            new_tab[i] = v  
        elseif (vtyp == "userdata") then  
            new_tab[i] = v  
        else  
            new_tab[i] = v  
        end  
    end  
    return new_tab 
end

function p.InitUI(item)
	
	local pEquipPic1 = GetImage(p.layer,ui.ID_CTRL_PICTURE_HEAD);
	if tonumber(item.itemId) ~= 0 then
		--local aniIndex = "item."..p.equip1.itemInfo.equip_id;
		local pEquipInfo= SelectRowInner( T_EQUIP, "id", item.itemId); 
		pEquipPic1:SetPicture( GetPictureByAni(pEquipInfo.item_pic,0) );
	else
		pEquipPic1:SetPicture(nil);
	end
	
	--名字
	local lCardRowInfo= SelectRowInner( T_EQUIP, "id",item.itemId); --从表中获取卡牌详细信息					
	local lTextName = GetLabel(p.layer, ui.ID_CTRL_TEXT_NAME);
	lTextName:SetText(tostring(lCardRowInfo.name));
	p.reinedItem.name = tostring(lCardRowInfo.name);
	
	--武器主要属性值
	local labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTRIBUTE1NAME);
	local str = GetStr("card_equip_attr"..item.attrType)
	labelV:SetText(GetStr("card_equip_attr"..item.attrType));
	
	labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTRIBUTE);
	labelV:SetText(tostring(item.attrValue));
	p.reinedItem.attrValue = item.attrValue
	
	--武器属性值2
	local labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTRIBUTE2NAME);
	
	if item.exType1 and tonumber(item.exType1) ~= 0 then
		labelV:SetText(GetStr("card_equip_attr"..item.exType1));
	
		labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTRIBUTE2);
		labelV:SetText(tostring(item.exValue1));
		p.reinedItem.exValue1 = item.exValue1
	end
	
	
		
	--当前经验值更新
	p.nowExp = tonumber(item.itemExp);
	p.reinedItem.itemExp = item.itemExp;
		
	--等级 ID_CTRL_TEXT_LEVEL		
	local lTextLev = GetLabel(p.layer, ui.ID_CTRL_TEXT_LEVEL);
	lTextLev:SetText( tostring(item.itemLevel) );
	p.reinedItem.itemLevel = item.itemLevel
	
	--当前的经验值条 ID_CTRL_EXP_CARDEXP
	local lCardLeveInfo= SelectRowInner( T_EQUIP_LEVEL, "equip_level", tostring(item.itemLevel));
	if lCardLeveInfo then
		local lCardExp = GetExp(p.layer, ui.ID_CTRL_EXP_EQUIPEXP);
		lCardExp:SetTotal(tonumber(lCardLeveInfo.exp));
		lCardExp:SetProcess(tonumber(item.itemExp));
		lCardExp:SetNoText();
			
	--经验值 ID_CTRL_TEXT_EXP
		local lTextExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_EXP);
		lTextExp:SetText(tostring(item.itemExp).."/"..tostring(lCardLeveInfo.exp));
	end
	
	
	p.ShowCardCost();

end	

function p.refreshItemList()
	p.consumeMoney = 0	
	p.addExp = 0;
	
	local lCount=0;
	--local lNum = #(p.itemListInfo)
	p.itemListInfo = p.itemListInfo or {};
	for i=1,10 do
		local lcardInfo = p.itemListInfo[i] or {};
		lCount = lCount + 1;
		p.SetCardInfo(lCount,lcardInfo);
	end
	
	p.ShowCardCost();
end;	

function p.ShowCardCost()
	
	local cardCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_GAIN_EXP);
	cardCount:SetText(tostring(p.addExp)); 
	
	local cardMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_FEE_MONEY);
	cardMoney:SetText(tostring(p.consumeMoney)); 
	
	p.userMoney = tonumber(msg_cache.msg_player.Money or 0);
	local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_USER_MONEY);
	moneyLab:SetText(tostring(p.userMoney));	
	
	if tonumber(p.userMoney) < tonumber(p.consumeMoney) then
		--local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
		cardMoney:SetFontColor(ccc4(255,0,0,255));
    else	
		cardMoney:SetFontColor(ccc4(255,255,255,255));
	end		
end;	

function p.SetCardInfo(pIndex,item)  --pIndex从1开始
	if pIndex > 10 then --正常不超过10
		return ;
	end
	
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", tostring(item.equip_id)) or {};
	
	local cardLevText = GetLabel(p.layer, ui["ID_CTRL_TEXT_CARDLEVEL"..pIndex]);
	cardLevText:SetVisible(true);
	cardLevText:SetText((tostring(item.equip_level or "")));
			
	local cardButton = GetButton(p.layer, ui["ID_CTRL_BUTTON_CHA"..pIndex]);
		
	--cardButton:SetImage( GetPictureByAni("n_battle.attack_"..lcardId,0) );
	
	if pEquipInfo.item_pic then
	
		cardButton:SetImage( GetPictureByAni(pEquipInfo.item_pic or "",0)  );
	else
		cardButton:SetImage(nil);
	end
	
	local cardName = GetLabel(p.layer, ui["ID_CTRL_TEXT_NAME"..pIndex]);
	cardName:SetText(tostring(pEquipInfo.name or ""));
	

	local lCardLeveInfo;
	if item.equip_level == 0 then
		lCardLeveInfo= SelectRowInner( T_EQUIP_LEVEL, "equip_level", "1");
	else
		lCardLeveInfo= SelectRowInner( T_EQUIP_LEVEL, "equip_level", tostring(item.equip_level));
	end	
	
	if lCardLeveInfo then
		p.consumeMoney = p.consumeMoney + lCardLeveInfo.feed_money;	
		p.addExp = p.addExp + lCardLeveInfo.feed_exp;
	end
	
end;

function p.InitAllCardInfo()
		
	local i;
	for i=1,10 do
		
		local tLevel= "ID_CTRL_TEXT_CARDLEVEL"..tostring(i);--按钮
		local tName = "ID_CTRL_TEXT_NAME"..tostring(i);--装备图背景
		
		local cardLevText = GetLabel(p.layer, ui[tLevel]);
		cardLevText:SetVisible(false);
	
		local cardName = GetLabel(p.layer,ui[tName]);
		cardName:SetText("");
	end
	
end;	

function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end

function p.CloseUI()
    if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;	
		p.baseCardInfo = nil;
		p.itemListInfo = nil;
		p.userMoney = 0;
		p.consumeMoney = 0;
		p.nowExp = 0;
		p.addExp = 0;
		equip_rein_select.CloseUI();
    end
	
	if p.callback then
		p.callback(p.isReined);
	end
	p.callback = nil;
	p.isReined = nil
	
end

function p.SetDelegate(layer)

	local starBtn = GetButton(layer, ui.ID_CTRL_BUTTON_START);
	starBtn:SetLuaDelegate(p.OnUIClickEvent);

	local closeBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	closeBtn:SetLuaDelegate(p.OnUIClickEvent);
	

	for i=1,10 do
		local lCardBtn = GetButton(layer, ui["ID_CTRL_BUTTON_CHA"..i]);
		lCardBtn:SetLuaDelegate(p.OnButtonEvent);
	end
end
	
function p.OnButtonEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	if IsClickEvent(uiEventType) then
		p.HideUI();
		equip_rein_select.ShowUI(p.itemListInfo,p.OnSelectCallback);
	end
end

function p.OnUIClickEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	local tag = uiNode:GetTag();
	WriteCon("tag = "..tag);
	WriteCon("ui.ID_CTRL_BUTTON_CHA1 : "..ui.ID_CTRL_BUTTON_CHA1);
	
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			p.CloseUI();
		elseif(ui.ID_CTRL_BUTTON_START == tag) then --强化
			p.upgrade();
			--equip_rein_result.ShowUI(p.item, p.reinedItem);
		end;
	end
end		

function p.ShowPackageUpgrade(pacageItem, callback)
	if pacageItem then
		local item = {};
		item.itemId 	= pacageItem.equip_id;
		item.itemUid	= pacageItem.id;
		item.itemType	= pacageItem.equip_type;
		item.itemLevel 	= pacageItem.equip_level;
		item.itemExp	= pacageItem.equip_exp;
		item.itemRank	= pacageItem.rare
		item.attrType	= pacageItem.attribute_type1;
		item.attrValue	= pacageItem.attribute_value1;
		item.attrGrow	= pacageItem.Attribute_grow or 0;
		item.exType1 	= pacageItem.attribute_type2;
		item.exValue1 	= pacageItem.attribute_value2;
		--item.exType2 	= pacageItem.Extra_type2;
		--item.exValue2 	= pacageItem.Extra_value2;
		--item.exType3	= pacageItem.Extra_type3;
		--item.exValue3	= pacageItem.Extra_value3;
		p.ShowUI(item,callback);
	end
end



function p.upgrade()
	
	if p.itemListInfo == nil or #p.itemListInfo <= 0 then
		dlg_msgbox.ShowOK("",GetStr("card_equip_up_item_null"),p.OnMsgCallback);
		return;
	end
	
	--判断当前装备等级是不是已是限制等级
	local playerLevel 	= tonumber(msg_cache.msg_player.Level);
	local playerEquipLimit		= p.SelectPlayerEquipLimit(playerLevel)
	
	if playerEquipLimit then
		
		local itemLevel = tonumber(p.item.itemLevel or 1);
		--WriteCon("=====itemLevel,plevel" .. itemLevel .. ","..playerLevel);
		if itemLevel >= tonumber(playerEquipLimit) then
			WriteCon("=====itemLevel");
			local str = string.format(GetStr("card_equip_up_lvl_limit"), playerEquipLimit, p.item.itemLevel or "1")
			dlg_msgbox.ShowOK("",str,p.OnMsgCallback);
			return;
		end
	else
		WriteCon("=====playerEquipLimit");
			
	end
	
	--判断用户金钱够不够
	local userMoney = tonumber(msg_cache.msg_player.Money or 0);
	if p.consumeMoney and p.consumeMoney > userMoney then
		dlg_msgbox.ShowOK("",GetStr("card_equip_up_money_short"),p.OnMsgCallback);
	end
	
	local ids = "";
	local has5Rank = false;
	if p.itemListInfo then
		for i = 1, #p.itemListInfo do
			local equip =  p.itemListInfo[i];
			if equip then
				if i > 1 then
					ids = ids .. ",";
				end
				ids = ids .. equip.id;
				if equip and tonumber(equip.rare) >= 5 then
					has5Rank = true;
				end
			end
			
		end
	end
	
	if ids == "" or ids == nil then
		return;
	end
	
	--判断是不是有5星的装备被合成掉
	if has5Rank then
		p.upIds = ids;
		dlg_msgbox.ShowYesNo("",GetStr("card_equip_up_5rank"),p.ContinueUpgrade);
		return
	end
	
	p.reqUpgrade(p.item.itemUid, ids);
end

--提示框回调方法
function p.OnMsgCallback(result)
	
	WriteCon("OnMsgCallback");
	
end

function p.SelectPlayerEquipLimit(playerLevel)
	local itemTable = SelectRowList(T_PLAYER_LEVEL,"level",playerLevel);
	if #itemTable >= 1 then
		local item = itemTable[1];
		return item.equip_upgrade_limit;
	else
		WriteConErr("itemTable error ");
	end
end

function p.ContinueUpgrade(ret)
	if ret then
		p.reqUpgrade(p.item.itemUid, p.upIds);
	end
end

function p.reqUpgrade(odId, ids)
	local uid = GetUID();
	
	
	if uid == 0 or uid == nil  or odId == nil or ids == nil then
		return ;
	end;
	
	local param = string.format("&base_user_card_id=%s&material_user_card_ids=%s",odId, ids);
	SendReq("Equip","AddPower",uid,param);	 
end

function p.OnNetUpgradeCallback(msg)
if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		if msg.base_card_new_info then
			p.reinedItem.itemLevel = msg.base_card_new_info.equip_level or p.item.itemLevel;
			p.reinedItem.itemExp	= msg.base_card_new_info.equip_exp or p.item.itemExp;
			p.reinedItem.attrValue = msg.base_card_new_info.attribute_value1 or p.item.attrValue;
			p.reinedItem.exValue1  = msg.base_card_new_info.attribute_value2 or p.item.exValue1;
		end
		--dlg_msgbox.ShowOK(GetStr("card_equip_net_suc_titel"),GetStr("card_equip_upgrade_suc"));
		equip_rein_result.ShowUI(p.item, p.reinedItem);
		if msg.base_card_new_info then
			p.item.itemLevel = msg.base_card_new_info.equip_level;
			p.item.itemExp	= msg.base_card_new_info.equip_exp;
			p.item.attrValue = msg.base_card_new_info.attribute_value1;
			p.itemListInfo = nil;
			p.InitUI(p.item);
			p.refreshItemList();
		end
		
	else
		local str = dlg_card_equip_detail.GetNetResultError(msg);
		if str then
			dlg_msgbox.ShowOK(GetStr("card_equip_net_err_titel"), str,nil);
		else
			WriteCon("**======mail_write_mail.NetCallback error ======**");
		end
		--TODO...
	end
end



function p.OnSelectCallback(isChanged,lst)
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		
	end
	
	if isChanged == true then
		p.itemListInfo = lst or {};
		p.refreshItemList()
	
	end
	
	
end


function p.ClearData()
	p.itemListInfo = nil;
	p.cardListByProf = {};
	p.InitAllCardInfo();
	p.consumeMoney = 0	
	p.addExp = 0;
end

