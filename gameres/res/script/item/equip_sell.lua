--------------------------------------------------------------
-- FileName:    dlg_item_sell.lua
-- author:      hst, 2013��9��5��
-- purpose:     ���߳���
--------------------------------------------------------------
CARD_BAG_SORT_BY_LEVEL	= 1001;
CARD_BAG_SORT_BY_STAR	= 1002;

MARK_ON = 100;
MARK_OFF = nil;

equip_sell = {}
local p = equip_sell;
local ui = ui_equip_sell_list;
local ui_list = ui_equip_sell_select_list;
p.layer = nil;
p.equlip_list = nil;
p.countNum = nil;
p.allNumText={};
p.selectNum = 0;
p.selectList = {};
p.consumeMoney = 0;
p.allEquipId = {};
p.equipListNode = {};
p.equipEnabled = true;
p.cardListByProf = {};
p.isDress = {};
p.equipLevel = {};
---------��ʾUI----------
function p.ShowUI( msg )
    if msg == nil then
        return ;
    end
    p.equlip_list = msg.equipment_info;
	p.countNum = msg.equip_room_limit;
	p.cardListByProf  = msg.equipment_info;
    if p.layer ~= nil then
        p.layer:SetVisible( true );
		equip_sell_statistics.layer:SetVisible( true );
        return ;
    end
    
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    layer:NoMask();
    layer:Init();
    GetUIRoot():AddDlg( layer );
    LoadDlg("equip_sell_list.xui", layer, nil);
    
    p.SetDelegate(layer);
    p.layer = layer;    
	p.ShowInfo();
	equip_sell_statistics.ShowUI();
end

function p.ShowInfo()
	
	if p.equlip_list ~= nil then
		
		local labRoomNum = GetLabel(p.layer, ui.ID_CTRL_TEXT_NUM); 
		labRoomNum:SetText(tostring(#p.equlip_list).."/"..tostring(p.countNum) ); 	
		p.refreshList(p.equlip_list);
	else
		local labRoomNum = GetLabel(p.layer, ui.ID_CTRL_TEXT_NUM); 
		labRoomNum:SetText("0/"..tostring(p.countNum) ); 	
		p.refreshList(p.equlip_list);
	end
	
	
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
	
	if p.allNumText ~= nil then
		p.allNumText = {};
		p.allEquipId = {};
		p.equipListNode = {};
		p.isDress = {};
		p.equipLevel = {};
	end
	
	WriteCon("cardCount ===== "..#lst);
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
	
	if  tonumber(p.selectNum) >= 10 then 
		p.setAllCardDisEnable();
	elseif tonumber(p.selectNum) < 10 then
		p.setCardDisEnable();
	end
	p.setNumFalse();
	
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
	
    lvImg:SetVisible(true);
	drsV:SetVisible( false );
	namePic:SetVisible(true);
	
	--��ť�����¼�
	bt:SetLuaDelegate(p.OnItemClickEvent);
	bt:RemoveAllChildren(true);
	bt:SetVisible(true);
	bt:SetId(tonumber(equip.id));
	
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", equip.equip_id); --�ӱ��л�ȡ������ϸ��Ϣ	

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

	--ѡ�����
	p.allNumText[equip.id] = selImg;
	p.allEquipId[equip.id] = equip.equip_id;
	--ͼƬ��ť
	p.equipListNode[#p.equipListNode + 1] = bt;
	--װ���ȼ�
	p.equipLevel[equip.id] = equip.equip_level;
	
	for k,v in pairs(p.selectList) do
		if v == equip.id then
			local levelConfig= SelectRowInner( T_EQUIP_LEVEL, "level", tostring(equip.equip_level));
			if levelConfig then
				p.consumeMoney = p.consumeMoney + tonumber(levelConfig.feed_money);
			end
			
			selImg:SetVisible(true);
			--nmV:SetText(tostring(k));
			
			--local equipCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_EQUIP_SEL_NUM);
			--equipCount:SetText(tostring(k).."/10");
			
			--local equipSellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_MONEY);
			--equipSellMoney:SetText(tostring(p.consumeMoney));
		end
	end
end
--��������¼�
function p.OnItemClickEvent(uiNode, uiEventType, param)
	local equipId = uiNode:GetId();
	local equipSelectText = p.allNumText[equipId] ;
	local equipIde = p.allEquipId[equipId];
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", equipIde); --�ӱ��л�ȡ������ϸ��Ϣ	
	local pEquipLevel = tonumber(p.equipLevel[equipId]);
	if p.isDress[equipId] ~=1 then
		if equipSelectText:IsVisible() == true then
			--equipSelectText:SetText("");
			equipSelectText:SetVisible(false);
			
			for k,v in pairs(p.selectList) do
				if v == equipId then
					table.remove(p.selectList,k);
				end
			end
			
			if p.selectNum ~= 0 then
				p.selectNum = p.selectNum-1;
				p.consumeMoney = p.consumeMoney - pEquipInfo.sellprice-(pEquipLevel*pEquipLevel);
				p.setNumFalse();
			end
			
		else
			if p.selectNum < 10 then
				equipSelectText:SetVisible(true);
				p.selectList[#p.selectList + 1] = equipId;
				p.selectNum = p.selectNum + 1;
				--equipSelectText:SetText(tostring(p.selectNum));
				equipSelectText:SetPicture(GetPictureByAni("common_ui.card_num", p.selectNum));
				p.consumeMoney = p.consumeMoney + pEquipInfo.sellprice+(pEquipLevel*pEquipLevel);
			end
		end
	else
		dlg_msgbox.ShowOK(GetStr("equip_sell_title"),GetStr("equip_is_dress"),p.OnOkCallback,p.layer);
	end
	
	--[[
	local equipCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_MATTER_NUM);
	equipCount:SetText(tostring(p.selectNum).."/10"); 
	
	local equipSellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_SELL_GOLD);
	equipSellMoney:SetText(tostring(p.consumeMoney)); 
		]]--
	equip_sell_statistics.setSellMoney(p.consumeMoney);
	equip_sell_statistics.setSellCardNum(p.selectNum);
	if  tonumber(p.selectNum) > 10 then 
		p.setAllCardDisEnable();
	elseif tonumber(p.selectNum) <= 10 then
		p.setCardDisEnable();
	end
end

function p.OnOkCallback()
	WriteCon("equip_is_dress");
end
	
--����������ť
function p.sortByBtnEvent(sortType)
	WriteCon("sortType = "..sortType);
	if sortType == nil then
		return;
	end
	local sortByBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ORDER);
	sortByBtn:SetLuaDelegate(p.OnUIEvent);
	local sortByImg = GetImage(p.layer, ui.ID_CTRL_PICTURE_172);
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
	WriteCon("sortByRule2 ......");
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
	return tonumber(a.equip_level) > tonumber(b.equip_level);
