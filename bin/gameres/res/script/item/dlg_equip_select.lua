--------------------------------------------------------------
-- FileName: 	dlg_equip_select.lua
-- author:		zjj, 2013/07/22
-- purpose:		装备选择界面
--------------------------------------------------------------

dlg_equip_select = {}
local p = dlg_equip_select;
p.layer = nil;

--调用意图
p.intent = nil;

--调用界面
p.caller = nil;

--可获取装备数
p.num = 1;
--已选择装备数
p.selectNum = 0;
--更换装备卡牌id
p.cardid = nil;

p.viewList = {};
--存放装备
p.Itemlist = {};
--已选装备列表
p.selectItemlist = {};
p.selectItem = nil;

--已近选择装备存放列表
p.selectIndexList = {};

---------意图----------
--EQUIP_INTENT_GETWEAPON	= 1;--选择武器
--EQUIP_INTENT_GETARMOR		= 2;--选择防具
--EQUIP_INTENT_GETORNAMENT	= 3;--选择饰品
--EQUIP_INTENT_GETLIST 		= 4;--装备强化选择
---------意图----------

--显示UI
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
	
	--加载装备数据
	equip_select_mgr.LoadAllEquip(intent);
	
	--初使化按钮
    p.InitShowButton( intent );

    --初使化标题
    p.InitTitleText( intent );
end

function p.InitIndexlist(equiplist)
	for i=1,#equiplist do
		p.selectIndexList[i] = 0;
	end
end

--初使化标题
function p.InitTitleText( intent )
    local title = GetLabel( p.layer, ui_dlg_equip_select.ID_CTRL_TEXT_TITLE);
    if EQUIP_INTENT_GETLIST == intent then
		title:SetText(GetStr("equip_select_title_intensify"));
    else
        title:SetText(GetStr("equip_select_title_change"));
    end
end

function p.InitShowButton( intent )
	--武器分类
	local weaponBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_WEAPON);
	weaponBtn:SetLuaDelegate(p.OnUIEventEquipList);
	--防具分类
	local armorBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_ARMOR);
	armorBtn:SetLuaDelegate(p.OnUIEventEquipList);
	--饰品分类
	local ornamentBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_ORNAMENT);
	ornamentBtn:SetLuaDelegate(p.OnUIEventEquipList);
	--全部
	local allBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_ALL);
	allBtn:SetLuaDelegate(p.OnUIEventEquipList);
	--返回按钮
	local backBtn = GetButton(p.layer, ui_dlg_equip_select.ID_CTRL_BUTTON_BACK);
	backBtn:SetLuaDelegate(p.OnUIEventEquipList);
	--确认按钮
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

--显示加载的装备
function p.ShowEquipList( equipList )
	p.InitIndexlist(equipList);
	local list = GetListBoxVert(p.layer ,ui_dlg_equip_select.ID_CTRL_VERTICAL_LIST_EQUIP);
	list:ClearView();
	p.Itemlist = equipList;
	if equipList == nil or #equipList <= 0 then
        WriteCon("ShowEquipList():equipList is null");
        return ;
    end
	
	--装备数量
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

