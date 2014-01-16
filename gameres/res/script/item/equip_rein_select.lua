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

equip_rein_select = {}
local p = equip_rein_select;
local ui = ui_equip_rein_select;
local ui_list = ui_equip_sell_select_list;

p.sortBtnMark = MARK_OFF;	--按规则排序是否开启
p.equlip_list = {};
p.sortByRuleV = nil;
p.cardListByProf = {};
p.curBtnNode = nil;
p.newEquip = {};
p.msg = nil;

p.countNum = nil;
p.allNumText={};
p.selectList = {};
p.consumeMoney = 0;
p.equipListNode = {};
p.equipEnabled = true;
p.cardListByProf = {};
p.isDress = {};
p.equipLevel = {};
p.callback = nil;
p.isChanged = nil;

--显示UI
function p.ShowUI(selectList,callback)
	p.callback = callback;
	if selectList and #selectList > 0 then
		for k,v in pairs(selectList) do
			p.selectList[#p.selectList+1] = v.id;
		end 
	end
    
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
	
	GetUIRoot():AddDlg(layer);
    LoadDlg("equip_rein_select.xui", layer, nil);
	
	p.layer = layer;
	p.card = card;
	p.SetDelegate();
	p.LoadEquipData();
end

--设置事件处理
function p.SetDelegate()
	
	local retBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_RETURN); 
	retBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	
	local orderBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ORDER); 
	orderBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local allBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ALL); 
	allBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local weaponBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_WEAPON); 
	weaponBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local armorBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ARMOR); 
	armorBtn:SetLuaDelegate(p.OnEquipUIEvent);
	
	local bt = GetButton(p.layer, ui.ID_CTRL_BUTTON_CLEAN);
	bt:SetLuaDelegate(p.OnEquipUIEvent);
	
	bt = GetButton(p.layer, ui.ID_CTRL_BUTTON_OK);
	bt:SetLuaDelegate(p.OnEquipUIEvent);
	
	
end

function p.OnEquipUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui.ID_CTRL_BUTTON_RETURN == tag ) then	
			p.CloseUI(true);
		elseif (ui.ID_CTRL_BUTTON_ORDER == tag) then --排序
			equip_bag_sort.ShowUI(4);
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
		elseif (ui.ID_CTRL_BUTTON_CLEAN == tag) then
			p.selectList = {};
			p.refreshList(p.newEquip);
		elseif (ui.ID_CTRL_BUTTON_OK == tag) then
			
			local rtn = {};
			local sels = {};
			for k, v in pairs(p.selectList) do
				sels[v] = v;
			end
			for k,v in pairs(p.newEquip) do
				if sels[v.id] ~= nil then
					rtn[#rtn+1] = v;
				end
			end
			
			local cb = p.callback
			local change = p.isChanged;
			p.CloseUI()
			if (cb) then
				cb(change,rtn);
			end
			
			
			
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
	labRoomNum:SetText(tostring(#p.equlip_list).."/"..tostring(msg.equip_room_limit)); 	
	p.refreshList(msg.equipment_info);
	
end

--显示列表
function p.refreshList(lst)
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();
	
	local equipCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_EQUIP_SEL_NUM);
	equipCount:SetText(tostring(0).."/10"); 
	p.consumeMoney = 0;
	local equipSellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_MONEY);
	equipSellMoney:SetText(tostring(p.consumeMoney)); 

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
		LoadUI("equip_sell_select_list.xui",view,nil);
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
				p.isDress[equip.id] = equip.Is_dress;
			end
		end
		list:AddView( view );
	end
	
end

--显示单张卡牌
function p.ShowEquipInfo( view, equip, index ,dataListIndex)
	
	WriteCon("index = "..index);
	local indexStr = tostring(index);
	local btTagStr 	= "ID_CTRL_BUTTON_ITEM_"..indexStr;--按钮
	local imgBdTagStr= "ID_CTRL_PICTURE_BD_"..indexStr;--装备图
	local imgTagStr = "ID_CTRL_PICTURE_IMAGE_"..indexStr;--装备图背景
	local lvTagStr 	= "ID_CTRL_TEXT_LV_"..indexStr;  --等级
	local drsTagStr = "ID_CTRL_TEXT_DRESSED_"..indexStr; --是否已装备
	local nmTagStr  = "ID_CTRL_TEXT_NUM_"..indexStr; --是否选中

	WriteCon("btTagStr = "..btTagStr);
	local bt 	= GetButton(view, ui_list[btTagStr]);
	local imgV= GetImage(view, ui_list[imgBdTagStr]);
	local imgBdV	= GetImage(view, ui_list[imgTagStr]);
	local lvV 	= GetLabel(view, ui_list[lvTagStr]);
	local drsV	= GetLabel(view, ui_list[drsTagStr]);
	local nmV	= GetLabel(view, ui_list[nmTagStr]);
	
	
	drsV:SetVisible( false );
	
	
	--按钮设置事件
	bt:SetLuaDelegate(p.OnItemClickEvent);
	bt:RemoveAllChildren(true);
	bt:SetVisible(true);
	bt:SetId(tonumber(equip.id));
	
	
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", tostring(equip.equip_id)); --从表中获取卡牌详细信息	
	
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
	
	
	p.allNumText[equip.id] = nmV;
	p.equipListNode[#p.equipListNode + 1] = bt;
	p.equipLevel[equip.id] = equip.equip_level;
	
	for k,v in pairs(p.selectList) do
		if v == equip.id then
			local levelConfig= SelectRowInner( T_EQUIP_LEVEL, "equip_level", tostring(equip.equip_level));
			if levelConfig then
				p.consumeMoney = p.consumeMoney + tonumber(levelConfig.feed_money);
			end
			
			nmV:SetVisible(true);
			nmV:SetText(tostring(k));
			
			local equipCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_EQUIP_SEL_NUM);
			equipCount:SetText(tostring(k).."/10");
			
			local equipSellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_MONEY);
			equipSellMoney:SetText(tostring(p.consumeMoney));
		end
	end
	
	
