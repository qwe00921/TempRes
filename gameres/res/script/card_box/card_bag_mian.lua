CARD_BAG_SORT_BY_LEVEL	= 1001;
CARD_BAG_SORT_BY_STAR	= 1002;
CARD_BAG_SORT_BY_TYPE = 1003;
CARD_BAG_SORT_BY_TIME = 1004;

MARK_ON = 100;
MARK_OFF = nil;

card_bag_mian = {}
local p = card_bag_mian;
local ui = ui_card_main_view
local ui_list = ui_card_list_view;
p.layer = nil;
p.allCardNumber = nil;		--所有卡牌数量
p.cardListInfo = nil;		--卡牌列表
p.cardListNode = {};		--所有卡牌节点列表
p.sortByRuleV 	= nil;		--按什么规则排列
p.sortBtnMark = MARK_OFF;	--按规则排序是否开启
p.BatchSellMark = MARK_OFF;		--批量出售是否开启
p.allCardPrice 	= 0;	--出售卡牌总价值
--p.sellCardList 	= {};	--出售卡牌列表
p.sellCardNodeList = {}	--出售卡牌节点列表
p.node = nil;
p.isReplace = false;
p.callback = nil;
p.hasRemove = false;
p.cardListInfoSell = {}
p.m_list = nil;

function p.ShowUI()
	dlg_menu.SetNewUI( p );
	p.show();
end

function p.show()
	maininterface.HideUI();
	if p.layer ~= nil then 
		p.CloseNotSelfUI();
		p.layer:SetVisible(true);
		p.SetEnableAll(true);
		local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
		if list then
			list:SetVisible(true);
		end
		return;
	end
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	layer:NoMask();
    layer:Init();   
	layer:SetSwallowTouch(false);
	p.SetEnableAll(true);
	
    GetUIRoot():AddDlg(layer);
    LoadDlg("card_main_view.xui", layer, nil);
    p.layer = layer;
    p.SetDelegate(layer);
	p.layer:SetVisible( true );
	p.Init();
end

--卡组为替换,移除功能
function p.ShouReplaceUI(callback, hasRemove)
	p.isReplace = true;
	p.callback  = callback;
	p.hasRemove = hasRemove;
	p.show();
	if p.cardListInfo then
		p.ShowCardList(p.cardListInfo);
	else
		card_bag_mgr.LoadAllCard( p.layer );
	end
end

function p.Init()

	cardNumLimit = msg_cache.msg_player.CardMax
	WriteCon("cardNumLimit========="..cardNumLimit);
	
	local headText = GetLabel(p.layer,ui.ID_CTRL_TEXT_TITLE );
	local cardNum = GetLabel(p.layer,ui.ID_CTRL_TEXT_CARD_NUM );

	if p.isReplace == true then
		headText:SetText(GetStr("card_group_edit_title"));
		local bt = GetButton(p.layer,ui.ID_CTRL_BUTTON_SELL);
		bt:SetVisible(false);
	end
	
	--加载卡牌列表数据
	if p.isReplace ~= true then
		card_bag_mgr.LoadAllCard( p.layer );
	end
end

function p.SetCardNum(delNum)
	local cardNumText = GetLabel(p.layer,ui.ID_CTRL_TEXT_CARD_NUM );
	local cardNum = p.allCardNumber;
	if delNum ~= nil and delNum > 0 then
		cardNum = cardNum - delNum;
		p.allCardNumber = cardNum;
		local countText = cardNum.."/"..cardNumLimit;
		cardNumText:SetText(countText);
	end
end

