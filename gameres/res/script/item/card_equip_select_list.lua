


card_equip_select_list  = {}
local p = card_equip_select_list;

p.INTENT_ADD = 1; --添加
p.INTENT_UPDATE = 2;--更换
p.INTENT_UPGRADE = 3; -- 升级

p.layer = nil;
p.allItems = nil;
p.groupItems = nil;

local ui = ui_card_equip_select_list;
local ui_list = ui_card_equip_select_list_item;

p.curBtnNode = nil;
p.allCardPrice = 0;
p.sellCardList = {};

p.selectList = {};

p.selectNum = 0;
p.tabIndex = 0;


p.intent = 0;
p.cardUid = nil;
p.selectType = 0;
p.upgradeItem = nil;
p.useMoney = 0;
p.upIds = nil;
p.upgradeCallback = nil;

function p.ShowUI(intent , cardUid, selectType, upgradeItem)
	p.intent = intent;
	p.cardUid = cardUid;
	p.selectType = tonumber(selectType);
	p.upgradeItem = upgradeItem;
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:NoMask();
	layer:Init();	
	GetUIRoot():AddDlg( layer );
    LoadDlg("card_equip_select_list.xui", layer, nil);
    

    p.layer = layer;
    p.SetDelegate(layer);
	p.refreshEquipUpgradeInfo();
	
	
	--加载卡牌列表数据  发请求
    p.OnSendReq();
	
end

function p.ShowPackageUpgrade(pacageItem, callback)
	if pacageItem then
		local item = {};
		item.itemId 	= pacageItem.Item_id;
		item.itemUid	= pacageItem.id;
		item.itemType	= pacageItem.Item_type;
		item.itemLevel 	= pacageItem.Equip_level;
		item.itemExp	= pacageItem.Equip_exp;
		item.itemRank	= pacageItem.Rare
		item.attrType	= pacageItem.Attribute_type;
		item.attrValue	= pacageItem.Attribute_value;
		item.attrGrow	= pacageItem.Attribute_grow or 0;
		item.exType1 	= pacageItem.Extra_type1;
		item.exValue1 	= pacageItem.Extra_value1;
		item.exType2 	= pacageItem.Extra_type2;
		item.exValue2 	= pacageItem.Extra_value2;
		item.exType3	= pacageItem.Extra_type3;
		item.exValue3	= pacageItem.Extra_value3;
		p.ShowUI(p.INTENT_UPGRADE,nil,nil,item);
		p.upgradeCallback = callback;
	end
end


--主界面事件处理
function p.SetDelegate(layer)
	local retBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	retBtn:SetLuaDelegate(p.OnUIClickEvent);
	

	local cardBtnAll = GetButton(layer, ui.ID_CTRL_BUTTON_ALL);
	local cardBtnPro1 = GetButton(layer, ui.ID_CTRL_BUTTON_PRO1);
	local cardBtnPro2 = GetButton(layer, ui.ID_CTRL_BUTTON_PRO2);
	local cardBtnPro3 = GetButton(layer, ui.ID_CTRL_BUTTON_PRO3);
	
	cardBtnPro3:SetLuaDelegate(p.OnUIClickEvent);
	cardBtnPro2:SetLuaDelegate(p.OnUIClickEvent);
	cardBtnAll:SetLuaDelegate(p.OnUIClickEvent);
	cardBtnPro1:SetLuaDelegate(p.OnUIClickEvent);
	p.SetBtnCheckedFX( cardBtnAll );
	
	
	if p.intent == p.INTENT_ADD 
		or p.intent == p.INTENT_UPDATE then
		cardBtnAll:SetEnabled(false);
		cardBtnPro3:SetEnabled(false);
		cardBtnPro2:SetEnabled(false);
		cardBtnPro1:SetEnabled(false);
		if p.selectType == 1 then
			cardBtnPro1:SetEnabled(true);
			cardBtnPro1:SetChecked(true);
			p.tabIndex = 1;
		elseif p.selectType == 2 then
			cardBtnPro2:SetEnabled(true);
			cardBtnPro2:SetChecked(true);
			p.tabIndex = 2;
		elseif p.selectType == 3 then
			cardBtnPro3:SetEnabled(true);
			cardBtnPro3:SetChecked(true);
			p.tabIndex = 3;
		end
	else 
		p.tabIndex = 0;
		cardBtnAll:SetEnabled(true);
		cardBtnAll:SetChecked(true);
	end
	
	local str = "";
	if p.intent == p.INTENT_ADD then
		str = GetStr("card_equip_add");
	elseif p.intent == p.INTENT_UPDATE then
		str = GetStr("card_equip_chg");
	else
		str = GetStr("card_equip_upgrade");
		local bt = GetButton(layer, ui.ID_CTRL_BUTTON_UPGRADE);
		bt:SetLuaDelegate(p.OnUIClickEvent);
	end
	
	local lv = GetLabel(p.layer, ui.ID_CTRL_TEXT_HEAD);
	if lv then
		lv:SetText(str);
	end
	
	
