--------------------------------------------------------------
-- FileName:    dlg_card_depot.lua
-- author:      hst, 2013��7��30��
-- purpose:     ���Ʋֿ�
--------------------------------------------------------------

dlg_card_depot = {}
local p = dlg_card_depot;
p.layer = nil;
p.isExport = false;
p.reSetBtn = nil;
p.submitBtn = nil;
p.impBtn = nil;
p.expBtn = nil;
p.sortFlag = true;
p.curBtnNode = nil;

function p.ShowUI()
    if p.layer == nil then
        local layer = createNDUIDialog();
        if layer == nil then
            return false;
        end

        layer:Init();
        --layer:SetFrameRectFull();

        GetUIRoot():AddDlg(layer);
        LoadDlg("dlg_card_depot.xui", layer, nil);

        p.SetDelegate(layer);
        p.layer = layer;
    end
    p.Init();
    --��������
    SetTimerOnce( card_depot_mgr.LoadAllCard, 0.5f );
end

function p.Init()
    --����
    local pbtn = GetButton(p.layer,ui_dlg_card_depot.ID_CTRL_BUTTON_23);
    pbtn:SetVisible( false );
    pbtn:SetEnabled( false );

    --ȷ��
    local pbtn = GetButton(p.layer,ui_dlg_card_depot.ID_CTRL_BUTTON_24);
    pbtn:SetVisible( false );
    pbtn:SetEnabled( false );

    --��ʾ���ֽڵ�
    p.tip = GetLabel( p.layer, ui_dlg_card_depot.ID_CTRL_TEXT_TIP );
end

--������Ϣ
function p.UpdateDepotInfo()
	local depotInfoNode = GetLabel( p.layer, ui_dlg_card_depot.ID_CTRL_TEXT_12 );
	local currenNumber = #card_depot_mgr.cardList;
	local depotSum = card_depot_mgr.storeSum + currenNumber;
	local msg = GetStr( "card_depot_volume" )..":"..currenNumber.."/"..depotSum
	depotInfoNode:SetText( msg );
end


--����ȡ����ť�Ƿ�ɵ��
function p.OutBtnSetEnabled( bEnabled )
    local checkBtn = GetButton(p.layer,ui_dlg_card_depot.ID_CTRL_BUTTON_37);
    checkBtn:SetEnabled( bEnabled );
end

--���Ʒ���ֿ�����ص�
function p.RefreshStore( result )
    if result ~= nil and result.store_num ~= nil then
        local tip = GetStr( "card_depot_intip_f" )..result.store_num..GetStr( "card_depot_intip_b" )
        dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), tip, p.OnMsgBoxCallback );
        card_depot_mgr.LoadAllCard();
    end
end

--�ֿ���ȡ����������ص�
function p.RefreshTakeout( result )
    if result ~= nil and result.takeout_num ~= nil then
        local tip = GetStr( "card_depot_outtip_f" )..result.takeout_num..GetStr( "card_depot_outtip_b" )
        dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), tip, p.OnMsgBoxCallback );
        card_depot_mgr.LoadAllCard();
    end
end

--�����¼�����
function p.SetDelegate(layer)
    --����
    local pCardBoxBtn01 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_11);
    pCardBoxBtn01:SetLuaDelegate(p.OnUIEventCardBox);

    --����
    local pCardBoxBtn02 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_14);
    pCardBoxBtn02:SetLuaDelegate(p.OnUIEventCardBox);

    --ȫ��
    local pCardBoxBtn03 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_2);
    pCardBoxBtn03:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ��
    local pCardBoxBtn04 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_15);
    pCardBoxBtn04:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ��Ȼ
    local pCardBoxBtn05 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_16);
    pCardBoxBtn05:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ����
    local pCardBoxBtn06 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_17);
    pCardBoxBtn06:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ����
    local pCardBoxBtn07 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_18);
    pCardBoxBtn07:SetLuaDelegate(p.OnUIEventCardBox);

    --���ֲࣺ��
    local pCardBoxBtn08 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_19);
    pCardBoxBtn08:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ����
    local pCardBoxBtn09 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_20);
    pCardBoxBtn09:SetLuaDelegate(p.OnUIEventCardBox);

    --���ࣺ��ħ
    local pCardBoxBtn10 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_21);
    pCardBoxBtn10:SetLuaDelegate(p.OnUIEventCardBox);

    --ȡ��
    p.expBtn = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_37);
    p.expBtn:SetLuaDelegate(p.OnUIEventCardBox);

    --����
    p.impBtn = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_38);
    p.impBtn:SetLuaDelegate(p.OnUIEventCardBox);

    --����
    p.reSetBtn = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_23);
    p.reSetBtn:SetLuaDelegate(p.OnUIEventCardBox);

    --ȷ��
    p.submitBtn = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_24);
    p.submitBtn:SetLuaDelegate(p.OnUIEventCardBox);
end

--�¼�����
function p.OnUIEventCardBox(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_depot.ID_CTRL_BUTTON_11 == tag ) then
            p.Back();

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_14 == tag ) then
        --WriteCon("����");
            if not p.sortFlag then
                card_depot_mgr.SortByLevelDes();
                p.sortFlag = true;
            else
                card_depot_mgr.SortByRareDes();
                p.sortFlag = false;
            end

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_2 == tag ) then
            --WriteCon("ȫ��");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.ShowAllCards();

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_15 == tag ) then
            --WriteCon("���ࣺ��");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_1 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_16 == tag ) then
            --WriteCon("���ࣺ��Ȼ");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_4 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_17 == tag ) then
            --WriteCon("���ࣺ����");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_5 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_18 == tag ) then
            --WriteCon("���ࣺ����");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_3 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_19 == tag ) then
            --WriteCon("���ֲࣺ��");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_6 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_20 == tag ) then
            --WriteCon("���ࣺ����");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_7 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_21 == tag ) then
            --WriteCon("���ࣺ��ħ");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_2 );
        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_37 == tag ) then
            --WriteCon("ȡ��");
            p.ExportCard();

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_38 == tag ) then
            --WriteCon("����");
            p.Import();

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_23 == tag ) then
            --WriteCon("����");
            p.ClearSelect();

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_24 == tag ) then
            --WriteCon("ȷ��");
            dlg_card_depot_check.ShowUI( card_depot_mgr.GetSelectCardList(), p.isExport, GetStr( "card_depot_export" ) );

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

