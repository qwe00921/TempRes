--------------------------------------------------------------
-- FileName: 	dlg_card_box_mainui.lua
-- author:		hst, 2013/07/09
-- purpose:		卡箱主界面
--------------------------------------------------------------

dlg_card_box_mainui = {}
local p = dlg_card_box_mainui;
p.layer = nil;
p.title = nil;
p.tip = nil;
p.resetBtn = nil;
p.checkBtn = nil;
p.sortFlag = false;
p.curBtnNode = nil --当前点击分类按钮结点

--调用意图
p.intent = nil;

--调用者
p.caller = nil;

---------显示UI----------
--intent = CARD_INTENT_PREVIEW      预览卡牌
--intent = CARD_INTENT_INTENSIFY    强化卡牌
--intent = CARD_INTENT_EVOLUTION    进化卡牌
--intent = CARD_INTENT_GETONE       选取1张卡牌
--intent = CARD_INTENT_GETLIST      选取多张卡牌
--intent = CARD_INTENT_LEADER       选取主卡牌
--intent = CARD_INTENT_SKILL        选取技能卡牌
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
    
    --加载数据
    --card_box_mgr.LoadAllCard( p.layer, intent );
    SetTimerOnce( card_box_mgr.LoadAllCard, 0.5f );
end

function p.Init( intent )
    --初使化按钮
    p.InitShowButton( intent );

    --初使化默认标题
    p.InitTitleText( intent );

    if card_box_mgr.titleText ~= nil then
        p.SetTitle( card_box_mgr.titleText );
    end

    if card_box_mgr.tipText ~= nil then
        p.SetTip( card_box_mgr.tipText );
    end

end

--根据进入卡箱的意图，来显示不同的按钮
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

--设置确认按钮是否可点击
function p.CheckBtnSetEnabled( bEnabled )
    p.checkBtn:SetEnabled( bEnabled );
end


--初使化标题
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

--容量信息
function p.UpdateDepotInfo()
    local depotInfoNode = GetLabel( p.layer, ui_dlg_card_box_mainui.ID_CTRL_TEXT_12 );
    local msg = #card_box_mgr.cardList.."/"..card_box_mgr.bag_max;
    depotInfoNode:SetText( msg );
end

--设置事件处理
function p.SetDelegate(layer)
    --返回
    local pCardBoxBtn01 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_11);
    pCardBoxBtn01:SetLuaDelegate(p.OnUIEventCardBox);

    --排序
    local pCardBoxBtn02 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_14);
    pCardBoxBtn02:SetLuaDelegate(p.OnUIEventCardBox);

    --全部
    local pCardBoxBtn03 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_2);
    pCardBoxBtn03:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：龙
    local pCardBoxBtn04 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_15);
    pCardBoxBtn04:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：自然
    local pCardBoxBtn05 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_16);
    pCardBoxBtn05:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：动物
    local pCardBoxBtn06 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_17);
    pCardBoxBtn06:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：飞行
    local pCardBoxBtn07 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_18);
    pCardBoxBtn07:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：植物
    local pCardBoxBtn08 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_19);
    pCardBoxBtn08:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：物质
    local pCardBoxBtn09 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_20);
    pCardBoxBtn09:SetLuaDelegate(p.OnUIEventCardBox);

    --分类：恶魔
    local pCardBoxBtn10 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_21);
    pCardBoxBtn10:SetLuaDelegate(p.OnUIEventCardBox);

    --确认选择
    local pCardBoxBtn11 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_37);
    pCardBoxBtn11:SetLuaDelegate(p.OnUIEventCardBox);

    --重置
    local pCardBoxBtn12 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_38);
    pCardBoxBtn12:SetLuaDelegate(p.OnUIEventCardBox);
    
    --等级排序
    local pCardBoxBtn13 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_SORTLEVEL);
    pCardBoxBtn13:SetLuaDelegate(p.OnUIEventCardBox);
    
     --稀有度排序
    local pCardBoxBtn14 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_31);
    pCardBoxBtn14:SetLuaDelegate(p.OnUIEventCardBox);
    
     --星阶排序
    local pCardBoxBtn15 = GetButton(layer,ui_dlg_card_box_mainui.ID_CTRL_BUTTON_SORTRARE);
    pCardBoxBtn15:SetLuaDelegate(p.OnUIEventCardBox);
end

--事件处理
function p.OnUIEventCardBox(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_11 == tag ) then
            --WriteCon("返回");
            p.CloseUI();

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_14 == tag ) then
            --WriteCon("排序");
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
            --WriteCon("全部");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.ShowAllCards();

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_15 == tag ) then
            --WriteCon("分类：龙");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_1 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_16 == tag ) then
            --WriteCon("分类：自然");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_4 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_17 == tag ) then
            --WriteCon("分类：动物");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_5 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_18 == tag ) then
            --WriteCon("分类：飞行");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_3 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_19 == tag ) then
            --WriteCon("分类：植物");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_6 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_20 == tag ) then
            --WriteCon("分类：物质");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_7 );

        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_21 == tag ) then
            --WriteCon("分类：恶魔");
            p.SetBtnCheckedFX( uiNode );
            card_box_mgr.LoadCardByCategory( CARD_PIERCE_2 );
        elseif ( ui_dlg_card_box_mainui.ID_CTRL_BUTTON_37 == tag ) then
            --WriteCon("确认选择");
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
            --WriteCon("重置");
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

--将卡牌列表显示
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

        --设置列表项信息，一行四张卡牌
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
    local evolution_step = tonumber( SelectCell( T_CARD, card.card_id, "evolution_step" ) );
    --evolutionStepNode:SetPicture( GetPictureByAni( "effect.num", evolution_step) );

    --增加事件
    cardPicNode:SetLuaDelegate(p.OnBtnClicked);

end

--点选卡牌，包括单选和多选
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
            --WriteCon("---------------队伍中的卡牌不能被选择------------------");
            if card_box_mgr.noSelectInTeamMsg ~= nil then
                dlg_msgbox.ShowOK( ToUtf8( "提示" ), card_box_mgr.noSelectInTeamMsg, p.OnMsgBoxCallback, p.layer );
            end
            return ;
        end
    end

    if p.intent == CARD_INTENT_INTENSIFY or p.intent == CARD_INTENT_EVOLUTION or p.intent == CARD_INTENT_GETONE then
        -- WriteCon("---------------选择一张卡牌------------------");
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
        --WriteCon("---------------取消选择------------------");
        end
    elseif p.intent == CARD_INTENT_GETLIST then
        --WriteCon("---------------选择多张卡牌------------------");
        if card_box_mgr.selectMaxNum ~= nil and card_box_mgr.selectMaxNum <= 0 then
            if card_box_mgr.selectMaxNumMsg ~= nil then
                dlg_msgbox.ShowOK( ToUtf8( "提示" ), card_box_mgr.selectMaxNumMsg, p.OnMsgBoxCallback, p.layer );
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
                    --WriteCon("---------------取消选择------------------");
                    break ;
                end
            end
            if exists == false then
                if card_box_mgr.selectMaxNum ~= nil and #card_box_mgr.selectCardList >= card_box_mgr.selectMaxNum then
                    --WriteCon("---------------超过可选的最大数量------------------");
                    if card_box_mgr.selectMaxNumMsg ~= nil then
                        dlg_msgbox.ShowOK( ToUtf8( "提示" ), card_box_mgr.selectMaxNumMsg, p.OnMsgBoxCallback, p.layer );
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