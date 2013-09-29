--------------------------------------------------------------
-- FileName: 	dlg_card_evolution.lua
-- author:		hst, 2013/07/18
-- purpose:		���ƽ���������
--------------------------------------------------------------

dlg_card_evolution = {}
local p = dlg_card_evolution;
p.layer = nil;
p.baseCard = nil;
p.materialCardId = nil;
p.needMoney = nil;

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
    LoadDlg("dlg_card_evolution.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
end

--�����¼�����
function p.SetDelegate(layer)
    --����
    local pBtn01 = GetButton(layer,ui_dlg_card_evolution.ID_CTRL_BUTTON_11);
    pBtn01:SetLuaDelegate(p.OnUIEventEvolution);

    --ѡ�񸱿�
    local pBtn02 = GetButton(layer,ui_dlg_card_evolution.ID_CTRL_BUTTON_2);
    pBtn02:SetLuaDelegate(p.OnUIEventEvolution);

    --��ʼ����
    local pBtn03 = GetButton(layer,ui_dlg_card_evolution.ID_CTRL_BUTTON_12);
    pBtn03:SetLuaDelegate(p.OnUIEventEvolution);
    pBtn03:SetEnabled( false );

end

--�¼�����
function p.OnUIEventEvolution(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_evolution.ID_CTRL_BUTTON_11 == tag ) then
            --WriteCon("����");
            p.CloseUI();
            dlg_card_box_mainui.ShowUI( CARD_INTENT_EVOLUTION );

        elseif ( ui_dlg_card_evolution.ID_CTRL_BUTTON_2 == tag ) then
           -- WriteCon("ѡ�񸱿���");
            --���λ�������
            card_box_mgr.SetDelCardById( p.baseCard.id );
            
            --���ö�Ӧ�ĸ�������Ϣ
            local cardMate = SelectCell( T_CARD, p.baseCard.card_id, "card_mate" );
            card_box_mgr.SetSelectEvolution( cardMate, true );
            
            dlg_card_box_mainui.ShowUI( CARD_INTENT_GETONE, dlg_card_evolution );

        elseif ( ui_dlg_card_evolution.ID_CTRL_BUTTON_12 == tag ) then
            --WriteCon("��ʼ����");
            if p.needMoney > msg_cache.msg_player.gold then
                dlg_msgbox.ShowYesNo( ToUtf8( "��ʾ" ), ToUtf8( "��Ҳ��㣡" ), p.OnMsgBoxCallback );
                return ;
            end
            dlg_card_evolution_result.ShowUI( p.baseCard, p.materialCardId );
            p.CloseUI();

        end

    end
end

function p.OnMsgBoxCallback(result)
    
end

--���õ�ǰ�Ŀ���
function p.LoadCurrentCard( card )
    if card == nil then
        --WriteCon("��ѡ����");
        return ;
    end
    p.baseCard = card;
    --dump_obj(card);
    --����ͼƬ
    local cardPicNode = GetButton( p.layer, ui_dlg_card_evolution.ID_CTRL_BUTTON_20 );
    local pic = GetCardPicById( card.card_id );
    if pic ~= nil then
        cardPicNode:SetImage( pic );
    end

    --��������
    local cardName = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_14 );
    local cardNameText = SelectCell( T_CARD, card.card_id, "name" );
    if cardNameText ~= nill then
    	cardName:SetText( cardNameText );
    end

    --ϡ�ж�
    local cardRare = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_16 );
    cardRare:SetText(GetStr("card_rare")..":"..card.rare );

    --�ȼ�
    local cardLV = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_19 );
    cardLV:SetText( GetStr("card_level")..":"..card.level );

    --����
--    local cardHP = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_21 );
--    cardHP:SetText( GetStr("card_hp")..":"..card.hp );

    --����
--    local cardEXP = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_24 );
--    cardEXP:SetText( GetStr("card_exp")..":"..card.exp );

    --����
--    local cardATK = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_22 );
--    cardATK:SetText( GetStr("card_attack")..":"..card.attack );

    --����
--    local damageType = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_25 );
--    if tonumber( card.damage_type ) == 1 then
--        damageType:SetText( GetStr( "damage_type" )..":"..GetStr( "damage_type_attack" ) );
--    elseif tonumber( card.damage_type ) == 2 then
--        damageType:SetText( GetStr( "damage_type" )..":"..GetStr( "damage_type_magic" ) );
--    elseif tonumber( card.damage_type ) == 3 then	
--        damageType:SetText( GetStr( "damage_type" )..":"..GetStr( "damage_type_all" ) );
--    end

    --����
--    local cardDEF = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_23 );
--    cardDEF:SetText( GetStr("card_defence")..":"..card.defence );

    --��������
--    local cardTeam = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_26 );
--    cardTeam:SetText( GetStr("card_team")..":"..card.team_no );
    
    --ӵ�н�Ǯ
    local moneyLabel = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_29 );
    local moneyValue = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_30 );
    moneyLabel:SetText( GetStr( "owned_money" ) );
    moneyValue:SetText( tostring( msg_cache.msg_player.gold ) );
    
    --���Ľ�Ǯ
    local needMoneyLabel = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_27 );
    local needMoneyValue = GetLabel( p.layer, ui_dlg_card_evolution.ID_CTRL_TEXT_28 );
    local nextEvolStep ="evolution_step_"..(tonumber( card.evolution_step ) + 1).."_cost";
    p.needMoney = tonumber( SelectCellMatch( T_CONFIG, "name", nextEvolStep, "config" ) );
    needMoneyLabel:SetText( GetStr( "spend_money" ) );
    needMoneyValue:SetText( tostring( p.needMoney ) );
end

--���ؼ�ѡ��ĸ�����
function p.LoadSelectData( card )
    if card == nil then
        return ;
    end
    p.materialCardId = card.id;
    local cardPicNode = GetButton( p.layer, ui_dlg_card_evolution.ID_CTRL_BUTTON_21 );
    local pic = GetCardPicById( card.card_id );
    if pic ~= nil then
        cardPicNode:SetImage( pic );
    end
    
    if p.materialCardId ~= nil then
    	local pBtn = GetButton(p.layer,ui_dlg_card_evolution.ID_CTRL_BUTTON_12);
        pBtn:SetEnabled( true );
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
        p.materialCardId = nil;
        p.needMoney = nil;
    end
end