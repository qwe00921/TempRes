CARD_BAG_SORT_BY_LEVEL	= 1001;
CARD_BAG_SORT_BY_STAR	= 1002;
CARD_BAG_SORT_BY_TIME = 1003;

PROFESSION_TYPE_0 = 2000
PROFESSION_TYPE_1 = 2001;
PROFESSION_TYPE_2 = 2002;
PROFESSION_TYPE_3 = 2003;
PROFESSION_TYPE_4 = 2004;

MARK_ON = 100;
MARK_OFF = nil;

card_bag_mian  = {}
local p = card_bag_mian;
local ui = ui_card_main_view;
local ui_list = ui_card_list_view;

p.layer 		= nil;
p.cardListInfo 	= nil;
p.curBtnNode 	= nil;
p.sortByRuleV 	= nil;
p.sortBtnMark 	= MARK_OFF;		--���������Ƿ���
p.BatchSellMark = MARK_OFF;		--���������Ƿ���
p.allCardPrice 	= 0;	--���ۿ����ܼ�ֵ
p.sellCardList 	= {};	--���ۿ����б�

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
	
	--���ؿ����б�����
    card_bag_mgr.LoadAllCard( p.layer );
end

--��ʾ�����б�
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
		
		--�����б���Ϣ��һ��4�ſ���
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

--��ʾ���ſ���
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
	--��ʾ����ͼƬ
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
	
	local cardTeamText = GetLabel(view,cardTeam );
	local teamText = tostring(card.Team_marks)
	if teamText ~= "0" then
		teamText:SetText(ToUtf8(teamText));
	end

	--���ÿ��ư�ť�¼�
	cardButton:SetLuaDelegate(p.OnCardClickEvent);
	cardButton:RemoveAllChildren(true);
	p.ClearDelList();
end

--�������
function p.OnCardClickEvent(uiNode, uiEventType, param)
	local cardUniqueId = uiNode:GetId();
	WriteCon("cardUniqueId = "..cardUniqueId);
	if p.BatchSellMark == MARK_ON then
		p.ShowSelectPic(uiNode);
	elseif p.BatchSellMark == MARK_OFF then 
		local cardData = nil;
		for k,v in ipairs(p.cardListInfo) do
			if tonumber(v.UniqueId) == cardUniqueId then
				cardData = v;
				break
			end
		end
		dlg_card_attr_base.ShowUI(cardData);
	end
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




--�������¼�����
function p.SetDelegate(layer)
	local retBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	retBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local sellBtn = GetButton(layer, ui.ID_CTRL_BUTTON_SELL);
	sellBtn:SetLuaDelegate(p.OnUIClickEvent);

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

--�¼�����
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_SELL == tag) then --��������
			p.sellBtnEvent();
		elseif(ui.ID_CTRL_BUTTON_RETURN == tag) then --����
			p.CloseUI();
			maininterface.CloseAllPanel();
		elseif(ui.ID_CTRL_BUTTON_ALL == tag) then --ȫ��
			WriteCon("=====allCardBtn");
			p.SetBtnCheckedFX( uiNode );
			card_bag_mgr.ShowCardByProfession(PROFESSION_TYPE_0);
		elseif(ui.ID_CTRL_BUTTON_PRO1 == tag) then --ְҵ1
			WriteCon("=====cardBtnPro1");
			p.SetBtnCheckedFX( uiNode );
			card_bag_mgr.ShowCardByProfession(PROFESSION_TYPE_1);
		elseif(ui.ID_CTRL_BUTTON_PRO2 == tag) then --ְҵ2
			WriteCon("=====cardBtnPro2");
			p.SetBtnCheckedFX( uiNode );
			card_bag_mgr.ShowCardByProfession(PROFESSION_TYPE_2);
		elseif(ui.ID_CTRL_BUTTON_PRO3 == tag) then --ְҵ3
			WriteCon("=====cardBtnPro3");
			p.SetBtnCheckedFX( uiNode );
			card_bag_mgr.ShowCardByProfession(PROFESSION_TYPE_3);
		elseif(ui.ID_CTRL_BUTTON_PRO4 == tag) then --ְҵ4
			WriteCon("=====cardBtnPro4");
			p.SetBtnCheckedFX( uiNode );
			card_bag_mgr.ShowCardByProfession(PROFESSION_TYPE_4);
		elseif(ui.ID_CTRL_BUTTON_SORT_BY == tag) then --���ȼ�����
			WriteCon("card_bag_sort.ShowUI()");
			p.ClearDelList()
			if p.sortBtnMark == nil then
				card_bag_sort.ShowUI();
			else
				p.sortBtnMark = nil;
				card_bag_sort.CloseUI();
			end
		end
	end
end
--���������ť�¼�
function p.sellBtnEvent()
	local btn = GetButton(p.layer, ui.ID_CTRL_BUTTON_SELL);
	if p.BatchSellMark == MARK_OFF then
		p.BatchSellMark = MARK_ON;
		btn:SetImage( GetPictureByAni("button.sell",0));
	elseif p.BatchSellMark == MARK_ON then
		if #p.sellCardList <= 0 then
			dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),ToUtf8("��ѡ����Ҫ���۵Ŀ�Ƭ"),nil,p.layer);
		else
			for i=1,#p.sellCardList do
				for j=1, #p.cardListInfo do
					if tonumber(p.sellCardList[i]) == p.cardListInfo[j].UniqueId then
						p.allCardPrice = p.allCardPrice + p.cardListInfo[j].Price;
					end
				end
			end
			dlg_msgbox.ShowYesNo(ToUtf8("ȷ����ʾ��"),ToUtf8("��Щ���������ļ۸��ǣ�"..tostring(p.allCardPrice).."��ң���ȷ��Ҫ������Щ������"),p.OnMsgBoxCallback,p.layer);
		end
	end
end

--ȷ�ϻ�ȡ������
function p.OnMsgBoxCallback(result)
	if result == true then
		WriteCon("true");
		p.allCardPrice = 0;
		card_bag_mgr.SendDelRequest(p.sellCardList);
	elseif result == false then
		WriteCon("false");
		p.allCardPrice = 0;
	end
end



--����������ť
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

--����ѡ�а�ť
function p.SetBtnCheckedFX( node )
    local btnNode = ConverToButton( node );
    if p.curBtnNode ~= nil then
    	p.curBtnNode:SetChecked( false );
    end
	btnNode:SetChecked( true );
	p.curBtnNode = btnNode;
	card_bag_sort.CloseUI();
	p.ClearDelList()
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
    end
end

function p.ClearData()
	p.cardListInfo = nil;
	p.curBtnNode = nil;
	p.sortByRuleV = nil;
	p.sortBtnMark = MARK_OFF;
	p.BatchSellMark = MARK_OFF;
	p.allCardPrice = 0;
	p.sellCardList = {};
end

function p.ClearDelList()
	p.allCardPrice = 0;
	p.sellCardList = {};
end
