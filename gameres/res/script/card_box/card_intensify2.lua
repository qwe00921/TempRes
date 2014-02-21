CARD_BAG_SORT_BY_LEVEL	= 1001;
CARD_BAG_SORT_BY_STAR	= 1002;
CARD_BAG_SORT_BY_TIME = 1003;

PROFESSION_TYPE_1 = 2001;
PROFESSION_TYPE_2 = 2002;
PROFESSION_TYPE_3 = 2003;
PROFESSION_TYPE_4 = 2004;
PROFESSION_TYPE_5 = 2005;
MARK_ON = 100;
MARK_OFF = nil;

card_intensify2  = {}
local p = card_intensify2;

local ui = ui_card_intensify2;
local ui_list = ui_card_list_intensify_view;

p.layer = nil;
p.cardListInfo = nil;
p.curBtnNode = nil;
p.sortByRuleV = nil;
p.sortBtnMark = MARK_OFF;	--按规则排序是否开启
p.baseCardInfo = nil;

--p.selectList = {};
--p.teamList = {};
--p.selectNum = 0;
--p.consumeMoney = 0;
--p.selectCardId = {};
--p.userMoney = 0;
p.cardListByProf = {};
function p.ShowUI(baseCardInfo)
	WriteCon("card_intensify2 ShowUI");
	p.baseCardInfo = baseCardInfo;
	p.cardListInfo = card_rein.getCardListInfo();
	--p.baseCardInfo = baseCardInfo;
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
    LoadDlg("card_intensify2.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
	
	--加载卡牌列表数据  发请求
    p.OnSendReq();
	--p.ShowCardList( cardList )
end

--可强化卡牌List请求
function p.OnSendReq()
	WriteCon("card_intensify2 OnSendReq");
	local uid = GetUID();
	--uid = 1234;
	if uid ~= nil and uid > 0 then
		--模块  Action  --msg_card_bag
		SendReq("CardList","List",uid,"");
	end
	
end
--[[
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
]]--
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
	
	local cardBtnPro5 = GetButton(layer, ui.ID_CTRL_BUTTON_PRO5);
	cardBtnPro5:SetLuaDelegate(p.OnUIClickEvent);
	
	local sortByBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SORT_BY);
	sortByBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	--local intensifyByBtn = GetButton(layer, ui.ID_CTRL_BUTTON_26);
	--intensifyByBtn:SetLuaDelegate(p.OnUIClickEvent);
	
end

--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			p.CloseUI();
			card_rein.ShowUI();
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
			p.ShowCardByProfession(PROFESSION_TYPE_5);
		elseif(ui.ID_CTRL_BUTTON_SORT_BY == tag) then --按等级排序
			if p.sortBtnMark == MARK_OFF then
				card_bag_sort.ShowUI(2);
			else
				p.sortBtnMark = MARK_OFF;
				card_bag_sort.HideUI();
				card_bag_sort.CloseUI();
			end
		end
	end
end

--[[
--确认强化为TRUE
function p.OnMsgBoxCallback(result)
	if result == true then
		WriteCon("true");
		
	end
end
]]--
--按规则排序按钮
function p.sortByBtnEvent(sortType)
	WriteCon("sortType = "..sortType);
	if sortType == nil then
		return
	end
	local sortByBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_SORT_BY);
	local sortImg = GetImage(p.layer, ui.ID_CTRL_PICTURE_176);
	sortByBtn:SetLuaDelegate(p.OnUIClickEvent);
	if(sortType == CARD_BAG_SORT_BY_LEVEL) then
		sortImg:SetPicture(GetPictureByAni("ui.card_order",1));
		p.sortByRuleV = CARD_BAG_SORT_BY_LEVEL;
	elseif(sortType == CARD_BAG_SORT_BY_STAR) then
		sortImg:SetPicture(GetPictureByAni("ui.card_order",2));
		p.sortByRuleV = CARD_BAG_SORT_BY_STAR;
	elseif(sortType == CARD_BAG_SORT_BY_TYPE) then 
		sortImg:SetPicture(GetPictureByAni("ui.card_order",3));		
		p.sortByRuleV = CARD_BAG_SORT_BY_TYPE;
	end
	p.sortByRule(sortType)

end 


