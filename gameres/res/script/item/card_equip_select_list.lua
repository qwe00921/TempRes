


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


p.cardEquipment = nil;

p.selectList = {};

p.selectNum = 0;

p.tabIndex = 0;


function p.ShowUI(cardEquipment)
	if cardEquipment == nil then 
		return;
	end
	
	p.cardEquipment = cardEquipment;
	
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
	
	
	
	--加载卡牌列表数据  发请求
    p.OnSendReq();
	
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
	
	
	if p.cardEquipment.intent == p.INTENT_ADD 
		or p.cardEquipment.intent == p.INTENT_UPDATE then
		cardBtnAll:SetEnabled(false);
		cardBtnPro3:SetEnabled(false);
		cardBtnPro2:SetEnabled(false);
		cardBtnPro1:SetEnabled(false);
		if p.cardEquipment.equipPos == 1 then
			cardBtnPro1:SetEnabled(true);
			p.tabIndex = 1;
		elseif p.cardEquipment.equipPos == 2 then
			cardBtnPro2:SetEnabled(true);
			p.tabIndex = 2;
		elseif p.cardEquipment.equipPos == 3 then
			cardBtnPro3:SetEnabled(true);
			p.tabIndex = 3;
		end
	end
	
	local str = "";
	if p.cardEquipment.intent == p.INTENT_ADD then
		str = GetStr("card_equip_add");
	elseif p.cardEquipment.intent == p.INTENT_UPDATE then
		str = GetStr("card_equip_chg");
	else
		str = GetStr("card_equip_upgrade");
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
			p.CloseUI();
		elseif(ui.ID_CTRL_BUTTON_ALL == tag) then --全部
			WriteCon("=====allCardBtn");
			p.SetBtnCheckedFX( uiNode );
			p.tabIndex = 0;
		elseif(ui.ID_CTRL_BUTTON_PRO1 == tag) then --武器
			WriteCon("=====cardBtnPro1");
			p.SetBtnCheckedFX( uiNode );
			p.tabIndex = 1
		elseif(ui.ID_CTRL_BUTTON_PRO2 == tag) then --防具
			WriteCon("=====cardBtnPro2");
			p.SetBtnCheckedFX( uiNode );
			p.tabIndex = 2
			card_bag_mgr.ShowCardByProfession(PROFESSION_TYPE_2);
		elseif(ui.ID_CTRL_BUTTON_PRO3 == tag) then --鞋子
			WriteCon("=====cardBtnPro3");
			p.SetBtnCheckedFX( uiNode );
			p.tabIndex = 3
		end
	end
end

--确认强化为TRUE
function p.OnMsgBoxCallback(result)
	if result == true then
		WriteCon("true");
		
	end
end

--显示
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

	p.allItems = lst;
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
			if j <= cardNum then
				local card = lst[j];
				local cardIndex = j - start_index + 1;
				p.ShowCardInfo( view, card, cardIndex , j);
			end
		end
		list:AddView( view );
	end
	
		
end

--显示单张卡牌
function p.ShowCardInfo( view, card, cardIndex ,dataListIndex)
	local cardBtn = nil;
	local cardLevel = nil;
	local cardTeam = nil;
	if cardIndex == 1 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
		cardSelect = ui_list.ID_CTRL_TEXT_SELECT_1;
		cardTeam = ui_list.ID_CTRL_TEAM1;
	elseif cardIndex == 2 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
		cardSelect = ui_list.ID_CTRL_TEXT_SELECT_2;
		cardTeam = ui_list.ID_CTRL_TEAM2;
	elseif cardIndex == 3 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
		cardSelect = ui_list.ID_CTRL_TEXT_SELECT_3;
		cardTeam = ui_list.ID_CTRL_TEAM3;
	elseif cardIndex == 4 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
		cardSelect = ui_list.ID_CTRL_TEXT_SELECT_4;
		cardTeam = ui_list.ID_CTRL_TEAM4;
	end
	--显示卡牌图片
	local cardButton = GetButton(view, cardBtn);
	--local cardId = tonumber(card.CardID);
	--WriteCon("CardID ===== "..cardId);
	--local aniIndex = "card.card_"..cardId;
	local aniIndex = "item."..card.Item_id;
	cardButton:SetImage( GetPictureByAni(aniIndex, 0) );
	--cardButton:SetImage( GetPictureByAni("card.card_101",0) );
	--local cardUniqueId = tonumber(card.id);
 	--WriteCon("cardUniqueId ===== "..cardUniqueId);
    cardButton:SetId(dataListIndex);

	local cardSelectText = GetLabel(view,cardSelect );
	cardSelectText:SetVisible( false );
	
	--p.selectList[cardUniqueId] = cardSelectText;
	--设置卡牌按钮事件
	cardButton:SetLuaDelegate(p.OnCardClickEvent);
	cardButton:RemoveAllChildren(true);
