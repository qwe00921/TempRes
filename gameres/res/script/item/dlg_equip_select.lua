--------------------------------------------------------------
-- FileName: 	dlg_equip_select.lua
-- author:		zjj, 2013/07/22
-- purpose:		װ��ѡ�����
--------------------------------------------------------------

dlg_equip_select = {}
local p = dlg_equip_select;
p.layer = nil;

--������ͼ
p.intent = nil;

--���ý���
p.caller = nil;

--�ɻ�ȡװ����
p.num = 1;
--��ѡ��װ����
p.selectNum = 0;
--����װ������id
p.cardid = nil;

p.viewList = {};
--���װ��
p.Itemlist = {};
--��ѡװ���б�
p.selectItemlist = {};
p.selectItem = nil;

--�ѽ�ѡ��װ������б�
p.selectIndexList = {};

---------��ͼ----------
--EQUIP_INTENT_GETWEAPON	= 1;--ѡ������
--EQUIP_INTENT_GETARMOR		= 2;--ѡ�����
--EQUIP_INTENT_GETORNAMENT	= 3;--ѡ����Ʒ
--EQUIP_INTENT_GETLIST 		= 4;--װ��ǿ��ѡ��
---------��ͼ----------

--��ʾUI
function p.ShowUI(intent,caller, num ,cardid)
	
	local layer = createNDUIDialog();
		if layer == nil then
			return false;
    end
	layer:Init();
    
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_equip_select.xui", layer, nil);
	
	p.layer = layer;

	if intent ~= nil then
        p.intent = intent;
    end
    if caller ~= nil then
        p.caller = caller;
    end
	if num ~= nil then
        p.num = num;
    end
	if cardid ~= nil then
        p.cardid = cardid;
    end
	
	--����װ������
	equip_select_mgr.LoadAllEquip(intent);
	
	--��ʹ����ť
    p.InitShowButton( intent );

    --��ʹ������
    p.InitTitleText( intent );
end

function p.InitIndexlist(equiplist)
	for i=1,#equiplist do
		p.selectIndexList[i] = 0;
	end
end

--��ʹ������
function p.InitTitleText( intent )
    local title = GetLabel( p.layer, ui_dlg_equip_select.ID_CTRL_TEXT_TITLE);
    if EQUIP_INTENT_GETLIST == intent then
		title:SetText(GetStr("equip_select_title_intensify"));
    else
        title:SetText(GetStr("equip_select_title_change"));
    end
end

function p.InitShowButton( intent )
	--��������
	local weaponBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_WEAPON);
	weaponBtn:SetLuaDelegate(p.OnUIEventEquipList);
	--���߷���
	local armorBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_ARMOR);
	armorBtn:SetLuaDelegate(p.OnUIEventEquipList);
	--��Ʒ����
	local ornamentBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_ORNAMENT);
	ornamentBtn:SetLuaDelegate(p.OnUIEventEquipList);
	--ȫ��
	local allBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_ALL);
	allBtn:SetLuaDelegate(p.OnUIEventEquipList);
	--���ذ�ť
	local backBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_BACK);
	backBtn:SetLuaDelegate(p.OnUIEventEquipList);
	--ȷ�ϰ�ť
	local okBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_OK);
	okBtn:SetLuaDelegate(p.OnUIEventEquipList);
	okBtn:SetEnabled( false );
	
	if intent ~= nil then
		if intent == EQUIP_INTENT_GETWEAPON then
			armorBtn:SetEnabled( false );
			ornamentBtn:SetEnabled( false );
			allBtn:SetEnabled( false );
		elseif intent == EQUIP_INTENT_GETARMOR then
			weaponBtn:SetEnabled( false );
			ornamentBtn:SetEnabled( false );
			allBtn:SetEnabled( false );
		elseif intent == EQUIP_INTENT_GETORNAMENT then
			weaponBtn:SetEnabled( false );
			armorBtn:SetEnabled( false );
			allBtn:SetEnabled( false );
		end
	end	
end

--��ʾ���ص�װ��
function p.ShowEquipList( equipList )
	p.InitIndexlist(equipList);
	local list = GetListBoxVert(p.layer ,ui_dlg_equip_select.ID_CTRL_VERTICAL_LIST_EQUIP);
	list:ClearView();
	p.Itemlist = equipList;
	if equipList == nil or #equipList <= 0 then
        WriteCon("ShowEquipList():equipList is null");
        return ;
    end
	
	--װ������
	local equipNum = #equipList;
	
	for i = 1,equipNum do
		local view = createNDUIXView();
        view:Init();
        LoadUI( "equip_list_view.xui", view, nil );
		local bg = GetUiNode( view, ui_equip_list_view.ID_CTRL_BUTTON_BG );
		view:SetViewSize( bg:GetFrameSize());
		view:EnableSelImage(true);
		view:SetLuaDelegate(p.OnViewEvent);
		view:SetId(i);
		
		local equip = equipList[i];		
		p.viewList[i] = view;
		p.SetEquipInfo(view ,equip);
		list:AddView( view );
	end
end

