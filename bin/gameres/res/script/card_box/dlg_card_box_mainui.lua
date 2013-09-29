--------------------------------------------------------------
-- FileName: 	dlg_card_box_mainui.lua
-- author:		hst, 2013/07/09
-- purpose:		����������
--------------------------------------------------------------

dlg_card_box_mainui = {}
local p = dlg_card_box_mainui;
p.layer = nil;
p.title = nil;
p.tip = nil;
p.resetBtn = nil;
p.checkBtn = nil;
p.sortFlag = false;
p.curBtnNode = nil --��ǰ������ఴť���

--������ͼ
p.intent = nil;

--������
p.caller = nil;

---------��ʾUI----------
--intent = CARD_INTENT_PREVIEW      Ԥ������
--intent = CARD_INTENT_INTENSIFY    ǿ������
--intent = CARD_INTENT_EVOLUTION    ��������
--intent = CARD_INTENT_GETONE       ѡȡ1�ſ���
--intent = CARD_INTENT_GETLIST      ѡȡ���ſ���
--intent = CARD_INTENT_LEADER       ѡȡ������
--intent = CARD_INTENT_SKILL        ѡȡ���ܿ���
--caller = obj or nil
-------------------


function p.ShowUI( intent,caller )

    if p.layer == nil then
        local layer = createNDUIDialog();
        if layer == nil then
            return false;
        end

        layer:Init();
        GetUIRoot():AddDlg(layer);
        LoadDlg("dlg_card_box_mainui.xui", layer, nil);

        p.SetDelegate(layer);
        p.layer = layer;
    end

    if intent ~= nil then
        p.intent = intent;
    end
    if caller ~= nil then
        p.caller = caller;
    end

    p.Init( intent );
    
    --��������
    --card_box_mgr.LoadAllCard( p.layer, intent );
    SetTimerOnce( card_box_mgr.LoadAllCard, 0.5f );
end

function p.Init( intent )
    --��ʹ����ť
    p.InitShowButton( intent );

    --��ʹ��Ĭ�ϱ���
    p.InitTitleText( intent );

    if card_box_mgr.titleText ~= nil then
        p.SetTitle( card_box_mgr.titleText );
    end

    if card_box_mgr.tipText ~= nil then
        p.SetTip( card_box_mgr.tipText );
    end

end

--���ݽ��뿨�����ͼ������ʾ��ͬ�İ�ť
function p.InitShowButton( intent )
    p.resetBtn = GetButton(p.layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_38);
    p.checkBtn = GetButton(p.layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_37);

    if CARD_INTENT_GETLIST ~= intent then
        p.resetBtn:SetVisible( false );
    else
        p.resetBtn:SetEnabled( false );
    end

    if CARD_INTENT_PREVIEW == intent or nil == intent then
        p.checkBtn:SetVisible( false );
    else
        p.checkBtn:SetEnabled( false );
    end
end

--����ȷ�ϰ�ť�Ƿ�ɵ��
function p.CheckBtnSetEnabled( bEnabled )
    p.checkBtn:SetEnabled( bEnabled );
end


--��ʹ������
function p.InitTitleText( intent )
    p.tip = GetLabel( p.layer, ui_dlg_card_box_mainui.ID_CTRL_TEXT_TIP );
    --[[
    p.title = GetLabel( p.layer, ui_dlg_card_box_mainui.ID_CTRL_TEXT_TITLE );

    if CARD_INTENT_INTENSIFY == intent then
        p.title:SetText(GetStr("card_box_intensify"));
    elseif CARD_INTENT_EVOLUTION == intent then
        p.title:SetText(GetStr("card_box_evolution"));
    elseif CARD_INTENT_GETONE == intent then
        p.title:SetText(GetStr("card_box_getone"));
    elseif CARD_INTENT_GETLIST == intent then
        p.title:SetText(GetStr("card_box_getlist"));
    elseif CARD_INTENT_LEADER == intent then
        p.title:SetText(GetStr("card_box_leader"));
    elseif CARD_INTENT_SKILL == intent then
        p.title:SetText(GetStr("card_box_skill"));
    else
        p.title:SetText(GetStr("card_box_preview"));
    end
    --]]
end

--������Ϣ
function p.UpdateDepotInfo()
    local depotInfoNode = GetLabel( p.layer, ui_dlg_card_box_mainui.ID_CTRL_TEXT_12 );
    local msg = #card_box_mgr.cardList.."/"..card_box_mgr.bag_max;
    depotInfoNode:SetText( msg );
end

