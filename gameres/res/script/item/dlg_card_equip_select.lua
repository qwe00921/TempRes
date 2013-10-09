--------------------------------------------------------------
-- FileName: 	dlg_card_equip_select.lua
-- author:		zjj, 2013/09/05
-- purpose:		����װ��ѡ�����
--------------------------------------------------------------

dlg_card_equip_select = {}
local p = dlg_card_equip_select;
p.layer = nil;

--������ͼ
p.intent = nil;

--���ý���
p.caller = nil;


--����װ������id
p.cardid = nil;

p.viewList = {};
--���װ��
p.equipList = nil;
--��ѡװ���б�
p.selectEquip = nil;

--�ѽ�ѡ��װ������б�
p.selectIndexList = {};

---------��ͼ----------
--EQUIP_INTENT_GETWEAPON	= 1;--ѡ������
--EQUIP_INTENT_GETARMOR		= 2;--ѡ�����
--EQUIP_INTENT_GETORNAMENT	= 3;--ѡ����Ʒ
--EQUIP_INTENT_GETLIST 		= 4;--װ��ǿ��ѡ��
---------��ͼ----------

--��ʾUI
function p.ShowUI( intent, caller, cardid)
	
	local layer = createNDUIDialog();
		if layer == nil then
			return false;
    end
	layer:Init();
    
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_card_equip_select.xui", layer, nil);
	
	p.layer = layer;

	if intent ~= nil then
        p.intent = intent;
    end
    if caller ~= nil then
        p.caller = caller;
    end
	if cardid ~= nil then
        p.cardid = cardid;
    end
	
	--����װ������
	equip_select_mgr.LoadAllEquip( intent );
	
	local backBtn = GetButton(p.layer,ui_dlg_card_equip_select.ID_CTRL_BUTTON_BACK);
	backBtn:SetLuaDelegate(p.OnUIEventEquipList);
end

--��ʾ���ص�װ��
function p.ShowEquipList( equipList )
    local list = GetListBoxVert(p.layer,ui_dlg_card_equip_select.ID_CTRL_VERTICAL_LIST_EQUIP_SELECT);
    list:ClearView();

    if equipList == nil or #equipList == 0 then
        WriteCon( "no equip cab be equiped" );
        return;
    end
    p.equipList = equipList;
    
    local listLenght = #equipList;
    local row = math.ceil(listLenght / 2);
    
    for i=1,row do
        local view = createNDUIXView();
        view:Init();
        LoadUI("card_equip_select_view.xui", view, nil);
        
        local bg = GetUiNode(view,ui_card_equip_select_view.ID_CTRL_PICTURE_BG);
        view:SetViewSize( bg:GetFrameSize());
        view:SetId( i );
        
        local equipLeft = equipList[ 2 * i - 1];
        p.SetLeftEquipInfo( view , equipLeft);
        if i*2 < listLenght then
            local equipRight = equipList[ 2 * i]; 
            p.SetRightEquipInfo( view, equipRight);
        else 
            p.HideRightView( view );
        end
        
        local leftEquipBtn = GetButton( view , ui_card_equip_select_view.ID_CTRL_BUTTON_ICON_L);
        leftEquipBtn:SetLuaDelegate(p.OnUIEventEquipList);
        local rightEquipBtn = GetButton( view , ui_card_equip_select_view.ID_CTRL_BUTTON_ICON_R);
        rightEquipBtn:SetLuaDelegate(p.OnUIEventEquipList);
        
        list:AddView( view );
    end
end