end

--���Ǽ�����
function p.sortByStar(a,b)
	--return tonumber(a.rare) < tonumber(b.rare);
	return tonumber(a.rare) < tonumber(b.rare) or ( tonumber(a.rare) == tonumber(b.rare) and tonumber(a.equip_id) < tonumber(b.equip_id));
end
--�������
function p.clearDate()
	if p.selectNum == 0 then
		return;
	end 
	for k,v in pairs(p.selectList) do
			--WriteCon("k : "..k);
			local numText = p.allNumText[v];
			--numText:SetText("");
			numText:SetVisible(false);
			
	end
	p.selectNum  = 0;
	p.selectList = {};
	p.setCardDisEnable();
	p.consumeMoney = 0;
	
	
	--[[
	local equipCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_MATTER_NUM);
	equipCount:SetText(tostring(p.selectNum).."/10"); 
	
	local equipSellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_SELL_GOLD);
	equipSellMoney:SetText(tostring(p.consumeMoney)); 
	]]--
end

--���ó�ѡ����Ŀ��Ʋ��ɵ�
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

--���ÿ��ƿɵ�
function p.setCardDisEnable()
	for i=1, #p.equipListNode do
		local uiNode = p.equipListNode[i]
		uiNode:SetEnabled(true);
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
--��ʼ�������б�
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
	end;
end;


--����UI�����ϵ��¼�����
function p.SetDelegate(layer)
	
    local backBtn = GetButton(layer,ui.ID_CTRL_BUTTON_RETURN);
    backBtn:SetLuaDelegate(p.OnUIEvent);
    
    local orderBtn = GetButton(layer,ui.ID_CTRL_BUTTON_ORDER);
    orderBtn:SetLuaDelegate(p.OnUIEvent);
    --[[
    local clearBtn = GetButton(layer,ui.ID_CTRL_BUTTON_CLEAR);
    clearBtn:SetLuaDelegate(p.OnUIEvent);
    
    local sellBtn = GetButton(layer,ui.ID_CTRL_BUTTON_SELL);
    sellBtn:SetLuaDelegate(p.OnUIEvent);
    ]]--
