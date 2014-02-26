CARD_BAG_SORT_BY_LEVEL	= 1001;
CARD_BAG_SORT_BY_STAR	= 1002;
CARD_BAG_SORT_BY_TIME = 1004;

PROFESSION_TYPE_1 = 2001;
PROFESSION_TYPE_2 = 2002;
PROFESSION_TYPE_3 = 2003;
PROFESSION_TYPE_4 = 2004;
PROFESSION_TYPE_5 = 2005;
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
p.sortBtnMark = MARK_OFF;	--按规则排序是否开启
p.sortByRuleNum = nil;
p.selectList = {};
p.teamList = {};
p.selectNum = 0;
p.consumeMoney = 0;
p.selectCardId = {};
p.userMoney = 0;
p.cardListByProf = {};
p.cardListNode = {};		--所有卡牌节点列表
p.cardNumListNode = {};
p.cardEnabled = true;
p.rookieNode_1 = nil;
p.rookieNode_2 = nil;
p.rookieNode_3 = nil;
p.rookieNode_4 = nil;
p.rookieNode_5 = nil;
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
	
    GetUIRoot():AddChildZ(layer,0);
    LoadDlg("card_intensify.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
	
	--加载卡牌列表数据  发请求
    p.OnSendReq();
	--p.ShowCardList( cardList )
end

--可强化卡牌List请求
function p.OnSendReq()
	WriteCon("card_intensify OnSendReq");
	local uid = GetUID();
	--uid = 1234;
	if uid ~= nil and uid > 0 then
		--模块  Action 
		SendReq("CardList","ListFeed",uid,"");
		--SendReq("CardList","List",uid,"");
	end
	
end
--强化卡牌请求
function p.OnSendReqIntensify(msg)
	local uid = GetUID();
	--uid = 10002;
	if uid ~= nil and uid > 0 then
		--模块  Action idm = 饲料卡牌unique_ID (1000125,10000123) 
		local param = string.format("&card_id=%d&idm="..msg, tonumber(p.baseCardInfo.UniqueId));
		SendReq("Card","Feedwould",uid,param);
		card_intensify_succeed.ShowUI(p.baseCardInfo);
		p.ClearData();
	end
end

--主界面事件处理
function p.SetDelegate(layer)
	local retBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	retBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();
	
--[[
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
	
	local cardBtnPro5 = GetButton(layer, ui.ID_CTRL_BUTTON_PRO5);
	cardBtnPro5:SetLuaDelegate(p.OnUIClickEvent);
	]]--update 2014-01-03
	local sortByBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SORT_BY);
	sortByBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local intensifyByBtn = GetButton(layer, ui.ID_CTRL_BUTTON_26);
	intensifyByBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local clearByBtn = GetButton(layer, ui.ID_CTRL_BUTTON_CLEAR);
	clearByBtn:SetLuaDelegate(p.OnUIClickEvent);
	
end

function p.rookieClickEvent()
	local intensifyByBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_26);
	p.OnUIClickEvent(intensifyByBtn, NUIEventType.TE_TOUCH_CLICK)
end
function p.rookieClickOnCard_1()
	p.OnCardClickEvent(p.rookieNode_1,NUIEventType.TE_TOUCH_CLICK)
end
function p.rookieClickOnCard_2()
	p.OnCardClickEvent(p.rookieNode_2,NUIEventType.TE_TOUCH_CLICK)
end
function p.rookieClickOnCard_3()
	p.OnCardClickEvent(p.rookieNode_3,NUIEventType.TE_TOUCH_CLICK)
end
function p.rookieClickOnCard_4()
	p.OnCardClickEvent(p.rookieNode_4,NUIEventType.TE_TOUCH_CLICK)
end
function p.rookieClickOnCard_5()
	p.OnCardClickEvent(p.rookieNode_5,NUIEventType.TE_TOUCH_CLICK)