--�����ұ���
function p.HideRightView( view )
	local equipPic = ui_card_equip_select_view.ID_CTRL_BUTTON_ICON_R;
    local equipLV = ui_card_equip_select_view.ID_CTRL_TEXT_LV_R;
    local equipName = ui_card_equip_select_view.ID_CTRL_TEXT_NAME_R;
    local equipStart = ui_card_equip_select_view.ID_CTRL_TEXT_START_R;
    local equipAtk = ui_card_equip_select_view.ID_CTRL_TEXT_ATK_R;
    local equipDef = ui_card_equip_select_view.ID_CTRL_TEXT_DEF_R;
    local equipSkill = ui_card_equip_select_view.ID_CTRL_TEXT_SKILL_R;
    local equipCardName = ui_card_equip_select_view.ID_CTRL_TEXT_CARD_NAME_R;
    local equipCardNameBg = ui_card_equip_select_view.ID_CTRL_PICTURE_CARD_NAME_BG_R;
    local equipTypeLab = ui_card_equip_select_view.ID_CTRL_TEXT_TYPE_R;
    local equipPicImg = GetButton( view, equipPic );
    equipPicImg:SetVisible( false );
    local equipLVLable = GetLabel( view, equipLV );
    equipLVLable:SetVisible( false );
    local equipNameLable = GetLabel( view, equipName );
    equipNameLable:SetVisible( false );
    local equipStartLab = GetLabel( view, equipStart );
    equipStartLab:SetVisible( false );
    local equipAtkLable = GetLabel( view, equipAtk );
    equipAtkLable:SetVisible( false );
    local equipDefLable = GetLabel( view, equipDef );
    equipDefLable:SetVisible( false );
    local equipSkillLable = GetLabel( view, equipSkill );
    equipSkillLable:SetVisible( false );
    local equipCardNameLable = GetLabel( view, equipCardName );
    equipCardNameLable:SetVisible( false );
    local equipCardNameBgPic = GetImage( view ,equipCardNameBg );
    equipCardNameBgPic:SetVisible( false );
    local equipTypeLab = GetLabel( view, equipTypeLab );
    equipTypeLab:SetVisible( false );
    local temp = Get9SlicesImage(view , ui_card_equip_select_view.ID_CTRL_9SLICES_BG_R);
    temp:SetVisible( false );
    temp = GetImage( view,ui_card_equip_select_view.ID_CTRL_PICTURE_25);
    temp:SetVisible( false );
    temp = GetImage( view,ui_card_equip_select_view.ID_CTRL_PICTURE_24);
    temp:SetVisible( false );
    temp = Get9SlicesImage( view ,ui_card_equip_select_view.ID_CTRL_9SLICES_20);
    temp:SetVisible( false );
    temp = Get9SlicesImage( view ,ui_card_equip_select_view.ID_CTRL_9SLICES_28);
    temp:SetVisible( false );
    temp = GetLabel( view, ui_card_equip_select_view.ID_CTRL_TEXT_31 );
    temp:SetVisible( false );
    temp = GetLabel( view, ui_card_equip_select_view.ID_CTRL_TEXT_33 );
    temp:SetVisible( false );
end

--��������װ����Ϣ
function p.SetRightEquipInfo(view , equip)
    
	local equipPic = ui_card_equip_select_view.ID_CTRL_BUTTON_ICON_R;
    
    local equipLV = ui_card_equip_select_view.ID_CTRL_TEXT_LV_R;
    
    local equipName = ui_card_equip_select_view.ID_CTRL_TEXT_NAME_R;
    
    local equipStart = ui_card_equip_select_view.ID_CTRL_TEXT_START_R;
    
    local equipAtk = ui_card_equip_select_view.ID_CTRL_TEXT_ATK_R;
    
    local equipDef = ui_card_equip_select_view.ID_CTRL_TEXT_DEF_R;
    
    local equipSkill = ui_card_equip_select_view.ID_CTRL_TEXT_SKILL_R;
    
    local equipCardName = ui_card_equip_select_view.ID_CTRL_TEXT_CARD_NAME_R;
    
    local equipCardNameBg = ui_card_equip_select_view.ID_CTRL_PICTURE_CARD_NAME_BG_R;
    
    local equipTypeLab = ui_card_equip_select_view.ID_CTRL_TEXT_TYPE_R;

    --װ��ͼ��
    local equipPicImg = GetButton( view, equipPic );
    equipPicImg:SetId( tonumber( equip.id ));
    
    --װ������
    local equipTypeLab = GetLabel( view, equipTypeLab );
    p.SetEquipTypeText( equipTypeLab );
    
    --װ���ȼ�
    local equipLVLable = GetLabel( view, equipLV );
    equipLVLable:SetText( tostring(equip.level));
    
    --װ������
    local equipNameLable = GetLabel( view, equipName );
    equipNameLable:SetText( equip.name );
    
    --װ���Ǽ�
    local equipStartLab = GetLabel( view, equipStart );
    equipStartLab:SetText( "(" .. equip.rare .. ToUtf8( "�Ǽ�" ) .. ")");
    
    --װ��������
    local equipAtkLable = GetLabel( view, equipAtk );
    equipAtkLable:SetText( tostring(p.GetAttack( equip )));
    
    --װ��������
    local equipDefLable = GetLabel( view, equipDef );
    equipDefLable:SetText( tostring(p.GetDef( equip )));
    
    --װ������
    local equipSkillLable = GetLabel( view, equipSkill );
    equipSkillLable:SetText("not skill");
    if tonumber( equip.skill ) ~= 0 then
        equipSkillLable:SetText( tostring(equip.skill));
    end
    
    --װ����������
    local equipCardNameLable = GetLabel( view, equipCardName );
    equipCardNameLable:SetVisible( false );
    --װ���������Ʊ���
    local equipCardNameBgPic = GetImage( view ,equipCardNameBg );
    equipCardNameBgPic:SetVisible( false );
    
    -----��������------

    --�����װ������
--  if tonumber(equip.card_id) ~= 0 then
--      --װ���ڿ�����
--      equipCardNameLable:SetVisible( true );
--      equipCardNameBgPic:SetVisible( true );
--      local card = nil;
--        for k,v in ipairs( msg_cache.msg_card_box ) do
--            if v.id == equip.card_id then
--                card = v;
--            end
--        end
--      local cardname = SelectCell( T_CARD, card.card_id , "name" );
--      equipCardNameLable:SetText( tostring( cardname));
--    end   
      -----��������------
end
--��������װ����Ϣ
function p.SetLeftEquipInfo(view ,equip)
	
	local equipPic = ui_card_equip_select_view.ID_CTRL_BUTTON_ICON_L;
	
	local equipLV = ui_card_equip_select_view.ID_CTRL_TEXT_LV_L;
	
	local equipName = ui_card_equip_select_view.ID_CTRL_TEXT_NAME_L;
	
	local equipStart = ui_card_equip_select_view.ID_CTRL_TEXT_START_L;
	
	local equipAtk = ui_card_equip_select_view.ID_CTRL_TEXT_ATK_L;
	
	local equipDef = ui_card_equip_select_view.ID_CTRL_TEXT_DEF_L;
	
	local equipSkill = ui_card_equip_select_view.ID_CTRL_TEXT_SKILL_L;
	
	local equipCardName = ui_card_equip_select_view.ID_CTRL_TEXT_CARD_NAME_L;
	
	local equipCardNameBg = ui_card_equip_select_view.ID_CTRL_PICTURE_CARD_NAME_BG_L;
	
	local equipTypeLab = ui_card_equip_select_view.ID_CTRL_TEXT_TYPE_L;

	--װ��ͼ��
	local equipPicImg = GetButton( view, equipPic );
	equipPicImg:SetId( tonumber( equip.id ));
	
	--װ������
    local equipTypeLab = GetLabel( view, equipTypeLab );
    p.SetEquipTypeText( equipTypeLab );
	
	--װ���ȼ�
	local equipLVLable = GetLabel( view, equipLV );
	equipLVLable:SetText( tostring(equip.level));
	
	--װ������
	local equipNameLable = GetLabel( view, equipName );
	equipNameLable:SetText( equip.name );
	
	--װ���Ǽ�
	local equipStartLab = GetLabel( view, equipStart );
	equipStartLab:SetText( "(" .. equip.rare .. ToUtf8( "�Ǽ�" ) .. ")");
	
	--װ��������
	local equipAtkLable = GetLabel( view, equipAtk );
	equipAtkLable:SetText( tostring(p.GetAttack( equip )));
	
	--װ��������
	local equipDefLable = GetLabel( view, equipDef );
	equipDefLable:SetText( tostring(p.GetDef( equip )));
	
	--װ������
	local equipSkillLable = GetLabel( view, equipSkill );
	equipSkillLable:SetText("not skill");
	if tonumber( equip.skill ) ~= 0 then
		equipSkillLable:SetText( tostring(equip.skill));
	end
	
	--װ����������
	local equipCardNameLable = GetLabel( view, equipCardName );
	equipCardNameLable:SetVisible( false );
	--װ���������Ʊ���
	local equipCardNameBgPic = GetImage( view ,equipCardNameBg );
	equipCardNameBgPic:SetVisible( false );
	
	-----��������------

	--�����װ������
--	if tonumber(equip.card_id) ~= 0 then
--		--װ���ڿ�����
--		equipCardNameLable:SetVisible( true );
--		equipCardNameBgPic:SetVisible( true );
--		local card = nil;
--        for k,v in ipairs( msg_cache.msg_card_box ) do
--            if v.id == equip.card_id then
--                card = v;
--            end
--        end
--		local cardname = SelectCell( T_CARD, card.card_id , "name" );
--		equipCardNameLable:SetText( tostring( cardname));
--    end	
      -----��������------