end

--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			if p.dataChanged == true then
				p.CloseUI();
				if p.upgradeCallback then
					p.upgradeCallback(true);
				else
					dlg_card_attr_base.RefreshCardDetail();
				end
			else
				p.CloseUI();
			end
		elseif(ui.ID_CTRL_BUTTON_ALL == tag) then --全部
			WriteCon("=====allCardBtn");
			p.SetBtnCheckedFX( uiNode );
			p.tabIndex = 0;
			p.refreshTab();
		elseif(ui.ID_CTRL_BUTTON_PRO1 == tag) then --武器
			WriteCon("=====cardBtnPro1");
			p.SetBtnCheckedFX( uiNode );
			p.tabIndex = 1
			p.refreshTab();
		elseif(ui.ID_CTRL_BUTTON_PRO2 == tag) then --防具
			WriteCon("=====cardBtnPro2");
			p.SetBtnCheckedFX( uiNode );
			p.tabIndex = 2
			p.refreshTab();
		elseif(ui.ID_CTRL_BUTTON_PRO3 == tag) then --鞋子
			WriteCon("=====cardBtnPro3");
			p.SetBtnCheckedFX( uiNode );
			p.tabIndex = 3
			p.refreshTab();
		elseif ui.ID_CTRL_BUTTON_UPGRADE == tag then
			p.upgrade();
			
		end
	end
end

--确认强化为TRUE
function p.OnMsgBoxCallback(result)
	if result == true then
		WriteCon("true");
		
	end
end

function p.upgrade()
	
	--判断当前装备等级是不是已是限制等级
	local playerLevel 	= tonumber(msg_cache.msg_player.level);
	local playerEquipLimit		= p.SelectPlayerEquipLimit(playerLevel)
	
	if playerEquipLimit then
		local itemLevel = tonumber(p.upgradeItem.itemLevel or 1);
		if itemLevel >= tonumber(playerEquipLimit) then
			local str = string.format(GetStr("card_equip_up_money_short"), playerEquipLimit, p.upgradeItem.itemLevel or "1")
			dlg_msgbox.ShowOK("",str,p.OnMsgCallback);
			return;
		end
	end
	
	--判断用户金钱够不够
	local userMoney = tonumber(msg_cache.msg_player.Money or 0);
	if p.useMoney and p.useMoney > userMoney then
		dlg_msgbox.ShowOK("",GetStr("card_equip_up_money_short"),p.OnMsgCallback);
	end
	
	local ids = "";
	local has5Rank = false;
	if p.allItems then
		for i = 1, #p.allItems do
			local equip =  p.allItems[i];
			if equip and equip.isSelected == true then
				if i > 1 then
					ids = ids .. ",";
				end
				ids = ids .. equip.id;
				if equip and tonumber(equip.Rare) >= 5 then
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
	
	p.reqUpgrade(p.upgradeItem.itemUid, ids);

end