end
--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			p.CloseUI();
			card_rein.ShowUI();
		elseif(ui.ID_CTRL_BUTTON_26 == tag) then --强化
			WriteCon("OnUIClickEvent....   intensify");
			local pCardLevelMax= SelectRowInner( T_CARD_LEVEL_LIMIT, "star", p.baseCardInfo.Rare); --从表中获取卡牌详细信息	
			--WriteCon("Max Level ："..pCardLevelMax.level_limit.."  now Level : "..p.baseCardInfo.Level);
			if #p.selectCardId <=0 then
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_intensify_no_card"),p.OnMsgCallback,p.layer);
			elseif tonumber( p.baseCardInfo.Level) >= tonumber(pCardLevelMax.level_limit) then
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_intensify_no_level_max"),p.OnMsgCallback,p.layer);
				
			else
				--[[
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
				]]--
				--update by csd 2013-12-18
				
				for k,v in pairs(p.selectCardId) do
					for i = 1,#p.cardListInfo do 
						local card = p.cardListInfo[i];
							if card.UniqueId == v then
								
								if tonumber(card.Rare) >= 4 then
									dlg_msgbox.ShowYesNo(GetStr("card_caption"),GetStr("card_intensify_rare"),p.OkCallback,p.layer);
									return;
								end
							end
					end
					
				end
				
				local lCardIdLst = {}
				for k,v in pairs(p.selectCardId) do
					table.insert(lCardIdLst, v);
				end;
				card_rein.ShowUI();
				card_rein.setSelCardList(lCardIdLst);
				p.CloseUI();
			end 
		--[[	
		elseif(ui.ID_CTRL_BUTTON_ALL == tag) then --全部
			p.SetBtnCheckedFX( uiNode );
			p.ShowCardView(p.cardListInfo);
			p.cardListByProf = p.cardListInfo;
		elseif(ui.ID_CTRL_BUTTON_PRO1 == tag) then --职业1
			p.SetBtnCheckedFX( uiNode );
			p.ShowCardByProfession(PROFESSION_TYPE_1);
		elseif(ui.ID_CTRL_BUTTON_PRO2 == tag) then --职业2
			p.SetBtnCheckedFX( uiNode );
			p.ShowCardByProfession(PROFESSION_TYPE_2);
		elseif(ui.ID_CTRL_BUTTON_PRO3 == tag) then --职业3
			p.SetBtnCheckedFX( uiNode );
			p.ShowCardByProfession(PROFESSION_TYPE_3);
		elseif(ui.ID_CTRL_BUTTON_PRO4 == tag) then --职业4
			p.SetBtnCheckedFX( uiNode );
			p.ShowCardByProfession(PROFESSION_TYPE_4);
		elseif(ui.ID_CTRL_BUTTON_PRO5 == tag) then --职业5
			p.SetBtnCheckedFX( uiNode );
			p.ShowCardByProfession(PROFESSION_TYPE_5);]]-- update 2014-01-03
		elseif(ui.ID_CTRL_BUTTON_SORT_BY == tag) then --按等级排序
				--card_bag_sort.ShowUI(1);

			if p.sortBtnMark == MARK_OFF then
				card_bag_sort.ShowUI(1);
			else
				p.sortBtnMark = MARK_OFF;
				card_bag_sort.HideUI();
				card_bag_sort.CloseUI();
			end
		elseif(ui.ID_CTRL_BUTTON_CLEAR == tag) then 
			--清除按钮
			p.clearDate();
		end
	end
end

function p.OkCallback(result)
	if result == true then
		local lCardIdLst = {}
		for k,v in pairs(p.selectCardId) do
			table.insert(lCardIdLst, v);
		end;
		card_rein.ShowUI();
		card_rein.setSelCardList(lCardIdLst);
		p.CloseUI();
		
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
	WriteCon("sortType = "..sortType);
	if sortType == nil then
		return
	end
	local sortByImage = GetImage(p.layer, ui.ID_CTRL_PICTURE_154);
	--sortByBtn:SetLuaDelegate(p.OnUIClickEvent);
	if(sortType == CARD_BAG_SORT_BY_LEVEL) then
		--sortByBtn:SetImage( GetPictureByAni("button.card_bag",0));
		sortByImage:SetPicture(GetPictureByAni("ui.card_order",1));
		p.sortByRuleV = CARD_BAG_SORT_BY_LEVEL;
	elseif(sortType == CARD_BAG_SORT_BY_STAR) then
		--sortByBtn:SetImage( GetPictureByAni("button.card_bag",1));
		sortByImage:SetPicture(GetPictureByAni("ui.card_order",2));
		p.sortByRuleV = CARD_BAG_SORT_BY_STAR;
	elseif(sortType == CARD_BAG_SORT_BY_TIME) then 
		--sortByBtn:SetImage( GetPictureByAni("button.card_bag",2));
		sortByImage:SetPicture(GetPictureByAni("ui.card_order",3));		
		p.sortByRuleV = CARD_BAG_SORT_BY_TIME;
	end
	p.sortByRule(sortType)