--设置装备信息
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

	--装备图标
	local equipPicImg = GetImage( view, equipPic );
	--装备等级
	local equipLVLable = GetLabel( view, equipLV );
	equipLVLable:SetText( tostring(equip.level));
	--装备名称
	local equipNameLable = GetLabel( view, equipName );
	equipNameLable:SetText( equip.name );
	--装备星级
	local equipStartImg = GetImage( view, equipStart );
	--装备攻击力
	local equipAtkLable = GetLabel( view, equipAtk );
	equipAtkLable:SetText( tostring(p.GetAttack( equip )));
	--装备防御力
	local equipDefLable = GetLabel( view, equipDef );
	equipDefLable:SetText( tostring(p.GetDef( equip )));
	--装备生命力
	local equipHpLable = GetLabel( view, equipHp );
	equipHpLable:SetText( tostring( p.GetHP( equip )));
	--装备技能
	local equipSkillLable = GetLabel( view, equipSkill );
	equipSkillLable:SetText("not skill");
	if equip.skill ~= nil then
		equipSkillLable:SetText( tostring(equip.skill));
	end
	p.SetCheckboxImg(view,false);
	--如果有装备卡牌
	if tonumber(equip.card_id) ~= nil then
		local card = nil;
		for k,v in ipairs( msg_cache.msg_card_box ) do
			if v.id == equip.card_id then
				card = v;
			end
        end
		--装备于卡牌名
		local equipCardNameLable = GetLabel( view, equipCardName );
		local cardname = SelectCell( T_CARD, card.card_id, "name" );
		equipCardNameLable:SetText( tostring( cardname));
		--卡牌等级
		local equipCardLvLable = GetLabel( view, equipCardLv );
		equipCardLvLable:SetText( tostring( card.level));
		--卡牌ID
		local equipCardIdLable = GetLabel( view, equipCardId );
		equipCardIdLable:SetText( tostring( card.card_id) );
		--未装备标示
		local equipNOImg = GetImage(view, equipNO);
		equipNOImg:SetVisible( false );
    end	
end


--获取道具当前的生命值
function p.GetHP( item )
	--[[local add_hp_max = SelectCell( T_ITEM, item.item_id, "add_hp_max" );
	local add_hp_min = SelectCell( T_ITEM, item.item_id, "add_hp_min" );
	local level_max = SelectCell( T_ITEM, item.item_id, "level_max" );--]]
	return p.GetCurrentValue( item.add_hp_max, item.add_hp_min, item.level_max, item.level  );
end

--获取道具当前的攻击力
function p.GetAttack( item )
	--[[local add_attack_max = SelectCell( T_ITEM, item.item_id, "add_attack_max" );
	local add_attack_min = SelectCell( T_ITEM, item.item_id, "add_attack_min" );
	local level_max = SelectCell( T_ITEM, item.item_id, "level_max" );--]]
    return p.GetCurrentValue( item.add_attack_max, item.add_attack_min, item.level_max, item.level  );
end

--获取道具当前的防御力
function p.GetDef( item )
	--[[local add_defence_max = SelectCell( T_ITEM, item.item_id, "add_defence_max" );
	local add_defence_min = SelectCell( T_ITEM, item.item_id, "add_defence_min" );
	local level_max = SelectCell( T_ITEM, item.item_id, "level_max" );--]]
    return p.GetCurrentValue( item.add_defence_max, item.add_defence_min, item.level_max, item.level  );
end

--获取装备相关信息的公式
function p.GetCurrentValue( maxValue, minValue, maxLv, lv)
	local maxv = tonumber( maxValue );
	local minv = tonumber( minValue );
	local maxLv = tonumber( maxLv )
	local lv = tonumber( lv );
	local cur_value = minValue + (maxv - minv)/(maxLv - 1) * ( lv - 1)
	return math.floor( cur_value );
end

--事件处理
function p.OnUIEventEquipList(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui_dlg_equip_select.ID_CTRL_BUTTON_BACK == tag ) then	
			p.CloseUI();
		elseif ( ui_dlg_equip_select.ID_CTRL_BUTTON_OK == tag ) then	
			--若为更换装备意图
			if p.intent ~= EQUIP_INTENT_GETLIST then
				p.SendEquipId();
				return;
			end
			--若为选择强化装备素材意图
			p.caller.LoadSelectItemData( p.GetSelectEquiplist() , nil );
			p.CloseUI();
		end					
	end
end

--发送请求给服务器更换装备
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


--装备更换成功回调
function p.ChangeEquipResult()
	dlg_card_equip.ReloadItemInfo(p.selectItem , p.intent);
	p.CloseUI();
end

--最终选择装备列表
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

--点击选择装备事件
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
	if p.selectNum > 0 then --有装备被选择
	okBtn:SetEnabled( true );
	end
end

function p.SetCheckboxImg( view, bEnable)
	local ChenckboxImg = GetImage(view, ui_equip_list_view.ID_CTRL_PICTURE_CHECK);
	ChenckboxImg:SetVisible(bEnable );
end

--判断设置确认按钮是否可点击
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