end

--����intent����װ������
function p.SetEquipTypeText( equipLab )
	if p.intent == EQUIP_INTENT_GETWEAPON then
	   equipLab:SetText( ToUtf8( "����" ));
	elseif p.intent == EQUIP_INTENT_GETARMOR then
	   equipLab:SetText( ToUtf8( "����" ));
	elseif p.intent == EQUIP_INTENT_GETORNAMENT then
	   equipLab:SetText( ToUtf8( "��Ʒ" ));
	end
end

--��ȡ���ߵ�ǰ������ֵ
function p.GetHP( item )
	--[[local add_hp_max = SelectCell( T_ITEM, item.item_id, "add_hp_max" );
	local add_hp_min = SelectCell( T_ITEM, item.item_id, "add_hp_min" );
	local level_max = SelectCell( T_ITEM, item.item_id, "level_max" );--]]
	return p.GetCurrentValue( item.add_hp_max, item.add_hp_min, item.level_max, item.level  );
end

--��ȡ���ߵ�ǰ�Ĺ�����
function p.GetAttack( item )
	--[[local add_attack_max = SelectCell( T_ITEM, item.item_id, "add_attack_max" );
	local add_attack_min = SelectCell( T_ITEM, item.item_id, "add_attack_min" );
	local level_max = SelectCell( T_ITEM, item.item_id, "level_max" );--]]
    return p.GetCurrentValue( item.add_attack_max, item.add_attack_min, item.level_max, item.level  );
end

--��ȡ���ߵ�ǰ�ķ�����
function p.GetDef( item )
	--[[local add_defence_max = SelectCell( T_ITEM, item.item_id, "add_defence_max" );
	local add_defence_min = SelectCell( T_ITEM, item.item_id, "add_defence_min" );
	local level_max = SelectCell( T_ITEM, item.item_id, "level_max" );--]]
    return p.GetCurrentValue( item.add_defence_max, item.add_defence_min, item.level_max, item.level  );
end

--��ȡװ�������Ϣ�Ĺ�ʽ
function p.GetCurrentValue( maxValue, minValue, maxLv, lv)
	local maxv = tonumber( maxValue );
	local minv = tonumber( minValue );
	local maxLv = tonumber( maxLv )
	local lv = tonumber( lv );
	local cur_value = minValue + (maxv - minv)/(maxLv - 1) * ( lv - 1)
	return math.floor( cur_value );
end

--�¼�����
function p.OnUIEventEquipList(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_equip_select.ID_CTRL_BUTTON_BACK == tag ) then	
			p.CloseUI();
			
		elseif ( ui_card_equip_select_view.ID_CTRL_BUTTON_ICON_L == tag ) then
		    p.selectItem = p.equipList[ ( uiNode:GetParent():GetId ()) * 2 - 1];
		    local itemid = uiNode:GetId();
			p.SendEquipId( itemid );
			
	    elseif ( ui_card_equip_select_view.ID_CTRL_BUTTON_ICON_R == tag) then
	        p.selectItem = p.equipList[ ( uiNode:GetParent():GetId ()) * 2 ];
            local itemid = uiNode:GetId();
            p.SendEquipId( itemid );
			
		end					
	end
end

--�������������������װ��
function p.SendEquipId( itemid )
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	local param = "&card_id=" .. tostring( p.cardid) .. "&item_id=" .. tostring( itemid );
	WriteCon( param );
	SendReq("Card","ChangeUserCardProperty", uid, param);
end


--װ�������ɹ��ص�
function p.ChangeEquipResult()
	dlg_card_equip.ReloadItemInfo(p.selectItem , p.intent);
	p.CloseUI();
end

--����ѡ��װ���б�
function p.GetSelectEquiplist()
	local t = {};
	for i=1,#p.selectIndexList do
		if p.selectIndexList[i] == 1 then
			t[#t+1] = p.Itemlist[i];
		end
	end
	p.selectItemlist = t;
	return t;
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
		p.intent = nil;
		p.caller = nil;
		p.num = 1;
		p.selectNum = 0;
		p.cardid = nil;
		p.viewList = {};
		p.selectItemlist = {};
    end
end