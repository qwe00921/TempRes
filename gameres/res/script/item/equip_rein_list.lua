


equip_rein_list = {}
local p = equip_rein_list;
p.layer = nil;
p.baseCardInfo = nil;

p.itemListInfo = nil;

p.consumeMoney = 0;
p.userMoney = 0;
p.addExp = 0;
p.nowExp = 0;
p.item = ni;

local ui = ui_card_rein_item;
p.callback = nil;
p.isReined = nil;
p.reinedItem = nil;

p.maskLayer = nil;

p.result = nil;

p.rookie_node = nil;

function p.ShowUI(item,callback)
	
	p.item = item;
	p.reinedItem = {};
	p.callback = callback
	
	if p.item == nil then
		return;
	end
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		p.InitUI(item);
		return;
	end
	
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	layer:NoMask();
    layer:Init();   
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddChild(layer);
    LoadDlg("card_rein_item.xui", layer, nil);

    p.layer = layer;
	p.InitUI(item);
	 p.SetDelegate(layer);	
end

function p.SetCardData(item)
	if p.layer ~= nil then 
		p.ShowUI(item);
		return;
	end	
end;	


function p.SetUserMoney(userMoney)
	p.userMoney	 = userMoney;
end;	


function p.copyTab(ori_tab)
    if (type(ori_tab) ~= "table") then  
        return nil  
    end  
	
    local new_tab = {}  
    for i,v in pairs(ori_tab) do  
        local vtyp = type(v)  
        if (vtyp == "table") then  
            new_tab[i] = p.copyTab(v)  
        elseif (vtyp == "thread") then  
            new_tab[i] = v  
        elseif (vtyp == "userdata") then  
            new_tab[i] = v  
        else  
            new_tab[i] = v  
        end  
    end  
    return new_tab 
end

function p.InitUI(item)
	
	local pEquipPic1 = GetImage(p.layer,ui.ID_CTRL_PICTURE_HEAD);
	if tonumber(item.itemId) ~= 0 then
		--local aniIndex = "item."..p.equip1.itemInfo.equip_id;
		local pEquipInfo= SelectRowInner( T_EQUIP, "id", item.itemId); 
		pEquipPic1:SetPicture( GetPictureByAni(pEquipInfo.item_pic,0) );
	else
		pEquipPic1:SetPicture(nil);
	end
	
	--����
	local lCardRowInfo= SelectRowInner( T_EQUIP, "id",item.itemId); --�ӱ��л�ȡ������ϸ��Ϣ					
	local lTextName = GetLabel(p.layer, ui.ID_CTRL_TEXT_NAME);
	lTextName:SetText(tostring(lCardRowInfo.name));
	p.reinedItem.name = tostring(lCardRowInfo.name);
	
	--������Ҫ����ֵ
	local labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTRIBUTE1NAME);
	local str = GetStr("card_equip_attr"..item.attrType)
	labelV:SetText(GetStr("card_equip_attr"..item.attrType));
	
	labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTRIBUTE);
	labelV:SetText(tostring(item.attrValue));
	p.reinedItem.attrValue = item.attrValue
	
	--��������ֵ2
	local labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTRIBUTE2NAME);
	
	if item.exType1 and tonumber(item.exType1) ~= 0 then
		labelV:SetText(GetStr("card_equip_attr"..item.exType1));
	
		labelV = GetLabel( p.layer, ui.ID_CTRL_TEXT_ATTRIBUTE2);
		labelV:SetText(tostring(item.exValue1));
		p.reinedItem.exValue1 = item.exValue1
	end
	
	
		
	--��ǰ����ֵ����
	p.nowExp = tonumber(item.itemExp);
	p.reinedItem.itemExp = item.itemExp;
		
	--�ȼ� ID_CTRL_TEXT_LEVEL		
	local lTextLev = GetLabel(p.layer, ui.ID_CTRL_TEXT_LEVEL);
	lTextLev:SetText( tostring(item.itemLevel) );
	p.reinedItem.itemLevel = item.itemLevel
	
	--��ǰ�ľ���ֵ�� ID_CTRL_EXP_CARDEXP
	local lCardLeveInfo= SelectRowInner( T_EQUIP_LEVEL, "level", tostring(item.itemLevel));
	if lCardLeveInfo then
		local lCardExp = GetExp(p.layer, ui.ID_CTRL_EXP_EQUIPEXP);
		lCardExp:SetTotal(tonumber(lCardLeveInfo.exp));
		lCardExp:SetProcess(tonumber(item.itemExp));
		lCardExp:SetNoText();
			
	--����ֵ ID_CTRL_TEXT_EXP
		local lTextExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_EXP);
		lTextExp:SetText(tostring(item.itemExp).."/"..tostring(lCardLeveInfo.exp));
	end
	
	
	p.ShowCardCost();

