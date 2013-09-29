--------------------------------------------------------------
-- FileName: 	dlg_equip_upgrade.lua
-- author:		zjj, 2013/08/05
-- purpose:		装备强化界面
--------------------------------------------------------------

dlg_equip_upgrade = {}
local p = dlg_equip_upgrade;

p.layer = nil;
p.equip = nil;

--素材存放列表
p.selectItemlist = {};

--用于判断选择物品剩余数
SELECT_EQUIP = 1;
SELECT_ITEM  = 2;

--存放素材数量文本
p.numLablist = {};
--存放素材图标图片
p.iconImglist = {};
--存放药品数量
p.itemNum = {0,0,0};
--存放玩家金币
p.gold = nil;
--判断时候强化过
p.isGo = false;

--显示UI
function p.ShowUI(equip)   
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
    LoadDlg("dlg_equip_upgrade.xui", layer, nil);
	
	p.layer = layer;
	p.equip = equip;
	p.SetDelegate();
	p.LoadItemData();
	p.LoadGoldData();
	p.ShowEquipInfo(equip);
end

--显示强化装备信息
function p.ShowEquipInfo(equip)	
	--强化装备图标
	local equipPicImg = GetImage( p.layer, ui_dlg_equip_upgrade.ID_CTRL_PICTURE_EQUIP );
	
	--强化装备名称
	local equipNameLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_EQUIP_NAME);
	equipNameLab:SetText(tostring(equip.name));
	
	--强化装备星级
	local equipStarImg = GetImage( p.layer, ui_dlg_equip_upgrade.ID_CTRL_PICTURE_EQUIP_STAR );
	
	--强化装备攻击力
	local equipAtkLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_EQUIP_ATK);
	equipAtkLab:SetText(tostring(p.GetAttack( equip )));
	
	--强化装备防御力
	local equipDefLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_EQUIP_DEF);
	equipDefLab:SetText(tostring(p.GetDef( equip )));
	
	--强化装备HP
	local equipHpLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_EQUIP_HP);
	equipHpLab:SetText(tostring(p.GetHP( equip )));
	
	--强化装备经验值
	local equipExpLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_EQUIP_EXP);
	equipExpLab:SetText( tostring( equip.exp ));

	--强化素材数量1
	local numLab1 = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_ITEMNUM1);
	p.numLablist[1] = numLab1;
	--强化素材数量2
	local numLab2 = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_ITEMNUM2);
	p.numLablist[2] = numLab2;
	--强化素材数量3
	local numLab3 = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_ITEMNUM3);
	p.numLablist[3] = numLab3;
	--强化素材数量4
	local numLab4 = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_ITEMNUM4);
	p.numLablist[4] = numLab4;
	
	--强化素材图标1
	local iconImg1 = GetImage( p.layer, ui_dlg_equip_upgrade.ID_CTRL_PICTURE_ITEM1 );
	p.iconImglist[1] = iconImg1;
	--强化素材图标2
	local iconImg2 = GetImage( p.layer, ui_dlg_equip_upgrade.ID_CTRL_PICTURE_ITEM2 );
	p.iconImglist[2] = iconImg2;
	--强化素材图标3
	local iconImg3 = GetImage( p.layer, ui_dlg_equip_upgrade.ID_CTRL_PICTURE_ITEM3 );
	p.iconImglist[3] = iconImg3;
	--强化素材图标4
	local iconImg4 = GetImage( p.layer, ui_dlg_equip_upgrade.ID_CTRL_PICTURE_ITEM4 );
	p.iconImglist[4] = iconImg4;
end

--读取强化装备药品数据
function p.LoadItemData()
	if not p.isGo then
		--如果第一次强化没有数据从cache中读取三种药品的数量
		for k, v in ipairs(msg_cache.msg_back_pack.user_items) do
			if v.item_id == "1300"  then
				p.itemNum[1] = p.itemNum[1] + tonumber(v.num);
			elseif v.item_id == "1301"  then
				p.itemNum[2] = p.itemNum[2] + tonumber(v.num);
			elseif v.item_id == "1302"  then
				p.itemNum[3] = p.itemNum[3] + tonumber(v.num);
			end		
		end
	end
end

--读取玩家金币数据
function p.LoadGoldData()
	if p.gold == nil then
		--如果第一次强化没有数据从cache中读取玩家金币
		p.gold = msg_cache.msg_player.gold;
	end
end

