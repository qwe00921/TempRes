--------------------------------------------------------------
-- FileName: 	equip_room.lua
-- author:		lll, 2014/01/07
-- purpose:		装备屋
--------------------------------------------------------------
CARD_BAG_SORT_BY_LEVEL	= 1001;
CARD_BAG_SORT_BY_STAR	= 1002;

PROFESSION_TYPE_1 = 2001;
PROFESSION_TYPE_2 = 2002;
MARK_ON = 100;
MARK_OFF = nil;

equip_room = {}
local p = equip_room;
local ui = ui_equip_room;
local ui_list = ui_equip_room_list;

p.sortBtnMark = MARK_OFF;	--按规则排序是否开启
p.equlip_list = {};
p.sortByRuleV = nil;
p.cardListByProf = {};
p.curBtnNode = nil;
p.newEquip = {};
p.msg = nil;
--显示UI
function p.ShowUI()
   -- dlg_menu.ShowUI();
	--dlg_menu.SetNewUI( p );
	dlg_userinfo.ShowUI( );
    if p.layer ~= nil then 
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddDlg(layer);
    LoadDlg("equip_room.xui", layer, nil);
	
	p.layer = layer;
	p.card = card;
	p.card = card;
	p.SetDelegate();
	p.LoadEquipData();
end

--设置事件处理
function p.SetDelegate()
	
	local retBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_RETURN); 
	retBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local sellBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_SELL); 
	sellBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local orderBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ORDER); 
	orderBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local allBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ALL); 
	allBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local weaponBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_WEAPON); 
	weaponBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local armorBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ARMOR); 
	armorBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	
end

function p.OnEquipUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		
		if p.sortBtnMark == MARK_ON then
			p.sortBtnMark = MARK_OFF;
			equip_bag_sort.CloseUI();
		end
		if ( ui.ID_CTRL_BUTTON_RETURN == tag ) then	
			p.CloseUI();
			--dlg_userinfo.ShowUI( );
			dlg_userinfo.HideUI();
			--country_main.ShowUI();
		elseif (ui.ID_CTRL_BUTTON_SELL == tag) then --卖出
			p.HideUI();
			equip_sell.ShowUI(p.msg);
		elseif (ui.ID_CTRL_BUTTON_ORDER == tag) then --排序
			equip_bag_sort.ShowUI(1);
		elseif (ui.ID_CTRL_BUTTON_ALL == tag) then --全部
			p.SetBtnCheckedFX( uiNode );
			p.refreshList(p.equlip_list);
			p.cardListByProf = p.cardListInfo;
		elseif (ui.ID_CTRL_BUTTON_WEAPON == tag) then --武器
			p.SetBtnCheckedFX( uiNode );
			p.ShowCardByProfession(PROFESSION_TYPE_1);
		elseif (ui.ID_CTRL_BUTTON_ARMOR == tag) then --防具
			p.SetBtnCheckedFX( uiNode );
			p.ShowCardByProfession(PROFESSION_TYPE_2);
		end				
	end
end



--按职业显示卡牌
function p.ShowCardByProfession(profType)
	WriteCon("ShowCardByProfession();");
	if profType == nil then
		WriteCon("ShowCardByProfession():profession Type is null");
		return;
	end 
	p.cardListByProf = p.GetCardList(profType);
	
	if p.sortByRuleV ~= nil then
		p.sortByRule(p.sortByRuleV)
	else
		p.refreshList(p.cardListByProf);
	end
end