--�����¼�����
function p.SetDelegate(layer)
    --����
    local pCardBoxBtn01 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_11);
    pCardBoxBtn01:SetLuaDelegate(p.OnUIEventCardBox);

    --����
    local pCardBoxBtn02 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_14);
    pCardBoxBtn02:SetLuaDelegate(p.OnUIEventCardBox);

    --ȫ��
    local pCardBoxBtn03 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_2);
    pCardBoxBtn03:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ��
    local pCardBoxBtn04 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_15);
    pCardBoxBtn04:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ��Ȼ
    local pCardBoxBtn05 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_16);
    pCardBoxBtn05:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ����
    local pCardBoxBtn06 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_17);
    pCardBoxBtn06:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ����
    local pCardBoxBtn07 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_18);
    pCardBoxBtn07:SetLuaDelegate(p.OnUIEventCardBox);

    --���ֲࣺ��
    local pCardBoxBtn08 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_19);
    pCardBoxBtn08:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ����
    local pCardBoxBtn09 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_20);
    pCardBoxBtn09:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ��ħ
    local pCardBoxBtn10 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_21);
    pCardBoxBtn10:SetLuaDelegate(p.OnUIEventCardBox);

    --ȷ��ѡ��
    local pCardBoxBtn11 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_37);
    pCardBoxBtn11:SetLuaDelegate(p.OnUIEventCardBox);

    --����
    local pCardBoxBtn12 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_38);
    pCardBoxBtn12:SetLuaDelegate(p.OnUIEventCardBox);
    
    --�ȼ�����
    local pCardBoxBtn13 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_SORTLEVEL);
    pCardBoxBtn13:SetLuaDelegate(p.OnUIEventCardBox);
    
     --ϡ�ж�����
    local pCardBoxBtn14 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_31);
    pCardBoxBtn14:SetLuaDelegate(p.OnUIEventCardBox);
    
     --�ǽ�����
    local pCardBoxBtn15 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_SORTRARE);
    pCardBoxBtn15:SetLuaDelegate(p.OnUIEventCardBox);
end

--�¼�����
function p.OnUIEventCardBox(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_11 == tag ) then
            --WriteCon("����");
            p.CloseUI();

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_14 == tag ) then
            --WriteCon("����");
            if not p.sortFlag then
                card_box_mgr.SortByLevelDes();
                p.sortFlag = true;
            else
                card_box_mgr.SortByRareDes();
                p.sortFlag = false;
            end
        
        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_SORTLEVEL == tag ) then
            card_box_mgr.SortByLevelDes();
            
        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_31 == tag ) then
            card_box_mgr.SortByRareDes();
            
        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_SORTRARE == tag ) then    
            card_box_mgr.SortByRareDes();
            
        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_2 == tag ) then
            --WriteCon("ȫ��");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.ShowAllCards();

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_15 == tag ) then
            --WriteCon("���ࣺ��");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_1 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_16 == tag ) then
            --WriteCon("���ࣺ��Ȼ");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_4 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_17 == tag ) then
            --WriteCon("���ࣺ����");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_5 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_18 == tag ) then
            --WriteCon("���ࣺ����");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_3 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_19 == tag ) then
            --WriteCon("���ֲࣺ��");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_6 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_20 == tag ) then
            --WriteCon("���ࣺ����");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_7 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_21 == tag ) then
            --WriteCon("���ࣺ��ħ");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_2 );
        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_37 == tag ) then
            --WriteCon("ȷ��ѡ��");
            if CARD_INTENT_EVOLUTION == p.intent then
                dlg_card_evolution.ShowUI();
                dlg_card_evolution.LoadCurrentCard( card_box_mgr.GetSelectCard() );
                p.CloseUI();

            elseif CARD_INTENT_INTENSIFY == p.intent then
                dlg_card_intensify.ShowUI();
                dlg_card_intensify.LoadCurrentCard( card_box_mgr.GetSelectCard() );
                p.CloseUI();

            elseif CARD_INTENT_GETONE == p.intent or CARD_INTENT_SKILL == intent or CARD_INTENT_LEADER == intent then
                p.caller.LoadSelectData( card_box_mgr.GetSelectCard() );
                p.CloseUI();

            elseif CARD_INTENT_GETLIST == p.intent then
                p.caller.LoadSelectData( card_box_mgr.GetSelectCardList() );
                p.CloseUI();

            end

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_38 == tag ) then
            --WriteCon("����");
            p.resetBtn:SetEnabled( false );
            p.checkBtn:SetEnabled( false );
            if card_box_mgr.tipText ~= nil then
                p.SetTip( card_box_mgr.tipText );
            end
            p.SetTip(str)
            card_box_mgr.ClearSelectList();
        end
    end