--显示卡牌列表
function p.ShowCardList(cardList)
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();
	list:SetZOrder(-100);
	p.m_list = list;
	p.cardListNode = {}
	p.allCardPrice 	= 0;	--出售卡牌总价值
	p.sellCardNodeList = {}	--出售卡牌节点列表
	
	local cardNumText = GetLabel(p.layer,ui.ID_CTRL_TEXT_CARD_NUM );
	local cardNum = nil;
	
	if cardList == nil or #cardList <= 0 then
		if p.allCardNumber == nil or p.allCardNumber == 0 then
			local countText = "0/"..cardNumLimit;
			cardNumText:SetText(countText);
		end
		WriteCon("ShowCardList():cardList is null");
		return;
	else
		cardNum = #cardList;
		WriteCon("cardNum ===== "..cardNum);
		if p.allCardNumber == nil or p.allCardNumber == 0 then
			p.allCardNumber = cardNum;
			local countText = cardNum.."/"..cardNumLimit;
			cardNumText:SetText(countText);
		end
	end
	if p.BatchSellMark == MARK_OFF then
		p.cardListInfo = cardList;
	end
	if p.hasRemove  == true then
		cardNum = cardNum or 0;
		cardNum = cardNum + 1;
	end
	
	local row = math.ceil(cardNum / 5);
	WriteCon("row ===== "..row);

	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("card_list_view.xui",view,nil);
		p.InitViewUI(view);
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		local row_index = i;
		local start_index = (row_index - 1) * 5 + 1
        local end_index = start_index + 4;
		
		--设置列表信息，一行5张卡牌
		for j = start_index,end_index do
			if i == 1 and j == 1 and p.hasRemove  == true then
				local cardIndex = j - start_index + 1;
				p.ShowCardInfo( view, nil, cardIndex ,i);
			elseif j <= cardNum then
				local lstIndex = j;
				if p.hasRemove  == true then
					lstIndex = j - 1;
				end
				local card = cardList[lstIndex];
				local cardIndex = j - start_index + 1;
				p.ShowCardInfo( view, card, cardIndex ,i);
			end
		end
		list:AddView( view );
	end
		
	if p.BatchSellMark == MARK_ON then
		p.setTeamCardDisEnable()
		card_bag_sell.Init()	--初始化出售信息
	end	
end

