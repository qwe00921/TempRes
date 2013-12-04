CARD_BAG_SORT_BY_LEVEL	= 1001;
CARD_BAG_SORT_BY_STAR	= 1002;
CARD_BAG_SORT_BY_TIME = 1003;

PROFESSION_TYPE_1 = 2001;
PROFESSION_TYPE_2 = 2002;
PROFESSION_TYPE_3 = 2003;
PROFESSION_TYPE_4 = 2004;

MARK_ON = 100;
MARK_OFF = nil;

card_intensify  = {}
local p = card_intensify;

local ui = ui_card_intensify;
local ui_list = ui_card_list_intensify_view;

p.layer = nil;
p.cardListInfo = nil;
p.curBtnNode = nil;
p.sortByRuleV = nil;
p.allCardPrice = 0;
p.sellCardList = {};
p.baseCardInfo = nil;

p.selectList = {};
p.teamList = {};
p.selectNum = 0;
p.consumeMoney = 0;
p.selectCardId = {};
p.userMoney = 0;
function p.ShowUI(baseCardInfo)
	
	if baseCardInfo == nil then 
		return;
	end
	p.baseCardInfo = baseCardInfo;
	--WriteCon(baseCardInfo.UniqueID.."********************");
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
    LoadDlg("card_intensify.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
	
	--加载卡牌列表数据  发请求
    p.OnSendReq();
	--p.ShowCardList( cardList )
end

--可强化卡牌List请求
function p.OnSendReq()
	
	local uid = GetUID();
	WriteCon("**可强化卡牌List请求**"..uid);
	--uid = 1234;
	if uid ~= nil and uid > 0 then
		--模块  Action 
		--local param = string.format("&id=%d", p.cardInfo.UniqueId);
		SendReq("CardList","List",uid,"");
	end
	
end
--强化卡牌请求
function p.OnSendReqIntensify(msg)
	local uid = GetUID();
	WriteCon("**强化卡牌请求**"..uid.." uniqueid = "..p.baseCardInfo.UniqueId);
	--uid = 10002;
	if uid ~= nil and uid > 0 then
		--模块  Action idm = 饲料卡牌unique_ID (1000125,10000123) 
		local param = string.format("&card_id=%d&idm="..msg, tonumber(p.baseCardInfo.UniqueId));
		WriteCon("param = "..param);
		SendReq("Card","Feedwould",uid,param);
		card_intensify_succeed.ShowUI(p.baseCardInfo);
		p.ClearData();
	end
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
	
	local intensifyByBtn = GetButton(layer, ui.ID_CTRL_BUTTON_26);
	intensifyByBtn:SetLuaDelegate(p.OnUIClickEvent);
	
end

--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			p.CloseUI();
		elseif(ui.ID_CTRL_BUTTON_26 == tag) then --强化
			WriteCon("=====intensifyByBtn");
			if #p.selectCardId <=0 then
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_intensify_no_card"),p.OnMsgCallback,p.layer);
			else
				local param = "";
				for k,v in pairs(p.selectCardId) do
					
					if k == #p.selectCardId then
						param = param..v;
					else
						param = param..v..",";
					end
				end
				p.OnSendReqIntensify(param);
				--p.CloseUI();
			end 
			
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
function p.ShowCardList(cardList,msg)
	if p.layer == nil then
		return;
	end
	if #cardList <= 0 then
		return;
	end
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();

	local cardCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_30);
	cardCount:SetText(tostring(p.selectNum).."/10"); 	
	
	local cardMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_32);
	cardMoney:SetText("0"); 
	
	
	local countLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_25);
	countLab:SetText(tostring(msg.cardlist_num).."/"..tostring(msg.cardmax));
	--持有金币
	local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
	moneyLab:SetText(tostring(msg.money));
	
	p.userMoney = msg.money;
	
	p.cardListInfo = cardList;
	
	if p.cardListInfo == nil or #p.cardListInfo <= 0 then
		WriteCon("ShowCardList():p.cardListInfo is null");
		return;
	end
	
	local cardNum = #p.cardListInfo -1;
	
	--列表删除要强化的那条卡牌数据 
	for i = 1 , #p.cardListInfo do
		if p.cardListInfo[i].UniqueId == p.baseCardInfo.UniqueId then
			table.remove(p.cardListInfo,i);
			break;
		end
	end	
	local row = math.ceil(cardNum / 4);
	
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("card_list_intensify_view.xui",view,nil);
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
		local row_index = i;
		local start_index = (row_index-1)*4+1
        local end_index = start_index + 3;
		
		--设置列表信息，一行4张卡牌
		for j = start_index,end_index do
			if j <= cardNum then
				local card = p.cardListInfo[j];
				
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
		cardTeam = ui_list.ID_CTRL_TEAM_1;
	elseif cardIndex == 2 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
		cardSelect = ui_list.ID_CTRL_TEXT_SELECT_2;
		cardTeam = ui_list.ID_CTRL_TEAM_2;
	elseif cardIndex == 3 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
		cardSelect = ui_list.ID_CTRL_TEXT_SELECT_3;
		cardTeam = ui_list.ID_CTRL_TEAM_3;
	elseif cardIndex == 4 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
		cardSelect = ui_list.ID_CTRL_TEXT_SELECT_4;
		cardTeam = ui_list.ID_CTRL_TEAM_4;
	end
	--显示卡牌图片
	local cardButton = GetButton(view, cardBtn);
	local cardId = tonumber(card.CardID);
	local aniIndex = "card.card_"..cardId;
	cardButton:SetImage( GetPictureByAni(aniIndex, 0) );
	--cardButton:SetImage( GetPictureByAni("card.card_101",0) );
	local cardUniqueId = tonumber(card.UniqueId);
    cardButton:SetId(cardUniqueId);

	
	local teamText = GetLabel(view,cardTeam);
	
	if card.Team_marks ~= 0 then
		teamText:SetText(GetStr("card_intensify_team")..tostring(card.Team_marks));
	end
	
	
	local cardSelectText = GetLabel(view,cardSelect );
	cardSelectText:SetVisible( false );
	local Team_marks = card.Team_marks;
	p.teamList[cardUniqueId] = Team_marks;
	
	p.selectList[cardUniqueId] = cardSelectText;
	--设置卡牌按钮事件
	cardButton:SetLuaDelegate(p.OnCardClickEvent);
	cardButton:RemoveAllChildren(true);
