--------------------------------------------------------------
-- FileName: 	dlg_card_evolution_result.lua
-- author:		hst, 2013/07/18
-- purpose:		����ǿ�����
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

--��������
function p.SendReq()
    if p.layer == nil or p.baseCard == nil or p.materialCardIds == "" then
        return ;
    end
    --WriteCon("**�����ƽ���**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
       return ;
    end;
    local param = string.format("&base_user_card_id=%d&material_user_card_id=%d", p.baseCard.id, p.materialCardId);
    SendReq("Card","Evolve",uid,param);
end

--����ص�����ʾ�������
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
    --����ͼƬ
    local cardPicNode = GetButton( p.layer, ui_dlg_card_evolution_result.ID_CTRL_BUTTON_4 );
     local pic = GetCardPicById( result.card_id );
    if pic ~= nil then
        cardPicNode:SetImage( pic );
    end

    --��������
    --[[
    local EStepNode = GetLabel( p.layer, ui_dlg_card_evolution_result.ID_CTRL_TEXT_6 );
    local EStep = SelectCell( T_CARD, result.card_id, "evolution_step" );
    EStepNode:SetText( GetStr( "card_evolution_setp" ).. EStep );
    --]]
end

--�����¼�����
function p.SetDelegate(layer)
    --����
    local pBtn01 = GetButton(layer,ui_dlg_card_evolution_result.ID_CTRL_BUTTON_7);
    pBtn01:SetLuaDelegate(p.OnUIEventEvolution);

    local pBtn02 = GetButton(layer,ui_dlg_card_evolution_result.ID_CTRL_BUTTON_8);
    pBtn02:SetLuaDelegate(p.OnUIEventEvolution);

end

--�¼�����
function p.OnUIEventEvolution(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_evolution_result.ID_CTRL_BUTTON_7 == tag ) then
            --WriteCon("����");
            p.CloseUI();

        elseif ( ui_dlg_card_evolution_result.ID_CTRL_BUTTON_8 == tag ) then
            --WriteCon("��������");
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