function p.ContinueUpgrade(ret)
	if ret then
		p.reqUpgrade(p.upgradeItem.itemUid, p.upIds);
	end
end

--显示要升级的装备信息
-- 
function p.refreshEquipUpgradeInfo()
	local imgV 	= GetImage(p.layer,ui.ID_CTRL_PICTURE_PRE_ITEM_IMAGE);
	local nmV 	= GetLabel(p.layer, ui.ID_CTRL_TEXT_PRE_ITEM_NAME);
	local lb1 	= GetLabel(p.layer, ui.ID_CTRL_TEXT_LABEL_1);
	local lb2 	= GetLabel(p.layer, ui.ID_CTRL_TEXT_LABEL_2);
	local lb3 	= GetLabel(p.layer, ui.ID_CTRL_TEXT_LABEL_3);
	local lb4 	= GetLabel(p.layer, ui.ID_CTRL_TEXT_LABEL_4);
	local lb5 	= GetLabel(p.layer, ui.ID_CTRL_TEXT_LABEL_5);
	local lb6 	= GetLabel(p.layer, ui.ID_CTRL_TEXT_LABEL_6);
	local bt	= GetButton(p.layer, ui.ID_CTRL_BUTTON_UPGRADE);
	local bg 	= Get9SlicesImage(p.layer, ui.ID_CTRL_9SLICES_29);
	local txtBg = Get9SlicesImage(p.layer, ui.ID_CTRL_9SLICES_30);
	
	
	
	if p.upgradeItem == nil or p.intent ~= p.INTENT_UPGRADE then
		
		imgV:SetVisible(false);
		nmV:SetVisible(false);
		lb1:SetVisible(false);
		lb2:SetVisible(false);
		lb3:SetVisible(false);
		lb4:SetVisible(false);
		lb5:SetVisible(false);
		lb6:SetVisible(false);
		bt:SetVisible(false);
		bg:SetVisible(false);
		txtBg:SetVisible(false);
		return
	end
	
	
	
	--显示卡牌图片
	local lst = p.allItems or {};
	local selNum = 0;
	local feeMoney = 0;
	local gainExp = 0;
	local userMoney = tonumber(msg_cache.msg_player.Money or 0);
	for i=1,#lst do
		local item = lst[i];
		if item.isSelected == true then
			selNum = selNum+1;
			local levelConfig 	= p.SelectEquipConfig(item.Equip_level);
			local itemConfig 	= p.SelectItem(item.Item_id);
			
			if itemConfig then
				gainExp  = gainExp + tonumber(itemConfig.exp);
			end
			
			if levelConfig then
				feeMoney = feeMoney + tonumber(levelConfig.feed_money);
				gainExp  = gainExp	+ tonumber(levelConfig.feed_exp);
			end
		end
	end
	
	local aniIndex = "item."..p.upgradeItem.itemId;
	imgV:SetPicture( GetPictureByAni(aniIndex, 0) );
	local nmStr = p.SelectItemName(p.upgradeItem.itemId);
	nmV:SetText(nmStr or "");
	
	local useNumV 		= GetLabel(p.layer, ui.ID_CTRL_TEXT_USED_NUM);
	local useMoneyV 	= GetLabel(p.layer, ui.ID_CTRL_TEXT_USED_MONEY);
	local userMoneyV 	= GetLabel(p.layer, ui.ID_CTRL_TEXT_USER_MONE);
	
	useNumV:SetText(tostring(selNum) .. "/10");
	useMoneyV:SetText(tostring(feeMoney));
	userMoneyV:SetText(tostring(userMoney));
	if feeMoney > userMoney then
		useMoneyV:SetFontColor(ccc4(255,0,0,255));
	end
	
	p.useMoney = feeMoney
	
	local itemLevel = tonumber(p.upgradeItem.itemLevel or 1);
	local preLevel	= itemLevel - 1;
	local levelCfg 	= p.SelectEquipConfig(tostring(itemLevel));
	local preLevelCfg = p.SelectEquipConfig(tostring(preLevel));
	
	local upExp = 0;
	local hadExp = 0;
	if levelCfg then
		upExp = tonumber(levelCfg.exp);
		
		if preLevelCfg then
			upExp = upExp - tonumber(preLevelCfg.exp);
		end
	end
	
	if preLevelCfg then
		hadExp = tonumber(p.upgradeItem.itemExp) - tonumber(preLevelCfg.exp);
	else
		hadExp = tonumber(p.upgradeItem.itemExp or "0")
	end
	
	
	--显示经验值
	local expFmt = "";	
	if gainExp > 0 then
		expFmt = string.format("%d (+%d)/%d",hadExp , gainExp, upExp);
	else 
		expFmt = string.format("%d/%d",hadExp or "0", upExp);
	end
	if expFmt then
		local preItemExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_PRE_ITEM_EXP);
		preItemExp:SetText(expFmt);
	end
	
	--显示经验条
	if upExp > 0 then
		local Exp = GetExp( p.layer, ui.ID_CTRL_EXP_PRE_ITEM_EXP );
		Exp:SetValue( 0, tonumber( upExp ), gainExp +  hadExp);
	end
	
	local nextLeve = tonumber(p.upgradeItem.itemLevel)  -- TODO
	local maxExp = tonumber(p.upgradeItem.itemExp) + gainExp;
	local nextCfg = levelCfg;
	
	while (nextCfg and (maxExp > tonumber(nextCfg.exp))) do
		nextLeve = nextLeve + 1;
		nextCfg = p.SelectEquipConfig(tostring(nextLeve));
	end
	
	
	--显示可升级的等级
	local itemV = GetLabel(p.layer, ui.ID_CTRL_TEXT_PRE_ITEM_LV );
	if itemV then
		itemV:SetText(p.upgradeItem.itemLevel .. " => " .. tostring(nextLeve) or "");
	end
	
	--显示属性类别
	local labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_LABEL_5);
	local str = GetStr("card_equip_attr"..p.upgradeItem.attrType)
	--local str = "c--"..tostring(nextLeve)
	labelV:SetText(str or "");
	
	--显示属性值
	local itemConfig 	= p.SelectItem(p.upgradeItem.itemId);
	if itemConfig then
		labelV = GetLabel( p.layer, ui.ID_CTR_PRE_ITEM_ATTR_VALUE);
		local attr1 = tonumber(p.upgradeItem.attrValue)
		local attr2 = attr1 + (tonumber(nextLeve) - tonumber(p.upgradeItem.itemLevel)) *tonumber(itemConfig.attribute_grow) ;
		local str =  string.format("%d => %d", attr1, attr2);
		labelV:SetText(str or "");
	end
	
	
	
	--msg_cache.msg_player.Money
	