end 


--返回数据显示 Lab框
function p.ShowCardList(cardList,msg)
	
	if p.layer == nil then
		return;
	end
	if #cardList <= 0 then
		return;
	end
--	card_rein.SetUserMoney(msg.money);
	card_rein.setCardListInfo(cardList);
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();

	local cardCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_30);
	cardCount:SetText(tostring(p.selectNum).."/10"); 	
	
	local cardMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_32);
	cardMoney:SetText("0"); 
	
	
	local countLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_25);
	
	--持有金币
	--local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
	--moneyLab:SetText(tostring(msg.money));
	
	countLab:SetText(tostring(msg.cardlist_num).."/"..tostring(msg.cardmax));
	
	p.userMoney = msg.money;
	p.cardListInfo = cardList;
	
	--列表删除要强化的那条卡牌数据 
	for i = 1 , #p.cardListInfo do
		if p.cardListInfo[i].UniqueId == p.baseCardInfo.UniqueId then
			table.remove(p.cardListInfo,i);
			break;
		end
	end	
	p.cardListByProf = p.cardListInfo;
	p.ShowCardView(p.cardListInfo);
	
	
end

function p.InitViewUI(view)
   for cardIndex=1,5 do
		if cardIndex == 1 then
			--cardBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
			cardSelect = ui_list.ID_CTRL_PICTURE_S1;
			cardTeam = ui_list.ID_CTRL_PICTURE_TEAM1;
			cardLevel = ui_list.ID_CTRL_LEVEL_1;
			cardLevelBg = ui_list.ID_CTRL_PICTURE_38;
		elseif cardIndex == 2 then
			--cardBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
			cardSelect = ui_list.ID_CTRL_PICTURE_S2;
			cardTeam = ui_list.ID_CTRL_PICTURE_TEAM2;
			cardLevel = ui_list.ID_CTRL_LEVEL_2;
			cardLevelBg = ui_list.ID_CTRL_PICTURE_39;
		elseif cardIndex == 3 then
			--cardBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
			cardSelect = ui_list.ID_CTRL_PICTURE_S3;
			cardTeam = ui_list.ID_CTRL_PICTURE_TEAM3;
			cardLevel = ui_list.ID_CTRL_LEVEL_3;
			cardLevelBg = ui_list.ID_CTRL_PICTURE_40;
		elseif cardIndex == 4 then
			--cardBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
			cardSelect = ui_list.ID_CTRL_PICTURE_S4;
			cardTeam = ui_list.ID_CTRL_PICTURE_TEAM4;
			cardLevel = ui_list.ID_CTRL_LEVEL_4;
			cardLevelBg = ui_list.ID_CTRL_PICTURE_41;
		elseif cardIndex == 5 then
			--cardBtn = ui_list.ID_CTRL_BUTTON_ITEM5;
			cardSelect = ui_list.ID_CTRL_PICTURE_S5;
			cardTeam = ui_list.ID_CTRL_PICTURE_TEAM5;
			cardLevel = ui_list.ID_CTRL_LEVEL_5;
			cardLevelBg = ui_list.ID_CTRL_PICTURE_47;
		end
		
		local teamPic = GetImage(view,cardTeam);
		teamPic:SetVisible(false);
		
		local cardSelectText = GetImage(view,cardSelect );
		cardSelectText:SetVisible( false );
			
		local levelText = GetLabel(view,cardLevel);
		levelText:SetVisible( false );
		
		local levelTextBg = GetImage(view,cardLevelBg );
		levelTextBg:SetVisible( false );
  end
end;	