--设置事件处理
function p.SetDelegate()
	--首页按钮
	local backBtn = GetButton(p.layer,ui_dlg_equip_upgrade.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local getEquipBtn = GetButton(p.layer,ui_dlg_equip_upgrade.ID_CTRL_BUTTON_EQUIPSELECT);
    getEquipBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local getItemBtn = GetButton(p.layer,ui_dlg_equip_upgrade.ID_CTRL_BUTTON_ITEMSELECT);
    getItemBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local startBtn = GetButton(p.layer,ui_dlg_equip_upgrade.ID_CTRL_BUTTON_START);
    startBtn:SetLuaDelegate(p.OnEquipUIEvent);
	startBtn:SetEnabled( false );

end

function p.OnEquipUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_dlg_equip_upgrade.ID_CTRL_BUTTON_BACK == tag ) then	
			dlg_item_select.CloseUI();
			p.CloseUI();			
		elseif ( ui_dlg_equip_upgrade.ID_CTRL_BUTTON_EQUIPSELECT == tag ) then	
			equip_select_mgr.delequipid = p.equip.id;
			dlg_equip_select.ShowUI( EQUIP_INTENT_GETLIST , dlg_equip_upgrade , p.GetCanSelectNum( SELECT_EQUIP ), nil);
			
		elseif ( ui_dlg_equip_upgrade.ID_CTRL_BUTTON_ITEMSELECT == tag ) then	
			dlg_item_select.ShowUI(p.GetCanSelectNum( SELECT_ITEM ), p.itemNum ,dlg_equip_upgrade);
			
		elseif ( ui_dlg_equip_upgrade.ID_CTRL_BUTTON_START == tag ) then
			if tonumber(p.GetCostMoney()) > tonumber(p.gold ) then
				p.MsgBox(p.layer);
				return;
			end
			p.ReqAddPower();
		end				
	end
end


--金币不足提示框
function p.MsgBox(layer)
	dlg_msgbox.ShowOK( GetStr( "msg_title_tips" ), GetStr( "gold_is_not_enough_for_upgrade_equip" ), p.OnMsgBoxCallback , layer );
end

--消息框回调
function p.OnMsgBoxCallback( result )

end

--判断可以选择几种素材
function p.GetCanSelectNum( item )
	local num = 0 ;
	if p.selectItemlist ~= nil then
		if item == SELECT_ITEM then
			for i=1, #p.selectItemlist do
				if p.selectItemlist[i].type ~= SELECT_ITEM then
					num = num + 1;
				end
			end 
		return 4-num;
		elseif item == SELECT_EQUIP then
			for i=1,#p.selectItemlist do
				if p.selectItemlist[i].type == SELECT_ITEM then
					num = num + 1;
				end 
			end
			return 4-num;	
		end	
	end
	return 4;
end

--获取道具当前的生命值
function p.GetHP( item )
	return p.GetCurrentValue( item.add_hp_max, item.add_hp_min, item.level_max, item.level  );
end

--获取道具当前的攻击力
function p.GetAttack( item )
    return p.GetCurrentValue( item.add_attack_max, item.add_attack_min, item.level_max, item.level  );
end

--获取道具当前的防御力
function p.GetDef( item )
    return p.GetCurrentValue( item.add_defence_max, item.add_defence_min, item.level_max, item.level  );
end

--获取装备相关信息的公式
function p.GetCurrentValue( maxValue, minValue, maxLv, lv)
	local maxv = tonumber( maxValue );
	local minv = tonumber( minValue );
	local maxLv = tonumber( maxLv )
	local lv = tonumber( lv );
	local cur_value = minv + (maxv - minv)/(maxLv - 1) * ( lv - 1)
	return math.floor( cur_value );
end