--显示单张卡牌
function p.ShowCardInfo(view, card, cardIndex,row)
	local cardBtn = nil;
	local cardLevel = nil;
	local cardTeam = nil;
	if cardIndex == 1 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
		cardLevel = ui_list.ID_CTRL_TEXT_LV1;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM1;
		cardLevelPic = ui_list.ID_CTRL_PICTURE_1;
	elseif cardIndex == 2 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
		cardLevel = ui_list.ID_CTRL_TEXT_LV2;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM2;
		cardLevelPic = ui_list.ID_CTRL_PICTURE_2;
	elseif cardIndex == 3 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
		cardLevel = ui_list.ID_CTRL_TEXT_LV3;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM3;
		cardLevelPic = ui_list.ID_CTRL_PICTURE_3;
	elseif cardIndex == 4 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
		cardLevel = ui_list.ID_CTRL_TEXT_LV4;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM4;
		cardLevelPic = ui_list.ID_CTRL_PICTURE_4;
	elseif cardIndex == 5 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM5;
		cardLevel = ui_list.ID_CTRL_TEXT_LV5;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM5;
		cardLevelPic = ui_list.ID_CTRL_PICTURE_5;
	end
	
	--显示卡牌图片
	local cardButton = GetButton(view, cardBtn);
	cardButton:SetVisible(true);
	local cardTeamPic = GetImage(view,cardTeam );
	cardTeamPic:SetVisible(true);
	local cardLevelText = GetLabel(view,cardLevel );
	cardLevelText:SetVisible(true);
	local cardLevelPicture = GetImage(view,cardLevelPic );
	cardLevelPicture:SetVisible(true);
	--设置卡牌按钮事件
	cardButton:SetLuaDelegate(p.OnCardClickEvent);
	cardButton:RemoveAllChildren(true);
	
	
	if row == 1 and cardIndex == 1 and p.hasRemove  == true then
		local lvImg = GetImage(view,ui_list.ID_CTRL_PICTURE_1 );
		cardButton:SetImage(GetPictureByAni("ui.card_edit_remove",0))
		 cardButton:SetId(0);
		cardTeamPic:SetVisible(false);
		if lvImg then
			lvImg:SetVisible(false);
		end
		return
	end
	
	local cardId = tonumber(card.CardID);
	local cardPicTable = SelectRowInner(T_CHAR_RES,"card_id",cardId);
	if cardPicTable == nil then
		WriteConErr("not find card id == "..cardId);
		return
	end
	local aniIndex = cardPicTable.head_pic;
	cardButton:SetImage( GetPictureByAni(aniIndex, 0) );
	local cardUniqueId = tonumber(card.UniqueId);
 	--WriteCon("cardUniqueId ===== "..cardUniqueId);
    cardButton:SetId(cardUniqueId);
	--等级
	local levelText = tostring(card.Level)
	cardLevelText:SetText(levelText);
	--队伍
	local teamId = tonumber(card.Team_marks)
	if teamId == 0 then
		cardTeamPic:SetVisible(false);
	elseif teamId == 1 then
		cardTeamPic:SetPicture( GetPictureByAni("common_ui.teamName",0));
	elseif teamId == 2 then
		cardTeamPic:SetPicture( GetPictureByAni("common_ui.teamName",1));
	elseif teamId == 3 then
		cardTeamPic:SetPicture( GetPictureByAni("common_ui.teamName",2));
	end
		
	--卡牌边框颜色
	local cardType = tonumber(card.element)
	
	
	--WriteCon("cardType ===== "..cardType);
	--cardBoxPic:SetPicture( GetPictureByAni("common_ui.cardBagTypeBox",cardType));
	-- if cardType == 0 then
		-- levelBgPic:SetPicture( GetPictureByAni("common_ui.levelBg",0));
	-- elseif cardType == 1 then
		-- levelBgPic:SetPicture( GetPictureByAni("common_ui.levelBg",0));
	-- elseif cardType == 2 then
		-- levelBgPic:SetPicture( GetPictureByAni("common_ui.levelBg",0));
	-- elseif cardType == 3 then
		-- levelBgPic:SetPicture( GetPictureByAni("common_ui.levelBg",0));
	-- elseif cardType == 4 then
		-- levelBgPic:SetPicture( GetPictureByAni("common_ui.levelBg",0));
	-- elseif cardType == 5 then
		-- levelBgPic:SetPicture( GetPictureByAni("common_ui.levelBg",0));
	-- elseif cardType == 6 then
		-- levelBgPic:SetPicture( GetPictureByAni("common_ui.levelBg",0));
	-- elseif cardType == 7 then
		-- levelBgPic:SetPicture( GetPictureByAni("common_ui.levelBg",0));
	-- end
	
	
	--p.ClearDelList();
	
	p.cardListNode[#p.cardListNode + 1] = cardButton;
	
	-- if p.BatchSellMark == MARK_ON then
		-- p.setTeamCardDisEnable()
	-- end	

end

function p.InitViewUI(view)
   for cardIndex=1,5 do
		if cardIndex == 1 then
			--cardBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
			cardBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
			cardLevel = ui_list.ID_CTRL_TEXT_LV1;
			cardTeam = ui_list.ID_CTRL_PICTURE_TEAM1;
			cardLevelPic = ui_list.ID_CTRL_PICTURE_1;
		elseif cardIndex == 2 then
			--cardBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
			cardBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
			cardLevel = ui_list.ID_CTRL_TEXT_LV2;
			cardTeam = ui_list.ID_CTRL_PICTURE_TEAM2;
			cardLevelPic = ui_list.ID_CTRL_PICTURE_2;
		elseif cardIndex == 3 then
			--cardBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
			cardBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
			cardLevel = ui_list.ID_CTRL_TEXT_LV3;
			cardTeam = ui_list.ID_CTRL_PICTURE_TEAM3;
			cardLevelPic = ui_list.ID_CTRL_PICTURE_3;
		elseif cardIndex == 4 then
			--cardBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
			cardBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
			cardLevel = ui_list.ID_CTRL_TEXT_LV4;
			cardTeam = ui_list.ID_CTRL_PICTURE_TEAM4;
			cardLevelPic = ui_list.ID_CTRL_PICTURE_4;
		elseif cardIndex == 5 then
			--cardBtn = ui_list.ID_CTRL_BUTTON_ITEM5;
			cardBtn = ui_list.ID_CTRL_BUTTON_ITEM5;
			cardLevel = ui_list.ID_CTRL_TEXT_LV5;
			cardTeam = ui_list.ID_CTRL_PICTURE_TEAM5;
			cardLevelPic = ui_list.ID_CTRL_PICTURE_5;
		end
		
		local teamPic = GetImage(view,cardTeam);
		teamPic:SetVisible(false);
		
		local cardLevelPictrue = GetImage(view,cardLevelPic);
		cardLevelPictrue:SetVisible(false);
		
		local levelText = GetLabel(view,cardLevel);
		levelText:SetVisible( false );
		
		local levelText = GetButton(view,cardBtn);
		levelText:SetVisible( false );
  end
end;	

function p.SetEnableAll(bVar)
	if nil ~= p.layer then
		local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
		if list then
			list:SetEnabledList(bVar);
			
			for i = 1, #p.cardListNode do
				local uiNode = p.cardListNode[i]
				uiNode:SetEnabled(bVar)
			end
		end
	end

end

--点击卡牌事件
function p.OnCardClickEvent(uiNode, uiEventType, param)
	local cardUniqueId = uiNode:GetId();
	WriteCon("cardUniqueId = "..cardUniqueId);
	
	card_bag_sort.HideUI();
	card_bag_sort.CloseUI();
	
	--是否处于编辑中
	if p.isReplace == true then
		if p.callback then
			local cardData = nil;
			for k,v in ipairs(p.cardListInfo) do
				if tonumber(v.UniqueId) == cardUniqueId or tonumber(v.UniqueID) == cardUniqueId then
					cardData = v;
					break
				end
			end
			p.callback(cardData);
		end
		p.HideUI();
	--出售中
	elseif p.BatchSellMark == MARK_ON then
		if uiNode:GetChild(ui_card_bag_select.ID_CTRL_PICTURE_CARD_SELECT) == nil then
			local team = nil;
			local rareStart = nil;
			local Item_Id1 = nil;
			local Item_Id2 = nil;
			local Item_Id3 = nil;
			local Gem1 = nil;
			local Gem2 = nil;
			local Gem3 = nil;
			for k,v in pairs(p.cardListInfo) do
				if cardUniqueId == v.UniqueId then
					team = v.Team_marks
					rareStart = v.Rare
					Item_Id1 = v.Item_Id1;
					Item_Id2 = v.Item_Id2;
					Item_Id3 = v.Item_Id3;
					Gem1 = v.Gem1;
					Gem2 = v.Gem2;
					Gem3 = v.Gem3;
					break;
				end
			end
			--WriteCon("team ===== "..team);
			if tonumber(team) ~= 0 then
				dlg_msgbox.ShowOK("确认提示框","队伍中的卡牌无法出售。",nil,p.layer);
				return
			elseif tonumber(Item_Id1) > 0 or tonumber(Item_Id2) > 0 or tonumber(Item_Id3) > 0 
								or tonumber(Gem1) > 0 or tonumber(Gem2) > 0 or tonumber(Gem3) > 0 then
				dlg_msgbox.ShowOK("确认提示框","此卡牌身上穿有道具，无法卖出",nil,p.layer);
				return
			elseif tonumber(rareStart) >= 4 then
				p.node = uiNode;
				dlg_msgbox.ShowYesNo("确认提示框","这张卡片为稀有卡片，确定要卖出吗？",p.SelectCardCallback,p.layer);
				return
			end
		end
		p.ShowSelectPic(uiNode);
	elseif p.BatchSellMark == MARK_OFF then 
		local cardData = nil;
		for k,v in ipairs(p.cardListInfo) do
			if tonumber(v.UniqueId) == cardUniqueId then
				cardData = v;
				break
			end
		end
		p.HideUI();
		dlg_card_attr_base.ShowUI(cardData);
		
	end
end

function p.SelectCardCallback(result)
	if result == true then
		WriteCon("true");
		p.ShowSelectPic(p.node);
		p.node = nil;
	elseif result == false then
		WriteCon("false");
	end
end

function p.ShowSelectPic(uiNode)
	local cardUniqueId = tonumber(uiNode:GetId());
	if uiNode:GetChild(ui_card_bag_select.ID_CTRL_PICTURE_CARD_SELECT) == nil then
		if #p.sellCardNodeList < 10 then
			p.sellCardNodeList[#p.sellCardNodeList + 1] = uiNode
			local sellNum = #p.sellCardNodeList;
			p.addSellNum(uiNode,sellNum)
			if #p.sellCardNodeList >= 10 then
				p.setAllCardDisEnable()
			end
		end
	else
		WriteCon("RemoveAllChildren");
		for k,v in pairs(p.sellCardNodeList) do
			if tonumber(cardUniqueId) == v:GetId() then
				table.remove(p.sellCardNodeList,k);
				p.refreshSelectNum()
			end
		end
		uiNode:RemoveAllChildren(true);
	end
	--设置出售数量
	card_bag_sell.setSellCardNum(#p.sellCardNodeList)
	--设置出售金币
	p.countSellMoney()
end

function p.countSellMoney()
	p.allCardPrice = 0;
	for k,v in pairs(p.sellCardNodeList) do
		local cardUid = v:GetId()
		for j,h in pairs(p.cardListInfo) do
			if cardUid == tonumber(h.UniqueId) then
				p.allCardPrice = p.allCardPrice + (h.Price + (h.Level)*(h.Level));--卡片基本价格+卡牌当前等级的平方
			end
		end
	end
	card_bag_sell.setSellMoney(p.allCardPrice);
end

function p.refreshSelectNum()
	if #p.sellCardNodeList >= 9 then
		p.setTeamCardDisEnable()
	end
	
	for k,v in pairs(p.sellCardNodeList) do
		local sellCardUid = v:GetId()
		for j,h in pairs(p.cardListNode) do
			local inAllCardUid = h:GetId()
			if sellCardUid == inAllCardUid then
				local sellNum = k;
				p.addSellNum(v,sellNum)
			end
		end
	end
end

--设置除选择外的卡牌不可点
function p.setAllCardDisEnable()
	for i=1, #p.cardListNode do
		local uiNode = p.cardListNode[i]
		if uiNode:GetChild(ui_card_bag_select.ID_CTRL_PICTURE_CARD_SELECT) == nil then
			uiNode:SetEnabled(false)
		end
	end
end

--屏蔽队伍按钮,其他都可点
function p.setTeamCardDisEnable()
	for j,h in pairs(p.cardListNode) do 
		local cardUniqueId = h:GetId();
		for k,v in pairs(p.cardListInfo) do
			if tonumber(v.Team_marks) > 0 and tonumber(v.UniqueId) == cardUniqueId then
				h:SetEnabled(false)
			elseif tonumber(v.Team_marks) == 0 and  tonumber(v.UniqueId) == cardUniqueId then
				h:SetEnabled(true)
			end
		end
	end

end

function p.addSellNum(uiNode,num)
	local view = createNDUIXView();
	view:Init();
	LoadUI("card_bag_select.xui",view,nil);
	local bg = GetUiNode( view, ui_card_bag_select.ID_CTRL_PICTURE_CARD_SELECT);
	view:SetViewSize( bg:GetFrameSize());
	view:SetTag(ui_card_bag_select.ID_CTRL_PICTURE_CARD_SELECT);
	local number = GetLabel(view,ui_card_bag_select.ID_CTRL_TEXT_NUM );
	number:SetText(tostring(num));
	uiNode:AddChild( view );
end


--主界面事件处理
function p.SetDelegate(layer)
	local retBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_RETURN);
	retBtn:SetLuaDelegate(p.OnUIClickEvent);

	local sellBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_SELL );
	sellBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local sortBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_SORT_BY );
	sortBtn:SetLuaDelegate(p.OnUIClickEvent);