end	

function p.refreshItemList()
	p.consumeMoney = 0	
	p.addExp = 0;
	
	local lCount=0;
	--local lNum = #(p.itemListInfo)
	p.itemListInfo = p.itemListInfo or {};
	for i=1,10 do
		local lcardInfo = p.itemListInfo[i] or {};
		lCount = lCount + 1;
		p.SetCardInfo(lCount,lcardInfo);
	end
	
	p.ShowCardCost();
end;	

function p.ShowCardCost()
	
	local cardCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_GAIN_EXP);
	cardCount:SetText(tostring(p.addExp)); 
	
	local cardMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_FEE_MONEY);
	cardMoney:SetText(tostring(p.consumeMoney)); 
	
	p.userMoney = tonumber(msg_cache.msg_player.Money or 0);
	local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_USER_MONEY);
	moneyLab:SetText(tostring(p.userMoney));	
	
	if tonumber(p.userMoney) < tonumber(p.consumeMoney) then
		--local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
		cardMoney:SetFontColor(ccc4(255,0,0,255));
    else	
		cardMoney:SetFontColor(ccc4(255,255,255,255));
	end		
end;	

function p.SetCardInfo(pIndex,item)  --pIndex��1��ʼ
	if pIndex > 10 then --����������10
		return ;
	end
	
	local pEquipInfo= SelectRowInner( T_EQUIP, "id", tostring(item.equip_id)) or {};
	
	local cardLevText = GetLabel(p.layer, ui["ID_CTRL_TEXT_CARDLEVEL"..pIndex]);
	cardLevText:SetVisible(true);
	cardLevText:SetText((tostring(item.equip_level or "")));
			
	local cardButton = GetButton(p.layer, ui["ID_CTRL_BUTTON_CHA"..pIndex]);
		
	--cardButton:SetImage( GetPictureByAni("n_battle.attack_"..lcardId,0) );
	
	if pEquipInfo.item_pic then
	
		cardButton:SetImage( GetPictureByAni(pEquipInfo.item_pic or "",0)  );
	else
		cardButton:SetImage(nil);
	end
	
	local cardName = GetLabel(p.layer, ui["ID_CTRL_TEXT_NAME"..pIndex]);
	cardName:SetText(tostring(pEquipInfo.name or ""));
	

	local lCardLeveInfo;
	if item.equip_level == 0 then
		lCardLeveInfo= SelectRowInner( T_EQUIP_LEVEL, "level", "1");
	else
		lCardLeveInfo= SelectRowInner( T_EQUIP_LEVEL, "level", tostring(item.equip_level));
	end	
	
	if lCardLeveInfo then
		p.consumeMoney = p.consumeMoney + tonumber(lCardLeveInfo.feed_money);	
		p.addExp = p.addExp + tonumber(lCardLeveInfo.feed_exp);
	end
	
	if pEquipInfo.exp then
		p.addExp = p.addExp + tonumber(pEquipInfo.exp)
	end
	
end;

function p.InitAllCardInfo()
		
	local i;
	for i=1,10 do
		
		local tLevel= "ID_CTRL_TEXT_CARDLEVEL"..tostring(i);--��ť
		local tName = "ID_CTRL_TEXT_NAME"..tostring(i);--װ��ͼ����
		
		local cardLevText = GetLabel(p.layer, ui[tLevel]);
		cardLevText:SetVisible(false);
	
		local cardName = GetLabel(p.layer,ui[tName]);
		cardName:SetText("");
	end
	
end;	

