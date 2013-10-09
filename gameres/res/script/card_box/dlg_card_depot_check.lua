--------------------------------------------------------------
-- FileName:    dlg_card_depot_check.lua
-- author:      hst, 2013��7��30��
-- purpose:     �����ֿ�ȷ��
--------------------------------------------------------------

dlg_card_depot_check = {}
local p = dlg_card_depot_check;
p.layer = nil;
p.cardList = nil;
p.isExport = nil;
p.cardInfoNodes = {};

---------��ʾUI----------
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

--�����¼�����
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

--�¼�����
function p.OnUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_depot_check.ID_CTRL_BUTTON_CONFIRM == tag ) then 
            p.SendReq();
            p.CloseUI();
            dlg_card_depot.ClearSelect();
            
        elseif ( ui_dlg_card_depot_check.ID_CTRL_BUTTON_CANCEL == tag ) then 
            --WriteCon("ȡ��");
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

--��ʾ��ѡ��Ŀ���
function p.ShowCardList()
    for i=1, #p.cardList do
        local card = p.cardList[i];
        local cardNodes = p.cardInfoNodes[i];
        
        --����ͼƬ
        local cardPicNode = cardNodes[1];
        local pic = GetCardPicById( card.card_id );
        if pic ~= nil then
            cardPicNode:SetPicture( pic );
        end
        cardPicNode:SetPicture( pic );
        --[[
        --�Ǽ�
        local cardRareNode = cardNodes[2];
        cardRareNode:SetText(GetStr("card_rare")..card.rare);
        
        --�ȼ�
        local cardLvNode = cardNodes[3];
        cardLvNode:SetText(GetStr("card_level")..card.level);
        --]]
    end
end

--������Ϣ��ʾ�Ľ�㡾��10����㡿
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