--------------------------------------------------------------
-- FileName: 	dlg_equip_upgrade_result.lua
-- author:		zjj, 2013/08/05
-- purpose:		装备强化确认界面
--------------------------------------------------------------

dlg_equip_upgrade_result = {}
local p = dlg_equip_upgrade_result;

p.layer = nil;
p.msg = nil;
p.msgResult = nil;

--显示UI
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
	--获取强化装备信息
	local equip = dlg_equip_upgrade.equip ;
	dump_obj(equip);
	local gold = dlg_equip_upgrade.gold;
	--强化装备名称
	local equipNameLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_EQUIP_NAME);
	equipNameLab:SetText(tostring(equip.name));
	
	--强化装备等级
	local equipLVLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_LV);
	equipLVLab:SetText(tostring(msgResult.baseItem.level));
	
	--强化装备攻击力
	local equipAtkLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_ATK);
	equipAtkLab:SetText(tostring(msgResult.baseItem.attack));
	
	--强化装备防御力
	local equipDefLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_DEF);
	equipDefLab:SetText(tostring(msgResult.baseItem.defence));
	
	--强化装备HP
	local equipHpLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_HP);
	equipHpLab:SetText(tostring(msgResult.baseItem.hp));
	
	--强化装备经验值
	local equipExpLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_EXP);
	equipExpLab:SetText( tostring( msgResult.baseItem.exp ));
	
	--强化装备增加经验值
	local equipaddExpLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_EXP_ADD);
	equipaddExpLab:SetText( tostring( msgResult.baseItem.addExp ));
	
	--旧装备图标

	--旧装备名字
	local equipoldNameLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_NAME_OLD);
	equipoldNameLab:SetText(tostring(equip.name));
	--旧装备等级
	local equipoldLvLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_LV_OLD);
	equipoldLvLab:SetText(tostring(equip.level));
	--新装备图标
	
	--新装备名字
	local equipnewNameLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_NAME_NEW);
	equipnewNameLab:SetText(tostring(equip.name));
	--新装备等级
	local equipnewLvLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_LV_NEW);
	equipnewLvLab:SetText(tostring(msgResult.baseItem.level));
	
	local costLab = GetLabel( p.layer , ui_dlg_equip_upgrade_result.ID_CTRL_TEXT_COST);
	local cost = tonumber(gold) - tonumber(msgResult.gold);
	costLab:SetText(tostring( cost));
	
end

--设置事件处理
function p.SetDelegate()
	--首页按钮
	local backBtn = GetButton(p.layer,ui_dlg_equip_upgrade_result.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnEquipUIEvent);

	--继续强化按钮
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
				dlg_msgbox.ShowOK( ToUtf8( "提示" ), ToUtf8( "恭喜你，该装备已经强化到最高等级" ), p.OnMsgBoxTip, p.layer );
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



--设置可见
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