--获取显示列表
function p.GetCardList(profType)
	local t = {};
	if p.equlip_list == nil then 
		return t;
	end
	if profType == PROFESSION_TYPE_0 then
		t = p.equlip_list;
	elseif profType == PROFESSION_TYPE_1 then 
		for k,v in pairs(p.equlip_list) do
			if tonumber(v.equip_type) == 1 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_2 then 
		for k,v in pairs(p.equlip_list) do
			if tonumber(v.equip_type) == 2 then
				t[#t + 1] = v;
			end
		end
	end
	return t;
end

--设置选中按钮
function p.SetBtnCheckedFX( node )
	WriteCon("SetBtnCheckedFX .. uiNode:GetTag() = "..node:GetTag());
	
    local btnNode = GetButton(p.layer, node:GetTag());
		
    if p.curBtnNode ~= nil then
		p.curBtnNode:SetChecked( false );
    end
	btnNode:SetChecked( true );
	
	p.curBtnNode = btnNode;
	equip_bag_sort.CloseUI();
end
--显示信息
function p.ShowInfo(msg)
	WriteCon( "** OnLoadList21" );
	
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	p.equlip_list = msg.equipment_info;
	p.cardListByProf  = msg.equipment_info;
	p.msg = msg;
	local labRoomNum = GetLabel(p.layer, ui.ID_CTRL_TEXT_NUM); 
	
	if p.equlip_list == nil then
		labRoomNum:SetText("0/"..tostring(msg.equip_room_limit)); 
	else
		
		labRoomNum:SetText(tostring(#p.equlip_list).."/"..tostring(msg.equip_room_limit)); 		
	end
	
	local tetCrit = GetLabel(p.layer, ui.ID_CTRL_TEXT_CRIT); 
	tetCrit:SetText(GetStr("equip_intensify_crit")..tostring(msg.crit_prob).."%"); 	
	
	if msg.equipment_info ~= nil then
		if p.sortByRuleV ~= nil then 
			p.cardListByProf = msg.equipment_info;
			p.sortByRule(p.sortByRuleV);
		else
			p.refreshList(msg.equipment_info);
		end
		
	end
	
end

--显示列表
function p.refreshList(lst)
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();

	if lst == nil or #lst <= 0 then
		WriteCon("refreshList():cardList is null");
		return;
	end
	p.newEquip = lst;
	local cardNum = #lst;
	local row = math.ceil(cardNum / 4);
	WriteCon("row ===== "..row);
	
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("equip_room_list.xui",view,nil);
		p.InitViewUI(view);
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
				
		local row_index = i;
		local start_index = (row_index-1)*4+1
        local end_index = start_index + 3;
		
		--设置列表信息，一行4张卡牌
		for j = start_index,end_index do
			if j <= cardNum then
				local equip = lst[j];
				local index = j - start_index + 1;
				p.ShowEquipInfo( view, equip, index , j);
			end
		end
		list:AddView( view );
	end
	
		
end

--显示单张卡牌
function p.ShowEquipInfo( view, equip, index ,dataListIndex)
	
	
	local indexStr = tostring(index);
	local btTagStr 	= "ID_CTRL_BUTTON_ITEM_"..indexStr;--按钮
	local imgBdTagStr= "ID_CTRL_PICTURE_BD_"..indexStr;--装备图
	local imgTagStr = "ID_CTRL_PICTURE_IMAGE_"..indexStr;--装备图背景
	local lvTagStr 	= "ID_CTRL_TEXT_LV_"..indexStr;  --等级
	local drsTagStr = "ID_CTRL_TEXT_DRESSED_"..indexStr; --是否已装备
	local nmTagStr  = "ID_CTRL_TEXT_NAME_"..indexStr; --装备名
	local nmBgTagStr= "ID_CTRL_PICTURE_NM_BG_"..indexStr;--装备名背景

	
	local bt 	= GetButton(view, ui_list[btTagStr]);
	local imgV= GetImage(view, ui_list[imgBdTagStr]);
	local imgBdV	= GetImage(view, ui_list[imgTagStr]);
	local lvV 	= GetLabel(view, ui_list[lvTagStr]);
	local drsV	= GetLabel(view, ui_list[drsTagStr]);
	local nmV	= GetLabel(view, ui_list[nmTagStr]);
	local nmBgV	= GetImage(view, ui_list[nmBgTagStr]);
	
	drsV:SetVisible( false );
	
	--按钮设置事件
	bt:SetLuaDelegate(p.OnItemClickEvent);
	bt:RemoveAllChildren(true);
	bt:SetId(dataListIndex);
	bt:SetVisible(true);
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", equip.equip_id); --从表中获取卡牌详细信息	
	
	--显示卡牌图片 背景图
	imgV:SetPicture( GetPictureByAni(pEquipInfo.item_pic, 0) );
	imgV:SetVisible(true);
	imgBdV:SetVisible(true);
	
	
	--显示等级
	lvV:SetText("LV." .. (tostring(equip.equip_level) or "1"));
	lvV:SetVisible(true);
	--是否已装备
	if tonumber(equip.Is_dress) == 1 then
		drsV:SetVisible(true);
	end
	
	--名称
	nmV:SetText(pEquipInfo.name or "");
	nmV:SetVisible(true);
	nmBgV:SetVisible(true);
	
	
	
end

--组装装备详细界面所需的数据(统一字段名)
function p.PasreCardDetail(itemInfo)
	local item = {};
	--item.cardId 	= cardInfo.CardID;
	--item.cardUid 	= ;
  --item.cardName	= "xxx"
	item.itemId 	= itemInfo.equip_id;
	item.itemUid	= itemInfo.id;
	item.itemType	= itemInfo.equip_type;
	item.itemLevel 	= itemInfo.equip_level;
	item.itemExp	= itemInfo.equip_exp;
	item.itemRank	= itemInfo.rare 
	item.attrType	= itemInfo.attribute_type1;
	item.attrValue	= itemInfo.attribute_value1;
	item.attrGrow	= nil --itemInfo.Attribute_grow;
	item.exType1 	= itemInfo.attribute_type2;
	item.exValue1 	= itemInfo.attribute_value2;
	item.isDress	= itemInfo.Is_dress
	--item.exType2 	= itemInfo.attribute_type2;
	--item.exValue2 	= itemInfo.attribute_value2;
	--item.exType3	= nil --itemInfo.Extra_type3;
	--item.exValue3	= nil --itemInfo.Extra_value3;
	--item.preItemUid	=	dressId--穿戴装备id
	return item;
end

function p.OnItemClickEvent(uiNode, uiEventType, param)
	
	if p.sortBtnMark == MARK_ON then
		p.sortBtnMark = MARK_OFF;
		equip_bag_sort.CloseUI();
	end
	local equipOne = p.newEquip[uiNode:GetId()];
	dlg_card_equip_detail.ShouUI4EquipRoom(p.PasreCardDetail(equipOne),p.onReinCallback,p.HideUI);
end

function p.onReinCallback(isRein)
	p.ShowUI();
	if isRein == true then
		p.LoadEquipData();
	end
end


function p.InitViewUI(view)
	local btTagStr 	= nil;--按钮
	local imgTagStr = nil;--装备图背景
	local lvTagStr 	= nil;  --等级
	local drsTagStr = nil; --是否已装备
	local nmTagStr  = nil; --装备名
	local nmBgTagStr= nil;--名称背景
	local imgBdTagStr=nil;--装备图
	
   for cardIndex=1,4 do
		if cardIndex == 1 then			
			btTagStr  = ui_list.ID_CTRL_BUTTON_ITEM_1;
			imgTagStr = ui_list.ID_CTRL_PICTURE_IMAGE_1;
			lvTagStr  = ui_list.ID_CTRL_TEXT_LV_1; 
			drsTagStr = ui_list.ID_CTRL_TEXT_DRESSED_1; 
			nmTagStr  = ui_list.ID_CTRL_TEXT_NAME_1; 
			nmBgTagStr= ui_list.ID_CTRL_PICTURE_NM_BG_1;
			imgBdTagStr= ui_list.ID_CTRL_PICTURE_BD_1;
		elseif cardIndex == 2 then
			btTagStr  = ui_list.ID_CTRL_BUTTON_ITEM_2;
			imgTagStr = ui_list.ID_CTRL_PICTURE_IMAGE_2;
			lvTagStr  = ui_list.ID_CTRL_TEXT_LV_1;  
			drsTagStr = ui_list.ID_CTRL_TEXT_DRESSED_2; 
			nmTagStr  = ui_list.ID_CTRL_TEXT_NAME_2; 
			nmBgTagStr= ui_list.ID_CTRL_PICTURE_NM_BG_2;
			imgBdTagStr= ui_list.ID_CTRL_PICTURE_BD_2;
		elseif cardIndex == 3 then
			btTagStr  = ui_list.ID_CTRL_BUTTON_ITEM_3;
			imgTagStr = ui_list.ID_CTRL_PICTURE_IMAGE_3;
			lvTagStr  = ui_list.ID_CTRL_TEXT_LV_3;  
			drsTagStr = ui_list.ID_CTRL_TEXT_DRESSED_3; 
			nmTagStr  = ui_list.ID_CTRL_TEXT_NAME_3; 
			nmBgTagStr= ui_list.ID_CTRL_PICTURE_NM_BG_3;
			imgBdTagStr= ui_list.ID_CTRL_PICTURE_BD_3;
		elseif cardIndex == 4 then
			btTagStr  = ui_list.ID_CTRL_BUTTON_ITEM_4;
			imgTagStr = ui_list.ID_CTRL_PICTURE_IMAGE_4;
			lvTagStr  = ui_list.ID_CTRL_TEXT_LV_4;
			drsTagStr = ui_list.ID_CTRL_TEXT_DRESSED_4;
			nmTagStr  = ui_list.ID_CTRL_TEXT_NAME_4;
			nmBgTagStr= ui_list.ID_CTRL_PICTURE_NM_BG_4;
			imgBdTagStr= ui_list.ID_CTRL_PICTURE_BD_4;
		end
				
		local bt = GetButton(view,btTagStr);
		bt:SetVisible(false);
		
		local equipBdPic = GetImage(view,imgTagStr);
		equipBdPic:SetVisible(false);
		
		local levelText = GetLabel(view,lvTagStr);
		levelText:SetVisible( false );
			
		local isEquipText = GetLabel(view,drsTagStr);
		isEquipText:SetVisible( false );
		
		local equipName = GetLabel(view,nmTagStr);
		equipName:SetVisible( false );
		
		local NameBg = GetImage(view,nmBgTagStr );
		NameBg:SetVisible( false );
		
		local equipPic = GetImage(view,imgBdTagStr );
		equipPic:SetVisible( false );
  end
end;






--http://fanta2.sb.dev.91.com/index.php?command=Equip&action=EquipmentList&user_id=112&R=80&V=77&MachineType=WIN32
function p.LoadEquipData()
	WriteCon("**载入装备列表**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	--local param = "&card_id=" .. tostring(p.card.id );
	--SendReq("Equip","EquipmentList", uid, param);
	SendReq("Equip","EquipmentList", uid,"");
end





	
--按规则排序按钮
function p.sortByBtnEvent(sortType)
	WriteCon("sortType = "..sortType);
	if sortType == nil then
		return;
	end
	local sortByBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ORDER);
	sortByBtn:SetLuaDelegate(p.OnEquipUIEvent);
	if(sortType == CARD_BAG_SORT_BY_LEVEL) then
		--sortByBtn:SetImage( GetPictureByAni("button.card_bag",0));
		sortByBtn:SetText(GetStr("equip_level"));
		p.sortByRuleV = CARD_BAG_SORT_BY_LEVEL;
	elseif(sortType == CARD_BAG_SORT_BY_STAR) then
		--sortByBtn:SetImage( GetPictureByAni("button.card_bag",1));
		p.sortByRuleV = CARD_BAG_SORT_BY_STAR;
		sortByBtn:SetText(GetStr("equip_rule"));
	end
	p.sortByRule(sortType);

end 

--按规则排序
function p.sortByRule(sortType)
	WriteCon("sortByRule ......"..sortType);
	if sortType == nil or p.cardListByProf == nil then 
		return
	end
	if sortType == CARD_BAG_SORT_BY_LEVEL then
		WriteCon("========sort by level");
		table.sort(p.cardListByProf,p.sortByLevel);
	elseif sortType == CARD_BAG_SORT_BY_STAR then
		WriteCon("========sort by star");
		table.sort(p.cardListByProf,p.sortByStar);
	end
	p.refreshList(p.cardListByProf);
end
--按等级排序
function p.sortByLevel(a,b)
	--return tonumber(a.equip_level) > tonumber(b.equip_level);
	return tonumber(a.equip_level) < tonumber(b.equip_level) or ( tonumber(a.equip_level) == tonumber(b.equip_level) and tonumber(a.equip_id) < tonumber(b.equip_id));
end

--按星级排序
function p.sortByStar(a,b)
	--return tonumber(a.rare) < tonumber(b.rare);
	return tonumber(a.rare) < tonumber(b.rare) or ( tonumber(a.rare) == tonumber(b.rare) and tonumber(a.equip_id) < tonumber(b.equip_id));
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
		p.equlip_list = {};
		p.sortByRuleV = nil;
		p.cardListByProf = {};
		p.curBtnNode = nil;
		p.newEquip = {};
		p.msg = nil;
		if p.sortBtnMark == MARK_ON then
			p.sortBtnMark = MARK_OFF;
			equip_bag_sort.CloseUI();
		end
    end

end