end

--事件处理
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			if p.isReplace == true then
				p.HideUI();
				dlg_card_group_main.OnSelectReplaceCallback(nil,true);
			else
				maininterface.ShowUI();
				p.CloseUI();
				
				dlg_menu.SetSelectButton( -1 );
			end
		elseif(ui.ID_CTRL_BUTTON_SORT_BY == tag) then
			WriteCon("card_bag_sort.ShowUI()");
			if p.sortBtnMark == MARK_OFF then
				card_bag_sort.ShowUI(0);
			else
				p.sortBtnMark = MARK_OFF;
				card_bag_sort.HideUI();
				card_bag_sort.CloseUI();
			end
		elseif(ui.ID_CTRL_BUTTON_SELL == tag) then
			card_bag_sort.HideUI();
			card_bag_sort.CloseUI();
			p.sellBtnEvent();
		end
	end
end

--点击批量出售事件
function p.sellBtnEvent()
	local btn = GetButton(p.layer, ui.ID_CTRL_BUTTON_SELL);
	--btn:SetEnabled(false)
	if p.BatchSellMark == MARK_OFF then
		p.BatchSellMark = MARK_ON;
		--btn:SetText("取消");
		btn:SetImage( GetPictureByAni( "common_ui.cardBagSell", 0 ) );
		btn:SetTouchDownImage( GetPictureByAni( "common_ui.cardBagSell", 1 ) );
		card_bag_sell.ShowUI();
		p.selectCardList()
		p.setTeamCardDisEnable()
		
	elseif p.BatchSellMark == MARK_ON then
		p.BatchSellMark = MARK_OFF
		p.allCardPrice 	= 0;	--出售卡牌总价值
		p.sellCardNodeList 	= {};	--出售卡牌列表
		btn:SetImage( GetPictureByAni( "common_ui.cardBagSell", 2 ) );
		btn:SetTouchDownImage( GetPictureByAni( "common_ui.cardBagSell", 3 ) );
		card_bag_sell.CloseUI() 
		p.ShowCardList(p.cardListInfo)
	end