--返回数据显示 Lab框
function p.ShowCardList(cardList,msg)

--	card_rein.SetUserMoney(msg.money);
	--card_rein.setCardListInfo(cardList);	
	if p.layer == nil then
		return;
	end
	if #cardList <= 0 then
		return;
	end
	p.cardListInfo = cardList;

	--local cardCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_30);
	--cardCount:SetText(tostring(p.selectNum).."/10"); 	
	
	--local cardMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_32);
	--cardMoney:SetText("0"); 
	
	
	local countLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_25);
	
	--持有金币
	--local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
	
	
	countLab:SetText(tostring(msg.cardlist_num).."/"..tostring(msg.cardmax));
	--moneyLab:SetText(tostring(msg.money));
	--p.userMoney = msg.money;

	--[[
	--列表删除要强化的那条卡牌数据 
	for i = 1 , #p.cardListInfo do
		if p.cardListInfo[i].UniqueId == p.baseCardInfo.UniqueId then
			table.remove(p.cardListInfo,i);
			break;
		end
	end	
]]--
	p.cardListByProf = p.cardListInfo;
	p.ShowCardView(p.cardListInfo);
	
	
end
--显示卡牌列表
function p.ShowCardView(cardList)
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();
	
	if cardList == nil or #cardList <= 0 then
		WriteCon("ShowCardView():cardList is null");
		return;
	end
	local cardNum = #cardList;
	
	local row = math.ceil(cardNum / 5);
	
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("card_list_intensify_view.xui",view,nil);
		
		p.InitViewUI(view); --先设置所有隐藏
		
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
		local row_index = i;
		local start_index = (row_index-1)*5+1
        local end_index = start_index + 4;

		
		--设置列表信息，一行5张卡牌
		for j = start_index,end_index do
			if j <= cardNum then
				local card = cardList[j];
				
				local cardIndex = j - start_index + 1;
				p.ShowCardInfo( view, card, cardIndex );
				
			end
		end
		list:AddView( view );
	end
	--p.selectList ID是key   p.selectCardId
	--[[
	for k,v in pairs(p.selectCardId) do
		p.selectList[v]:SetVisible(true);
	end
	]]--
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

--显示单张卡牌
function p.ShowCardInfo( view, card, cardIndex )
	--WriteCon("************"..cardIndex);
	local cardBtn = nil;
	local cardLevel = nil;
	local cardTeam = nil;
	local cardSelect = nil;
	if cardIndex == 1 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
		cardSelect = ui_list.ID_CTRL_PICTURE_S1;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM1;
		cardLevel = ui_list.ID_CTRL_LEVEL_1;
		cardLeveImg = ui_list.ID_CTRL_PICTURE_38;
	elseif cardIndex == 2 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
		cardSelect = ui_list.ID_CTRL_PICTURE_S2;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM2;
		cardLevel = ui_list.ID_CTRL_LEVEL_2;
		cardLeveImg = ui_list.ID_CTRL_PICTURE_39;
	elseif cardIndex == 3 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
		cardSelect = ui_list.ID_CTRL_PICTURE_S3;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM3;
		cardLevel = ui_list.ID_CTRL_LEVEL_3;
		cardLeveImg = ui_list.ID_CTRL_PICTURE_40;
	elseif cardIndex == 4 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
		cardSelect = ui_list.ID_CTRL_PICTURE_S4;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM4;
		cardLevel = ui_list.ID_CTRL_LEVEL_4;
		cardLeveImg = ui_list.ID_CTRL_PICTURE_41;
	elseif cardIndex == 5 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM5;
		cardSelect = ui_list.ID_CTRL_PICTURE_S5;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM5;
		cardLevel = ui_list.ID_CTRL_LEVEL_5;
		cardLeveImg = ui_list.ID_CTRL_PICTURE_47;
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
	teamText:SetVisible( true );
	
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
	if p.baseCardInfo ~= nil then
		if tonumber(card.UniqueId) == tonumber(p.baseCardInfo.UniqueID) then
			local cardSelectText = GetImage(view,cardSelect );
			cardSelectText:SetVisible( true );
		end;
	end;
	--local Team_marks = card.Team_marks;
	--p.teamList[cardUniqueId] = Team_marks;
	
	--p.selectList[cardUniqueId] = cardSelectText;
	
	
	
	
	--设置卡牌按钮事件
	cardButton:SetLuaDelegate(p.OnCardClickEvent);
	cardButton:RemoveAllChildren(true);
