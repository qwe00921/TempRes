--------------------------------------------------------------
-- FileName: 	dlg_card_attr_base.lua
-- author:		hst, 2013/11/29
-- purpose:		卡牌基本信息界面
--------------------------------------------------------------
dlg_card_attr_base = {}
local p = dlg_card_attr_base;
p.layer = nil;
p.cardInfo = nil;
p.cardDetail = nil;

p.groupFlag = false;
p.mainUIFlag = false;

--id是UniqueId
function p.ShowUI(cardInfo, groupFlag, mainUIFlag)
	WriteCon(cardInfo.CardID.."************");
	
	if groupFlag ~= nil then
		p.groupFlag = groupFlag;
	end
	
	if mainUIFlag ~= nil then
		p.mainUIFlag = mainUIFlag;
		WriteCon( "asdasdasdasdasdasdsa " );
		dlg_menu.SetNewUI( p );
	end
	
	if cardInfo == nil then
		return;
	end
	p.cardInfo = cardInfo;
	 if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
	
	--layer:NoMask();
	layer:Init();	
	GetUIRoot():AddDlg( layer );
    LoadDlg("dlg_card_attr_base.xui", layer, nil);
	p.layer = layer;
    p.SetDelegate(layer);
	
	cardInfo.UniqueId = cardInfo.UniqueId or cardInfo.UniqueID;
	
	p.LoadCardDetail(cardInfo.UniqueId);
end

