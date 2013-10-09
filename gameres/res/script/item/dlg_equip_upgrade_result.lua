--------------------------------------------------------------
-- FileName: 	dlg_equip_upgrade_result.lua
-- author:		zjj, 2013/08/05
-- purpose:		װ��ǿ��ȷ�Ͻ���
--------------------------------------------------------------

dlg_equip_upgrade_result = {}
local p = dlg_equip_upgrade_result;

p.layer = nil;
p.msg = nil;
p.msgResult = nil;

--��ʾUI
function p.ShowUI(msgResult)
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
    LoadDlg("dlg_equip_upgrade_result.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
	p.ShowCardInfo(msgResult);

end

function p.ShowCardInfo(msgResult)	
	p.msg = msgResult;
	--��ȡǿ��װ����Ϣ
	local equip = dlg_equip_upgrade.equip ;
	dump_obj(equip);
	local gold = dlg_equip_upgrade.gold;
	--ǿ��װ������
	local equipNameLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_EQUIP_NAME);
	equipNameLab:SetText(tostring(equip.name));
	
	--ǿ��װ���ȼ�
	local equipLVLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_LV);
	equipLVLab:SetText(tostring(msgResult.baseItem.level));
	
	--ǿ��װ��������
	local equipAtkLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_ATK);
	equipAtkLab:SetText(tostring(msgResult.baseItem.attack));
	
	--ǿ��װ��������
	local equipDefLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_DEF);
	equipDefLab:SetText(tostring(msgResult.baseItem.defence));
	
	--ǿ��װ��HP
	local equipHpLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_HP);
	equipHpLab:SetText(tostring(msgResult.baseItem.hp));
	
	--ǿ��װ������ֵ
	local equipExpLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_EXP);
	equipExpLab:SetText( tostring( msgResult.baseItem.exp ));
	
	--ǿ��װ�����Ӿ���ֵ
	local equipaddExpLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_EXP_ADD);
	equipaddExpLab:SetText( tostring( msgResult.baseItem.addExp ));
	
	--��װ��ͼ��

	--��װ������
	local equipoldNameLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_NAME_OLD);
	equipoldNameLab:SetText(tostring(equip.name));
	--��װ���ȼ�
	local equipoldLvLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_LV_OLD);
	equipoldLvLab:SetText(tostring(equip.level));
	--��װ��ͼ��
	
	--��װ������
	local equipnewNameLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_NAME_NEW);
	equipnewNameLab:SetText(tostring(equip.name));
	--��װ���ȼ�
	local equipnewLvLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_LV_NEW);
	equipnewLvLab:SetText(tostring(msgResult.baseItem.level));
	
	local costLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_COST);
	local cost = tonumber(gold) - tonumber(msgResult.gold);
	costLab:SetText(tostring( cost));
	
end

--�����¼�����
function p.SetDelegate()
	--��ҳ��ť
	local backBtn = GetButton(p.layer,ui_dlg_equip_upgrade_result.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnEquipUIEvent);

	--����ǿ����ť
	local goonBtn =  GetButton(p.layer,ui_dlg_equip_upgrade_result.ID_CTRL_BUTTON_CONTINUE);
	goonBtn:SetLuaDelegate(p.OnEquipUIEvent);

end

function p.OnEquipUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_dlg_equip_upgrade_result.ID_CTRL_BUTTON_BACK == tag ) then	
			p.CloseUI();
			dlg_equip_upgrade.CloseUI();
			dlg_item_select.CloseUI();
		elseif  ( ui_dlg_equip_upgrade_result.ID_CTRL_BUTTON_CONTINUE == tag ) then	
			if tonumber(p.msg.baseItem.level) == 7 then
				dlg_msgbox.ShowOK( ToUtf8( "��ʾ" ), ToUtf8( "��ϲ�㣬��װ���Ѿ�ǿ������ߵȼ�" ), p.OnMsgBoxTip, p.layer );
				return;
			end
			dlg_equip_upgrade.ReloadUI(p.msg);
			p.CloseUI();
		end				
	end
end


function p.OnMsgBoxTip()
	p.CloseUI();
	dlg_equip_upgrade.CloseUI();
	dlg_item_select.CloseUI();
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