end

--显示Tab数据
function p.refreshTab()
	local lst = nil;
	if p.tabIndex == 0 then
		lst = p.allItems;
	else 
		if p.groupItems then
			lst = p.groupItems[p.tabIndex];
		end
	end
	
	p.refreshList(lst);
end


--显示列表
function p.refreshList(lst)
	
	WriteCon("refreshList()");
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();

	if lst == nil or #lst <= 0 then
		WriteCon("refreshList():cardList is null");
		return;
	end
	WriteCon("cardCount ===== "..#lst);
	local cardNum = #lst;
	local row = math.ceil(cardNum / 4);
	WriteCon("row ===== "..row);
	
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("card_equip_select_list_item.xui",view,nil);
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
		local row_index = i;
		local start_index = (row_index-1)*4+1
        local end_index = start_index + 3;
		
		--设置列表信息，一行4张卡牌
		for j = start_index,end_index do
			--if j <= cardNum then
				local card = lst[j];
				local cardIndex = j - start_index + 1;
				p.ShowCardInfo( view, card, cardIndex , j);
			--end
		end
		list:AddView( view );
	end
	
		
end



--显示单张卡牌
function p.ShowCardInfo( view, itemInfo, cardIndex ,dataListIndex)
	
	local indexStr = tostring(cardIndex);
	local btTagStr 	= "ID_CTRL_BUTTON_ITEM_"..indexStr;
	local imgTagStr = "ID_CTRL_PICTURE_IMAGE_"..indexStr;
	local lvTagStr 	= "ID_CTRL_TEXT_LEVEL_"..indexStr;  --等级
	local drsTagStr = "ID_CTRL_TEXT_DRESSED_"..indexStr; --是否已装备
	local selTagStr = "ID_CTRL_TEXT_SELECT_"..indexStr;  --是否已选择标记
	local rankTagStr= "ID_CTRL_TEXT_RANK_"..indexStr; --星级
	local nmTagStr  = "ID_CTRL_TEXT_NAME_"..indexStr; --卡牌名
	local nmBgTagStr= "ID_CTRL_PICTURE_NM_BG_"..indexStr;--名称背景
	local imgBdTagStr= "ID_CTRL_PICTURE_BD_"..indexStr;
	
	local bt 	= GetButton(view, ui_list[btTagStr]);
	local imgV	= GetImage(view, ui_list[imgTagStr]);
	local lvV 	= GetLabel(view, ui_list[lvTagStr]);
	local drsV	= GetLabel(view, ui_list[drsTagStr]);
	local selV	= GetLabel(view, ui_list[selTagStr]);
	local rankV	= GetLabel(view, ui_list[rankTagStr]);
	local nmV	= GetLabel(view, ui_list[nmTagStr]);
	local imgBdV= GetImage(view, ui_list[imgBdTagStr]);
	local nmBgV	= GetImage(view, ui_list[nmBgTagStr]);
	
	
	selV:SetVisible( false );
	drsV:SetVisible( false );
	
	if itemInfo == nil then
		imgV:SetVisible( false );
		imgBdV:SetVisible( false );
		nmBgV:SetVisible( false );
		return;
	end
	
	--设置事件
	bt:SetLuaDelegate(p.OnItemClickEvent);
	bt:RemoveAllChildren(true);
	bt:SetId(dataListIndex);
	
	--显示卡牌图片
	local aniIndex = "item."..itemInfo.Item_id;
	imgV:SetPicture( GetPictureByAni(aniIndex, 0) );
	
	--显示等级
	lvV:SetText("LV." .. (itemInfo.Equip_level or "1"));
	--显示星级
	if itemInfo.Rare and itemInfo.Rare ~= "0" then
		rankV:SetText(itemInfo.Rare .. GetStr("card_equip_rand_txt"));
	end
	
	--是否已装备
	if itemInfo.Is_dress == "1" then
		drsV:SetVisible(true);
	end
	
	--名称
	local str = p.SelectItemName(itemInfo.Item_id)
	nmV:SetText(str or "");
	
	--是否已选择
	if itemInfo.isSelected == true then
		selV:SetVisible( true );
	end
	
	p.selectList[dataListIndex] = selV;
	
	
	
end


--点击卡牌
function p.OnItemClickEvent(uiNode, uiEventType, param)
	local dataListIndex = uiNode:GetId();
	WriteCon("dataListIndex = "..dataListIndex);
	
	local lst = nil;
	if p.tabIndex == 0 then
		lst = p.allItems;
	else
		local gs = p.groupItems or {};
		lst = gs[p.tabIndex];
	end
		
	if lst == nil then 
		return;
	end
	
	local equip = lst[dataListIndex]
	
	if (equip == nil ) then
		return
	end
	
	if p.intent == p.INTENT_ADD 
		or p.intent == p.INTENT_UPDATE then
		--local item = p.SelectItem(equip.Item_id);
		local preItemUid = nil 
		if p.upgradeItem then
			preItemUid = p.upgradeItem.itemUid;
		end
 		local it = p.PasreCardDetail(p.cardUid, equip, preItemUid);
		dlg_card_equip_detail.ShowUI4Dress(it);
	else
		local cardSelectText = p.selectList[dataListIndex] 
	
		if cardSelectText:IsVisible() == true then
			cardSelectText:SetVisible(false);
			equip.isSelected = false;
			p.selectNum = p.selectNum-1;
		else
			if equip.Is_dress == "1" then
				dlg_msgbox.ShowOK("",GetStr("card_equip_up_dressed"),p.OnMsgCallback);
				return;
			elseif p.selectNum >= 10 then 
				dlg_msgbox.ShowOK("",GetStr("card_equip_up_10"),p.OnMsgCallback);
				return;
			else
				cardSelectText:SetVisible(true);
				equip.isSelected = true;
				p.selectNum = p.selectNum+1;
			end
		end
		
		p.refreshEquipUpgradeInfo(true);
		
	end
	
		
end



--提示框回调方法
function p.OnMsgCallback(result)
	
	WriteCon("OnMsgCallback");
	
end


--设置选中按钮
function p.SetBtnCheckedFX( node )
    local btnNode = ConverToButton( node );
    if p.curBtnNode ~= nil then
    	p.curBtnNode:SetChecked( false );
    end
	btnNode:SetChecked( true );
	p.curBtnNode = btnNode;
	p.sellCardList = {};
end

--数据分组
function p.divideItems()
	if p.allItems == nil then
		return
	end
	p.groupItems = p.groupItems or {};
	for i = 1, #p.allItems do
		local t = tonumber(p.allItems[i].Item_type);
			p.groupItems[t] = p.groupItems[t] or {};
			p.groupItems[t][#p.groupItems[t] + 1] = p.allItems[i];
	end
	
end

--组装装备详细界面所需的数据(统一字段名)
function p.PasreCardDetail(cardUid, itemInfo, dressId)
	local item = {};
	--item.cardId 	= cardInfo.CardID;
	item.cardUid 	= cardUid;
  --item.cardName	= "xxx"
	item.itemId 	= itemInfo.Item_id;
	item.itemUid	= itemInfo.id;
	item.itemType	= itemInfo.Item_type;
	item.itemLevel 	= itemInfo.Equip_level;
	item.itemExp	= itemInfo.Equip_exp;
	item.itemRank	= itemInfo.Rare
	item.attrType	= itemInfo.Attribute_type;
	item.attrValue	= itemInfo.Attribute_value;
	item.attrGrow	= itemInfo.Attribute_grow;
	item.exType1 	= itemInfo.Extra_type1;
	item.exValue1 	= itemInfo.Extra_value1;
	item.exType2 	= itemInfo.Extra_type2;
	item.exValue2 	= itemInfo.Extra_value2;
	item.exType3	= itemInfo.Extra_type3;
	item.exValue3	= itemInfo.Extra_value3;
	item.preItemUid	=	dressId--穿戴装备id
	return item;
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
		p.ClearData()
		p.allItems = nil;
		p.curBtnNode = nil;
		p.allCardPrice = nil;
		p.sellCardList = nil;
		p.useMoney = 0;
		p.selectList = {};
		p.dataChanged = false;
		p.upgradeCallback = nil;
    end
end

--清除数据
function p.ClearData()
	p.allItems = nil;
	p.curBtnNode = nil;
	p.allCardPrice = 0;
	p.sellCardList = {};
	p.tabIndex = 0
	p.allItems = nil;
	p.groupItems = nil;
end

--读取物品表,物品名
function p.SelectItemName(id)
	local itemTable = SelectRowList(T_EQUIP,"id",id);
	if #itemTable >= 1 then
		local text = itemTable[1].name;
		return text;
	else
		WriteConErr("itemTable error ");
	end
end


--读取物品表物品信息
function p.SelectItem(id)
	local itemTable = SelectRowList(T_EQUIP,"id",id);
	if #itemTable == 1 then
		local item = itemTable[1];
		return item;
	else
		WriteConErr("itemTable error ");
	end
end

--读取装备等级表配置信息
function p.SelectEquipConfig(level)
	local itemTable = SelectRowList(T_EQUIP_LEVEL,"equip_level",level);
	if #itemTable >= 1 then
		local item = itemTable[1];
		return item;
	else
		WriteConErr("itemTable error ");
	end
end

--读取装备等级对应的经验
function p.SelectEquipCofig4Exp(level)
	local item = p.SelectEquipConfig(level);
	if item then
		return item.exp;
	end
end

function p.SelectPlayerEquipLimit(playerLevel)
	local itemTable = SelectRowList(T_PLAYER_LEVEL,"level",level);
	if #itemTable >= 1 then
		local item = itemTable[1];
		return item.pet_upgrade_limit;
	else
		WriteConErr("itemTable error ");
	end
end

------------------------------------------------------------------网络----------------------------------------------------------------------
--可强化卡牌List请求
function p.OnSendReq()
	
	local uid = GetUID();
	
	
	if uid == 0 or uid == nil  then
		return ;
	end;
	
	local param = "";--string.format("&card_unique_id=%s",cardUniqueId)
	SendReq("Equip","EquipmentList",uid,param);		
end


--强化卡牌请求
function p.OnSendReqIntensify()
	local uid = GetUID();
	WriteCon("**可强化卡牌List请求**"..uid);
	--uid = 10002;
	if uid ~= nil and uid > 0 then
		--模块  Action idm = 饲料卡牌unique_ID (1000125,10000123) 
		--local param = string.format("&id=%d", p.cardInfo.UniqueId);
		--SendReq("card","e_Feedwould",p.baseCardId,param);
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
			p.upgradeItem.itemLevel = msg.base_card_new_info.Equip_level;
			p.upgradeItem.itemExp	= msg.base_card_new_info.Equip_exp;
			p.upgradeItem.attrValue = msg.base_card_new_info.Attribute_value;
		end
		dlg_msgbox.ShowYesNo(GetStr("card_equip_net_suc_titel"),GetStr("card_equip_upgrade_suc"),p.OnResult);
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

function p.OnResult(result)
	if result == true then
		p.allItems = nil;
		p.groupItems = nil;
		p.dataChanged = true;
		p.refreshEquipUpgradeInfo();
		p.OnSendReq();
	else
		p.CloseUI();
		if p.upgradeCallback then
			p.upgradeCallback(true);
		else
			dlg_card_attr_base.RefreshCardDetail();
		end
		
	end
end


--网络返回卡详细信息
function p.OnLoadList(msg)
	
	WriteCon( "** OnLoadList21" );
	
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	
	if msg.result == true then
		
		p.allItems = msg.equipment_info;
		p.divideItems()
		
		p.refreshTab();
		--p.ShowList(msg.equipment_info or {})
		
		WriteCon( "** OnLoadList1 " .. #msg.equipment_info);
	else
		--local str = mail_main.GetNetResultError(msg);
		--if str then
			--dlg_msgbox.ShowOK(GetStr("mail_erro_title"), str,nil);
		--else
		--	WriteCon("**======mail_write_mail.NetCallback error ======**");
		--end
		--TODO...
		WriteCon( "** OnLoadList2" );
	end
	--[[ 数据结构
		card_info: {
		UniqueID: "10000272",
		UserID: "123456",
		CardID: "101",
		Race: "1",
		Class: "2",
		Level: "1",
		Level_max: "60",
		Exp: "0",
		Damage_type: "1",
		Bind: "0",
		Team_marks: "0",
		Signature: "0",
		Rare: "2",
		Rare_max: "6",
		Hp: "400",
		Attack: "200",
		Defence: "90",
		Speed: "5",
		Skill: "0",
		Crit: "10",
		Item_id1: "33450",
		Item_id2: "0",
		Item_id3: "33452",
		Gem1: "0",
			Gem2: "0",
		Gem3: "0",
		Price: "0",
		Time: "2013-11-30 13:51:45",
		Source: "0"
		}
		]]--
end