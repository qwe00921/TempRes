

CARD_BAG_SORT_BY_LEVEL	= 1001;
CARD_BAG_SORT_BY_STAR	= 1002;

PROFESSION_TYPE_1 = 2001;
PROFESSION_TYPE_2 = 2002;

equip_dress_select  = {}
local p = equip_dress_select;

p.INTENT_ADD = 1; --���
p.INTENT_UPDATE = 2;--����

p.sortBtnMark = MARK_OFF;

p.layer = nil;
p.allItems = nil;
p.groupItems = nil;

local ui = ui_equip_change_list;
local ui_list = ui_card_equip_select_list_item;

p.curBtnNode = nil;
p.cardUid = nil;
p.selectType = 0;
p.exItem = nil;

p.callback = nil;

function p.ShowUI(cardUid, selectType, callback,exItem)
	p.cardUid = cardUid;
	p.selectType = tonumber(selectType);
	p.exItem = exItem;
	p.callback = callback;
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:NoMask();
	layer:Init();	
	GetUIRoot():AddDlg( layer );
    LoadDlg("equip_change_list.xui", layer, nil);
    

    p.layer = layer;
    p.SetDelegate(layer);
	
	--���ؿ����б�����  ������
    p.OnSendReq();
	
end


--�������¼�����
function p.SetDelegate(layer)
	local retBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	retBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local orderBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ORDER); 
	orderBtn:SetLuaDelegate(p.OnUIClickEvent);
end

--�¼�����
function p.OnUIClickEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --����
			--if p.dataChanged == true then
				local callback = p.callback;
				local chg = p.dataChanged;
				p.CloseUI();
				if callback then
					callback(chg);
				end
			--else
			--	p.CloseUI();
			--end
		elseif (ui.ID_CTRL_BUTTON_ORDER == tag) then --����
			equip_bag_sort.ShowUI(3);
		end
	end
end

--����������ť
function p.sortByBtnEvent(sortType)
	WriteCon("sortType = "..sortType);
	if sortType == nil then
		return;
	end
	local sortByBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ORDER);
	sortByBtn:SetLuaDelegate(p.OnUIClickEvent);
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

--����������
function p.sortByRule(sortType)
	WriteCon("sortByRule ......"..sortType);
	local lst = nil;
	if p.selectType == 0 then
		lst = p.allItems;
	else
		local gs = p.groupItems or {};
		lst = gs[tonumber(p.selectType) or 1];
	end
	if sortType == nil or  lst== nil then 
		return
	end
	if sortType == CARD_BAG_SORT_BY_LEVEL then
		WriteCon("========sort by level");
		table.sort(lst,p.sortByLevel);
	elseif sortType == CARD_BAG_SORT_BY_STAR then
		WriteCon("========sort by star");
		table.sort(lst,p.sortByStar);
	end
	p.refreshTab();
end

--���ȼ�����
function p.sortByLevel(a,b)
	return tonumber(a.equip_level) > tonumber(b.equip_level);
end

--���Ǽ�����
function p.sortByStar(a,b)
	return tonumber(a.rare) > tonumber(b.rare);
end


--ȷ��ǿ��ΪTRUE
function p.OnMsgBoxCallback(result)
	if result == true then
		WriteCon("true");
		
	end
end

--��ʾTab����
function p.refreshTab()
	local lst = nil;
	
	if p.groupItems then
		lst = p.groupItems[tonumber(p.selectType) or 0];
	end
	
	
	p.refreshList(lst);
end


--��ʾ�б�
function p.refreshList(lst)
	
	WriteCon("refreshList()");
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_VIEW);
	list:ClearView();

	if lst == nil or #lst <= 0 then
		WriteCon("refreshList():cardList is null");
		return;
	end
	WriteCon("cardCount ===== "..#lst);
	local cardNum = #lst;
	local row = math.ceil(cardNum / 4);
	WriteCon("row ===== "..row);
	
	for i = 1, row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("card_equip_select_list_item.xui",view,nil);
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_13);
        view:SetViewSize( bg:GetFrameSize());
		
		local row_index = i;
		local start_index = (row_index-1)*4+1
        local end_index = start_index + 3;
		
		--�����б���Ϣ��һ��4�ſ���
		for j = start_index,end_index do
			--if j <= cardNum then
				local card = lst[j];
				local cardIndex = j - start_index + 1;
				p.setItemInfo( view, card, cardIndex , j);
			--end
		end
		list:AddView( view );
	end
	
		
end



