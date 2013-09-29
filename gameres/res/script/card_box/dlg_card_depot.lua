--------------------------------------------------------------
-- FileName:    dlg_card_depot.lua
-- author:      hst, 2013年7月30日
-- purpose:     卡牌仓库
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
    --加载数据
    SetTimerOnce( card_depot_mgr.LoadAllCard, 0.5f );
end

function p.Init()
    --重置
    local pbtn = GetButton(p.layer,ui_dlg_card_depot.ID_CTRL_BUTTON_23);
    pbtn:SetVisible( false );
    pbtn:SetEnabled( false );

    --确认
    local pbtn = GetButton(p.layer,ui_dlg_card_depot.ID_CTRL_BUTTON_24);
    pbtn:SetVisible( false );
    pbtn:SetEnabled( false );

    --提示文字节点
    p.tip = GetLabel( p.layer, ui_dlg_card_depot.ID_CTRL_TEXT_TIP );
end

--容量信息
function p.UpdateDepotInfo()
	local depotInfoNode = GetLabel( p.layer, ui_dlg_card_depot.ID_CTRL_TEXT_12 );
	local currenNumber = #card_depot_mgr.cardList;
	local depotSum = card_depot_mgr.storeSum + currenNumber;
	local msg = GetStr( "card_depot_volume" )..":"..currenNumber.."/"..depotSum
	depotInfoNode:SetText( msg );
end


--设置取出按钮是否可点击
function p.OutBtnSetEnabled( bEnabled )
    local checkBtn = GetButton(p.layer,ui_dlg_card_depot.ID_CTRL_BUTTON_37);
    checkBtn:SetEnabled( bEnabled );
end

--卡牌放入仓库请求回调
function p.RefreshStore( result )
    if result ~= nil and result.store_num ~= nil then
        local tip = GetStr( "card_depot_intip_f" )..result.store_num..GetStr( "card_depot_intip_b" )
        dlg_msgbox.ShowOK( ToUtf8( "提示" ), tip, p.OnMsgBoxCallback );
        card_depot_mgr.LoadAllCard();
    end
end

--仓库中取出卡牌请求回调
function p.RefreshTakeout( result )
    if result ~= nil and result.takeout_num ~= nil then
        local tip = GetStr( "card_depot_outtip_f" )..result.takeout_num..GetStr( "card_depot_outtip_b" )
        dlg_msgbox.ShowOK( ToUtf8( "提示" ), tip, p.OnMsgBoxCallback );
        card_depot_mgr.LoadAllCard();
    end
end

--设置事件处理
function p.SetDelegate(layer)
    --返回
    local pCardBoxBtn01 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_11);
    pCardBoxBtn01:SetLuaDelegate(p.OnUIEventCardBox);

    --排序
    local pCardBoxBtn02 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_14);
    pCardBoxBtn02:SetLuaDelegate(p.OnUIEventCardBox);

    --全部
    local pCardBoxBtn03 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_2);
    pCardBoxBtn03:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：龙
    local pCardBoxBtn04 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_15);
    pCardBoxBtn04:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：自然
    local pCardBoxBtn05 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_16);
    pCardBoxBtn05:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：动物
    local pCardBoxBtn06 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_17);
    pCardBoxBtn06:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：飞行
    local pCardBoxBtn07 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_18);
    pCardBoxBtn07:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：植物
    local pCardBoxBtn08 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_19);
    pCardBoxBtn08:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：物质
    local pCardBoxBtn09 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_20);
    pCardBoxBtn09:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：恶魔
    local pCardBoxBtn10 = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_21);
    pCardBoxBtn10:SetLuaDelegate(p.OnUIEventCardBox);

    --取出
    p.expBtn = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_37);
    p.expBtn:SetLuaDelegate(p.OnUIEventCardBox);

    --放入
    p.impBtn = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_38);
    p.impBtn:SetLuaDelegate(p.OnUIEventCardBox);

    --重置
    p.reSetBtn = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_23);
    p.reSetBtn:SetLuaDelegate(p.OnUIEventCardBox);

    --确认
    p.submitBtn = GetButton(layer,ui_dlg_card_depot.ID_CTRL_BUTTON_24);
    p.submitBtn:SetLuaDelegate(p.OnUIEventCardBox);
end

--事件处理
function p.OnUIEventCardBox(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_depot.ID_CTRL_BUTTON_11 == tag ) then
            p.Back();

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_14 == tag ) then
        --WriteCon("排序");
            if not p.sortFlag then
                card_depot_mgr.SortByLevelDes();
                p.sortFlag = true;
            else
                card_depot_mgr.SortByRareDes();
                p.sortFlag = false;
            end

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_2 == tag ) then
            --WriteCon("全部");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.ShowAllCards();

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_15 == tag ) then
            --WriteCon("分类：龙");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_1 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_16 == tag ) then
            --WriteCon("分类：自然");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_4 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_17 == tag ) then
            --WriteCon("分类：动物");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_5 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_18 == tag ) then
            --WriteCon("分类：飞行");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_3 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_19 == tag ) then
            --WriteCon("分类：植物");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_6 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_20 == tag ) then
            --WriteCon("分类：物质");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_7 );

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_21 == tag ) then
            --WriteCon("分类：恶魔");
            p.SetBtnCheckedFX( uiNode );
            card_depot_mgr.LoadCardByCategory( CARD_PIERCE_2 );
        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_37 == tag ) then
            --WriteCon("取出");
            p.ExportCard();

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_38 == tag ) then
            --WriteCon("放入");
            p.Import();

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_23 == tag ) then
            --WriteCon("重置");
            p.ClearSelect();

        elseif ( ui_dlg_card_depot.ID_CTRL_BUTTON_24 == tag ) then
            --WriteCon("确认");
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

--导出卡牌
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

--将卡牌列表显示
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

        --设置列表项信息，一行四张卡牌
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

    --队伍编号
    local teamNumNode = GetLabel( view, teamNum );
    if tonumber( card.team_no ) ~= 0 then
        teamNumNode:SetText(GetStr("card_team")..card.team_no);
    else
        local subTitleBgNode = Get9SlicesImage( view, subTitleBg );
        subTitleBgNode:SetVisible( false );
    end

    --等级
    local lvNode = GetLabel( view, lv );
    lvNode:SetText(GetStr("card_level")..card.level);

    --卡牌图片
    local cardPicNode = GetButton( view, cardPic );
    local pic = GetCardPicById( card.card_id );
    if pic ~= nil then
        cardPicNode:SetImage( pic );
    end
    cardPicNode:SetId( tonumber(card.id));

    --进化阶数
    local evolutionStepNode = GetImage( view, evolutionStep );

    --增加事件
    cardPicNode:SetLuaDelegate(p.OnBtnClicked);

end

--点选卡牌，包括单选和多选
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
        	dlg_msgbox.ShowOK( ToUtf8( "提示" ), tipMsg, p.OnMsgBoxCallback );
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
                    dlg_msgbox.ShowOK( ToUtf8( "提示" ), tipMsg, p.OnMsgBoxCallback );
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
        --调用卡牌详情
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