--------------------------------------------------------------
-- FileName:    dlg_card_depot_check.lua
-- author:      hst, 2013年7月30日
-- purpose:     进出仓库确认
--------------------------------------------------------------

dlg_card_depot_check = {}
local p = dlg_card_depot_check;
p.layer = nil;
p.cardList = nil;
p.isExport = nil;
p.cardInfoNodes = {};

---------显示UI----------
function p.ShowUI( cardList,isExport, tip )
    if cardList == nil or isExport == nil then
    	return ;
    else
        p.cardList = cardList;	
        p.isExport = isExport;
    end
    
    if p.layer == nil then
        local layer = createNDUIDialog();
        if layer == nil then
            return false;
        end
        
        layer:Init();
        --layer:SetFrameRectFull();
        GetUIRoot():AddDlg(layer);
        
        LoadDlg("dlg_card_depot_check.xui", layer, nil);
        
        p.SetDelegate(layer);
        p.layer = layer;
    end
    if tip ~= nil then
    	p.SetTip( tip );
    end
    p.InitCardInfoNode();
    p.ShowCardList();
    
   
end

--设置事件处理
function p.SetDelegate(layer)
    local pBtn = GetButton(layer,ui_dlg_card_depot_check.ID_CTRL_BUTTON_CONFIRM);
    pBtn:SetLuaDelegate(p.OnUIEvent);
    
    local pBtn = GetButton(layer,ui_dlg_card_depot_check.ID_CTRL_BUTTON_CANCEL);
    pBtn:SetLuaDelegate(p.OnUIEvent);
end

function p.SetTip( str )
    if str == nil then
    	return ;
    end
	local tip = GetLabel( p.layer, ui_dlg_card_depot_check.ID_CTRL_TEXT_TIP );
	tip:SetText( tostring( str ) );
end

--事件处理
function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_depot_check.ID_CTRL_BUTTON_CONFIRM == tag ) then 
            p.SendReq();
            p.CloseUI();
            dlg_card_depot.ClearSelect();
            
        elseif ( ui_dlg_card_depot_check.ID_CTRL_BUTTON_CANCEL == tag ) then 
            --WriteCon("取消");
            p.CloseUI();
        end     
    end
end

function p.GetSelectCardId()
    local cardIds = "";
    for k, v in ipairs(p.cardList) do
    	cardIds = cardIds..v.id;
    	if k ~= #p.cardList then
    		cardIds = cardIds..",";
    	end
    end
	return cardIds;
end

function p.SendReq()
    local uid = GetUID();
    local action ;
    local cardIds = p.GetSelectCardId();
    if uid == 0 or uid == nil then
        return ;
    end;
    if p.isExport ~= nil and p.isExport == true then
    	action = "TakeOutUserCards";
    else
        action = "StoreUserCards";	
    end
    local param = string.format("&card_ids=%s", cardIds);
    SendReq("Card",action,uid,param);
end

--显示所选择的卡牌
function p.ShowCardList()
    for i=1, #p.cardList do
        local card = p.cardList[i];
        local cardNodes = p.cardInfoNodes[i];
        
        --卡牌图片
        local cardPicNode = cardNodes[1];
        local pic = GetCardPicById( card.card_id );
        if pic ~= nil then
            cardPicNode:SetPicture( pic );
        end
        cardPicNode:SetPicture( pic );
        --[[
        --星级
        local cardRareNode = cardNodes[2];
        cardRareNode:SetText(GetStr("card_rare")..card.rare);
        
        --等级
        local cardLvNode = cardNodes[3];
        cardLvNode:SetText(GetStr("card_level")..card.level);
        --]]
    end
end

--卡牌信息显示的结点【共10个结点】
function p.InitCardInfoNode()
    local cardPids = {
       ui_dlg_card_depot_check.ID_CTRL_PICTURE_CARDPIC1,
       ui_dlg_card_depot_check.ID_CTRL_PICTURE_CARDPIC2,
       ui_dlg_card_depot_check.ID_CTRL_PICTURE_CARDPIC3,
       ui_dlg_card_depot_check.ID_CTRL_PICTURE_CARDPIC4,
       ui_dlg_card_depot_check.ID_CTRL_PICTURE_CARDPIC5,
       ui_dlg_card_depot_check.ID_CTRL_PICTURE_CARDPIC6,
       ui_dlg_card_depot_check.ID_CTRL_PICTURE_CARDPIC7,
       ui_dlg_card_depot_check.ID_CTRL_PICTURE_CARDPIC8,
       ui_dlg_card_depot_check.ID_CTRL_PICTURE_CARDPIC9,
       ui_dlg_card_depot_check.ID_CTRL_PICTURE_CARDPIC10
      };
    local cardRares = {
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDRARE1,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDRARE2,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDRARE3,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDRARE4,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDRARE5,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDRARE6,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDRARE7,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDRARE8,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDRARE9,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDRARE10
      }; 
    local cardLvs = {
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDLV1,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDLV2,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDLV3,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDLV4,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDLV5,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDLV6,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDLV7,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDLV8,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDLV9,
       ui_dlg_card_depot_check.ID_CTRL_TEXT_CARDLV10
      }; 
    
    for i=1, 10 do
        local cardPic = GetImage( p.layer, cardPids[i] );
        local cardRare = GetLabel( p.layer, cardRares[i] );
        local cardLv = GetLabel( p.layer, cardLvs[i] );
        local t = {cardPic, cardRare, cardLv};
        p.cardInfoNodes[#p.cardInfoNodes+1] = t;
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
        p.cardList = nil;
        p.isExport = nil;
        p.cardInfoNodes = {};
    end
end