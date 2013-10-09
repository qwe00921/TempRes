--------------------------------------------------------------
-- FileName: 	dlg_card_intensify.lua
-- author:		hst, 2013/07/18
-- purpose:		卡牌强化主界面
--------------------------------------------------------------

dlg_card_intensify = {}
local p = dlg_card_intensify;
p.layer = nil;
p.baseCard = nil;
p.materialCardIds = "";
p.needMoney = nil;
p.allMoney = nil;

function p.ShowUI()

    if p.layer ~= nil then
        p.layer:SetVisible( true );
        return ;
    end
    
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
    layer:Init();
    GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_card_intensify.xui", layer, nil);

    p.SetDelegate(layer);
    p.layer = layer;
    
    local btn = GetButton(p.layer,ui_dlg_card_intensify.ID_CTRL_BUTTON_12);
    btn:SetEnabled( false );
        
end

--设置事件处理
function p.SetDelegate(layer)
    --返回
    local pCardBoxBtn01 = GetButton(layer,ui_dlg_card_intensify.ID_CTRL_BUTTON_11);
    pCardBoxBtn01:SetLuaDelegate(p.OnUIEventIntensify);

    local pCardBoxBtn02 = GetButton(layer,ui_dlg_card_intensify.ID_CTRL_BUTTON_2);
    pCardBoxBtn02:SetLuaDelegate(p.OnUIEventIntensify);

    local pCardBoxBtn03 = GetButton(layer,ui_dlg_card_intensify.ID_CTRL_BUTTON_12);
    pCardBoxBtn03:SetLuaDelegate(p.OnUIEventIntensify);


end

--事件处理
function p.OnUIEventIntensify(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_intensify.ID_CTRL_BUTTON_11 == tag ) then
            WriteCon("返回");
            p.CloseUI();
            dlg_card_box_mainui.ShowUI( CARD_INTENT_INTENSIFY );

        elseif ( ui_dlg_card_intensify.ID_CTRL_BUTTON_2 == tag ) then
            WriteCon("选择副卡牌");
            
            --屏蔽基础卡牌
            card_box_mgr.SetDelCardById( p.baseCard.id );
            --屏蔽主卡牌
            card_box_mgr.SetDelLeader( true );
            dlg_card_box_mainui.ShowUI( CARD_INTENT_GETLIST, dlg_card_intensify );

        elseif ( ui_dlg_card_intensify.ID_CTRL_BUTTON_12 == tag ) then
            if p.allMoney > msg_cache.msg_player.gold then
                dlg_msgbox.ShowYesNo( ToUtf8( "提示" ), ToUtf8( "金币不足！" ), p.OnMsgBoxCallback );
            	return ;
            end
            dlg_card_intensify_result.ShowUI( p.baseCard, p.materialCardIds);
            p.CloseUI();
        end

    end
end

function p.OnMsgBoxCallback(result)
	
end

function p.LoadCurrentCard( card )
     if card == nil then
        WriteCon("请选择卡牌");
        return ;
    end
    p.baseCard = card;
    --dump_obj(card);
    --卡牌图片
    local cardPicNode = GetButton( p.layer, ui_dlg_card_intensify.ID_CTRL_BUTTON_40 );
    local pic = GetCardPicById( card.card_id );
    if pic ~= nil then
        cardPicNode:SetImage( pic );
    end

    --卡牌名称
    local cardName = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_14 );
    local cardNameText = SelectCell( T_CARD, card.card_id, "name" );
    if cardNameText ~= nil then
    	cardName:SetText( cardNameText );
    end

    --稀有度
    local cardRare = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_16 );
    cardRare:SetText(GetStr("card_rare")..":"..card.rare );

    --等级
    local cardLV = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_19 );
    cardLV:SetText( GetStr("card_level")..":"..card.level );

    --生命
    local cardHP = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_21 );
    cardHP:SetText( GetStr("card_hp")..":"..card.hp );

    --经验
--    local cardEXP = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_24 );
--    cardEXP:SetText( GetStr("card_exp")..":"..card.exp );

    --攻击
    local cardATK = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_22 );
    cardATK:SetText( GetStr("card_attack")..":"..card.attack );

    --五行
--    local damageType = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_25 );
--    if tonumber( card.damage_type ) == 1 then
--        damageType:SetText( GetStr( "damage_type" )..":"..GetStr( "damage_type_attack" ) );
--    elseif tonumber( card.damage_type ) == 2 then
--        damageType:SetText( GetStr( "damage_type" )..":"..GetStr( "damage_type_magic" ) );
--    elseif tonumber( card.damage_type ) == 3 then   
--        damageType:SetText( GetStr( "damage_type" )..":"..GetStr( "damage_type_all" ) );
--    end

    --防御
    local cardDEF = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_23 );
    cardDEF:SetText( GetStr("card_defence")..":"..card.defence );

    --所属部队
    local cardTeam = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_26 );
    cardTeam:SetText( GetStr("card_team")..":"..card.team_no );

    --消耗金钱
    local cardNeedMoney = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_41 );
    WriteCon( "///////////" .. card.level );
    p.needMoney = SelectCellMatch( T_CARD_GROW, "level", card.level, "need_money" );
    cardNeedMoney:SetText( p.needMoney );

    --拥有金钱
    local money = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_43 );
    money:SetText( tostring( msg_cache.msg_player.gold ) );

end

--加载己选择的副卡牌
function p.LoadSelectData( cardList )
    --dump_obj(cardList)
    if cardList == nil or #cardList <= 0 then
        return ;
    end
    p.materialCardIds = "";
    local max_length = 10;
    local current_length = #cardList;
    local UINODE = {
        ui_dlg_card_intensify.ID_CTRL_BUTTON_30,
        ui_dlg_card_intensify.ID_CTRL_BUTTON_31,
        ui_dlg_card_intensify.ID_CTRL_BUTTON_32,
        ui_dlg_card_intensify.ID_CTRL_BUTTON_33,
        ui_dlg_card_intensify.ID_CTRL_BUTTON_34,
        ui_dlg_card_intensify.ID_CTRL_BUTTON_35,
        ui_dlg_card_intensify.ID_CTRL_BUTTON_36,
        ui_dlg_card_intensify.ID_CTRL_BUTTON_37,
        ui_dlg_card_intensify.ID_CTRL_BUTTON_38,
        ui_dlg_card_intensify.ID_CTRL_BUTTON_39
    };
    for i = 1,max_length do
        local cardPicNode = GetButton( p.layer, UINODE[i] );
        if i <= current_length then
            local card = cardList[i];
            p.materialCardIds = p.materialCardIds..tostring( card.id );
            if i~= current_length then
                p.materialCardIds = p.materialCardIds..",";
            end
            local pic = GetCardPicById( card.card_id );
            if pic ~= nil then
                cardPicNode:SetImage( pic );
            end
        else
            cardPicNode:SetImage( GetPictureByAni("card.card_box_db", -1) );   
        end
    end
    if p.materialCardId ~= "" then
    	local btn = GetButton(p.layer,ui_dlg_card_intensify.ID_CTRL_BUTTON_12);
    	btn:SetEnabled( true );
    	local cardNeedMoney = GetLabel( p.layer, ui_dlg_card_intensify.ID_CTRL_TEXT_41 );
    	p.allMoney = current_length * tonumber(p.needMoney);
    	cardNeedMoney:SetText( tostring( p.allMoney ) );
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
        p.baseCard = nil;
        p.materialCardIds = "";
        p.needMoney = nil;
        p.allMoney = nil;
    end
end