--显示卡牌列表
function p.ShowCardView(cardList)
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();
	p.cardListNode = {};
	if cardList == nil or #cardList <= 0 then
		WriteCon("ShowCardView():cardList is null");
		return;
	end
	local cardNum = #cardList;
	
	local row = math.ceil(cardNum / 5);
	if #p.cardListNode ~= 0 then
		p.cardListNode = {};
	end
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("card_list_intensify_view.xui",view,nil);
		
		p.InitViewUI(view);
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
		local row_index = i;
		local start_index = (row_index-1)*5+1
        local end_index = start_index + 4;
		
		--设置列表信息，一行4张卡牌
		for j = start_index,end_index do
			if j <= cardNum then
				local card = cardList[j];
				
				local cardIndex = j - start_index + 1;
				p.ShowCardInfo( view, card, cardIndex, i );
				
			end
		end
		list:AddView( view );
	end
	--p.selectList ID是key   p.selectCardId
	
	for k,v in pairs(p.selectCardId) do
		for i = 1,cardNum do 
			local card = cardList[i];
				if card.UniqueId == v then
					p.selectList[v]:SetVisible(true);
				end
		end
		
	end
	
	if  tonumber(p.selectNum) >= 10 then 
		p.setAllCardDisEnable();
	elseif tonumber(p.selectNum) < 10 then
		p.setCardDisEnable();
	end
	
	p.setNumFalse();
	