end

function p.selectCardList()
	p.cardListInfoSell = {}
	local Item_Id1 = nil;
	local Item_Id2 = nil;
	local Item_Id3 = nil;
	local Gem1 = nil;
	local Gem2 = nil;
	local Gem3 = nil;

	for k,v in pairs(p.cardListInfo) do
		Item_Id1 = v.Item_Id1;
		Item_Id2 = v.Item_Id2;
		Item_Id3 = v.Item_Id3;
		Gem1 = v.Gem1;
		Gem2 = v.Gem2;
		Gem3 = v.Gem3;
		if tonumber(Item_Id1) > 0 or tonumber(Item_Id2) > 0 or tonumber(Item_Id3) > 0 
				or tonumber(Gem1) > 0 or tonumber(Gem2) > 0 or tonumber(Gem3) > 0 
				or tonumber(v.Team_marks) > 0 then
			WriteCon("selectCardList =="..k);
		else
			p.cardListInfoSell[#p.cardListInfoSell+1] = v
		end
	end
	p.ShowCardList(p.cardListInfoSell)
end

--安规则排序按钮
function p.sortByBtnEvent(sortType)
	if sortType == nil then
		return
	end
	local sortByBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_SORT_BY);
	sortByBtn:SetLuaDelegate(p.OnUIClickEvent);
	if(sortType == CARD_BAG_SORT_BY_LEVEL) then
		--sortByBtn:SetImage( GetPictureByAni("button.card_bag",0));
		p.sortByRuleV = CARD_BAG_SORT_BY_LEVEL;
		--sortByBtn:SetText("等级");
		sortByBtn:SetImage(GetPictureByAni("common_ui.cardBagSort",2));
		sortByBtn:SetTouchDownImage(GetPictureByAni("common_ui.cardBagSort",3));
	elseif(sortType == CARD_BAG_SORT_BY_STAR) then
		--sortByBtn:SetImage( GetPictureByAni("button.card_bag",1));
		p.sortByRuleV = CARD_BAG_SORT_BY_STAR;
		--sortByBtn:SetText("星级");
		sortByBtn:SetImage(GetPictureByAni("common_ui.cardBagSort",4));
		sortByBtn:SetTouchDownImage(GetPictureByAni("common_ui.cardBagSort",5));
	elseif(sortType == CARD_BAG_SORT_BY_TYPE) then 
		--sortByBtn:SetImage( GetPictureByAni("button.card_bag",2));
		p.sortByRuleV = CARD_BAG_SORT_BY_TYPE;
		--sortByBtn:SetText("属性");
		sortByBtn:SetImage(GetPictureByAni("common_ui.cardBagSort",6));
		sortByBtn:SetTouchDownImage(GetPictureByAni("common_ui.cardBagSort",7));
	end
	card_bag_mgr.sortByRule(sortType)