end

--点击卡牌
function p.OnCardClickEvent(uiNode, uiEventType, param)
	local dataListIndex = uiNode:GetId();
	WriteCon("dataListIndex = "..dataListIndex);
	local equip = p.allItems[dataListIndex]
	
	if (equip == nil ) then
		return
	end
	
	if p.cardEquipment.intent == p.INTENT_ADD 
		or p.cardEquipment.intent == p.INTENT_UPDATE then
		local item = p.SelectItem(equip.Item_id);
		equip.equipId = equip.id;
		equip.itemInfo = item;
		equip.cardUniqueId = p.cardEquipment.cardUniqueId;
		if p.cardEquipment.intent == p.INTENT_UPDATE then
			
		end
		dlg_card_equip_detail.ShowUI4Dress(equip, p.cardEquipment.dressedItem);
	end
	
	--[[
	local cardSelectText = p.selectList[cardUniqueId] 
	
	if cardSelectText:IsVisible() == true then
		cardSelectText:SetVisible(false);
		p.selectNum = p.selectNum-1;
	else
		if p.selectNum >= 10 then 
			dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_intensify_card_num_10"),p.OnMsgCallback,p.layer);
		else
			cardSelectText:SetVisible(true);
			p.selectNum = p.selectNum+1;
		end
	end
	]]--
		
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

--提示框回调方法
function p.OnMsgCallback(result)
	
	WriteCon("OnMsgCallback");
	
end


function p.ShowSelectPic(uiNode)
	local cardUniqueId = tostring(uiNode:GetId());
	if uiNode:GetChild(ui_card_bag_select.ID_CTRL_PICTURE_CARD_SELECT) == nil then
		local view = createNDUIXView();
		view:Init();
		LoadUI("card_bag_select.xui",view,nil);
		local bg = GetUiNode( view, ui_card_bag_select.ID_CTRL_PICTURE_CARD_SELECT);
        view:SetViewSize( bg:GetFrameSize());
		view:SetTag(ui_card_bag_select.ID_CTRL_PICTURE_CARD_SELECT);
		uiNode:AddChild( view );
		p.sellCardList[#p.sellCardList + 1] = cardUniqueId;
	else
		WriteCon("RemoveAllChildren");
		for k,v in pairs(p.sellCardList) do
			if v == cardUniqueId then
				table.remove(p.sellCardList,k);
			end
		end
		uiNode:RemoveAllChildren(true);
	end
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
        card_bag_mgr.ClearData();
		p.allItems = nil;
		p.curBtnNode = nil;
		p.allCardPrice = nil;
		p.sellCardList = nil;
		
		p.selectList = {};
    end
end

function p.ClearData()
	p.allItems = nil;
	p.curBtnNode = nil;
	p.allCardPrice = 0;
	p.sellCardList = {};
	
	p.allItems = nil;
	p.groupItems = nil;
end



----------------------------网络--------------------------------
--可强化卡牌List请求
function p.OnSendReq()
	
	local uid = GetUID();
	--uid=123456
	
	if uid == 0 or uid == nil  then
		return ;
	end;
	
	local param = "";--string.format("&card_unique_id=%s",cardUniqueId)
	SendReq("Item","EquipmentList",uid,param);		
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