end
--显示单张卡牌
function p.ShowCardInfo( view, card, cardIndex, row )
	--WriteCon("************"..cardIndex);
	local cardBtn = nil;
	local cardLevel = nil;
	local cardTeam = nil;
	local cardSelect = nil;
	local numText = nil;
	if cardIndex == 1 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
		cardSelect = ui_list.ID_CTRL_PICTURE_S1;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM1;
		cardLevel = ui_list.ID_CTRL_LEVEL_1;
		cardLeveImg = ui_list.ID_CTRL_PICTURE_38
		numText = ui_list.ID_CTRL_TEXT_NUM1;
	elseif cardIndex == 2 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
		cardSelect = ui_list.ID_CTRL_PICTURE_S2;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM2;
		cardLevel = ui_list.ID_CTRL_LEVEL_2;
		cardLeveImg = ui_list.ID_CTRL_PICTURE_39
		numText = ui_list.ID_CTRL_TEXT_NUM2;
	elseif cardIndex == 3 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
		cardSelect = ui_list.ID_CTRL_PICTURE_S3;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM3;
		cardLevel = ui_list.ID_CTRL_LEVEL_3;
		cardLeveImg = ui_list.ID_CTRL_PICTURE_40;
		numText = ui_list.ID_CTRL_TEXT_NUM3;
	elseif cardIndex == 4 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
		cardSelect = ui_list.ID_CTRL_PICTURE_S4;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM4;
		cardLevel = ui_list.ID_CTRL_LEVEL_4;
		cardLeveImg = ui_list.ID_CTRL_PICTURE_41;
		numText = ui_list.ID_CTRL_TEXT_NUM4;
	elseif cardIndex == 5 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM5;
		cardSelect = ui_list.ID_CTRL_PICTURE_S5;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM5;
		cardLevel = ui_list.ID_CTRL_LEVEL_5;
		cardLeveImg = ui_list.ID_CTRL_PICTURE_47;
		numText = ui_list.ID_CTRL_TEXT_NUM5;
	end
	--显示卡牌图片
	local cardButton = GetButton(view, cardBtn);
	local cardId = tonumber(card.CardID);
	
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", cardId); --从表中获取卡牌详细信息	
	cardButton:SetImage( GetPictureByAni(pCardInfo.head_pic, 0) );
	--cardButton:SetImage( GetPictureByAni("card.card_101",0) );
	local cardUniqueId = tonumber(card.UniqueId);
    cardButton:SetId(cardUniqueId);

	--ui.public.team1.png  队伍
	local teamText = GetImage(view,cardTeam);
	--[[
	if card.Team_marks == 1 then
		teamText:SetImage( GetPictureByAni("ui.public.team1.png", 0) );
	elseif card.Team_marks == 2 then
		teamText:SetImage( GetPictureByAni("ui.public.team2.png", 0) );
	elseif card.Team_marks == 3 then
		teamText:SetImage( GetPictureByAni("ui.public.team3.png", 0) );
	else
		teamText:SetVisible( false );
	end
	]]--
	if card.Team_marks == 1 then
		teamText:SetPicture( GetPictureByAni("common_ui.teamName", 0) );
	elseif card.Team_marks == 2 then
		teamText:SetPicture( GetPictureByAni("common_ui.teamName", 1) );
	elseif card.Team_marks == 3 then
		teamText:SetPicture( GetPictureByAni("common_ui.teamName", 2) );
	else
		teamText:SetVisible( false );
	end
	--卡牌等级
	local levelText = GetLabel(view,cardLevel);
	levelText:SetText(tostring(card.Level));
	levelText:SetVisible(true);

	local levelImg = GetImage(view,cardLeveImg);
	levelImg:SetVisible(true);
	
	--是否选中图片
	local cardSelectText = GetImage(view,cardSelect );
	cardSelectText:SetVisible( false );
		
	--local num = GetLabel(view,numText);
	--num.SetVisible( false );
	
	--p.cardNumListNode[cardUniqueId] = cardSelectText;
	
	local Team_marks = card.Team_marks;
	p.teamList[cardUniqueId] = Team_marks;
	
	p.selectList[cardUniqueId] = cardSelectText;
	
	--设置卡牌按钮事件
	cardButton:SetLuaDelegate(p.OnCardClickEvent);
	cardButton:RemoveAllChildren(true);
	
	if tonumber(card.Item_id1) ~= 0 or tonumber(card.Item_id2) ~= 0 then
		cardButton:SetEnabled(false);
	end
	if row == 1 and cardIndex == 1 then
		p.rookieNode_1 = cardButton;
	elseif row == 1 and cardIndex == 2 then
		p.rookieNode_2 = cardButton;
	elseif row == 1 and cardIndex == 3 then
		p.rookieNode_3 = cardButton;
	elseif row == 1 and cardIndex == 4 then
		p.rookieNode_4 = cardButton;
	elseif row == 1 and cardIndex == 5 then
		p.rookieNode_5 = cardButton;
	end
	p.cardListNode[#p.cardListNode + 1] = cardButton;
end

--点击卡牌
function p.OnCardClickEvent(uiNode, uiEventType, param)
	local cardUniqueId = uiNode:GetId();
	local cardSelectText = p.selectList[cardUniqueId] 
	--local numText = p.cardNumListNode[cardUniqueId];
	local pCardLeveInfo = nil;
	local card = nil;
	for k,v in pairs(p.cardListInfo) do
		if v.UniqueId == cardUniqueId then
			card = v;
			if v.Level == 0 then
				pCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", 1);
			else
				pCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", v.Level);
			end
			break;
		end
	end
	
	if cardSelectText:IsVisible() == true then
		cardSelectText:SetVisible(false);
		--numText:SetVisible(false);
		--numText:SetText("");
		for k,v in pairs(p.selectCardId) do
			if v == cardUniqueId then
				table.remove(p.selectCardId,k);
			end
		end
		p.setNumFalse();
		p.selectNum = p.selectNum-1;
		
		local feed_money = 0;
		if pCardLeveInfo.feed_money ~= nil then
			feed_money = tonumber(pCardLeveInfo.feed_money);
		end
	
		--p.consumeMoney = p.consumeMoney + pCardLeveInfo.feed_money + tonumber(card.Level)*tonumber(card.Level);
		p.consumeMoney = p.consumeMoney - feed_money;
	else
		if p.selectNum >= 10 then 
			dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_intensify_card_num_10"),p.OnMsgCallback,p.layer);
			
		elseif p.teamList[cardUniqueId] ~= 0 then
			dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_intensify_card_team"),p.OnMsgCallback,p.layer);
		else
			cardSelectText:SetVisible(true);
			p.selectNum = p.selectNum+1;
			--numText:SetText(tostring(p.selectNum));
			cardSelectText:SetPicture(GetPictureByAni("common_ui.card_num",  p.selectNum) );
	--		numText:SetVisible(true);
			p.selectCardId[#p.selectCardId + 1] = cardUniqueId;
			
			local feed_money = 0;
			if pCardLeveInfo.feed_money ~= nil then
				feed_money = tonumber(pCardLeveInfo.feed_money);
			end
			--p.consumeMoney = p.consumeMoney + pCardLeveInfo.feed_money + tonumber(card.Level)*tonumber(card.Level);
			p.consumeMoney = p.consumeMoney + feed_money
			
		end
	end
	local cardCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_30);
	cardCount:SetText(tostring(p.selectNum).."/10"); 
	
	local cardMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_32);
	cardMoney:SetText(tostring(p.consumeMoney)); 
	
	--if tonumber(p.userMoney) < tonumber(p.consumeMoney) then
		--local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
		--moneyLab:SetFontColor(ccc4(255,0,0,255));
	--end
	if  tonumber(p.selectNum) >= 10 then 
		p.setAllCardDisEnable();
		p.cardEnabled = false;
	elseif tonumber(p.selectNum) < 10 then
		p.setCardDisEnable();
		p.cardEnabled = true;
	end
	
