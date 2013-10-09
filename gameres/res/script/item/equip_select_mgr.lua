--------------------------------------------------------------
-- FileName: 	equip_select_mgr.lua
-- author:		zjj, 2013/08/01
-- purpose:		װ��ѡ�������
--------------------------------------------------------------

equip_select_mgr = {}
local p = equip_select_mgr;

p.intent = nil;
p.equipList = {};

--����װ����Ϣ
p.delequipid = nil;

--��������װ����Ϣ 
function p.LoadAllEquip( intent )
	if intent ~= nil then
		p.intent = intent;
	end
	
	--WriteCon("**����װ������**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	--��������
	local param = "&item_type=equip";
	SendReq("Equip", "GetUserKindItems" , uid , param);
	
end

--װ������ص�����ʾװ���б�
function p.RefershUI( datalist )
	if datalist == nil then
		WriteCon(" equip_select_mgr:dataList is null");
		return
	end
	p.equipList = datalist;
	--����
	if p.intent == EQUIP_INTENT_GETWEAPON then
        p.equipList = p.LoadEquipByCategory( EQUIP_WEAPON );
	--����
    elseif p.intent == EQUIP_INTENT_GETARMOR then
        p.equipList = p.LoadEquipByCategory( EQUIP_ARMOR );
	--��Ʒ
    elseif p.intent == EQUIP_INTENT_GETORNAMENT then
        p.equipList = p.LoadEquipByCategory( EQUIP_JEWELRY );     
    end
	--ɾ��ǿ��װ������
	if p.delequipid ~= nil then
		for k, v in ipairs(p.equipList) do
            if tonumber( v.id ) == tonumber(p.delequipid ) then
                table.remove( p.equipList, k);
                break ;
            end
        end
	end
	if p.intent ~= EQUIP_INTENT_GETLIST then
	   dlg_card_equip_select.ShowEquipList( p.equipList );
	   return;
	end
	dlg_equip_select.ShowEquipList( p.equipList );
end

--����ĳһ�����װ��
function p.LoadEquipByCategory( category )
	--����ĳһ����װ��
    local equipList = p.GetEquipList( category );
	return equipList;
end

--��ȡĳһ����װ��
function p.GetEquipList( category )	
    if p.equipList == nil or #p.equipList <= 0 then
        return nil;
    end
    local t = {};
    for k,v in ipairs(p.equipList) do
        if tonumber(v.type) == category then
            t[#t+1] = v;
        end
    end
    return t;
end
