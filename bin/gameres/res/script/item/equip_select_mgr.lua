--------------------------------------------------------------
-- FileName: 	equip_select_mgr.lua
-- author:		zjj, 2013/08/01
-- purpose:		装备选择管理器
--------------------------------------------------------------

equip_select_mgr = {}
local p = equip_select_mgr;

p.intent = nil;
p.equipList = {};

--屏蔽装备信息
p.delequipid = nil;

--加载所有装备信息 
function p.LoadAllEquip( intent )
	if intent ~= nil then
		p.intent = intent;
	end
	
	--WriteCon("**请求装备数据**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	--发起请求
	local param = "&item_type=equip";
	SendReq("Equip", "GetUserKindItems" , uid , param);
	
end

--装备请求回调，显示装备列表
function p.RefershUI( datalist )
	if datalist == nil then
		WriteCon(" equip_select_mgr:dataList is null");
		return
	end
	p.equipList = datalist;
	--武器
	if p.intent == EQUIP_INTENT_GETWEAPON then
        p.equipList = p.LoadEquipByCategory( EQUIP_WEAPON );
	--防具
    elseif p.intent == EQUIP_INTENT_GETARMOR then
        p.equipList = p.LoadEquipByCategory( EQUIP_ARMOR );
	--饰品
    elseif p.intent == EQUIP_INTENT_GETORNAMENT then
        p.equipList = p.LoadEquipByCategory( EQUIP_JEWELRY );     
    end
	--删除强化装备本身
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

--加载某一分类的装备
function p.LoadEquipByCategory( category )
	--加载某一类型装备
    local equipList = p.GetEquipList( category );
	return equipList;
end

--获取某一类型装备
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