--��������
function p.ExportCard()
    p.isExport = true;
    p.reSetBtn:SetVisible( true );
    p.submitBtn:SetVisible( true );
    p.impBtn:SetVisible( false );
    p.expBtn:SetVisible( false );
    p.SetTip( GetStr( "card_select_to_box" ) );
end

function p.Import()
    card_box_mgr.SetTitleText( GetStr( "card_box_title" ) );
    card_box_mgr.SetTipText( GetStr( "card_select_to_depot" ) );
    
    if card_depot_mgr.storeSum < 10 then
    	card_box_mgr.SetSelectMaxNum( card_depot_mgr.storeSum );
    	card_box_mgr.SetSelectMaxNumMsg( GetStr( "card_depot_outof" ) );
    else
        card_box_mgr.SetSelectMaxNum(10);
        card_box_mgr.SetSelectMaxNumMsg( GetStr( "card_select_max_10" ) );	 
    end
    card_box_mgr.SetNoSelectInTeam(true);
    card_box_mgr.SetNoSelectInTeamMsg( GetStr( "card_select_team_msg" ) );
    dlg_card_box_mainui.ShowUI( CARD_INTENT_GETLIST, dlg_card_depot );
end

function p.LoadSelectData(cardList)
    --dump_obj( cardList );
    dlg_card_depot_check.ShowUI( cardList, p.isExport, GetStr( "card_depot_import" ) );
end

function p.ClearTip()
    if p.tip ~= nil then
        p.tip:SetText( "" );
    end
end

function p.SetTip(str)
    if p.tip ~= nil then
        p.tip:SetText( tostring( str ) );
    end
end

function p.Back()
    if p.isExport then
        p.ClearSelect();
        p.ClearTip();
        p.isExport = false;
        p.reSetBtn:SetVisible( false );
        p.submitBtn:SetVisible( false );
        p.impBtn:SetVisible( true );
        p.expBtn:SetVisible( true );
    else
        p.CloseUI();
    end
end

function p.ClearSelect()
    p.submitBtn:SetEnabled( false );
    p.reSetBtn:SetEnabled( false );
    p.SetTip( GetStr( "card_select_to_box" ) );
    card_depot_mgr.ClearSelectList();
end

--�������б���ʾ
function p.ShowCardList( cardList )
    local list = GetListBoxVert(p.layer ,ui_dlg_card_depot.ID_CTRL_VERTICAL_LIST_15);
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
                p.SetViewInfo( view, card, itemIndex );
            end
        end

        list:AddView( view );
    end
end

function p.SetViewInfo( view, card, itemIndex )
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

    --�����¼�
    cardPicNode:SetLuaDelegate(p.OnBtnClicked);

end

--��ѡ���ƣ�������ѡ�Ͷ�ѡ
function p.OnBtnClicked( uiNode, uiEventType, param )
    if p.isExport then
        local selectMax = 10;
        local tipMsg = "";
        if card_depot_mgr.bagSum > selectMax then
            tipMsg = GetStr( "card_select_max_10" );
        else
            selectMax = card_depot_mgr.bagSum;
            tipMsg = GetStr( "card_box_outof" );
        end
        if selectMax == 0 then
        	dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), tipMsg, p.OnMsgBoxCallback );
        	return ;
        end

        if #card_depot_mgr.selectCardList == 0 then
            uiNode:AddFgEffect("ui.card_select_fx");
            card_depot_mgr.selectCardList[1] = uiNode;
        else
            local exists = false;
            for k, v in ipairs(card_depot_mgr.selectCardList) do
                if v:GetId() == uiNode:GetId() then
                    exists = true;
                    uiNode:DelAniEffect("ui.card_select_fx");
                    table.remove( card_depot_mgr.selectCardList, k);
                    break ;
                end
            end
            if exists == false then
                if #card_depot_mgr.selectCardList >= selectMax then
                    dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), tipMsg, p.OnMsgBoxCallback );
                else
                    uiNode:AddFgEffect("ui.card_select_fx");
                    card_depot_mgr.selectCardList[#card_depot_mgr.selectCardList + 1] = uiNode;
                end
            end
        end
        if #card_depot_mgr.selectCardList > 0 then
            p.submitBtn:SetEnabled( true );
            p.reSetBtn:SetEnabled( true );
            p.SetTip( GetStr( "card_select_lable" )..":"..#card_depot_mgr.selectCardList.."/"..selectMax );
        else
            p.submitBtn:SetEnabled( false );
            p.reSetBtn:SetEnabled( false );
            p.SetTip( GetStr( "card_select_to_box" ));
        end
    else
        --���ÿ�������
        local card = card_depot_mgr.GetCardById( uiNode:GetId() );
        dlg_card_equip.ShowUI( card );
    end
end

function p.OnMsgBoxCallback(result)

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
        p.isExport = false;
        p.reSetBtn = nil;
        p.submitBtn = nil;
        p.impBtn = nil;
        p.expBtn = nil;
        card_depot_mgr.ClearData();
    end
end