end

--�¼�����
function p.OnUIEvent(uiNode, uiEventType, param)
	WriteCon("button OnUIEvent");
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        --ȷ�ϳ���
        if ( ui.ID_CTRL_BUTTON_RETURN == tag ) then
			
            p.CloseUI();   
			equip_room.ShowUI();        
        elseif ( ui.ID_CTRL_BUTTON_ORDER == tag ) then
            
			equip_bag_sort.ShowUI(2);
        elseif ( ui.ID_CTRL_BUTTON_CLEAR == tag ) then 
            
			p.clearDate();
        elseif ( ui.ID_CTRL_BUTTON_SELL == tag ) then 
			if p.selectNum == 0 then
				dlg_msgbox.ShowOK(GetStr("equip_sell_title"),GetStr("equip_sell_nul"),p.OnMsgCallback,p.layer);
			else
				dlg_msgbox.ShowYesNo(GetStr("equip_sell_title"),GetStr("equip_sell_cont")..tostring(p.selectNum)..GetStr("equip_sell_cont_2"),p.OnMsgBoxCallback,p.layer);
			end
						
        end     
    end
end
function p.OnMsgCallback()
	
	WriteCon("equip id is nul!");
end
--���ȷ�Ͽ��ȷ�Ϻ� ������װ�������� 
function p.OnCallback()
	
	WriteCon("OnCallback!");
	p.LoadEquipData();
	p.clearDate();	
end
--ȷ�������Ի��� ��������
function p.OnMsgBoxCallback(result)
	
	if result == true then
		local param = "";
		for k,v in pairs(p.selectList) do
						
			if k == #p.selectList then
				param = param..v;
			else
				param = param..v..",";
			end
		end
		p.LoadEquipSell(param);     
	elseif result == false then
		WriteCon("false");
	end
	
	
end
--װ���۳��ɹ��ص�

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
--ȷ������ɹ���������ý�ҶԻ���
function p.sellResult(msg)
	local money = msg.money;
	dlg_msgbox.ShowOK(GetStr("equip_sell_title"),GetStr("card_sale")..tostring(money.Add)..GetStr("card_sale_money"),p.OnCallback,p.layer);
end

--������������������װ���б�����ݺ�ص�����
function p.update(msg)
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	p.allNumText={};
	p.selectNum = 0;
	p.selectList = {};
	p.consumeMoney = 0;
	p.allEquipId = {};
	p.equipListNode = {};
	p.equlip_list = msg.equipment_info;
	p.countNum = msg.equip_room_limit;
	p.cardListByProf  = msg.equipment_info;
	p.ShowInfo();
	equip_sell_statistics.Init();
end

--�۳��������� http://fanta2.sb.dev.91.com/index.php?command=Equip&action=Sell&user_id=123456&id=60174,60175&V=100&R=100&MachineType=WIN32
--http://fanta2.sb.dev.91.com/index.php?command=Equip&action=Sell&user_id=112&60185&R=80&V=77&MachineType=WIN32
--http://fanta2.sb.dev.91.com/index.php?command=Equip&action=Sell&user_id=112&id=60179&V=100&R=100&MachineType=WIN32
function p.LoadEquipSell(param)
	WriteCon("**����װ���б�**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	local param2 = "id=" .. param;
	--SendReq("Equip","EquipmentList", uid, param);
	SendReq("Equip","Sell", uid,param2);
end
--����UI
function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end 
	if equip_sell_statistics.layer ~= nil then
		 equip_sell_statistics.layer:SetVisible( false );
    end 
end
--�ر�UI
function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		p.equlip_list = nil;
		p.countNum = nil;
		p.allNumText={};
		p.selectNum = 0;
		p.selectList = {};
		p.consumeMoney = 0;
		p.allEquipId = {};
		p.equipListNode = {};
		p.cardListByProf = {};
		p.isDress = {};
		p.equipLevel = {};
		equip_sell_statistics.CloseUI();
    end
end