function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end

function p.CloseUI()
    if p.layer ~= nil then
		equip_rein_select.CloseUI(); --���ȹ��ӽ���
		
	    p.layer:LazyClose();
        p.layer = nil;	
		p.baseCardInfo = nil;
		p.itemListInfo = nil;
		p.userMoney = 0;
		p.consumeMoney = 0;
		p.nowExp = 0;
		p.addExp = 0;
		p.result = nil;
    end
	
	if p.callback then
		p.callback(p.isReined);
	end
	p.callback = nil;
	p.isReined = nil
	p.rookie_node = nil;
	if p.maskLayer ~= nil then
		p.maskLayer:LazyClose();
		p.maskLayer = nil;
	end
end

function p.SetDelegate(layer)

	local starBtn = GetButton(layer, ui.ID_CTRL_BUTTON_START);
	starBtn:SetLuaDelegate(p.OnUIClickEvent);
	p.rookie_node = starBtn;

	local closeBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	closeBtn:SetLuaDelegate(p.OnUIClickEvent);
	

	for i=1,10 do
		local lCardBtn = GetButton(layer, ui["ID_CTRL_BUTTON_CHA"..i]);
		lCardBtn:SetLuaDelegate(p.OnButtonEvent);
	end
end

function p.GetRookieNode()
	return p.rookie_node;
end
	
function p.OnButtonEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	if IsClickEvent(uiEventType) then
		p.HideUI();
		equip_rein_select.ShowUI(p.itemListInfo,p.OnSelectCallback);
	end
end

function p.OnUIClickEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	local tag = uiNode:GetTag();
	WriteCon("tag = "..tag);
	WriteCon("ui.ID_CTRL_BUTTON_CHA1 : "..ui.ID_CTRL_BUTTON_CHA1);
	
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --����
			p.CloseUI();
		elseif(ui.ID_CTRL_BUTTON_START == tag) then --ǿ��
			p.upgrade();
			--equip_rein_result.ShowUI(p.item, p.reinedItem);
		end;
	end
end		

function p.ShowPackageUpgrade(pacageItem, callback)
	if pacageItem then
		local item = {};
		item.itemId 	= pacageItem.equip_id;
		item.itemUid	= pacageItem.id;
		item.itemType	= pacageItem.equip_type;
		item.itemLevel 	= pacageItem.equip_level;
		item.itemExp	= pacageItem.equip_exp;
		item.itemRank	= pacageItem.rare
		item.attrType	= pacageItem.attribute_type1;
		item.attrValue	= pacageItem.attribute_value1;
		item.attrGrow	= pacageItem.Attribute_grow or 0;
		item.exType1 	= pacageItem.attribute_type2;
		item.exValue1 	= pacageItem.attribute_value2;
		--item.exType2 	= pacageItem.Extra_type2;
		--item.exValue2 	= pacageItem.Extra_value2;
		--item.exType3	= pacageItem.Extra_type3;
		--item.exValue3	= pacageItem.Extra_value3;
		p.ShowUI(item,callback);
	end
end



function p.upgrade()
	
	if p.itemListInfo == nil or #p.itemListInfo <= 0 then
		dlg_msgbox.ShowOK("",GetStr("card_equip_up_item_null"),p.OnMsgCallback);
		return;
	end
	
	--�жϵ�ǰװ���ȼ��ǲ����������Ƶȼ�
	local playerLevel 	= tonumber(msg_cache.msg_player.Level);
	local playerEquipLimit		= p.SelectPlayerEquipLimit(playerLevel)
	
	if playerEquipLimit then
		
		local itemLevel = tonumber(p.item.itemLevel or 1);
		--WriteCon("=====itemLevel,plevel" .. itemLevel .. ","..playerLevel);
		if itemLevel >= tonumber(playerEquipLimit) then
			WriteCon("=====itemLevel");
			local str = string.format(GetStr("card_equip_up_lvl_limit"), tostring(playerLevel),tostring(playerEquipLimit) or "1")
			dlg_msgbox.ShowOK("",str,p.OnMsgCallback);
			return;
		end
	else
		WriteCon("=====playerEquipLimit");
			
	end
	
	--�ж��û���Ǯ������
	local userMoney = tonumber(msg_cache.msg_player.Money or 0);
	if p.consumeMoney and p.consumeMoney > userMoney then
		dlg_msgbox.ShowOK("",GetStr("card_equip_up_money_short"),p.OnMsgCallback);
		return;
	end
	
	local ids = "";
	local has5Rank = false;
	if p.itemListInfo then
		for i = 1, #p.itemListInfo do
			local equip =  p.itemListInfo[i];
			if equip then
				if i > 1 then
					ids = ids .. ",";
				end
				ids = ids .. equip.id;
				if equip and tonumber(equip.rare) >= 5 then
					has5Rank = true;
				end
			end
			
		end
	end
	
	if ids == "" or ids == nil then
		return;
	end
	
	--�ж��ǲ�����5�ǵ�װ�����ϳɵ�
	if has5Rank then
		p.upIds = ids;
		dlg_msgbox.ShowYesNo("",GetStr("card_equip_up_5rank"),p.ContinueUpgrade);
		return
	end
	
	p.reqUpgrade(p.item.itemUid, ids);