end
--点击卡牌事件
function p.OnItemClickEvent(uiNode, uiEventType, param)
	local equipId = uiNode:GetId();
	local equipSelectText = p.allNumText[equipId] ;

	local pEquipLevel = tonumber(p.equipLevel[equipId]);
	local levelConfig= SelectRowInner( T_EQUIP_LEVEL, "equip_level", tostring(p.equipLevel[equipId])); --从表中获取卡牌详细信息	
	local selectNum = #p.selectList;
	if p.isDress[equipId] ~=1 then
		if equipSelectText:IsVisible() == true then
			equipSelectText:SetText("");
			equipSelectText:SetVisible(false);
			
			for k,v in pairs(p.selectList) do
				if v == equipId then
					table.remove(p.selectList,k);
				end
			end
		
			if levelConfig then
				p.consumeMoney = p.consumeMoney - tonumber(levelConfig.feed_money);
			end
			p.setNumFalse();
			selectNum = selectNum-1;
		else
			if selectNum < 10 then
				equipSelectText:SetVisible(true);
				p.selectList[#p.selectList + 1] = equipId;
				selectNum = selectNum + 1;
				equipSelectText:SetText(tostring(selectNum));
				if levelConfig then
					p.consumeMoney = p.consumeMoney + tonumber(levelConfig.feed_money);
				end
			end
		end
		p.isChanged = true;
	else
		dlg_msgbox.ShowOK(GetStr("equip_sell_title"),GetStr("equip_is_dress"),p.OnOkCallback,p.layer);
	end
	
	
	local equipCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_EQUIP_SEL_NUM);
	equipCount:SetText(tostring(selectNum).."/10"); 
	
	local equipSellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_MONEY);
	equipSellMoney:SetText(tostring(p.consumeMoney)); 
	
		
	if p.equipEnabled == true and tonumber(selectNum) >= 10 then 
		p.setAllCardDisEnable();
		p.equipEnabled = false;
	elseif p.equipEnabled == false and tonumber(selectNum) < 10 then
		p.setCardDisEnable();
		p.equipEnabled = true;
	end
end

function p.OnOkCallback()
	WriteCon("equip_is_dress");