--��ʾ���ſ���
function p.setItemInfo( view, itemInfo, cardIndex ,dataListIndex)
	
	local indexStr = tostring(cardIndex);
	local btTagStr 	= "ID_CTRL_BUTTON_ITEM_"..indexStr;
	local imgTagStr = "ID_CTRL_PICTURE_IMAGE_"..indexStr;
	local lvTagStr 	= "ID_CTRL_TEXT_LEVEL_"..indexStr;  --�ȼ�
	local drsTagStr = "ID_CTRL_TEXT_DRESSED_"..indexStr; --�Ƿ���װ��
	local selTagStr = "ID_CTRL_TEXT_SELECT_"..indexStr;  --�Ƿ���ѡ����
	local rankTagStr= "ID_CTRL_TEXT_RANK_"..indexStr; --�Ǽ�
	local nmTagStr  = "ID_CTRL_TEXT_NAME_"..indexStr; --������
	local nmBgTagStr= "ID_CTRL_PICTURE_NM_BG_"..indexStr;--���Ʊ���
	local imgBdTagStr= "ID_CTRL_PICTURE_BD_"..indexStr;
	
	local bt 	= GetButton(view, ui_list[btTagStr]);
	local imgV	= GetImage(view, ui_list[imgTagStr]);
	local lvV 	= GetLabel(view, ui_list[lvTagStr]);
	local drsV	= GetLabel(view, ui_list[drsTagStr]);
	local selV	= GetLabel(view, ui_list[selTagStr]);
	local rankV	= GetLabel(view, ui_list[rankTagStr]);
	local nmV	= GetLabel(view, ui_list[nmTagStr]);
	local imgBdV= GetImage(view, ui_list[imgBdTagStr]);
	local nmBgV	= GetImage(view, ui_list[nmBgTagStr]);
	
	
	selV:SetVisible( false );
	drsV:SetVisible( false );
	
	if itemInfo == nil then
		imgV:SetVisible( false );
		imgBdV:SetVisible( false );
		nmBgV:SetVisible( false );
		return;
	end
	
	--�����¼�
	bt:SetLuaDelegate(p.OnItemClickEvent);
	bt:RemoveAllChildren(true);
	bt:SetId(dataListIndex);
	
	--��ʾ����ͼƬ
	
	imgV:SetPicture( p.SelectImage(itemInfo.equip_id) );
	
	--��ʾ�ȼ�
	lvV:SetText("LV." .. (itemInfo.equip_level or "1"));
	--��ʾ�Ǽ�
	if itemInfo.rare and itemInfo.rare ~= "0" then
		rankV:SetText(itemInfo.rare .. GetStr("card_equip_rand_txt"));
	end
	
	--�Ƿ���װ��
	if itemInfo.Is_dress == 1 or itemInfo.Is_dress == "1" then
		drsV:SetVisible(true);
	end
	
	--����
	local str = p.SelectItemName(itemInfo.equip_id)
	nmV:SetText(str or "");
	
	--�Ƿ���ѡ��
	if itemInfo.isSelected == true then
		selV:SetVisible( true );
	end
	
	
end

function p.SelectImage(id)
	
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", tostring(id)); 
	if pEquipInfo then
		return GetPictureByAni(pEquipInfo.item_pic,0);
	end
	
end


--�������
function p.OnItemClickEvent(uiNode, uiEventType, param)
	local dataListIndex = uiNode:GetId();
	WriteCon("dataListIndex = "..dataListIndex);
	
	local lst = nil;
	if p.selectType == 0 then
		lst = p.allItems;
	else
		local gs = p.groupItems or {};
		lst = gs[tonumber(p.selectType) or 1];
	end
		
	if lst == nil then 
		return;
	end
	
	local equip = lst[dataListIndex]
	
	if (equip == nil ) then
		return
	end
	
	
	local preItemUid = nil 
	if 	p.exItem then
		preItemUid = p.exItem.itemUid;
	end
 	local it = p.PasreCardDetail(p.cardUid, equip, preItemUid);
	dlg_card_equip_detail.ShowUI4Dress(it,p.OnDressCallback);
		
end



--��ʾ��ص�����
function p.OnMsgCallback(result)
	
	WriteCon("OnMsgCallback");
	
end

function p.OnDressCallback(dressed)
	if dressed == true then
		local callback = p.callback;
		p.CloseUI();
		if callback then
			callback(true);
		end
	end
end


--����ѡ�а�ť
function p.SetBtnCheckedFX( node )
    local btnNode = ConverToButton( node );
    if p.curBtnNode ~= nil then
    	p.curBtnNode:SetChecked( false );
    end
	btnNode:SetChecked( true );
	p.curBtnNode = btnNode;
	equip_bag_sort.CloseUI();
end

