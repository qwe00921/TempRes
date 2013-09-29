--------------------------------------------------------------
-- FileName: 	dlg_card_equip.lua
-- author:		zjj, 2013/07/30
-- purpose:		�����������
--------------------------------------------------------------

dlg_card_equip = {}
local p = dlg_card_equip;

p.layer = nil;
p.card = nil;
p.carditems = {};

p.RemoveEquipTpye = nil;
--��ʾUI
function p.ShowUI(card)
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_card_equip.xui", layer, nil);
	
	p.layer = layer;
	p.card = card;
	p.SetDelegate();
	p.ShowCardInfo(card);
	p.LoadCardEquipData();

end

--��ʼ��������װ���ȼ�PIC
function p.HideEquipLvPic()
	local lvPic1 = GetImage( p.layer,ui_dlg_card_equip.ID_CTRL_PICTURE_EQUIP_LV_1 );
	local lvPic2 = GetImage( p.layer,ui_dlg_card_equip.ID_CTRL_PICTURE_EQUIP_LV_2 );
	local lvPic3 = GetImage( p.layer,ui_dlg_card_equip.ID_CTRL_PICTURE_EQUIP_LV_3 );
	lvPic1:SetVisible( false );
	lvPic2:SetVisible( false );
	lvPic3:SetVisible( false );
end

function p.ShowCardInfo( card )
    dump_obj( card );
	if card ~= nil then
		--��ƬͼƬ
		local cardPic = GetImage( p.layer,ui_dlg_card_equip.ID_CTRL_PICTURE_CARD );
		local pic = GetCardPicById( card.card_id );
		if pic ~= nil then
			cardPic:SetPicture( pic );
		end
		
		--��Ƭ����
		local cardNameLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_CARDNAME);
		local cardName = SelectCell( T_CARD, card.card_id, "name" );
		cardNameLab:SetText( tostring(cardName));
		--�ȼ�
		local cardLvLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_CARDLV);
		cardLvLab:SetText(tostring(card.level));
		--HP
		local cardHpLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_CARDHP);
		cardHpLab:SetText(tostring(card.hp));
		--������
		local cardAtkLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_CARDATK);
		cardAtkLab:SetText(tostring(card.attack));
		--������
		local cardDefLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_CARDDEF);
		cardDefLab:SetText(tostring(card.defence));
	    --��������
	    local skillNameLab = GetLabel( p.layer, ui_dlg_card_equip.ID_CTRL_TEXT_SKILL_NAME );
	    --����˵��
	    local skillDescriptionLab = GetLabel( p.layer, ui_dlg_card_equip.ID_CTRL_TEXT_SKILL_DESCRIPTION );
	    
	    local skill_id = SelectCell( T_CARD, card.card_id, "skill" );
        if skill_id ~= "0" then
            skillNameLab:SetText( SelectCell( T_SKILL, skill_id, "name" ));
            skillDescriptionLab:SetText( SelectCell( T_SKILL, skill_id, "description" ));
        end
	end		
end

--��ʾ����װ����Ϣ
function p.ShowEquipInfo(carditems)
	
	p.carditems = carditems;
	local weapon = carditems.weapon;
	if weapon ~= nil then
--		WriteCon("**������**");
		--����ͼ��  
		local weaponIconBtn = GetButton( p.layer, ui_dlg_card_equip.ID_CTRL_BUTTON_WUQI);
		weaponIconBtn:SetImage(GetPictureByAni("item.item_db", 9));
		
		--�����ȼ�
		local weaponLVLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_WEAPON_LV);
		weaponLVLab:SetText(tostring(weapon.level));
		
		--������
		local weaponNameLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_WEAPON_NAME);
		local name = SelectCell( T_ITEM, weapon.item_id, "name" );
		weaponNameLab:SetText(tostring(name));
		
		local lvPic1 = GetImage( p.layer,ui_dlg_card_equip.ID_CTRL_PICTURE_EQUIP_LV_1 );
        lvPic1:SetVisible( true );
	end
		
	-----------------------------------------------------------------------
	local armor = carditems.armor;
	if armor ~= nil then
--		WriteCon("**�з���**");
		--����ͼ��
		local armorIconBtn =  GetButton( p.layer, ui_dlg_card_equip.ID_CTRL_BUTTON_FANGJU);
		armorIconBtn:SetImage(GetPictureByAni("item.item_db", 9));
		
		--���ߵȼ�
		local armorLVLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_ARMOR_LV);
		armorLVLab:SetText(tostring(armor.level));
		
		--������
		local armorNameLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_ARMOR_NAME);
		local name = SelectCell( T_ITEM, armor.item_id, "name" )
		armorNameLab:SetText(tostring(name));
		
		local lvPic2 = GetImage( p.layer,ui_dlg_card_equip.ID_CTRL_PICTURE_EQUIP_LV_2 );
        lvPic2:SetVisible( true );
	end	
	
	------------------------------------------------------------------------
	local jewelry = carditems.jewelry;
	if jewelry ~= nil then