function p.SetDelegate(layer)
	layer = layer or p.layer;
	
	
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardInfo.CardID); --从表中获取卡牌详细信息	
	local pCardInfo2= SelectRowInner( T_CARD, "id", p.cardInfo.CardID);
	local pCardUpLevelInfo= SelectRowInner( T_CARD_LEVEL, "level", tonumber(p.cardInfo.Level)+1);
	
	--缘份
	local pLabLuckIntro = GetLabel(layer,ui_dlg_card_attr_base.ID_CTRL_LUCK_INTRO);
	pLabLuckIntro:SetText(pCardInfo.luck_intro);
	
	
	
	--------------------------------------------------------------------------
	--卡牌图片
	local pImgCardPic = GetImage(layer, ui_dlg_card_attr_base.ID_CTRL_CARD_PICTURE); --卡牌图片控件
	local pImage = GetPictureByAni(pCardInfo.card_pic,0)--卡牌图片
	pImgCardPic:SetPicture(pImage);
	
	
	--卡牌名字
	local pLableName = GetLabel(layer,ui_dlg_card_attr_base.ID_CTRL_TEXT_CARDNAME);
	pLableName:SetText(pCardInfo2.Name);
	--卡牌星级 ID_CTRL_PICTURE_CARDSTAR Rare
	local pPicCardStar = GetImage( layer, ui_dlg_card_attr_base.ID_CTRL_PICTURE_CARDSTAR );
	if p.cardInfo.Rare == 1 then
		pPicCardStar:SetPicture(GetPictureByAni("ui.card_star",0));
	elseif p.cardInfo.Rare == 2 then
		pPicCardStar:SetPicture(GetPictureByAni("ui.card_star",1));
	elseif p.cardInfo.Rare == 3 then
		pPicCardStar:SetPicture(GetPictureByAni("ui.card_star",2));
	elseif p.cardInfo.Rare == 4 then
		pPicCardStar:SetPicture(GetPictureByAni("ui.card_star",3));
	elseif p.cardInfo.Rare == 5 then
		pPicCardStar:SetPicture(GetPictureByAni("ui.card_star",4));
	elseif p.cardInfo.Rare == 6 then
		pPicCardStar:SetPicture(GetPictureByAni("ui.card_star",5));
	elseif p.cardInfo.Rare == 7 then
		pPicCardStar:SetPicture(GetPictureByAni("ui.card_star",6));
	end	
	 
	--卡牌属性 ID_CTRL_PICTURE_CARDNATURE element card_nature
	local pPicCardNature = GetImage( layer, ui_dlg_card_attr_base.ID_CTRL_PICTURE_CARDNATURE );
	if tonumber(pCardInfo2.element) == 1 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",0));
	elseif tonumber(pCardInfo2.element) == 2 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",1));
	elseif tonumber(pCardInfo2.element) == 3 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",2));
	elseif tonumber(pCardInfo2.element) == 4 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",3));
	elseif tonumber(pCardInfo2.element) == 5 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",4));
	elseif tonumber(pCardInfo2.element) == 6 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",5));
	end
	
	
	--返回
    local pBtnBack = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BUTTON_BACK);
    pBtnBack:SetLuaDelegate(p.OnUIEventEvolution);
	
	--强化
	local pBtnIntensify = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BTN_INTENSIFY);
    pBtnIntensify:SetLuaDelegate(p.OnUIEventEvolution);
	
	--装备按钮
	local bt = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_1);
    bt:SetLuaDelegate(p.OnUIEventEvolution);
	bt = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_2);
    bt:SetLuaDelegate(p.OnUIEventEvolution);
	bt = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_3);
    bt:SetLuaDelegate(p.OnUIEventEvolution);
		
	--ID_CTRL_TEXT_EQUIP1 T_EQUIP 装备名称
	local pLableEquip1 = GetLabel(layer,ui_dlg_card_attr_base.ID_CTRL_TEXT_EQUIP1);
	local pLableEquip2 = GetLabel(layer,ui_dlg_card_attr_base.ID_CTRL_TEXT_EQUIP2);
	local pLableEquip3 = GetLabel(layer,ui_dlg_card_attr_base.ID_CTRL_TEXT_EQUIP3);
	
	
	--装备图片
	local pEquipPic1 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_1);
	if p.equip1 and tonumber(p.equip1.equipId) ~= 0 and p.equip1.itemInfo then
		--local aniIndex = "item."..p.equip1.itemInfo.Item_id;
		local pEquipInfo= SelectRowInner( T_EQUIP, "id", p.equip1.itemInfo.Item_id); 
		pEquipPic1:SetPicture( GetPictureByAni(pEquipInfo.item_pic,0) );
		pLableEquip1:SetText(pEquipInfo.name);
	else
		pEquipPic1:SetPicture(nil);
	end
	
	local pEquipPic2 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_2);
	if p.equip2 and tonumber(p.equip2.equipId) ~= 0 and p.equip2.itemInfo then
		--local aniIndex = "item."..p.equip2.itemInfo.Item_id;
		local pEquipInfo= SelectRowInner( T_EQUIP, "id", p.equip2.itemInfo.Item_id); 
		pEquipPic2:SetPicture( GetPictureByAni(pEquipInfo.item_pic,0) );
		pLableEquip2:SetText(pEquipInfo.name);
	else
		pEquipPic2:SetPicture(nil);
	end
	
	local pEquipPic3 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_3);
	if p.equip3 and tonumber(p.equip3.equipId) ~= 0 and p.equip3.itemInfo then
		--local aniIndex = "item."..p.equip3.itemInfo.Item_id;
		local pEquipInfo= SelectRowInner( T_EQUIP, "id", p.equip2.itemInfo.Item_id); 
		pEquipPic3:SetPicture( GetPictureByAni(pEquipInfo.item_pic,0) );
		pLableEquip3:SetText(pEquipInfo.name);
	else
		pEquipPic3:SetPicture(nil);
	end
	
	--卡牌等级
	local pLabCardGrad = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_GRADE);
	pLabCardGrad:SetText(GetStr("card_level")..tostring("  ")..tostring(p.cardInfo.Level));
	
	--卡牌HP
	local pLabCardHP = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_HP);
	pLabCardHP:SetText(GetStr("card_hp")..tostring("  ")..tostring(p.cardInfo.Hp));
	
	--卡牌攻击
	local pLabCardAttack = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_ATTACK);
	pLabCardAttack:SetText(GetStr("card_attack")..tostring("  ")..tostring(p.cardInfo.Attack));
	
	--卡牌速度
	local pLabCardSpeed = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_SPEED);
	pLabCardSpeed:SetText(GetStr("card_speed")..tostring("  ")..tostring(p.cardInfo.Speed));
	
	--卡牌防御
	local pLabCardDefense = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_DEFENSE);
	pLabCardDefense:SetText(GetStr("card_defence")..tostring("  ")..tostring(p.cardInfo.Defence));
	
	--卡牌Type type =1平衡型（各属性均衡成长）type =2耐力型（HP成长+10%，攻击成长-10%）type=3破坏型（攻击成长+10%，防御成长-10%）type=4守护型（防御成长+10%，攻击成长-10%）

	local pLabCardType = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_TEXT_TYPE);
	WriteCon("type = ".. tostring(pCardInfo2.type));
	if tonumber(pCardInfo2.type) == 1 then
		pLabCardType:SetText(GetStr("card_type")..tostring("  ")..GetStr("card_type1"));
	elseif tonumber(pCardInfo2.type) == 2 then
		pLabCardType:SetText(GetStr("card_type")..tostring("  ")..GetStr("card_type2"));
	elseif tonumber(pCardInfo2.type) == 3 then
		pLabCardType:SetText(GetStr("card_type")..tostring("  ")..GetStr("card_type3"));
	elseif tonumber(pCardInfo2.type) == 4 then
		pLabCardType:SetText(GetStr("card_type")..tostring("  ")..GetStr("card_type4"));
	else
		pLabCardType:SetText(GetStr("card_type")..tostring("  "));
	end
	--距离升级的经验是多少
	local pLabCardUpExp = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_TEXT_LEVELUPEXP);
	
	local upExp = tonumber(pCardUpLevelInfo.exp)-tonumber(p.cardInfo.Exp);
	pLabCardUpExp:SetText(GetStr("card_up_level")..tostring("  ")..tostring(upExp));
	
	local pLabSkillName = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_TEXT_SKILLNAME);
	local pLabSkillInfo = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_INTRO);
	--技能
	if  tonumber(pCardInfo2.skill) ~= 0 and  pCardInfo2.skill ~= nil then
		WriteCon("pCardInfo2.skill = "..tostring(pCardInfo2.skill));
		local pCardSkill= SelectRowInner( T_SKILL, "id", pCardInfo2.skill);
		pLabSkillName:SetText(pCardSkill.name); 
		pLabSkillInfo:SetText(pCardSkill.description); 
	end
	
	--经验条
	local expBar = GetExp( p.layer, ui_dlg_card_attr_base.ID_CTRL_EXP_44 );
	local expSstartNum = tonumber(p.cardInfo.Exp);
	local expLeast = 0;
	expbar_move_effect.showEffect(expBar,expLeast,tonumber(pCardUpLevelInfo.exp),expSstartNum,0);
	-------------------------------------------------------------------------------------------------
	--local T_ITEM     = LoadTable( "item.ini" );
	local pCardInfo= nil;
	
	--local cardInfo = msg.cardInfo;
	
	
	
	