--����װ����Ϣ
function p.SetEquipInfo(view ,equip)
	
	local equipPic = ui_equip_list_view.ID_CTRL_PICTURE_EQUIP;
	local equipLV = ui_equip_list_view.ID_CTRL_TEXT_LV;
	local equipName = ui_equip_list_view.ID_CTRL_TEXT_NAME;
	local equipStart = ui_equip_list_view.ID_CTRL_PICTURE_START;
	local equipAtk = ui_equip_list_view.ID_CTRL_TEXT_ATK;
	local equipDef = ui_equip_list_view.ID_CTRL_TEXT_DEF;
	local equipHp = ui_equip_list_view.ID_CTRL_TEXT_HP;
	local equipSkill = ui_equip_list_view.ID_CTRL_TEXT_SKILL;
	local equipCardName = ui_equip_list_view.ID_CTRL_TEXT_CARDNAME;
	local equipCardLv = ui_equip_list_view.ID_CTRL_TEXT_CARDLV;
	local equipCardId = ui_equip_list_view.ID_CTRL_TEXT_CARDID;
	local equipNO = ui_equip_list_view.ID_CTRL_PICTURE_NOEQUIP;

	--װ��ͼ��
	local equipPicImg = GetImage( view, equipPic );
	--װ���ȼ�
	local equipLVLable = GetLabel( view, equipLV );
	equipLVLable:SetText( tostring(equip.level));
	--װ������
	local equipNameLable = GetLabel( view, equipName );
	equipNameLable:SetText( equip.name );
	--װ���Ǽ�
	local equipStartImg = GetImage( view, equipStart );
	--װ��������
	local equipAtkLable = GetLabel( view, equipAtk );
	equipAtkLable:SetText( tostring(p.GetAttack( equip )));
	--װ��������
	local equipDefLable = GetLabel( view, equipDef );
	equipDefLable:SetText( tostring(p.GetDef( equip )));
	--װ��������
	local equipHpLable = GetLabel( view, equipHp );
	equipHpLable:SetText( tostring( p.GetHP( equip )));
	--װ������
	local equipSkillLable = GetLabel( view, equipSkill );
	equipSkillLable:SetText("not skill");
	if equip.skill ~= nil then
		equipSkillLable:SetText( tostring(equip.skill));
	end
	p.SetCheckboxImg(view,false);
	--�����װ������
	if tonumber(equip.card_id) ~= nil then
		local card = nil;
		for k,v in ipairs( msg_cache.msg_card_box ) do
			if v.id == equip.card_id then
				card = v;
			end
        end
		--װ���ڿ�����
		local equipCardNameLable = GetLabel( view, equipCardName );
		local cardname = SelectCell( T_CARD, card.card_id, "name" );
		equipCardNameLable:SetText( tostring( cardname));
		--���Ƶȼ�
		local equipCardLvLable = GetLabel( view, equipCardLv );
		equipCardLvLable:SetText( tostring( card.level));
		--����ID
		local equipCardIdLable = GetLabel( view, equipCardId );
		equipCardIdLable:SetText( tostring( card.card_id) );
		--δװ����ʾ
		local equipNOImg = GetImage(view, equipNO);
		equipNOImg:SetVisible( false );
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
        if ( ui_dlg_equip_select.ID_CTRL_BUTTON_BACK == tag ) then	
			p.CloseUI();
		elseif ( ui_dlg_equip_select.ID_CTRL_BUTTON_OK == tag ) then	
			--��Ϊ����װ����ͼ
			if p.intent ~= EQUIP_INTENT_GETLIST then
				p.SendEquipId();
				return;
			end
			--��Ϊѡ��ǿ��װ���ز���ͼ
			p.caller.LoadSelectItemData( p.GetSelectEquiplist() , nil );
			p.CloseUI();
		end					
	end
end

--�������������������װ��
function p.SendEquipId()
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	local item_id = nil;
	p.GetSelectEquiplist();
	for k,v in ipairs( p.selectItemlist ) do
		if v ~= nil then
			p.selectItem = v;
        end
	end
	local param = "&card_id=" .. tostring( p.cardid) .. "&item_id=" .. tostring(p.selectItem.id);
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

--���ѡ��װ���¼�
function p.OnViewEvent(uiNode, uiEventType, param)
	local view = ConverToView(uiNode);
	if  IsClickEvent(uiEventType) then
		if p.selectIndexList[uiNode:GetId()] == 0 then
			if p.CanSelectEquip() then
				p.selectIndexList[uiNode:GetId()] = 1;
				p.selectNum = p.selectNum + 1;
				p.SetCheckboxImg( uiNode , true);
			end
		elseif p.selectIndexList[uiNode:GetId()] == 1 then
			p.selectIndexList[uiNode:GetId()] = 0;
			p.selectNum = p.selectNum - 1;
			p.SetCheckboxImg( uiNode , false);
		end	
	end
	local okBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_OK);
	okBtn:SetEnabled( false );
	if p.selectNum > 0 then --��װ����ѡ��
	okBtn:SetEnabled( true );
	end
end

function p.SetCheckboxImg( view, bEnable)
	local ChenckboxImg = GetImage(view, ui_equip_list_view.ID_CTRL_PICTURE_CHECK);
	ChenckboxImg:SetVisible(bEnable );
end

--�ж�����ȷ�ϰ�ť�Ƿ�ɵ��
function p.CheckandSetBtnSetEnabled()
	local okBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_OK);
	if p.selectNum >= 1 then
	    okBtn:SetEnabled( true );   
		return;
	end
	okBtn:SetEnabled( false );
end

function p.CanSelectEquip()
	if p.selectNum < p.num then
		return true;
	end
	return false;
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