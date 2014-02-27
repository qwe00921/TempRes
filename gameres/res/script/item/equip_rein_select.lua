--------------------------------------------------------------
-- FileName: 	equip_room.lua
-- author:		lll, 2014/01/07
-- purpose:		װ����
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

p.sortBtnMark = MARK_OFF;	--�����������Ƿ���
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
p.isDress = {};
p.equipLevel = {};
p.callback = nil;
p.isChanged = nil;

p.rookie_node = nil;
p.rookie_node1 = nil;

--��ʾUI
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
	
	GetUIRoot():AddChild(layer);
    LoadDlg("equip_rein_select.xui", layer, nil);
	
	p.layer = layer;
	p.card = card;
	p.SetDelegate();
	p.LoadEquipData();
end

--�����¼�����
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
	
	p.rookie_node1 = bt;
end

function p.OnEquipUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui.ID_CTRL_BUTTON_RETURN == tag ) then	
			p.CloseUI(true);
		elseif (ui.ID_CTRL_BUTTON_ORDER == tag) then --����
			equip_bag_sort.ShowUI(4);
		elseif (ui.ID_CTRL_BUTTON_ALL == tag) then --ȫ��
			p.SetBtnCheckedFX( uiNode );
			p.refreshList(p.equlip_list);
			p.cardListByProf = p.cardListInfo;
		elseif (ui.ID_CTRL_BUTTON_WEAPON == tag) then --����
			p.SetBtnCheckedFX( uiNode );
			p.ShowCardByProfession(PROFESSION_TYPE_1);
		elseif (ui.ID_CTRL_BUTTON_ARMOR == tag) then --����
			p.SetBtnCheckedFX( uiNode );
			p.ShowCardByProfession(PROFESSION_TYPE_2);
		elseif (ui.ID_CTRL_BUTTON_CLEAN == tag) then
			p.selectList = {};
			p.refreshList(p.newEquip);
		elseif (ui.ID_CTRL_BUTTON_OK == tag) then
			
			local rtn = {};
			local sels = {};
			--ԭ˳��ᱻ��
			--[[
			for k, v in pairs(p.selectList) do
				sels[v] = v;
			end
			for k,v in pairs(p.newEquip) do
				if sels[v.id] ~= nil then
					rtn[#rtn+1] = v;
				end
			end
			]]--
			for k1, v1 in pairs(p.selectList) do
				for k,v in pairs(p.newEquip) do
					if v.id == v1 then
						rtn[#rtn+1] = v;
					end
				end
			end;
			
			local cb = p.callback
			local change = p.isChanged;
			p.CloseUI()
			if (cb) then
				cb(change,rtn);
			end
			
			
			
		end				
	end
end


--��ְҵ��ʾ����
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

--��ȡ��ʾ�б�
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

--����ѡ�а�ť
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
--��ʾ��Ϣ
function p.ShowInfo(msg)
	WriteCon( "** OnLoadList21" );
	
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	p.equlip_list = {}
	p.cardListByProf = {}
	for k,v in ipairs(msg.equipment_info) do
		if v.id ~= equip_rein_list.item.itemUid then
			p.equlip_list[#p.equlip_list + 1] = v;
			p.cardListByProf[#p.cardListByProf + 1] = v;
		end;
	end;
--	p.equlip_list = msg.equipment_info;
--	p.cardListByProf  = msg.equipment_info;
	p.msg = msg;
	local labRoomNum = GetLabel(p.layer, ui.ID_CTRL_TEXT_NUM); 
	labRoomNum:SetText(tostring(#p.equlip_list).."/"..tostring(msg.equip_room_limit)); 	
	
	if p.sortByRuleV then
		p.sortByBtnEvent(p.sortByRuleV);
	else
		p.refreshList(p.cardListByProf);
	end
	
	
end

--��ʾ�б�
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
	local row = math.ceil(cardNum / 5);
	WriteCon("row ===== "..row);
	
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("equip_sell_select_list.xui",view,nil);
		p.InitViewUI(view);
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
				
		local row_index = i;
		local start_index = (row_index-1)*5+1
        local end_index = start_index + 4;
		
		--�����б���Ϣ��һ��4�ſ���
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

--��ʾ���ſ���
function p.ShowEquipInfo( view, equip, index ,dataListIndex)
	
	WriteCon("index = "..index);
	local indexStr = tostring(index);
	local btTagStr 	= "ID_CTRL_BUTTON_ITEM_"..indexStr;--��ť
	local imgBdTagStr= "ID_CTRL_PICTURE_BD_"..indexStr;--װ��ͼ
	local imgTagStr = "ID_CTRL_PICTURE_IMAGE_"..indexStr;--װ��ͼ����
	local lvTagStr 	= "ID_CTRL_TEXT_LV_"..indexStr;  --�ȼ�
	local lvImgStr = "ID_CTRL_PICTURE_LV"..indexStr; --�ȼ�ͼƬ
	
	local drsTagStr = "ID_CTRL_PICTURE_DRESSED_"..indexStr; --�Ƿ���װ��
	--local nmTagStr  = "ID_CTRL_TEXT_NUM_"..indexStr; --�Ƿ�ѡ��
    local selTagStr = "ID_CTRL_PICTURE_SEL_"..indexStr; --�Ƿ�ѡ��
	local equipNameStr = "ID_CTRL_TEXT_NAME"..indexStr; --װ������
	local namePicStr = "ID_CTRL_PICTURE_12"..indexStr;  --װ�����ֵĵ�ͼ
	local imgEnableStr = "ID_CTRL_PICTURE_ENABLE"..indexStr;

	WriteCon("btTagStr = "..btTagStr);
	local bt 	= GetButton(view, ui_list[btTagStr]);
	local imgV= GetImage(view, ui_list[imgBdTagStr]);
	local imgBdV	= GetImage(view, ui_list[imgTagStr]);
	local lvV 	= GetLabel(view, ui_list[lvTagStr]);
	local drsV	= GetImage(view, ui_list[drsTagStr]);
	--local nmV	= GetLabel(view, ui_list[nmTagStr]);
	local selImg = GetImage(view, ui_list[selTagStr]);
	local lvImg = GetImage(view, ui_list[lvImgStr]);
	local equipName = GetLabel(view, ui_list[equipNameStr]);
	local namePic = GetImage(view, ui_list[namePicStr]);
	local imgEnable = GetImage(view, ui_list[imgEnableStr]);
	
	lvImg:SetVisible(true);
	drsV:SetVisible( false );
	namePic:SetVisible(true);
	
	--��ť�����¼�
	bt:SetLuaDelegate(p.OnItemClickEvent);
	bt:RemoveAllChildren(true);
	bt:SetVisible(true);
	bt:SetId(tonumber(equip.id));
	imgEnable:SetId(tonumber(equip.id));
	
	if dataListIndex == 2 then
		p.rookie_node = bt;
	end
	
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", tostring(equip.equip_id)); --�ӱ��л�ȡ������ϸ��Ϣ	

	--װ������
	local str = pEquipInfo.name;
	equipName:SetText(str or "");
	equipName:SetVisible(true);
		
	--��ʾ����ͼƬ ����ͼ
	imgV:SetPicture( GetPictureByAni(pEquipInfo.item_pic, 0) );
	imgV:SetVisible(true);
	imgBdV:SetVisible(true);
	
	
	--��ʾ�ȼ�
	lvV:SetText("" .. (tostring(equip.equip_level) or "1"));
	lvV:SetVisible(true);
	--�Ƿ���װ��
	if tonumber(equip.Is_dress) == 1 then
		drsV:SetVisible(true);
	end
	

	p.allNumText[equip.id] = selImg;
	p.equipListNode[#p.equipListNode + 1] = imgEnable;
	p.equipLevel[equip.id] = equip.equip_level;
	
	for k,v in pairs(p.selectList) do
		if v == equip.id then
			local levelConfig= SelectRowInner( T_EQUIP_LEVEL, "level", tostring(equip.equip_level));
			if levelConfig then
				p.consumeMoney = p.consumeMoney + tonumber(levelConfig.feed_money);
			end
			
			selImg:SetVisible(true);
			selImg:SetPicture(GetPictureByAni("common_ui.card_num",k));
			--nmV:SetText(tostring(k));
			
			local equipCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_EQUIP_SEL_NUM);
			equipCount:SetText(tostring(k).."/10");
			
			local equipSellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_MONEY);
			equipSellMoney:SetText(tostring(p.consumeMoney));
		end
	end
	
	
end

function p.GetRookieNode()
	return p.rookie_node;
end

function p.GetRookieNode1()
	return p.rookie_node1;
end

--��������¼�
function p.OnItemClickEvent(uiNode, uiEventType, param)
	local equipId = uiNode:GetId();
	local equipSelectText = p.allNumText[equipId] ;

	local pEquipLevel = tonumber(p.equipLevel[equipId]);
	local levelConfig= SelectRowInner( T_EQUIP_LEVEL, "level", tostring(p.equipLevel[equipId])); --�ӱ��л�ȡ������ϸ��Ϣ	
	local selectNum = #p.selectList;
	if p.isDress[equipId] ~=1 then
		if equipSelectText:IsVisible() == true then
			--equipSelectText:SetText("");
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
--				equipSelectText:SetText(tostring(selectNum));
				equipSelectText:SetPicture(GetPictureByAni("common_ui.card_num",selectNum));
				if levelConfig then
					p.consumeMoney = p.consumeMoney + tonumber(levelConfig.feed_money);
				end
			end
		end
		p.isChanged = true;
	else
		dlg_msgbox.ShowOK(GetStr("card_equip_up_select"),GetStr("card_equip_up_select_dressed"),p.OnOkCallback,p.layer);
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
--���ó�ѡ����Ŀ��Ʋ��ɵ�
function p.setAllCardDisEnable()
	for i=1, #p.equipListNode do
		local id = p.equipListNode[i]:GetId();
		local uiNode = p.equipListNode[i]
		--uiNode:SetEnabled(false);
		uiNode:SetVisible(true);
		for i=1,#p.selectList do
			if tonumber(id) == tonumber(p.selectList[i]) then
				--uiNode:SetEnabled(true);
				uiNode:SetVisible(false);
				break;
			end
		end
		
	end
end

--���ÿ��ƿɵ�
function p.setCardDisEnable()
	for i=1, #p.equipListNode do
		local uiNode = p.equipListNode[i]
		--uiNode:SetEnabled(true);
		uiNode:SetVisible(false);
	end
end
--������Ÿ���
function p.setNumFalse()
	for k,v in pairs(p.selectList) do
			--WriteCon("k : "..k);
			local numText = p.allNumText[v];
			numText:SetPicture(GetPictureByAni("common_ui.card_num",k));
			--numText:SetText(tostring(k));
	end

end

function p.InitViewUI(view)
	local btTagStr 	= nil;--��ť
	local imgTagStr = nil;--װ��ͼ����
	local lvTagStr 	= nil;  --�ȼ�
	local drsTagStr = nil; --�Ƿ���װ��
	local nmTagStr  = nil; --װ����
	local imgBdTagStr=nil;--װ��ͼ
	local imgSelStr = nil; --��ѡ�ߵ�ͼƬ
	local imgLvStr = nil;  --LV��ͼƬ
    for i=1,5 do
		btTagStr  = ui_list["ID_CTRL_BUTTON_ITEM_"..tostring(i)];
		imgTagStr = ui_list["ID_CTRL_PICTURE_IMAGE_"..tostring(i)];
		lvTagStr  = ui_list["ID_CTRL_TEXT_LV_"..tostring(i)]; 
		drsTagStr = ui_list["ID_CTRL_PICTURE_DRESSED_"..tostring(i)]; 
		nmTagStr  = ui_list["ID_CTRL_TEXT_NAME"..tostring(i)]; 
		imgBdTagStr= ui_list["ID_CTRL_PICTURE_BD_"..tostring(i)];
		imgSelStr = ui_list["ID_CTRL_PICTURE_SEL_"..tostring(i)];
		imgLvStr  = ui_list["ID_CTRL_PICTURE_LV"..tostring(i)];
		imgNamePicStr = ui_list["ID_CTRL_PICTURE_12"..tostring(i)];
		imgEnableStr = ui_list["ID_CTRL_PICTURE_ENABLE"..tostring(i)];
						
		local bt = GetButton(view,btTagStr);
		bt:SetVisible(false);
		
		local equipBdPic = GetImage(view,imgTagStr);
		equipBdPic:SetVisible(false);
		
		local levelText = GetLabel(view,lvTagStr);
		levelText:SetVisible( false );
			
		local isEquipText = GetImage(view,drsTagStr);
		isEquipText:SetVisible( false );
		
		local equipName = GetLabel(view,nmTagStr);
		equipName:SetVisible( false );
		
		local picName = GetImage(view,imgNamePicStr);
		picName:SetVisible(false);
		
		local equipPic = GetImage(view,imgBdTagStr );
		equipPic:SetVisible( false );
		
		local selPic = GetImage(view, imgSelStr);
		selPic:SetVisible(false);
		
		local lvPic = GetImage(view, imgLvStr);
		lvPic:SetVisible(false);
		
		local imgEnable = GetImage(view, imgEnableStr);
		imgEnable:SetVisible(false);
    end
end;





--http://fanta2.sb.dev.91.com/index.php?command=Equip&action=EquipmentList&user_id=112&R=80&V=77&MachineType=WIN32
function p.LoadEquipData()
	WriteCon("**����װ���б�**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	--local param = "&card_id=" .. tostring(p.card.id );
	--SendReq("Equip","EquipmentList", uid, param);
	SendReq("Equip","EquipmentList", uid,"");
end





	
--����������ť
function p.sortByBtnEvent(sortType)
	WriteCon("sortType = "..sortType);
	if sortType == nil then
		return;
	end
	local sortByBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ORDER);
	sortByBtn:SetLuaDelegate(p.OnEquipUIEvent);
	local sortByImg = GetImage(p.layer, ui.ID_CTRL_PICTURE_134);
	if(sortType == CARD_BAG_SORT_BY_LEVEL) then
		sortByImg:SetPicture(GetPictureByAni("common_ui.cardBagSort",2));
		p.sortByRuleV = CARD_BAG_SORT_BY_LEVEL;
	elseif(sortType == CARD_BAG_SORT_BY_STAR) then
		sortByImg:SetPicture(GetPictureByAni("common_ui.cardBagSort",4));
		p.sortByRuleV = CARD_BAG_SORT_BY_STAR;
	end
	p.sortByRule(sortType);

end 

--����������
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

--���ȼ�����
function p.sortByLevel(a,b)
	return tonumber(a.equip_level) < tonumber(b.equip_level);
end

--���Ǽ�����
function p.sortByStar(a,b)
	return tonumber(a.rare) < tonumber(b.rare);
end
function p.CloseUI(isGoBack)
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
	
	p.equlip_list = {};
		--p.sortByRuleV = nil;
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
	
	p.rookie_node = nil;
	p.rookie_node1 = nil;
	
	if p.sortBtnMark == MARK_ON then
		p.sortBtnMark = MARK_OFF;
		equip_bag_sort.CloseUI();
	end

end

function p.SelectItemName(id)
	local itemTable = SelectRowList(T_EQUIP,"id",id);
	if #itemTable >= 1 then
		local text = itemTable[1].name;
		return text;
	else
		WriteConErr("itemTable error ");
	end
end