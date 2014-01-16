--------------------------------------------------------------
-- FileName:    dlg_item_sell.lua
-- author:      hst, 2013年9月5日
-- purpose:     道具出售
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
---------显示UI----------
function p.ShowUI( msg )
    if msg == nil then
        return ;
    end
    p.equlip_list = msg.equipment_info;
	p.countNum = msg.equip_room_limit;
	p.cardListByProf  = msg.equipment_info;
    if p.layer ~= nil then
        p.layer:SetVisible( true );
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
end

function p.ShowInfo()
	
	local labRoomNum = GetLabel(p.layer, ui.ID_CTRL_TEXT_NUM); 
	labRoomNum:SetText(tostring(#p.equlip_list).."/"..tostring(p.countNum) ); 	
	p.refreshList(p.equlip_list);
	
end





--显示列表
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
	
	if  tonumber(p.selectNum) >= 10 then 
		p.setAllCardDisEnable();
	elseif tonumber(p.selectNum) < 10 then
		p.setCardDisEnable();
	end
	p.setNumFalse();
	
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
	--选中序号
	p.allNumText[equip.id] = nmV;
	p.allEquipId[equip.id] = equip.equip_id;
	--图片按钮
	p.equipListNode[#p.equipListNode + 1] = bt;
	--装备等级
	p.equipLevel[equip.id] = equip.equip_level;
	
	
end
--点击卡牌事件
function p.OnItemClickEvent(uiNode, uiEventType, param)
	local equipId = uiNode:GetId();
	local equipSelectText = p.allNumText[equipId] ;
	local equipIde = p.allEquipId[equipId];
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", equipIde); --从表中获取卡牌详细信息	
	local pEquipLevel = tonumber(p.equipLevel[equipId]);
	if p.isDress[equipId] ~=1 then
		if equipSelectText:IsVisible() == true then
			equipSelectText:SetText("");
			equipSelectText:SetVisible(false);
			
			for k,v in pairs(p.selectList) do
				if v == equipId then
					table.remove(p.selectList,k);
				end
			end
			p.consumeMoney = p.consumeMoney - pEquipInfo.sell_price-(pEquipLevel*pEquipLevel);
			p.setNumFalse();
			p.selectNum = p.selectNum-1;
		else
			if p.selectNum < 10 then
				equipSelectText:SetVisible(true);
				p.selectList[#p.selectList + 1] = equipId;
				p.selectNum = p.selectNum + 1;
				equipSelectText:SetText(tostring(p.selectNum));
				p.consumeMoney = p.consumeMoney + pEquipInfo.sell_price+(pEquipLevel*pEquipLevel);
			end
		end
	else
		dlg_msgbox.ShowOK(GetStr("equip_sell_title"),GetStr("equip_is_dress"),p.OnOkCallback,p.layer);
	end
	
	
	local equipCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_MATTER_NUM);
	equipCount:SetText(tostring(p.selectNum).."/10"); 
	
	local equipSellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_SELL_GOLD);
	equipSellMoney:SetText(tostring(p.consumeMoney)); 
		
	if  tonumber(p.selectNum) >= 10 then 
		p.setAllCardDisEnable();
	elseif tonumber(p.selectNum) < 10 then
		p.setCardDisEnable();
	end
end

function p.OnOkCallback()
	WriteCon("equip_is_dress");
end
	
--按规则排序按钮
function p.sortByBtnEvent(sortType)
	WriteCon("sortType = "..sortType);
	if sortType == nil then
		return;
	end
	local sortByBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_ORDER);
	--sortByBtn:SetLuaDelegate(p.OnUIEvent);
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
--按等级排序
function p.sortByLevel(a,b)
	return tonumber(a.equip_level) > tonumber(b.equip_level);
end

--按星级排序
function p.sortByStar(a,b)
	--return tonumber(a.rare) < tonumber(b.rare);
	return tonumber(a.rare) < tonumber(b.rare) or ( tonumber(a.rare) == tonumber(b.rare) and tonumber(a.equip_id) < tonumber(b.equip_id));
end
--清除方法
function p.clearDate()
	if p.selectNum == 0 then
		return;
	end 
	for k,v in pairs(p.selectList) do
			--WriteCon("k : "..k);
			local numText = p.allNumText[v];
			numText:SetText("");
	end
	p.selectNum  = 0;
	p.selectList = {};
	p.setCardDisEnable();
	p.consumeMoney = 0;
	
	local equipCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_MATTER_NUM);
	equipCount:SetText(tostring(p.selectNum).."/10"); 
	
	local equipSellMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_SELL_GOLD);
	equipSellMoney:SetText(tostring(p.consumeMoney)); 
	
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
			numText:SetVisible(true);
	end

end
--初始化卡牌列表
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


--设置UI界面上的事件处理
function p.SetDelegate(layer)
	
    local backBtn = GetButton(layer,ui.ID_CTRL_BUTTON_RETURN);
    backBtn:SetLuaDelegate(p.OnUIEvent);
    
    local orderBtn = GetButton(layer,ui.ID_CTRL_BUTTON_ORDER);
    orderBtn:SetLuaDelegate(p.OnUIEvent);
    
    local clearBtn = GetButton(layer,ui.ID_CTRL_BUTTON_CLEAR);
    clearBtn:SetLuaDelegate(p.OnUIEvent);
    
    local sellBtn = GetButton(layer,ui.ID_CTRL_BUTTON_SELL);
    sellBtn:SetLuaDelegate(p.OnUIEvent);
    
end

--事件处理
function p.OnUIEvent(uiNode, uiEventType, param)
	WriteCon("button OnUIEvent");
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        --确认出售
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
--金币确认框点确认后 申请新装备的数据 
function p.OnCallback()
	
	WriteCon("OnCallback!");
	p.LoadEquipData();
	
end
--确认卖出对话框 后发送请求
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
--装备售出成功回调

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
--确认买出成功后跳出获得金币对话框
function p.sellResult(msg)
	local money = msg.money;
	dlg_msgbox.ShowOK(GetStr("equip_sell_title"),GetStr("card_sale")..tostring(money.Add)..GetStr("card_sale_money"),p.OnCallback,p.layer);
end

--卡牌卖出后重新申请装备列表的数据后回调方法
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
end

--售出卡牌请求 http://fanta2.sb.dev.91.com/index.php?command=Equip&action=Sell&user_id=123456&id=60174,60175&V=100&R=100&MachineType=WIN32
--http://fanta2.sb.dev.91.com/index.php?command=Equip&action=Sell&user_id=112&60185&R=80&V=77&MachineType=WIN32
--http://fanta2.sb.dev.91.com/index.php?command=Equip&action=Sell&user_id=112&id=60179&V=100&R=100&MachineType=WIN32
function p.LoadEquipSell(param)
	WriteCon("**载入装备列表**");
	local uid = GetUID();
	if uid == 0 or uid == nil then
        return ;
    end;
	local param2 = "id=" .. param;
	--SendReq("Equip","EquipmentList", uid, param);
	SendReq("Equip","Sell", uid,param2);
end
--隐藏UI
function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end
--关闭UI
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
		
    end
end