end

--点击卡牌
function p.OnCardClickEvent(uiNode, uiEventType, param)
	local cardUniqueId = uiNode:GetId();
	local card = nil;
	--卡牌星级上限
	--p.cardListInfo
	for i = 1 , #p.cardListInfo do
		if p.cardListInfo[i].UniqueId == cardUniqueId then
			card = p.cardListInfo[i];
		end
	end	
		
	local pCardRare= SelectRowInner( T_CARD_LEVEL_LIMIT, "star",card.Rare); --从表中获取卡牌详细信息	
	
	if tonumber( card.Level) >= tonumber(pCardRare.level_limit) then
		dlg_msgbox.ShowOK(GetStr("card_box_intensify"),tostring(card.Rare)..GetStr("card_intensify_no_level1")..tostring(pCardRare.level_limit)..GetStr("card_intensify_no_level2"),p.OnMsgCallback,p.layer);
	else
		
		p.OnSendCardDetail(cardUniqueId);	
	end
	
	
	
end

function p.OnSendCardDetail(cardUniqueId)
	local uid = GetUID();
	
	if uid == 0 or uid == nil or cardUniqueId == nil then
		return ;
	end;
	
	local param = string.format("&card_unique_id=%s",cardUniqueId)
	SendReq("Equip","CardDetailShow",uid,param);
	p.CloseUI();
	card_rein.ClearSelData();	
	card_rein.ShowUI();
	
end;	

function p.GetCardInfo(cardUniqueId)
	for k,v in pairs(p.cardListInfo) do
		if v.UniqueId == cardUniqueId then
			if v.Level == 0 then
				pCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", 1);
			else
				pCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", v.Level);
			end
			break;
		end
	end	
end;	

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
	if sortType == CARD_BAG_SORT_BY_LEVEL then
		WriteCon("========sort by level");
		table.sort(p.cardListByProf,p.sortByLevel);
	elseif sortType == CARD_BAG_SORT_BY_STAR then
		WriteCon("========sort by star");
		table.sort(p.cardListByProf,p.sortByStar);
	elseif sortType == CARD_BAG_SORT_BY_TIME then
		WriteCon("========sort by time");
		table.sort(p.cardListByProf,p.sortByTime);
	elseif sortType == CARD_BAG_SORT_BY_TYPE then
		WriteCon("========sort by Elementb");
		table.sort(p.cardListByProf,p.sortByType);
	end
	p.ShowCardView(p.cardListByProf);
end

--按等级排序
function p.sortByLevel(a,b)
	return tonumber(a.Level) < tonumber(b.Level);
end
--按星级排序
function p.sortByStar(a,b)
	return tonumber(a.Rare) < tonumber(b.Rare);
end
--按时间排序
function p.sortByTime(a,b)
	return tonumber(a.Time) < tonumber(b.Time);
end

--按属性排序
function p.sortByType(a,b)
	--return tonumber(a.element) < tonumber(b.element);
	return tonumber(a.element) > tonumber(b.element) or ( tonumber(a.element) == tonumber(b.element) and tonumber(a.CardID) < tonumber(b.CardID));
end

--按属性排序2
function p.sortByTypeb(a,b)
	--return tonumber(a.element) < tonumber(b.element);
	return tonumber(a.element) < tonumber(b.element) or ( tonumber(a.element) == tonumber(b.element) and tonumber(a.CardID) < tonumber(b.CardID));
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
		--p.selectList = {};
		--p.teamList = {};
		--p.selectCardId = {};
		--p.baseCardInfo = nil;
		--p.consumeMoney = 0;
		--p.selectNum = 0;
		p.baseCardInfo = nil;
        --card_bag_mgr.ClearData();
		p.cardListByProf = {};
		card_bag_sort.HideUI();
		card_bag_sort.CloseUI();
		--p.userMoney = 0;
		
    end
end

function p.ClearData()
	--p.selectNum = 0;
	--p.selectCardId = {};
	p.cardListInfo = nil;
	p.cardListByProf = {};
end