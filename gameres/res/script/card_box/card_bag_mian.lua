CARD_BAG_SORT_BY_LEVEL	= 1001;
CARD_BAG_SORT_BY_STAR	= 1002;
CARD_BAG_SORT_BY_TIME = 1003;

PROFESSION_TYPE_1 = 2001;
PROFESSION_TYPE_2 = 2002;
PROFESSION_TYPE_3 = 2003;
PROFESSION_TYPE_4 = 2004;

card_bag_mian  = {}
local p = card_bag_mian;

local ui = ui_card_main_view;
local ui_list = ui_card_list_view;

p.layer = nil;
p.curBtnNode = nil;
p.sortBtnMark = nil;
p.sortByRuleV = nil;

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
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddDlg(layer);
    LoadDlg("card_main_view.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
	
	--加载卡牌列表数据
    card_bag_mgr.LoadAllCard( p.layer );
	--p.ShowCardList( cardList )
end
--主界面事件处理
function p.SetDelegate(layer)
	local retBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	retBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local sellBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SELL);
	sellBtn:SetLuaDelegate(p.OnUIClickEvent);

	local cardBtnAll = GetButton(layer, ui.ID_CTRL_BUTTON_ALL);
	cardBtnAll:SetLuaDelegate(p.OnUIClickEvent);

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
			maininterface.CloseAllPanel();
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
function p.ShowCardList(cardList)
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();

	p.cardListInfo = cardList;
	if cardList == nil or #cardList <= 0 then
		WriteCon("ShowCardList():cardList is null");
		return;
	end
	WriteCon("cardCount ===== "..#cardList);
	local cardNum = #cardList;
	local row = math.ceil(cardNum / 4);
	WriteCon("row ===== "..row);
	
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("card_list_view.xui",view,nil);
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
		local row_index = i;
		local start_index = (row_index-1)*4+1
        local end_index = start_index + 3;
		
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
function p.ShowCardInfo( view, card, cardIndex )
	local cardBtn = nil;
	local cardLevel = nil;
	local cardTeam = nil;
	if cardIndex == 1 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM1;
		cardLevel = ui_list.ID_CTRL_TEXT_LEVEL1;
		cardTeam = ui_list.ID_CTRL_TEXT_TEAM1;
	elseif cardIndex == 2 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM2;
		cardLevel = ui_list.ID_CTRL_TEXT_LEVEL2;
		cardTeam = ui_list.ID_CTRL_TEXT_TEAM2;
	elseif cardIndex == 3 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM3;
		cardLevel = ui_list.ID_CTRL_TEXT_LEVEL3;
		cardTeam = ui_list.ID_CTRL_TEXT_TEAM3;
	elseif cardIndex == 4 then
		cardBtn = ui_list.ID_CTRL_BUTTON_ITEM4;
		cardLevel = ui_list.ID_CTRL_TEXT_LEVEL4;
		cardTeam = ui_list.ID_CTRL_TEXT_TEAM4;
	end
	
	--显示卡牌图片
	local cardButton = GetButton(view, cardBtn);
	local cardId = tonumber(card.CardID);
	WriteCon("CardID ===== "..cardId);
	local aniIndex = "card.card_"..cardId;
	cardButton:SetImage( GetPictureByAni(aniIndex, 0) );
	--cardButton:SetImage( GetPictureByAni("card.card_101",0) );
	local cardUniqueId = tonumber(card.UniqueId);
 	WriteCon("cardUniqueId ===== "..cardUniqueId);
    cardButton:SetId(cardUniqueId);

	local cardLevelText = GetLabel(view,cardLevel );
	local levelText = tostring(card.Level)
	cardLevelText:SetText(ToUtf8(levelText));
	
	--local cardTeamText = GetLabel(view,cardTeam );
	
	--设置卡牌按钮事件
	cardButton:SetLuaDelegate(p.OnCardClickEvent);
end

--点击卡牌
function p.OnCardClickEvent(uiNode, uiEventType, param)
	local cardUniqueId = uiNode:GetId();
	WriteCon("cardUniqueId = "..cardUniqueId);
	local cardData = nil;
	for k,v in ipairs(p.cardListInfo) do
		if tonumber(v.UniqueId) == cardUniqueId then
			cardData = v;
			break
		end
	end
	dlg_card_attr_base.ShowUI(cardData);
	
end

--设置选中按钮
function p.SetBtnCheckedFX( node )
    local btnNode = ConverToButton( node );
    if p.curBtnNode ~= nil then
    	p.curBtnNode:SetChecked( false );
    end
	btnNode:SetChecked( true );
	p.curBtnNode = btnNode;
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
		p.curBtnNode = nil;
		p.sortBtnMark = nil;
		p.sortByRuleV = nil;
        card_bag_mgr.ClearData();
    end
end