end

--点击出售按钮
function p.sellCardClick()
	WriteCon("sellCardClick()");
	if p.sellCardNodeList == nil or #p.sellCardNodeList <= 0 then
		dlg_msgbox.ShowOK("确认提示框","请选择您要出售的卡片",nil,p.layer);
	else
		dlg_msgbox.ShowYesNo("确认提示框","你确定要卖出这些卡牌吗？",p.OnMsgBoxCallback,p.layer);
	end
end

--确认或取消出售
function p.OnMsgBoxCallback(result)
	if result == true then
		WriteCon("true");
		local sellCardList = {}
		for k,v in pairs(p.sellCardNodeList) do
			sellCardList[#sellCardList + 1] = v:GetId()
		end
		card_bag_mgr.SendDelRequest(sellCardList);
	elseif result == false then
		WriteCon("false");
	end
end

--点击清除选择
function p.clearSellClick()
	WriteCon("clearSellClick()");
	for k,v in pairs(p.sellCardNodeList) do
		v:RemoveAllChildren(true);
	end
	p.sellCardNodeList = {}	
	p.setTeamCardDisEnable()
	card_bag_sell.Init()
end


--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		
		local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
		if list then
			list:SetVisible(false);
		end
	end
end


function p.CloseUI()
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		-- p.modifyTeam = false;
		-- p.mainUIFlag = false;
		
		p.ClearData()
        card_bag_mgr.ClearData();
		card_bag_sort.HideUI();
		card_bag_sort.CloseUI();
		card_bag_sell.CloseUI();
		dlg_msgbox.CloseUI();
		--maininterface.ShowUI();
    end
end

function p.ClearData()
	p.allCardNumber = nil;		--所有卡牌数量
	p.cardListInfo = nil;		--卡牌列表
	p.cardListNode = {};		--所有卡牌节点列表
	p.sortByRuleV 	= nil;		--按什么规则排列
	p.sortBtnMark = MARK_OFF;	--按规则排序是否开启
	p.BatchSellMark = MARK_OFF;		--批量出售是否开启
	p.allCardPrice 	= 0;	--出售卡牌总价值
	p.sellCardNodeList = {}	--出售卡牌节点列表
	p.node = nil;
	p.isReplace = false;
	p.hasRemove = false;
	p.callback = nil;
	p.cardListInfoSell = {}
end
function p.UIDisappear()
	p.CloseUI();
	dlg_card_attr_base.CloseUI();
	card_rein.CloseUI();
	card_intensify.CloseUI();
	card_intensify2.CloseUI();
	card_intensify_succeed.CloseUI();
	equip_dress_select.CloseUI();
	equip_rein_list.CloseUI();
	maininterface.BecomeFirstUI();
end

function p.CloseNotSelfUI()
	dlg_card_attr_base.CloseUI();
	card_rein.CloseUI();
	card_intensify.CloseUI();
	card_intensify2.CloseUI();
	card_intensify_succeed.CloseUI();
	equip_dress_select.CloseUI();
	equip_rein_list.CloseUI();
	maininterface.BecomeFirstUI();
end