--强化请求
function p.ReqAddPower()
	WriteCon("**发送强化装备请求**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end; 
	local medicineStr = ""; --药品素材参数
	local equipIds = ""; -- 装备素材参数
	local t = {};
	local k = {};
	for i=1,#p.selectItemlist do
		if p.selectItemlist[i].type ~= 2 then 
			t[#t + 1] = p.selectItemlist[i];
		else
			k[#k + 1] = p.selectItemlist[i];
		end
	end
	for i=1,#t do
		if i == #t then
			medicineStr = medicineStr .. tostring(t[i].item_id) .. ":" .. tostring(t[i].itemNum);
		else 
			medicineStr = medicineStr .. tostring(t[i].item_id) .. ":" .. tostring(t[i].itemNum) .. ",";
		end	
	end
	for i=1,#k do
		if i == #k then
			equipIds = equipIds .. tostring(k[i].id) ;
		else 
			equipIds = equipIds .. tostring(k[i].id) .. ",";
		end	
	end
	local param ="&baseItemId="..tostring(p.equip.id).."&deItemStr="..medicineStr .. "&malItemIds=" .. equipIds ;
	SendReq("Item","AddPower", uid, param);
end

--计算花费
function p.GetCostMoney()
	local level = p.equip.level;
	local needmoney = tonumber(SelectCellMatch( T_EQUIPMENT_GROW, "level", level, "need_money" ));
	local num = 0;
	for i=1,#p.selectItemlist do
		if p.selectItemlist[i].type == 2 then
			num = num + p.selectItemlist[i].itemNum;
		else
			num = num + 1;
		end
	end
	return num * needmoney;
end

--设置强化花费
function p.SetCostLab()
	local costLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_MONEY);
	costLab:SetText(tostring(p.GetCostMoney()));
end

--载入素材列表
function p.LoadSelectItemData(equiplist, item_type)
	WriteCon("**装备素材数量"  .. #equiplist);
	local t = {};
	for i=1,#p.selectItemlist do
		if item_type == nil then
			--剔除装备
			if p.selectItemlist[i].type ==  ITEM_TYPE_8 then
				t[#t + 1] = p.selectItemlist[i];
			end
		elseif item_type == ITEM_TYPE_8 then
			--剔除药品
			if p.selectItemlist[i].type ~= ITEM_TYPE_8 then
				t[#t + 1] = p.selectItemlist[i];
			end
		end	
	end	
	
	if equiplist == nil then
		p.selectItemlist = t;
		return;
	end
	
	for i=1,#equiplist do
		t[#t + 1] = equiplist[i];
	end	
	p.selectItemlist = t;
	p.RefreshItem();
	p.SetCostLab();
	local startBtn = GetButton(p.layer,ui_dlg_equip_upgrade.ID_CTRL_BUTTON_START);
	startBtn:SetEnabled( false );
	if #p.selectItemlist > 0 then
		local startBtn = GetButton(p.layer,ui_dlg_equip_upgrade.ID_CTRL_BUTTON_START);
		startBtn:SetEnabled( true );
	end
end

function p.RefreshItem()
	--重置数字
	for i=1,4 do
		p.numLablist[i]:SetText("");
		p.iconImglist[i]:SetPicture(nil);
	end
	--刷新数字
	for i=1,#p.selectItemlist do	
		p.numLablist[i]:SetText("ZB");
		p.iconImglist[i]:SetPicture( GetPictureByAni("item.item_icon", 3));
		if p.selectItemlist[i] ~= nil and p.selectItemlist[i].type == ITEM_TYPE_8 then
			p.numLablist[i]:SetText( tostring( p.selectItemlist[i].itemNum));
			if tonumber(p.selectItemlist[i].item_id) == 1300 then
				p.iconImglist[i]:SetPicture( GetPictureByAni("item.item_icon", 0));
			elseif tonumber(p.selectItemlist[i].item_id) == 1301 then
				p.iconImglist[i]:SetPicture( GetPictureByAni("item.item_icon", 1));
			elseif tonumber(p.selectItemlist[i].item_id) == 1302 then
				p.iconImglist[i]:SetPicture( GetPictureByAni("item.item_icon", 2));
			end
		end	
	end
end

--重载界面
function p.ReloadUI(msgResult)
	
	local startBtn = GetButton(p.layer,ui_dlg_equip_upgrade.ID_CTRL_BUTTON_START);
	startBtn:SetEnabled( false );
	--刷新装备数值
	--修改装备等级
	p.equip.level = msgResult.baseItem.level;
	--强化装备图标
	local equipPicImg = GetImage( p.layer, ui_dlg_equip_upgrade.ID_CTRL_PICTURE_EQUIP );
	
	--强化装备名称
	local equipNameLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_EQUIP_NAME);
	equipNameLab:SetText(tostring(p.equip.name));
	
	--强化装备星级
	local equipStarImg = GetImage( p.layer, ui_dlg_equip_upgrade.ID_CTRL_PICTURE_EQUIP_STAR );
	
	--强化装备攻击力
	local equipAtkLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_EQUIP_ATK);
	equipAtkLab:SetText(tostring(msgResult.baseItem.attack));
	
	--强化装备防御力
	local equipDefLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_EQUIP_DEF);
	equipDefLab:SetText(tostring(msgResult.baseItem.defence));
	
	--强化装备HP
	local equipHpLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_EQUIP_HP);
	equipHpLab:SetText(tostring(msgResult.baseItem.hp));
	
	--强化装备经验值
	local equipExpLab = GetLabel( p.layer , ui_dlg_equip_upgrade.ID_CTRL_TEXT_EQUIP_EXP);
	equipExpLab:SetText(tostring(msgResult.baseItem.exp));
	
	--清空数据
	p.selectItemlist = {};
	--重置数字、图标
	for i=1,4 do
		p.numLablist[i]:SetText("");
		p.iconImglist[i]:SetPicture(nil);
	end
	--设置剩余药品数量
	p.isGo = true;
	for i=1,3 do
		if msgResult.deItems[i] ~= nil then
			p.itemNum[i] = msgResult.deItems[i].item_num;
		end	
	end
	
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

