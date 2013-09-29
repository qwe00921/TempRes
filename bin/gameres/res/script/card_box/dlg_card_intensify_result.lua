--------------------------------------------------------------
-- FileName: 	dlg_card_intensify_result.lua
-- author:		hst, 2013/07/18
-- purpose:		����ǿ�����
--------------------------------------------------------------

dlg_card_intensify_result = {}
local p = dlg_card_intensify_result;
p.layer = nil;
p.baseCard = nil;
p.materialCardIds ="";

function p.ShowUI( baseCard, materialCardIds )
    if baseCard == nil or materialCardIds == "" then
    	return ;
    else
        p.baseCard = baseCard;
        p.materialCardIds = materialCardIds;
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
    LoadDlg("dlg_card_intensify_result.xui", layer, nil);

    p.SetDelegate(layer);
    p.layer = layer;
    
    p.SendReq();
end

--ǿ������
function p.SendReq()
    if p.layer == nil or p.baseCard == nil or p.materialCardIds == "" then
        return ;
    end
    WriteCon("**������ǿ��**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
       return ;
    end;
    local param = string.format("&base_user_card_id=%d&material_user_card_ids=%s", p.baseCard.id, p.materialCardIds);
    SendReq("Card","Upgrade",uid,param);
end

--����ص�����ʾ�����б�
function p.RefreshUI( result )
    --dump_obj( result );
    if result == "" or result == nil then
    	return ;
    end
    p.SetCardIntensifyInfo( result );
    msg_cache.msg_player.gold = tonumber( result.gold );
    task_map_mainui.RefreshMoney( msg_cache.msg_player.gold );
end

function p.SetCardIntensifyInfo( result )
    --����ͼƬ
    local cardPicNode = GetButton( p.layer, ui_dlg_card_intensify_result.ID_CTRL_BUTTON_5 );
    local pic = GetCardPicById( result.card_id );
    if pic ~= nil then
        cardPicNode:SetImage( pic );
    end

    --��������
    --local cardName = GetLabel( p.layer, ui_dlg_card_intensify_result.ID_CTRL_TEXT_14 );
    --cardName:SetText();

    --�ȼ�
    local cardLV = GetLabel( p.layer, ui_dlg_card_intensify_result.ID_CTRL_TEXT_6 );
    cardLV:SetText( GetStr("card_level")..p.baseCard.level.."---->"..result.level );

    --����
    local cardHP = GetLabel( p.layer, ui_dlg_card_intensify_result.ID_CTRL_TEXT_7 );
    cardHP:SetText( GetStr("card_hp")..p.baseCard.hp );
    local cardHP_result = GetLabel( p.layer, ui_dlg_card_intensify_result.ID_CTRL_TEXT_14 );
    cardHP_result:SetText( GetStr("card_hp")..result.hp );

    --����
    local cardATK = GetLabel( p.layer, ui_dlg_card_intensify_result.ID_CTRL_TEXT_8 );
    cardATK:SetText( GetStr("card_attack")..p.baseCard.attack );
    local cardATK_result = GetLabel( p.layer, ui_dlg_card_intensify_result.ID_CTRL_TEXT_15 );
    cardATK_result:SetText( GetStr("card_attack")..result.attack );

    --����
    local cardDEF = GetLabel( p.layer, ui_dlg_card_intensify_result.ID_CTRL_TEXT_9 );
    cardDEF:SetText( GetStr("card_defence")..p.baseCard.defence );
    local cardDEF_result = GetLabel( p.layer, ui_dlg_card_intensify_result.ID_CTRL_TEXT_16 );
    cardDEF_result:SetText( GetStr("card_defence")..result.defence );

end

--�����¼�����
function p.SetDelegate(layer)
    --����
    local pBtn01 = GetButton(layer,ui_dlg_card_intensify_result.ID_CTRL_BUTTON_17);
    pBtn01:SetLuaDelegate(p.OnUIEventIntensify);

    local pBtn02 = GetButton(layer,ui_dlg_card_intensify_result.ID_CTRL_BUTTON_18);
    pBtn02:SetLuaDelegate(p.OnUIEventIntensify);

end

--�¼�����
function p.OnUIEventIntensify(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_intensify_result.ID_CTRL_BUTTON_17 == tag ) then
            WriteCon("����");
            p.CloseUI();
        --dlg_card_box_mainui.ShowUI( CARD_INTENT_INTENSIFY );

        elseif ( ui_dlg_card_intensify_result.ID_CTRL_BUTTON_18 == tag ) then
            WriteCon("����ǿ��");
            p.CloseUI();
            dlg_card_box_mainui.ShowUI( CARD_INTENT_INTENSIFY );

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
        p.materialCardIds ="";
    end
end