end

--设置除选择外的卡牌不可点
function p.setAllCardDisEnable()
	for i=1, #p.cardListNode do
		local cardUniqueId = p.cardListNode[i]:GetId();
		local uiNode = p.cardListNode[i]
		for i=1,#p.selectCardId do
			if tonumber(cardUniqueId) == tonumber(p.selectCardId[i]) then
				uiNode:SetEnabled(true);
				break;
			else
				uiNode:SetEnabled(false);
			end
		end
		
	end
end
--设置序号更新
function p.setNumFalse()
	for k,v in pairs(p.selectCardId) do
			--WriteCon("k : "..k);
			local cardSelectText = p.selectList[v];
			cardSelectText:SetPicture(GetPictureByAni("common_ui.card_num",k));
			--numText:SetText(tostring(k));
	end

end


--设置卡牌可点
function p.setCardDisEnable()
	for i=1, #p.cardListNode do
		local uiNode = p.cardListNode[i]
		for j=1,#p.cardListInfo do
			if tonumber(p.cardListInfo[i].Item_id1) ~= 0 or tonumber(p.cardListInfo[i].Item_id2) ~= 0 then
				uiNode:SetEnabled(false);
			else
				uiNode:SetEnabled(true);
			end
		end
		
	end
end

--清除方法
function p.clearDate()
	for k,v in pairs(p.selectCardId) do
			--WriteCon("k : "..k);
			--local numText = p.cardNumListNode[v];
			--numText:SetT
			local cardSelectText = p.selectList[v] ;
			cardSelectText:SetVisible(false);
	end
	p.selectNum  = 0;
	p.selectCardId = {};
	p.setCardDisEnable();
	p.consumeMoney = 0;
	local cardCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_30);
	cardCount:SetText(tostring(p.selectNum).."/10"); 
	
	local cardMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_32);
	cardMoney:SetText(tostring(p.consumeMoney)); 
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
	card_bag_sort.CloseUI();
end


function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end

--按职业显示卡牌
function p.ShowCardByProfession(profType)
	WriteCon("card_intensify.ShowCardByProfession();");
	if profType == nil then
		WriteCon("ShowCardByProfession():profession Type is null");
		return;
	end 
	p.cardListByProf = p.GetCardList(profType);
		
	if p.cardListByProf == nil or #p.cardListByProf <= 0 then
		WriteCon("p.cardListByProf == nil or #p.cardListByProf <= 0");
	end
	if p.sortByRuleV ~= nil then
		p.sortByRule(p.sortByRuleV)
	else
		p.ShowCardView(p.cardListByProf);
	end
	
end

