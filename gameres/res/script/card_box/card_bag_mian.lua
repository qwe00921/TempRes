card_bag_mian  = {}
local p = card_bag_mian;

local ui = ui_card_main_view;
local ui_list = ui_card_list_view;
p.layer = nil;
p.curBtnNode = nil;

function p.ShowUI()
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		return;
	end
	
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	--layer:NoMask();
    layer:Init();   
	--layer:SetSwallowTouch(false);
	
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

end


--显示卡牌列表
function p.ShowCardList(cardList)
	p.cardListInfo = cardList;
	if cardList == nil or #cardList <= 0 then
		WriteCon("ShowCardList():cardList is null");
		return;
	end
	WriteCon("cardCount ===== "..#cardList);
	local cardNum = #cardList;
	local row = math.ceil(cardNum / 4);
	WriteCon("row ===== "..row);
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();
	
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
 	WriteCon("aniIndex ===== "..aniIndex);
	cardButton:SetImage( GetPictureByAni(aniIndex, 0) );
	--cardButton:SetImage( GetPictureByAni("card.card_101",0) );
    cardButton:SetId(cardId);
	
	--设置卡牌按钮事件
	cardButton:SetLuaDelegate(p.OnCardClickEvent);
end

--点击卡牌
function p.OnCardClickEvent(uiNode, uiEventType, param)
	local cardId = uiNode:GetId();
	WriteCon("cardId = "..cardId);
	local cardData = nil;
	for k,v in ipairs(p.cardListInfo) do
		if tonumber(v.CardID) == cardId then
			cardData = v;
		end
	end
	dlg_card_attr_base.ShowUI(cardData);
	
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
        pack_box_mgr.ClearData();
    end
end
