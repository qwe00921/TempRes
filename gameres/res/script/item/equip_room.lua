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

equip_room = {}
local p = equip_room;
local ui = ui_equip_room;
local ui_list = ui_equip_room_list;

p.sortBtnMark = MARK_OFF;	--�����������Ƿ���
p.equlip_list = {};
p.sortByRuleV = nil;
p.cardListByProf = {};
p.curBtnNode = nil;
p.newEquip = {};
p.msg = nil;
--��ʾUI
function p.ShowUI(card)
    
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
    LoadDlg("equip_room.xui", layer, nil);
	
	p.layer = layer;
	p.card = card;
	p.SetDelegate();
	p.LoadEquipData();
end

--�����¼�����
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
		if ( ui.ID_CTRL_BUTTON_RETURN == tag ) then	
			p.CloseUI();
		elseif (ui.ID_CTRL_BUTTON_SELL == tag) then --����
			equip_sell.ShowUI(p.msg);
		elseif (ui.ID_CTRL_BUTTON_ORDER == tag) then --����
			equip_bag_sort.ShowUI(1);
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
	p.equlip_list = msg.equipment_info;
	p.cardListByProf  = msg.equipment_info;
	p.msg = msg;
	local labRoomNum = GetLabel(p.layer, ui.ID_CTRL_TEXT_NUM); 
	labRoomNum:SetText(tostring(#p.equlip_list).."/"..tostring(msg.equip_room_limit)); 	
	p.refreshList(msg.equipment_info);
	
end

--��ʾ�б�
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
		
		--�����б���Ϣ��һ��4�ſ���
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

--��ʾ���ſ���
function p.ShowEquipInfo( view, equip, index ,dataListIndex)
	
	
	local indexStr = tostring(index);
	local btTagStr 	= "ID_CTRL_BUTTON_ITEM_"..indexStr;--��ť
	local imgBdTagStr= "ID_CTRL_PICTURE_BD_"..indexStr;--װ��ͼ
	local imgTagStr = "ID_CTRL_PICTURE_IMAGE_"..indexStr;--װ��ͼ����
	local lvTagStr 	= "ID_CTRL_TEXT_LV_"..indexStr;  --�ȼ�
	local drsTagStr = "ID_CTRL_TEXT_DRESSED_"..indexStr; --�Ƿ���װ��
	local nmTagStr  = "ID_CTRL_TEXT_NAME_"..indexStr; --װ����
	local nmBgTagStr= "ID_CTRL_PICTURE_NM_BG_"..indexStr;--װ��������

	
	local bt 	= GetButton(view, ui_list[btTagStr]);
	local imgV= GetImage(view, ui_list[imgBdTagStr]);
	local imgBdV	= GetImage(view, ui_list[imgTagStr]);
	local lvV 	= GetLabel(view, ui_list[lvTagStr]);
	local drsV	= GetLabel(view, ui_list[drsTagStr]);
	local nmV	= GetLabel(view, ui_list[nmTagStr]);
	local nmBgV	= GetImage(view, ui_list[nmBgTagStr]);
	
	drsV:SetVisible( false );
	
	--��ť�����¼�
	bt:SetLuaDelegate(p.OnItemClickEvent);
	bt:RemoveAllChildren(true);
	bt:SetId(dataListIndex);
	bt:SetVisible(true);
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", equip.equip_id); --�ӱ��л�ȡ������ϸ��Ϣ	
	
	--��ʾ����ͼƬ ����ͼ
	imgV:SetPicture( GetPictureByAni(pEquipInfo.item_pic, 0) );
	imgV:SetVisible(true);
	imgBdV:SetVisible(true);
	
	
	--��ʾ�ȼ�
	lvV:SetText("LV." .. (equip.Equip_level or "1"));
	lvV:SetVisible(true);
	--�Ƿ���װ��
	if tonumber(equip.Is_dress) == 1 then
		drsV:SetVisible(true);
	end
	
	--����
	nmV:SetText(pEquipInfo.name or "");
	nmV:SetVisible(true);
	nmBgV:SetVisible(true);
	
	
	
end

function p.OnItemClickEvent(uiNode, uiEventType, param)
	local equipOne = p.newEquip[uiNode:GetId()];
	dlg_card_equip_detail.ShowUI(equipOne);
end


function p.InitViewUI(view)
	local btTagStr 	= nil;--��ť
	local imgTagStr = nil;--װ��ͼ����
	local lvTagStr 	= nil;  --�ȼ�
	local drsTagStr = nil; --�Ƿ���װ��
	local nmTagStr  = nil; --װ����
	local nmBgTagStr= nil;--���Ʊ���
	local imgBdTagStr=nil;--װ��ͼ
	
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

    end

end