--		WriteCon("**����Ʒ**");
		--��Ʒͼ��
		local jewelryIconBtn =  GetButton( p.layer, ui_dlg_card_equip.ID_CTRL_BUTTON_SHIPIN);
		jewelryIconBtn:SetImage(GetPictureByAni("item.item_db", 9));
		
		--��Ʒ�ȼ�
		local jewelryLVLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_ORNAMENT_LV);
		jewelryLVLab:SetText(tostring(jewelry.level));
		
		--��Ʒ��
		local jewelryHpLab = GetLabel(p.layer,ui_dlg_card_equip.ID_CTRL_TEXT_ORNAMENT_NAME);
		local name = SelectCell( T_ITEM, jewelry.item_id, "name" );
		jewelryHpLab:SetText(tostring(name));
		
		local lvPic3 = GetImage( p.layer,ui_dlg_card_equip.ID_CTRL_PICTURE_EQUIP_LV_3 );
        lvPic3:SetVisible( true );
	end
end



function p.LoadCardEquipData()
	WriteCon("**���뿨��װ���б�**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	local param = "&card_id=" .. tostring(p.card.id );
	SendReq("Card","GetUserCardProperty", uid, param);

end


--�����¼�����
function p.SetDelegate()
	--���ذ�ť
	local backBtn = GetButton(p.layer,ui_dlg_card_equip.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	--��������
	local CweaponBtn = GetButton(p.layer, ui_dlg_card_equip.ID_CTRL_BUTTON_WUQI);
	CweaponBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	
	--��������
	local CarmorBtn = GetButton(p.layer, ui_dlg_card_equip.ID_CTRL_BUTTON_FANGJU);
	CarmorBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
		
	--������Ʒ
	local CornamentBtn = GetButton(p.layer, ui_dlg_card_equip.ID_CTRL_BUTTON_SHIPIN);
	CornamentBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	p.HideEquipLvPic();
end

function p.OnEquipUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_dlg_card_equip.ID_CTRL_BUTTON_BACK == tag ) then	
			p.CloseUI();
		elseif (ui_dlg_card_equip.ID_CTRL_BUTTON_WUQI == tag) then --ѡ������
			dlg_card_equip_select.ShowUI(EQUIP_INTENT_GETWEAPON, dlg_card_equip, p.card.id );
			
		elseif (ui_dlg_card_equip.ID_CTRL_BUTTON_FANGJU == tag) then --ѡ�����
			dlg_card_equip_select.ShowUI(EQUIP_INTENT_GETARMOR, dlg_card_equip, p.card.id);
			
		elseif (ui_dlg_card_equip.ID_CTRL_BUTTON_SHIPIN == tag) then --ѡ����Ʒ
			dlg_card_equip_select.ShowUI(EQUIP_INTENT_GETORNAMENT, dlg_card_equip,  p.card.id);
		
		end				
	end
end
	

--��ȡ���ߵ�ǰ������ֵ
function p.GetHP( item )
	local add_hp_max = SelectCell( T_ITEM, item.item_id, "add_hp_max" );
	local add_hp_min = SelectCell( T_ITEM, item.item_id, "add_hp_min" );
	local level_max = SelectCell( T_ITEM, item.item_id, "level_max" );
	return p.GetCurrentValue( add_hp_max, add_hp_min, level_max, item.level  );
end

--��ȡ���ߵ�ǰ�Ĺ�����
function p.GetAttack( item )
	local add_attack_max = SelectCell( T_ITEM, item.item_id, "add_attack_max" );
	local add_attack_min = SelectCell( T_ITEM, item.item_id, "add_attack_min" );
	local level_max = SelectCell( T_ITEM, item.item_id, "level_max" );
    return p.GetCurrentValue( add_attack_max, add_attack_min, level_max, item.level  );
end

--��ȡ���ߵ�ǰ�ķ�����
function p.GetDef( item )
	local add_defence_max = SelectCell( T_ITEM, item.item_id, "add_defence_max" );
	local add_defence_min = SelectCell( T_ITEM, item.item_id, "add_defence_min" );
	local level_max = SelectCell( T_ITEM, item.item_id, "level_max" );
    return p.GetCurrentValue( add_defence_max, add_defence_min, level_max, item.level  );
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

--���ظı����
function p.ReloadItemInfo(selectItem , intent)
	if intent == EQUIP_INTENT_GETWEAPON then
		p.carditems.weapon = selectItem;
	elseif intent == EQUIP_INTENT_GETARMOR then
		p.carditems.armor = selectItem;
	elseif intent == EQUIP_INTENT_GETORNAMENT then
		p.carditems.jewelry = selectItem;
	end
	p.ShowEquipInfo(p.carditems);
end

--���ÿɼ�
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end


function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end

end