end
--设置除选择外的卡牌不可点
function p.setAllCardDisEnable()
	for i=1, #p.equipListNode do
		local id = p.equipListNode[i]:GetId();
		local uiNode = p.equipListNode[i]
		for i=1,#p.selectList do
			if tonumber(id) == tonumber(p.selectList[i]) then
				uiNode:SetEnabled(true);
				break;
			else
				uiNode:SetEnabled(false);
			end
		end
		
	end
end

--设置卡牌可点
function p.setCardDisEnable()
	for i=1, #p.equipListNode do
		local uiNode = p.equipListNode[i]
		uiNode:SetEnabled(true);
	end
end
--设置序号更新
function p.setNumFalse()
	for k,v in pairs(p.selectList) do
			--WriteCon("k : "..k);
			local numText = p.allNumText[v];
			numText:SetText(tostring(k));
	end

end

function p.InitViewUI(view)
	local btTagStr 	= nil;--按钮
	local imgTagStr = nil;--装备图背景
	local lvTagStr 	= nil;  --等级
	local drsTagStr = nil; --是否已装备
	local nmTagStr  = nil; --装备名
	local imgBdTagStr=nil;--装备图
	
   for cardIndex=1,4 do
		if cardIndex == 1 then			
			btTagStr  = ui_list.ID_CTRL_BUTTON_ITEM_1;
			imgTagStr = ui_list.ID_CTRL_PICTURE_IMAGE_1;
			lvTagStr  = ui_list.ID_CTRL_TEXT_LV_1; 
			drsTagStr = ui_list.ID_CTRL_TEXT_DRESSED_1; 
			nmTagStr  = ui_list.ID_CTRL_TEXT_NUM_1; 
			imgBdTagStr= ui_list.ID_CTRL_PICTURE_BD_1;
		elseif cardIndex == 2 then
			btTagStr  = ui_list.ID_CTRL_BUTTON_ITEM_2;
			imgTagStr = ui_list.ID_CTRL_PICTURE_IMAGE_2;
			lvTagStr  = ui_list.ID_CTRL_TEXT_LV_1;  
			drsTagStr = ui_list.ID_CTRL_TEXT_DRESSED_2; 
			nmTagStr  = ui_list.ID_CTRL_TEXT_NUM_2; 
			imgBdTagStr= ui_list.ID_CTRL_PICTURE_BD_2;
		elseif cardIndex == 3 then
			btTagStr  = ui_list.ID_CTRL_BUTTON_ITEM_3;
			imgTagStr = ui_list.ID_CTRL_PICTURE_IMAGE_3;
			lvTagStr  = ui_list.ID_CTRL_TEXT_LV_3;  
			drsTagStr = ui_list.ID_CTRL_TEXT_DRESSED_3; 
			nmTagStr  = ui_list.ID_CTRL_TEXT_NUM_3; 
			imgBdTagStr= ui_list.ID_CTRL_PICTURE_BD_3;
		elseif cardIndex == 4 then
			btTagStr  = ui_list.ID_CTRL_BUTTON_ITEM_4;
			imgTagStr = ui_list.ID_CTRL_PICTURE_IMAGE_4;
			lvTagStr  = ui_list.ID_CTRL_TEXT_LV_4;
			drsTagStr = ui_list.ID_CTRL_TEXT_DRESSED_4;
			nmTagStr  = ui_list.ID_CTRL_TEXT_NUM_4;
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
	return tonumber(a.equip_level) < tonumber(b.equip_level);
end

--按星级排序
function p.sortByStar(a,b)
	return tonumber(a.rare) < tonumber(b.rare);
end
function p.CloseUI(isGoBack)
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
	
	p.equlip_list = {};
		p.sortByRuleV = nil;
		p.cardListByProf = {};
		p.curBtnNode = nil;
		p.newEquip = {};
		p.msg = nil;
		p.countNum = nil;
		p.allNumText={};
		
		p.consumeMoney = 0;
		
		p.equipListNode = {};
		p.isDress = {};
		p.equipLevel = {};
		
	if isGoBack and p.callback then
		p.callback(false);
	end
	
	p.selectList = {};
	p.callback = nil;
	p.isChanged = nil;

end