end



function p.OnUIEventEvolution(uiNode, uiEventType, param)
	
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardInfo.cardID); --从表中获取卡牌详细信息	
	local pLabDowerIntro = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_INTRO);
	
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui_dlg_card_attr_base.ID_CTRL_BUTTON_BACK == tag then
			p.CloseUI();
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_INTENSIFY == tag then
			--卡牌强化
			card_intensify2.OnSendReq();
			card_rein.ShowUI(p.cardInfo);
			p.CloseUI();
			
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_SALE == tag then
			--卡牌卖出
			if p.cardInfo.Item_Id1 ~= 0 or  p.cardInfo.Gem1 ~= 0 then
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_sale_isitem"),p.OnMsgCallback,p.layer);
			elseif p.cardInfo.Team_marks== 1 then
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_sale_team"),p.OnMsgCallback,p.layer);
			elseif p.cardInfo.Rare >=  5 then
					dlg_msgbox.ShowYesNo(GetStr("card_caption"),GetStr("card_sale_rare")..tostring(p.cardInfo.Price)..GetStr("card_sale_sure"),p.OnMsgBoxCallback,p.layer);
			else	
				dlg_msgbox.ShowYesNo(GetStr("card_caption"),GetStr("card_sale_money_a")..tostring(p.cardInfo.Price)..GetStr("card_sale_money")..GetStr("card_sale_sure"),p.OnMsgBoxCallback,p.layer);
				--卖出卡牌
				
				--卖出后回调的窗口
				--p.SaleKO(); 
				
			end
			
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_ARRT == tag then
			--卡牌详细
			dlg_card_attr.ShowUI(p.cardInfo.CardID);
		elseif ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_1 == tag then
			if p.equip1 and tonumber(p.equip1.equipId) ~= 0 and p.equip1.itemInfo then
				local item = p.PasreCardDetail(p.cardInfo, p.equip1, "1");
				dlg_card_equip_detail.ShowUI4CardEquip(item);
			else
				
				card_equip_select_list.ShowUI(card_equip_select_list.INTENT_ADD , p.cardInfo.UniqueId, 1, nil);
			end
			
		elseif ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_2 == tag then
			if p.equip2 and tonumber(p.equip2.equipId) ~= 0 and p.equip2.itemInfo then
				local item = p.PasreCardDetail(p.cardInfo, p.equip2, "2");
				dlg_card_equip_detail.ShowUI4CardEquip(item);
			else
				card_equip_select_list.ShowUI(card_equip_select_list.INTENT_ADD , p.cardInfo.UniqueId, 2, nil);
			end
			
		elseif ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_3 == tag then
			if p.equip3 and tonumber(p.equip3.equipId) ~= 0 and p.equip3.itemInfo then
				local item = p.PasreCardDetail(p.cardInfo, p.equip3, "3");
				dlg_card_equip_detail.ShowUI4CardEquip(item);
			else
				card_equip_select_list.ShowUI(card_equip_select_list.INTENT_ADD , p.cardInfo.UniqueId, 3, nil);
			end
		elseif ui_dlg_card_attr_base.ID_CTRL_BUTTON_REPLACE == tag then
			--替换，显示星灵列表
			card_bag_mian.ShowUI( true, p.mainUIFlag );
			p.CloseUI();
		end
	end