--获取显示列表
function p.GetCardList(profType)
	local t = {};
	if p.cardListInfo == nil then 
		return t;
	end
	if profType == PROFESSION_TYPE_0 then
		t = p.cardListInfo;
	elseif profType == PROFESSION_TYPE_1 then 
		for k,v in pairs(p.cardListInfo) do
			if tonumber(v.Class) == 1 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_2 then 
		for k,v in pairs(p.cardListInfo) do
			if tonumber(v.Class) == 2 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_3 then 
		for k,v in pairs(p.cardListInfo) do
			if tonumber(v.Class) == 3 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_4 then 
		for k,v in pairs(p.cardListInfo) do
			if tonumber(v.Class) == 4 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_5 then 
		for k,v in pairs(p.cardListInfo) do
			if tonumber(v.Class) == 5 then
				t[#t + 1] = v;
			end
		end
	end
	return t;
end

--按规则排序
function p.sortByRule(sortType)
	if sortType == nil or p.cardListByProf == nil then 
		return
	end
	if p.sortByRuleNum == nil then
		p.sortByRuleNum = sortType;
		if sortType == CARD_BAG_SORT_BY_LEVEL then
			WriteCon("========sort by level");
			table.sort(p.cardListByProf,p.sortByLevel);
		elseif sortType == CARD_BAG_SORT_BY_STAR then
			WriteCon("========sort by star");
			table.sort(p.cardListByProf,p.sortByStar);
		elseif sortType == CARD_BAG_SORT_BY_TIME then
			WriteCon("========sort by Element");
			table.sort(p.cardListByProf,p.sortByTime);
		end
	else
		if p.sortByRuleNum == sortType then
			p.sortByRuleNum = nil;
			if sortType == CARD_BAG_SORT_BY_LEVEL then
				WriteCon("========sort by levelb");
				table.sort(p.cardListByProf,p.sortByLevelb);
			elseif sortType == CARD_BAG_SORT_BY_STAR then
				WriteCon("========sort by starb");
				table.sort(p.cardListByProf,p.sortByStarb);
			elseif sortType == CARD_BAG_SORT_BY_TIME then
				WriteCon("========sort by Elementb");
				table.sort(p.cardListByProf,p.sortByTimeb);
			elseif sortType == CARD_BAG_SORT_BY_TYPE then
				WriteCon("========sort by Elementb");
				table.sort(p.cardListByProf,p.sortByTypeb);
			end
		else
			p.sortByRuleNum = sortType;
			if sortType == CARD_BAG_SORT_BY_LEVEL then
				WriteCon("========sort by level");
				table.sort(p.cardListByProf,p.sortByLevel);
			elseif sortType == CARD_BAG_SORT_BY_STAR then
				WriteCon("========sort by star");
				table.sort(p.cardListByProf,p.sortByStar);
			elseif sortType == CARD_BAG_SORT_BY_TIME then
				WriteCon("========sort by Element");
				table.sort(p.cardListByProf,p.sortByTime);
			elseif sortType == CARD_BAG_SORT_BY_TYPE then
				WriteCon("========sort by Elementb");
				table.sort(p.cardListByProf,p.sortByType);
			end
		end
	end
	
	p.ShowCardView(p.cardListByProf);
end

--按等级排序1
function p.sortByLevel(a,b)
	return tonumber(a.Level) > tonumber(b.Level);  -- or ( tonumber(a.Level) == tonumber(b.Level) and tonumber(a.CardID) < tonumber(b.CardID));
end
--按等级排序2
function p.sortByLevelb(a,b)
	return tonumber(a.Level) < tonumber(b.Level);  -- or ( tonumber(a.Level) == tonumber(b.Level) and tonumber(a.CardID) < tonumber(b.CardID));
end
--按星级排序1
function p.sortByStar(a,b)
	return tonumber(a.Rare) > tonumber(b.Rare); -- or ( tonumber(a.Rare) == tonumber(b.Rare) and tonumber(a.CardID) > tonumber(b.CardID));
end
--按星级排序2
function p.sortByStarb(a,b)
	return tonumber(a.Rare) < tonumber(b.Rare); -- or ( tonumber(a.Rare) == tonumber(b.Rare) and tonumber(a.CardID) < tonumber(b.CardID));
end
--按属性排序
function p.sortByTime(a,b)
	return tonumber(a.element) > tonumber(b.element); -- or ( tonumber(a.element) == tonumber(b.element) and tonumber(a.CardID) < tonumber(b.CardID));
end
--按属性排序2
function p.sortByTimeb(a,b)
	return tonumber(a.element) < tonumber(b.element); -- or ( tonumber(a.element) == tonumber(b.element) and tonumber(a.CardID) < tonumber(b.CardID));
end

--按属性排序
function p.sortByType(a,b)
	--return tonumber(a.element) < tonumber(b.element);
	return tonumber(a.element) > tonumber(b.element); -- or ( tonumber(a.element) == tonumber(b.element) and tonumber(a.CardID) < tonumber(b.CardID));
end

--按属性排序2
function p.sortByTypeb(a,b)
	--return tonumber(a.element) < tonumber(b.element);
	return tonumber(a.element) < tonumber(b.element); -- or ( tonumber(a.element) == tonumber(b.element) and tonumber(a.CardID) < tonumber(b.CardID));
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
		p.selectList = {};
		p.teamList = {};
		p.selectCardId = {};
		p.baseCardInfo = nil;
		p.consumeMoney = 0;
		p.selectNum = 0;
        card_bag_mgr.ClearData();
		p.cardListByProf = {};
		p.userMoney = 0;
		p.cardListNode={};
		p.cardNumListNode = {};
		p.sortByRuleNum = nil;
		p.cardEnabled = nil;
		card_bag_sort.HideUI();
		card_bag_sort.CloseUI();
    end
end

function p.ClearData()
	p.selectNum = 0;
	p.selectCardId = {};
	p.cardListInfo = nil;
	p.cardListByProf = {};
	consumeMoney = 0;
	p.sortByRuleNum = nil;
	
end