end

function p.SetBtnCheckedFX( node )
    local btnNode = ConverToButton( node );
    if p.curBtnNode ~= nil then
    	p.curBtnNode:SetChecked( false );
    end
	btnNode:SetChecked( true );
	p.curBtnNode = btnNode;
end

--�������б���ʾ
function p.ShowCardList( cardList )
    local list = GetListBoxVert(p.layer ,ui_dlg_card_box_mainui.ID_CTRL_VERTICAL_LIST_15);
    list:ClearView();
    --list:SetMarginX( 10 );
    --list:SetMarginY( 10 );
    --list:SetSpacing( 30 );
    if cardList == nil or #cardList <= 0 then
        WriteCon("ShowCardList():cardList is null");
        return ;
    end

    local listLenght = #cardList;
    local row = math.ceil(listLenght / 4);

    for i = 1,row do
        local view = createNDUIXView();
        view:Init();
        LoadUI( "card_box_view.xui", view, nil );
        local bg = GetUiNode( view, ui_card_box_view.ID_CTRL_PICTURE_25 );
        view:SetViewSize( bg:GetFrameSize());

        local row_index = i;
        local start_index = (row_index-1)*4+1;
        local end_index = start_index + 3;

        --�����б�����Ϣ��һ�����ſ���
        for j = start_index,end_index do
            if j <= listLenght then
                local card = cardList[j];
                local itemIndex = end_index - j;
                p.SetItemInfo( view, card, itemIndex );
            end
        end

        list:AddView( view );
    end
end

function p.SetItemInfo( view, card, itemIndex )
    local teamNum;
    local lv;
    local cardPic;
    local evolutionStep;
    local subTitleBg;
    if itemIndex == 3 then
        teamNum = ui_card_box_view.ID_CTRL_TEXT_19;
        lv = ui_card_box_view.ID_CTRL_TEXT_23;
        cardPic = ui_card_box_view.ID_CTRL_BUTTON_38;
        evolutionStep = ui_card_box_view.ID_CTRL_PICTURE_22;
        subTitleBg = ui_card_box_view.ID_CTRL_9SLICES_77;
    elseif itemIndex == 2 then
        teamNum = ui_card_box_view.ID_CTRL_TEXT_20;
        lv = ui_card_box_view.ID_CTRL_TEXT_16;
        cardPic = ui_card_box_view.ID_CTRL_BUTTON_39;
        evolutionStep = ui_card_box_view.ID_CTRL_PICTURE_19;
        subTitleBg = ui_card_box_view.ID_CTRL_9SLICES_76;
    elseif itemIndex == 1 then
        teamNum = ui_card_box_view.ID_CTRL_TEXT_21;
        lv = ui_card_box_view.ID_CTRL_TEXT_17;
        cardPic = ui_card_box_view.ID_CTRL_BUTTON_40;
        evolutionStep = ui_card_box_view.ID_CTRL_PICTURE_23;
        subTitleBg = ui_card_box_view.ID_CTRL_9SLICES_75;
    elseif itemIndex == 0 then
        teamNum = ui_card_box_view.ID_CTRL_TEXT_22;
        lv = ui_card_box_view.ID_CTRL_TEXT_18;
        cardPic = ui_card_box_view.ID_CTRL_BUTTON_41;
        evolutionStep = ui_card_box_view.ID_CTRL_PICTURE_24;
        subTitleBg = ui_card_box_view.ID_CTRL_9SLICES_74;
    end

    --������
    local teamNumNode = GetLabel( view, teamNum );
    if tonumber( card.team_no ) ~= 0 then
    	teamNumNode:SetText(GetStr("card_team")..card.team_no);
    else
        local subTitleBgNode = Get9SlicesImage( view, subTitleBg );
        subTitleBgNode:SetVisible( false );
    end

    --�ȼ�
    local lvNode = GetLabel( view, lv );
    lvNode:SetText(GetStr("card_level")..card.level);

    --����ͼƬ
    local cardPicNode = GetButton( view, cardPic );
    local pic = GetCardPicById( card.card_id );
    if pic ~= nil then
    	cardPicNode:SetImage( pic );
    end
    cardPicNode:SetId( tonumber(card.id));

    --��������
    local evolutionStepNode = GetImage( view, evolutionStep );
    local evolution_step = tonumber( SelectCell( T_CARD, card.card_id, "evolution_step" ) );
    --evolutionStepNode:SetPicture( GetPictureByAni( "effect.num", evolution_step) );

    --�����¼�
    cardPicNode:SetLuaDelegate(p.OnBtnClicked);