end

--不能卖出提示框回调方法
function p.OnMsgCallback(result)
	
	WriteCon("OnMsgCallback");
	
end
--卖出提示框回调方法
function p.OnMsgBoxCallback(result)
	if result then
		
		local uid = GetUID();
		WriteCon("**发送买出卡牌请求**"..uid);
		--uid = 10002;
		if uid ~= nil and uid > 0 then
			--模块  Action 
			local param = string.format("&id=%d", p.cardInfo.UniqueId);
			SendReq("CardList","Sell",uid,param);
		end
	
	end
	
end

--卖出后回调的窗口
function p.SaleKO(msg)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	--local T_CARD    = LoadTable( "card.ini" );
	local pCardbase= SelectRowInner( T_CARD, "id", p.cardInfo.CardID); --从表中获取卡牌详细信息
	
	if pCardbase==nil then
		WriteCon("pCardbase==nil");
	end
	
	card_bag_mgr.RefreshCardList(p.cardInfo.UniqueId);
	
	dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_sale")..ToUtf8(pCardbase.name)..GetStr("card_sale_get")..tostring(msg.money.Add)..GetStr("card_sale_money"),p.OnMsgCallbackCloseUI,p.layer);
	
end

function p.OnMsgCallbackCloseUI(result)
	if result then
		p.CloseUI();
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
		p.cardInfo = nil;
	    p.layer:LazyClose();
        p.layer = nil;
		p.groupFlag = false;
		p.mainUIFlag = false;
		
		p.cardDetail = {}
		p.equip1 = {};
		p.equip2 = {};
		p.equip3 = {};
		expbar_move_effect.ClearData();
    end
end

--组装dlg_card_equip_detail需要的字段
function p.PasreCardDetail(cardInfo, equip, pos)
	local item = {};
	local itemInfo = equip.itemInfo;
	item.cardId 	= cardInfo.CardID;
	item.cardUid 	= cardInfo.UniqueId;
  --item.cardName	= "xxx"
	item.itemId 	= itemInfo.Item_id;
	item.itemUid	= equip.equipId;
	item.itemType	= pos;
	item.itemLevel 	= itemInfo.Equip_level;
	item.itemExp	= itemInfo.Equip_exp;
	item.itemRank	= itemInfo.Rare
	item.attrType	= itemInfo.Attribute_type;
	item.attrValue	= itemInfo.Attribute_value;
	item.attrGrow	= itemInfo.Attribute_grow;
	item.exType1 	= itemInfo.Extra_type1;
	item.exValue1 	= itemInfo.Extra_value1;
	item.exType2 	= itemInfo.Extra_type2;
	item.exValue2 	= itemInfo.Extra_value2;
	item.exType3	= itemInfo.Extra_type3;
	item.exValue3	= itemInfo.Extra_value3;
	--preItemUid="xxxx"  --穿戴装备id
	return item;
end

--重新重新卡的信息
function p.RefreshCardDetail()
	p.LoadCardDetail(p.cardInfo.UniqueId);
end

---------------------------------------网络-----------------------------------------------------------


--读取卡详细信息
function p.LoadCardDetail(cardUniqueId)
	
	
	local uid = GetUID();
	
	--uid=123456
	--cardUniqueId="10000272";
	
	if uid == 0 or uid == nil or cardUniqueId == nil then
		return ;
	end;
	
	local param = string.format("&card_unique_id=%s",cardUniqueId)
	SendReq("Equip","CardDetailShow",uid,param);		
end
--网络返回卡详细信息
function p.OnLoadCardDetail(msg)
	
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		p.cardDetail = msg.card_info or {};
		p.equip1 = {};
		p.equip2 = {};
		p.equip3 = {};
		if msg.card_info then
			p.equip1.equipId = msg.card_info.Item_id1;
			p.equip1.itemInfo = msg.item1_info;
			p.equip2.equipId = msg.card_info.Item_id2;
			p.equip2.itemInfo = msg.item2_info;
			p.equip3.equipId = msg.card_info.Item_id3;
			p.equip3.itemInfo = msg.item3_info;
		end
		
		p.SetDelegate();
	else
		--local str = mail_main.GetNetResultError(msg);
		--if str then
			--dlg_msgbox.ShowOK(GetStr("mail_erro_title"), str,nil);
		--else
		--	WriteCon("**======mail_write_mail.NetCallback error ======**");
		--end
		--TODO...
	end
	--[[ 数据结构
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

function p.UIDisappear()
	p.CloseUI();
end