end

--��ʾ��ص�����
function p.OnMsgCallback(result)
	
	WriteCon("OnMsgCallback");
	
end

function p.SelectPlayerEquipLimit(playerLevel)
	local itemTable = SelectRowList(T_PLAYER_LEVEL,"level",tostring(playerLevel));
	if #itemTable >= 1 then
		local item = itemTable[1];
		return item.equip_upgrade_limit;
	else
		WriteConErr("itemTable error ");
	end
end

function p.ContinueUpgrade(ret)
	if ret then
		p.reqUpgrade(p.item.itemUid, p.upIds);
	end
end

function p.reqUpgrade(odId, ids)
	local uid = GetUID();
	
	
	if uid == 0 or uid == nil  or odId == nil or ids == nil then
		return ;
	end;
	
	local param = string.format("&base_user_card_id=%s&material_user_card_ids=%s",odId, ids);
	SendReq("Equip","AddPower",uid,param);	 
end

function p.OnNetUpgradeCallback(msg)
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		if msg.base_card_new_info then
			p.reinedItem.itemLevel = msg.base_card_new_info.equip_level or p.item.itemLevel;
			p.reinedItem.itemExp	= msg.base_card_new_info.equip_exp or p.item.itemExp;
			p.reinedItem.attrValue = msg.base_card_new_info.attribute_value1 or p.item.attrValue;
			p.reinedItem.exValue1  = msg.base_card_new_info.attribute_value2 or p.item.exValue1;
		end
		--dlg_msgbox.ShowOK(GetStr("card_equip_net_suc_titel"),GetStr("card_equip_upgrade_suc"));
		equip_rein_result.ShowUI(p.item, p.reinedItem);
		if msg.base_card_new_info then
			p.item.itemLevel = msg.base_card_new_info.equip_level;
			p.item.itemExp	= msg.base_card_new_info.equip_exp;
			p.item.attrValue = msg.base_card_new_info.attribute_value1;
			p.itemListInfo = nil;
			p.InitUI(p.item);
			p.refreshItemList();
		end
		
		p.isReined = true;
		
	else
		local str = dlg_card_equip_detail.GetNetResultError(msg);
		if str then
			dlg_msgbox.ShowOK(GetStr("card_equip_net_err_titel"), str,nil);
		else
			WriteCon("**======mail_write_mail.NetCallback error ======**");
		end
		--TODO...
	end
end



function p.OnSelectCallback(isChanged,lst)
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		
	end
	
	if isChanged == true then
		p.itemListInfo = lst or {};
		p.refreshItemList()
	
	end
	
	
end


function p.ClearData()
	p.itemListInfo = nil;
	p.cardListByProf = {};
	p.InitAllCardInfo();
	p.consumeMoney = 0	
	p.addExp = 0;
end