end

--点击卡牌
function p.OnCardClickEvent(uiNode, uiEventType, param)
	local cardUniqueId = uiNode:GetId();
	local cardSelectText = p.selectList[cardUniqueId] 
		
	local pCardLeveInfo = nil;
	
	for k,v in pairs(p.cardListInfo) do
		if v.UniqueId == cardUniqueId then
			if v.Level == 0 then
				pCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "card_level", 1);
			else
				pCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "card_level", v.Level);
			end
			break;
		end
	end
	
	if cardSelectText:IsVisible() == true then
		cardSelectText:SetVisible(false);
		for k,v in pairs(p.selectCardId) do
			if v == cardUniqueId then
				table.remove(p.selectCardId,k);
			end
		end
		
		p.selectNum = p.selectNum-1;
		p.consumeMoney = p.consumeMoney - pCardLeveInfo.feed_money;
	else
		if p.selectNum >= 10 then 
			dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_intensify_card_num_10"),p.OnMsgCallback,p.layer);
		elseif p.teamList[cardUniqueId] ~= 0 then
			dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_intensify_card_team"),p.OnMsgCallback,p.layer);
		else
			cardSelectText:SetVisible(true);
			p.selectNum = p.selectNum+1;
			p.selectCardId[#p.selectCardId + 1] = cardUniqueId;
			
			p.consumeMoney = p.consumeMoney + pCardLeveInfo.feed_money;
		end
	end
	local cardCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_30);
	cardCount:SetText(tostring(p.selectNum).."/10"); 
	
	local cardMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_32);
	cardMoney:SetText(tostring(p.consumeMoney)); 
	
	if tonumber(p.userMoney) < tonumber(p.consumeMoney) then
		local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
		moneyLab:SetFontColor(ccc4(255,0,0,255));
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
		p.cardListInfo = nil;
		p.curBtnNode = nil;
		p.sortBtnMark = MARK_OFF;
		p.sortByRuleV = nil;
		p.BatchSellMark = MARK_OFF;
		p.allCardPrice = 0;
		p.selectList = {};
		p.teamList = {};
		p.sellCardList = {};
		p.selectCardId = {};
		p.baseCardInfo = nil;
		p.consumeMoney = 0;
		p.selectNum = 0;
        card_bag_mgr.ClearData();
		
    end
end

function p.ClearData()
	p.selectNum = 0;
	p.selectCardId = {};
	p.cardListInfo = nil;
end