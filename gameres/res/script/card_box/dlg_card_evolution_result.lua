--------------------------------------------------------------
-- FileName: 	dlg_card_evolution_result.lua
-- author:		hst, 2013/07/18
-- purpose:		卡牌强化结果
--------------------------------------------------------------

dlg_card_evolution_result = {}
local p = dlg_card_evolution_result;
p.layer = nil;
p.baseCard = nil;
p.materialCardId = nil;

function p.ShowUI( baseCard, materialCardId )
     if baseCard == nil or materialCardIds == "" then
        return ;
    else
        p.baseCard = baseCard;
        p.materialCardId = materialCardId;
    end
    
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
    LoadDlg("dlg_card_evolution_result.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);
    p.SendReq();
end

--进化请求
function p.SendReq()
    if p.layer == nil or p.baseCard == nil or p.materialCardIds == "" then
        return ;
    end
    --WriteCon("**请求卡牌进化**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
       return ;
    end;
    local param = string.format("&base_user_card_id=%d&material_user_card_id=%d", p.baseCard.id, p.materialCardId);
    SendReq("Card","Evolve",uid,param);
end

--请求回调，显示进化结果
function p.RefreshUI( result )
    --dump_obj( result );
    if result == "" or result == nil then
        return ;
    end
    p.SetCardEvolutionInfo( result );
    msg_cache.msg_player.gold = tonumber( result.gold );
    task_map_mainui.RefreshMoney( msg_cache.msg_player.gold );
end

function p.SetCardEvolutionInfo( result )
    --卡牌图片
    local cardPicNode = GetButton( p.layer, ui_dlg_card_evolution_result.ID_CTRL_BUTTON_4 );
     local pic = GetCardPicById( result.card_id );
    if pic ~= nil then
        cardPicNode:SetImage( pic );
    end

    --进化次数
    --[[
    local EStepNode = GetLabel( p.layer, ui_dlg_card_evolution_result.ID_CTRL_TEXT_6 );
    local EStep = SelectCell( T_CARD, result.card_id, "evolution_step" );
    EStepNode:SetText( GetStr( "card_evolution_setp" ).. EStep );
    --]]
end

--设置事件处理
function p.SetDelegate(layer)
    --返回
    local pBtn01 = GetButton(layer,ui_dlg_card_evolution_result.ID_CTRL_BUTTON_7);
    pBtn01:SetLuaDelegate(p.OnUIEventEvolution);

    local pBtn02 = GetButton(layer,ui_dlg_card_evolution_result.ID_CTRL_BUTTON_8);
    pBtn02:SetLuaDelegate(p.OnUIEventEvolution);

end

--事件处理
function p.OnUIEventEvolution(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_evolution_result.ID_CTRL_BUTTON_7 == tag ) then
            --WriteCon("返回");
            p.CloseUI();

        elseif ( ui_dlg_card_evolution_result.ID_CTRL_BUTTON_8 == tag ) then
            --WriteCon("继续进化");
            p.CloseUI();
            dlg_card_box_mainui.ShowUI( CARD_INTENT_EVOLUTION );

        end

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
    end
end