--���ݷ���
function p.divideItems()
	if p.allItems == nil then
		return
	end
	p.groupItems = p.groupItems or {};
	for i = 1, #p.allItems do
		local t = tonumber(p.allItems[i].equip_type);
		WriteCon("p.groupItems[t] = "..t);
		p.groupItems[t] = p.groupItems[t] or {};
		p.groupItems[t][#p.groupItems[t] + 1] = p.allItems[i];
	end
	
end

--��װװ����ϸ�������������(ͳһ�ֶ���)
function p.PasreCardDetail(cardUid, itemInfo, dressId)
	local item = {};
	--item.cardId 	= cardInfo.CardID;
	item.cardUid 	= cardUid;
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
	--item.exType2 	= itemInfo.attribute_type2;
	--item.exValue2 	= itemInfo.attribute_value2;
	--item.exType3	= nil --itemInfo.Extra_type3;
	--item.exValue3	= nil --itemInfo.Extra_value3;
	item.preItemUid	=	dressId--����װ��id
	return item;
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
		p.ClearData()
		p.allItems = nil;
		p.curBtnNode = nil;
		
		p.dataChanged = false;
		p.callback = nil;
    end
end

--�������
function p.ClearData()
	p.allItems = nil;
	p.curBtnNode = nil;
	
	p.selectType = 0;
	p.allItems = nil;
	p.groupItems = nil;
end

--��ȡ��Ʒ��,��Ʒ��
function p.SelectItemName(id)
	local itemTable = SelectRowList(T_EQUIP,"id",id);
	if #itemTable >= 1 then
		local text = itemTable[1].name;
		return text;
	else
		WriteConErr("itemTable error ");
	end
end


--��ȡ��Ʒ����Ʒ��Ϣ
function p.SelectItem(id)
	local itemTable = SelectRowList(T_EQUIP,"id",id);
	if #itemTable == 1 then
		local item = itemTable[1];
		return item;
	else
		WriteConErr("itemTable error ");
	end
end

--��ȡװ���ȼ���������Ϣ
function p.SelectEquipConfig(level)
	
	local itemTable = SelectRowList(T_EQUIP_LEVEL,"equip_level",level);
	if #itemTable >= 1 then
		local item = itemTable[1];
		return item;
	else
		WriteConErr("equip_level itemTable error ");
	end
end

--��ȡװ���ȼ���Ӧ�ľ���
function p.SelectEquipCofig4Exp(level)
	local item = p.SelectEquipConfig(level);
	if item then
		return item.exp;
	end
end

function p.SelectPlayerEquipLimit(playerLevel)
	local itemTable = SelectRowList(T_PLAYER_LEVEL,"level",playerLevel);
	if #itemTable >= 1 then
		local item = itemTable[1];
		return item.equip_upgrade_limit;
	else
		WriteConErr("itemTable error ");
	end
end

------------------------------------------------------------------����----------------------------------------------------------------------
--List����
function p.OnSendReq()
	
	local uid = GetUID();
	if uid == 0 or uid == nil  then
		return ;
	end;
	
	local param = "";--string.format("&card_unique_id=%s",cardUniqueId)
	SendReq("Equip","EquipmentList",uid,param);		
end


function p.OnResult(result)
	if result == true then
		p.allItems = nil;
		p.groupItems = nil;
		p.dataChanged = true;
		p.OnSendReq();
	else
		if p.callback then
			p.callback(true);
		end
		p.CloseUI();
	end
end


--���緵�ؿ���ϸ��Ϣ
function p.OnLoadList(msg)
	
	WriteCon( "** OnLoadList21" );
	
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	
	if msg.result == true then
		
		p.allItems = msg.equipment_info;
		p.divideItems()
		
		p.refreshTab();
		--p.ShowList(msg.equipment_info or {})
		
		WriteCon( "** OnLoadList1 " .. #msg.equipment_info);
	else
		--local str = mail_main.GetNetResultError(msg);
		--if str then
			--dlg_msgbox.ShowOK(GetStr("mail_erro_title"), str,nil);
		--else
		--	WriteCon("**======mail_write_mail.NetCallback error ======**");
		--end
		--TODO...
		WriteCon( "** OnLoadList2" );
	end
	--[[ ���ݽṹ
		card_info: {
		UniqueID: "10000272",
		UserID: "123456",
		CardID: "101",
		Race: "1",
		Class: "2",
		Level: "1",
		Level_max: "60",
		Exp: "0",
		Damage_type: "1",
		Bind: "0",
		Team_marks: "0",
		Signature: "0",
		Rare: "2",
		Rare_max: "6",
		Hp: "400",
		Attack: "200",
		Defence: "90",
		Speed: "5",
		Skill: "0",
		Crit: "10",
		Item_id1: "33450",
		Item_id2: "0",
		Item_id3: "33452",
		Gem1: "0",
			Gem2: "0",
		Gem3: "0",
		Price: "0",
		Time: "2013-11-30 13:51:45",
		Source: "0"
		}
		]]--
end