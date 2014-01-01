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
p.sortByRuleV 	= nil;		--按什么规则排列
p.sortBtnMark = MARK_OFF;	--按规则排序是否开启
p.BatchSellMark = MARK_OFF;		--批量出售是否开启
p.allCardPrice 	= 0;	--出售卡牌总价值
p.sellCardList 	= {};	--出售卡牌列表


function p.ShowUI()
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
	--layer:SetSwallowTouch(false);
	
    GetUIRoot():AddDlg(layer);
    LoadDlg("card_main_view.xui", layer, nil);
    p.layer = layer;
    p.SetDelegate(layer);
	p.layer:SetVisible( true );
	p.Init();
end

function p.Init()
	cardNumLimit = msg_cache.msg_player.CardMax
	WriteCon("cardNumLimit========="..cardNumLimit);
	
	local headText = GetLabel(p.layer,ui.ID_CTRL_TEXT_87 );
	local cardNum = GetLabel(p.layer,ui.ID_CTRL_TEXT_CARD_NUM );
	--加载卡牌列表数据
	card_bag_mgr.LoadAllCard( p.layer );
end

--显示卡牌列表
function p.ShowCardList(cardList)
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();

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
	
	p.cardListInfo = cardList;
	
	local row = math.ceil(cardNum / 5);
	WriteCon("row ===== "..row);

	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("card_list_view.xui",view,nil);
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
				p.ShowCardInfo( view, card, cardIndex );
			end
		end
		list:AddView( view );
	end
end

--显示单张卡牌
function p.ShowCardInfo(view, card, cardIndex)
	local cardBtn = nil;
	local cardLevel = nil;
	local cardTeam = nil;
	if cardIndex == 1 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
		cardLevel = ui_list.ID_CTRL_TEXT_LV1;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM1;
		cardBoxBg = ui_list.ID_CTRL_PICTURE_BG1;
	elseif cardIndex == 2 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
		cardLevel = ui_list.ID_CTRL_TEXT_LV2;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM2;
		cardBoxBg = ui_list.ID_CTRL_PICTURE_BG2;
	elseif cardIndex == 3 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
		cardLevel = ui_list.ID_CTRL_TEXT_LV3;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM3;
		cardBoxBg = ui_list.ID_CTRL_PICTURE_BG3;
	elseif cardIndex == 4 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
		cardLevel = ui_list.ID_CTRL_TEXT_LV4;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM4;
		cardBoxBg = ui_list.ID_CTRL_PICTURE_BG4;
	elseif cardIndex == 5 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM5;
		cardLevel = ui_list.ID_CTRL_TEXT_LV5;
		cardTeam = ui_list.ID_CTRL_PICTURE_TEAM5;
		cardBoxBg = ui_list.ID_CTRL_PICTURE_BG5;
	end
	--显示卡牌图片
	local cardButton = GetButton(view, cardBtn);
	local cardId = tonumber(card.CardID);
	local cardPicTable = SelectRowInner(T_CHAR_RES,"card_id",cardId);
	if cardPicTable == nil then
		WriteConErr("cardPicTable error ");
	end
	local aniIndex = cardPicTable.head_pic;
	cardButton:SetImage( GetPictureByAni(aniIndex, 0) );
	local cardUniqueId = tonumber(card.UniqueId);
 	--WriteCon("cardUniqueId ===== "..cardUniqueId);
    cardButton:SetId(cardUniqueId);
	--等级
	local cardLevelText = GetLabel(view,cardLevel );
	local levelText = "LV "..tostring(card.Level)
	cardLevelText:SetText(levelText);
	--队伍
	local cardTeamPic = GetImage(view,cardTeam );
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
	local cardBoxPic = GetImage(view,cardBoxBg );
	local cardType = tonumber(card.Class)
	--WriteCon("cardType ===== "..cardType);
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
	
	--设置卡牌按钮事件
	cardButton:SetLuaDelegate(p.OnCardClickEvent);
	--cardButton:RemoveAllChildren(true);
	--p.ClearDelList();
	
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
			p.CloseUI();
			maininterface.BecomeFirstUI();
			maininterface.CloseAllPanel();
		elseif(ui.ID_CTRL_BUTTON_SORT_BY == tag) then
			WriteCon("card_bag_sort.ShowUI()");
			if p.sortBtnMark == MARK_OFF then
				card_bag_sort.ShowUI(0);
			else
				p.sortBtnMark = MARK_OFF;
				card_bag_sort.CloseUI();
			end
		elseif(ui.ID_CTRL_BUTTON_SELL == tag) then
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
		btn:SetText("取消");
		card_bag_sell.ShowUI();
	elseif p.BatchSellMark == MARK_ON then
		p.BatchSellMark = MARK_OFF
		btn:SetText("出售");
		card_bag_sell.CloseUI() 
	end
	

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
		sortByBtn:SetText("等级");
	elseif(sortType == CARD_BAG_SORT_BY_STAR) then
		--sortByBtn:SetImage( GetPictureByAni("button.card_bag",1));
		p.sortByRuleV = CARD_BAG_SORT_BY_STAR;
		sortByBtn:SetText("星级");
	elseif(sortType == CARD_BAG_SORT_BY_TYPE) then 
		--sortByBtn:SetImage( GetPictureByAni("button.card_bag",2));
		p.sortByRuleV = CARD_BAG_SORT_BY_TYPE;
		sortByBtn:SetText("属性");
	end
	card_bag_mgr.sortByRule(sortType)

end



function p.CloseUI()
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		-- p.modifyTeam = false;
		-- p.mainUIFlag = false;
		
		p.ClearData()
        -- card_bag_mgr.ClearData();
		-- card_bag_sort.CloseUI();
    end
end

function p.ClearData()
	p.allCardNumber = nil;
	p.cardListInfo = nil;

end
