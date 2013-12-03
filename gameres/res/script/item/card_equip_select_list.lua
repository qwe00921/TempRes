CARD_BAG_SORT_BY_LEVEL	= 1001;
CARD_BAG_SORT_BY_STAR	= 1002;
CARD_BAG_SORT_BY_TIME = 1003;

PROFESSION_TYPE_1 = 2001;
PROFESSION_TYPE_2 = 2002;
PROFESSION_TYPE_3 = 2003;
PROFESSION_TYPE_4 = 2004;

MARK_ON = 100;
MARK_OFF = nil;

card_equip_select_list  = {}
local p = card_equip_select_list;

local ui = ui_card_equip_select_list;
local ui_list = ui_card_equip_select_list_item;

p.layer = nil;
p.listInfo = nil;
p.curBtnNode = nil;
p.sortByRuleV = nil;
p.allCardPrice = 0;
p.sellCardList = {};

p.baseCardId = nil;

p.selectList = {};

p.selectNum = 0;
function p.ShowUI(baseCardId)
	if baseCardId == nil then 
	--	return;
	end
	p.baseCardId = baseCardId;
	
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
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddDlg(layer);
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
	cardBtnAll:SetLuaDelegate(p.OnUIClickEvent);
	p.SetBtnCheckedFX( cardBtnAll );

	local cardBtnPro1 = GetButton(layer, ui.ID_CTRL_BUTTON_PRO1);
	cardBtnPro1:SetLuaDelegate(p.OnUIClickEvent);

	local cardBtnPro2 = GetButton(layer, ui.ID_CTRL_BUTTON_PRO2);
	cardBtnPro2:SetLuaDelegate(p.OnUIClickEvent);
	
	local cardBtnPro3 = GetButton(layer, ui.ID_CTRL_BUTTON_PRO3);
	cardBtnPro3:SetLuaDelegate(p.OnUIClickEvent);
	
	local cardBtnPro4 = GetButton(layer, ui.ID_CTRL_BUTTON_PRO4);
	cardBtnPro4:SetLuaDelegate(p.OnUIClickEvent);
	
	local sortByBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SORT_BY);
	sortByBtn:SetLuaDelegate(p.OnUIClickEvent);
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
			card_bag_mgr.ShowAllCards();
		elseif(ui.ID_CTRL_BUTTON_PRO1 == tag) then --职业1
			WriteCon("=====cardBtnPro1");
			p.SetBtnCheckedFX( uiNode );
			card_bag_mgr.ShowCardByProfession(PROFESSION_TYPE_1);
		elseif(ui.ID_CTRL_BUTTON_PRO2 == tag) then --职业2
			WriteCon("=====cardBtnPro2");
			p.SetBtnCheckedFX( uiNode );
			card_bag_mgr.ShowCardByProfession(PROFESSION_TYPE_2);
		elseif(ui.ID_CTRL_BUTTON_PRO3 == tag) then --职业3
			WriteCon("=====cardBtnPro3");
			p.SetBtnCheckedFX( uiNode );
			card_bag_mgr.ShowCardByProfession(PROFESSION_TYPE_3);
		elseif(ui.ID_CTRL_BUTTON_PRO4 == tag) then --职业4
			WriteCon("=====cardBtnPro4");
			p.SetBtnCheckedFX( uiNode );
			card_bag_mgr.ShowCardByProfession(PROFESSION_TYPE_4);
		elseif(ui.ID_CTRL_BUTTON_SORT_BY == tag) then --按等级排序
			WriteCon("card_bag_sort.ShowUI()");
			if p.sortBtnMark == nil then
				card_bag_sort.ShowUI();
			else
				p.sortBtnMark = nil;
				card_bag_sort.CloseUI();
			end
		end
	end
end

--确认强化为TRUE
function p.OnMsgBoxCallback(result)
	if result == true then
		WriteCon("true");
		
	end
end

--按规则排序按钮
function p.sortByBtnEvent(sortType)
	if sortType == nil then
		return
	end
	local sortByBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_SORT_BY);
	sortByBtn:SetLuaDelegate(p.OnUIClickEvent);
	if(sortType == CARD_BAG_SORT_BY_LEVEL) then
		sortByBtn:SetImage( GetPictureByAni("button.card_bag",0));
		p.sortByRuleV = CARD_BAG_SORT_BY_LEVEL;
	elseif(sortType == CARD_BAG_SORT_BY_STAR) then
		sortByBtn:SetImage( GetPictureByAni("button.card_bag",1));
		p.sortByRuleV = CARD_BAG_SORT_BY_STAR;
	elseif(sortType == CARD_BAG_SORT_BY_TIME) then 
		sortByBtn:SetImage( GetPictureByAni("button.card_bag",2));
		p.sortByRuleV = CARD_BAG_SORT_BY_TIME;
	end
	card_bag_mgr.sortByRule(sortType)

end 


--显示卡牌列表
function p.ShowList(lst)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	WriteCon("ShowList()");
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();

	p.listInfo = lst;
	if lst == nil or #lst <= 0 then
		WriteCon("ShowList():cardList is null");
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
				p.ShowCardInfo( view, card, cardIndex );
			end
		end
		list:AddView( view );
	end
end

--显示单张卡牌
function p.ShowCardInfo( view, card, cardIndex )
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
	local cardUniqueId = tonumber(card.id);
 	WriteCon("cardUniqueId ===== "..cardUniqueId);
    cardButton:SetId(cardUniqueId);

	local cardSelectText = GetLabel(view,cardSelect );
	cardSelectText:SetVisible( false );
	
	p.selectList[cardUniqueId] = cardSelectText;
	--设置卡牌按钮事件
	--cardButton:SetLuaDelegate(p.OnCardClickEvent);
	cardButton:RemoveAllChildren(true);
end

--点击卡牌
function p.OnCardClickEvent(uiNode, uiEventType, param)
	local cardUniqueId = uiNode:GetId();
	WriteCon("cardUniqueId = "..cardUniqueId);
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
	card_bag_sort.CloseUI();
	p.sellCardList = {};
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
		p.listInfo = nil;
		p.curBtnNode = nil;
		p.sortByRuleV = nil;
		p.allCardPrice = nil;
		p.sellCardList = nil;
		p.baseCardId = nil;
		p.selectList = {};
    end
end

function p.ClearData()
	p.listInfo = nil;
	p.curBtnNode = nil;
	p.sortBtnMark = MARK_OFF;
	p.sortByRuleV = nil;
	p.BatchSellMark = MARK_OFF;
	p.allCardPrice = 0;
	p.sellCardList = {};
end

----------------------------网络--------------------------------
--可强化卡牌List请求
function p.OnSendReq()
	
	local uid = GetUID();
	uid=123456
	
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
	
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	WriteCon( "** OnLoadList" );
	
	if msg.result == true then
		p.ShowList(msg.equipment_info or {})
		
		WriteCon( "** OnLoadList1" );
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