function p.OnServerBack( data )
	if not data.result then
		--dlg_msgbox.ShowOK( "����", data.message, nil, p.layer );
		return;
	end
	
	p.result = data;
	if p.maskLayer == nil then
		local layer = createNDUILayer();
		layer:Init();
		layer:SetFrameRectFull();
		layer:SetZOrder( 999999 );
		p.maskLayer = layer;
		GetUIRoot():AddChild( layer );
	end
	p.maskLayer:SetSwallowTouch( true );
	
	local batch1 = battle_show.GetNewBatch();

	local cmd = nil;
	for i = 1, #p.itemListInfo do
		local seq1 = batch1:AddSerialSequence();
		local node1 = GetImage( p.layer, ui["ID_CTRL_PICTURE_NODE".. i] );
		local cmd1 = createCommandEffect():AddFgEffect( 0.8, node1, "lancer.card_intensify_effect_1" );
		seq1:AddCommand( cmd1 );
		
		local cmdLua = createCommandLua():SetCmd( "item_rein_effect_end", i, 1, "" );
		seq1:AddCommand( cmdLua );
		
		cmd = cmd1;
	end
	
	local batch2 = battle_show.GetNewBatch();
	local seq2 = batch1:AddSerialSequence();
	local node2 = GetImage( p.layer, ui.ID_CTRL_PICTURE_162 );
	local cmd2 = createCommandEffect():AddFgEffect( 1.5, node2, "lancer.card_intensify_effect_2" );
	seq2:AddCommand( cmd2 );
	seq2:SetWaitEnd( cmd );
	
	local luaBatch = battle_show.GetNewBatch();
	local luaSeq = luaBatch:AddSerialSequence();
	local cmdLua = createCommandLua():SetCmd( "item_rein_converged", 1, 1, "" );
	luaSeq:AddCommand( cmdLua );
	luaSeq:SetWaitEnd( cmd2 );
	
	local batch3 = battle_show.GetNewBatch();
	local seq3 = batch3:AddSerialSequence();
	local node3 = GetImage( p.layer, ui.ID_CTRL_PICTURE_163 );
	node3:SetFrameRect( node2:GetFrameRect() );
	local cmd3 = createCommandEffect():AddActionEffect( 0.35, node3, "lancer_cmb.card_intensify_move" );
	seq3:AddCommand( cmd3 );
	seq3:SetWaitEnd( cmd2 );
	
	local env = cmd3:GetVarEnv();
	
	local center1 = node3:GetCenterPos();
	local card = GetImage( p.layer, ui.ID_CTRL_PICTURE_HEAD );	
	local center2 = card:GetCenterPos();
	env:SetFloat( "$1", center2.x - center1.x );
	env:SetFloat( "$2", center2.y - center1.y );
	
	local luaBatch1 = battle_show.GetNewBatch();
	local luaSeq1 = luaBatch1:AddSerialSequence();
	local cmdLua1 = createCommandLua():SetCmd( "item_rein_move_end", 1, 1, "" );
	luaSeq1:AddCommand( cmdLua1 );
	luaSeq1:SetWaitEnd( cmd3 );
end

function p.ConvergedEnd()
	local node = GetImage( p.layer, ui.ID_CTRL_PICTURE_163 );
	local node1 = GetImage( p.layer, ui.ID_CTRL_PICTURE_162 );
	node:SetFrameRect( node1:GetFrameRect() );
	node:SetVisible( true );
	if not node:HasAniEffect( "lancer_cmb.card_intensify_effect_3" ) then
		node:AddFgEffect( "lancer_cmb.card_intensify_effect_3" );
	end
end

function p.EffectMoveEnd()
	WriteConWarning( "moveEnd" );
	if p.maskLayer ~= nil then
		p.maskLayer:SetSwallowTouch( false );
	end

	--card_intensify_succeed.ShowUI(p.baseCardInfo);
	--card_intensify_succeed.ShowCardLevel( p.result );
	p.OnNetUpgradeCallback( p.result );
	--p.HideUI();
end

function p.HideSelectCard( id, num )
	--local lCardSprite = "ID_CTRL_SPRITE_"..tostring(id);--cardpic
	--local cardSprite = GetPlayer(p.layer, ui[lCardSprite]);
	--cardSprite:SetVisible(false);
	
	local cardButton = GetButton(p.layer, ui["ID_CTRL_BUTTON_CHA"..id]);
	cardButton:SetImage( nil );
end