end

--��ѡ���ƣ�������ѡ�Ͷ�ѡ
function p.OnBtnClicked( uiNode, uiEventType, param )
	if p.intent == nil then
		return;
	end
    if p.intent == CARD_INTENT_PREVIEW then
		local card = card_box_mgr.GetCardById( uiNode:GetId() );
		dlg_card_equip.ShowUI(card);
        return ;
    end
    if card_box_mgr.isNoSelectInTeam then
        local card = card_box_mgr.GetCardById( uiNode:GetId() );
        if tonumber( card.team_no ) ~= 0 then
            --WriteCon("---------------�����еĿ��Ʋ��ܱ�ѡ��------------------");
            if card_box_mgr.noSelectInTeamMsg ~= nil then
                dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), card_box_mgr.noSelectInTeamMsg, p.OnMsgBoxCallback, p.layer );
            end
            return ;
        end
    end

    if p.intent == CARD_INTENT_INTENSIFY or p.intent == CARD_INTENT_EVOLUTION or p.intent == CARD_INTENT_GETONE then
        -- WriteCon("---------------ѡ��һ�ſ���------------------");
        if card_box_mgr.selectCard == nil then
            card_box_mgr.selectCard = uiNode;
            uiNode:AddFgEffect("ui.card_select_fx");
            p.CheckBtnSetEnabled( true );
        elseif card_box_mgr.selectCard:GetId() ~= uiNode:GetId() then
            card_box_mgr.selectCard:DelAniEffect("ui.card_select_fx");
            uiNode:AddFgEffect("ui.card_select_fx");
            card_box_mgr.selectCard = uiNode;
        else
            card_box_mgr.selectCard:DelAniEffect("ui.card_select_fx");
            card_box_mgr.selectCard = nil;
            p.CheckBtnSetEnabled( false );
        --WriteCon("---------------ȡ��ѡ��------------------");
        end
    elseif p.intent == CARD_INTENT_GETLIST then
        --WriteCon("---------------ѡ����ſ���------------------");
        if card_box_mgr.selectMaxNum ~= nil and card_box_mgr.selectMaxNum <= 0 then
            if card_box_mgr.selectMaxNumMsg ~= nil then
                dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), card_box_mgr.selectMaxNumMsg, p.OnMsgBoxCallback, p.layer );
            end
            return ;
        end

        if #card_box_mgr.selectCardList == 0 then
            uiNode:AddFgEffect("ui.card_select_fx");
            card_box_mgr.selectCardList[1] = uiNode;
        else
            local exists = false;
            for k, v in ipairs(card_box_mgr.selectCardList) do
                if v:GetId() == uiNode:GetId() then
                    exists = true;
                    uiNode:DelAniEffect("ui.card_select_fx");
                    table.remove( card_box_mgr.selectCardList, k);
                    --WriteCon("---------------ȡ��ѡ��------------------");
                    break ;
                end
            end
            if exists == false then
                if card_box_mgr.selectMaxNum ~= nil and #card_box_mgr.selectCardList >= card_box_mgr.selectMaxNum then
                    --WriteCon("---------------������ѡ���������------------------");
                    if card_box_mgr.selectMaxNumMsg ~= nil then
                        dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), card_box_mgr.selectMaxNumMsg, p.OnMsgBoxCallback, p.layer );
                    end
                else
                    uiNode:AddFgEffect("ui.card_select_fx");
                    card_box_mgr.selectCardList[#card_box_mgr.selectCardList + 1] = uiNode;
                end
            end
        end

        if #card_box_mgr.selectCardList > 0 then
            p.resetBtn:SetEnabled( true );
            p.checkBtn:SetEnabled( true );
            local tipText = GetStr( "card_select_lable" )..":"..#card_box_mgr.selectCardList ;
            if card_box_mgr.selectMaxNum ~= nil then
                tipText = tipText.."/"..card_box_mgr.selectMaxNum;
            end
            p.SetTip( tipText );
        else
            p.resetBtn:SetEnabled( false );
            p.checkBtn:SetEnabled( false );
            p.SetTip( card_box_mgr.tipText );
        end
    end
end

function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end

function p.OnMsgBoxCallback()

end

function p.SetTitle(str)
    if str ~= nil then
        --p.title:SetText( str );
    end
end

function p.SetTip(str)
    if str ~= nil then
        p.tip:SetText( str );
    end
end

function p.CloseUI()
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
        p.title = nil;
        p.tip = nil;
        p.resetBtn = nil;
        p.checkBtn = nil;
        card_box_mgr.ClearData();
    end
end