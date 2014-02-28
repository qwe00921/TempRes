--------------------------------------------------------------
-- FileName: 	dlg_card_attr_base.lua
-- author:		hst, 2013/11/29
-- purpose:		卡牌基本信息界面
--------------------------------------------------------------
dlg_card_attr_base = {}
local p = dlg_card_attr_base;
local ui = ui_dlg_card_attr_base;
p.layer = nil;
p.cardInfo = nil;
p.cardDetail = nil;

p.groupFlag = false;
p.mainUIFlag = false;

p.attribute = {AtkEffect = 0,
			   DefEffect = 0,
			   SpeedEffect = 0,
			   HpEffect = 0,}

--装备加成类型值
EQUIP_ATTRIBTYPE_ATK = 1 
EQUIP_ATTRIBTYPE_DEF = 2
EQUIP_ATTRIBTYPE_LIFE = 3
EQUIP_ATTRIBTYPE_SPEED = 4
EQUIP_ATTRIBTYPE_CRIPT = 5

--id是UniqueId
function p.ShowUI(cardInfo, groupFlag, mainUIFlag)
	dlg_menu.HideUI();
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
	
	
	if groupFlag ~= nil then
		p.groupFlag = groupFlag;
	end
	
	if mainUIFlag ~= nil then
		p.mainUIFlag = mainUIFlag;
		dlg_menu.SetNewUI( p );
	end
	if card_bag_mian.layer == nil then
		WriteCon("card_bag_mian.layer == nil ");
		dlg_menu.SetNewUI( p );
	end
	if cardInfo == nil then
		return;
	end
	p.cardInfo = cardInfo;
	--layer:NoMask();
	layer:Init();	
	GetUIRoot():AddChildZ(layer,0);
    LoadDlg("dlg_card_attr_base.xui", layer, nil);
	p.layer = layer;
    p.SetDelegate();
	
	cardInfo.UniqueId = cardInfo.UniqueId or cardInfo.UniqueID;
	
	p.LoadCardDetail(cardInfo.UniqueId);
end

function p.SetDelegate()
	layer = layer or p.layer;
	
	
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardInfo.CardID); --从表中获取卡牌详细信息	
	local pCardInfo2= SelectRowInner( T_CARD, "id", p.cardInfo.CardID);
	local pCardUpLevelInfo= SelectRowInner( T_CARD_LEVEL, "level", tonumber(p.cardInfo.Level)+1);
	
	--缘份
	--local pLabLuckIntro = GetLabel(p.layer,ui.ID_CTRL_LUCK_INTRO);
	--pLabLuckIntro:SetText(pCardInfo.luck_intro);
	
	--------------------------------------------------------------------------
	--卡牌图片
	local pImgCardPic = GetImage(p.layer, ui.ID_CTRL_CARD_PICTURE); --卡牌图片控件
	local pImage = GetPictureByAni(pCardInfo.card_pic,0)--卡牌图片
	pImgCardPic:SetPicture(pImage);
	
	
	--卡牌名字
	local pLableName = GetLabel(p.layer,ui.ID_CTRL_TEXT_CARDNAME);
	pLableName:SetText(pCardInfo2.name);
	--卡牌星级 ID_CTRL_PICTURE_CARDSTAR Rare
	--[[
	local pPicCardStar = GetImage( p.layer, ui.ID_CTRL_PICTURE_CARDSTAR );
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
	end--]]
	 
	--卡牌属性 ID_CTRL_PICTURE_CARDNATURE element card_nature
	local pPicCardNature = GetImage( p.layer, ui.ID_CTRL_PICTURE_CARDNATURE );
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
	elseif tonumber(pCardInfo2.element) == 7 then
		pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",6));
	end
	
	--返回
    local pBtnBack = GetButton(p.layer,ui.ID_CTRL_BUTTON_BACK);
    pBtnBack:SetLuaDelegate(p.OnUIEventEvolution);
	
	--强化
	local pBtnIntensify = GetButton(p.layer,ui.ID_CTRL_BTN_INTENSIFY);
    pBtnIntensify:SetLuaDelegate(p.OnUIEventEvolution);
	
	--装备按钮
	local bt = GetButton(p.layer,ui.ID_CTRL_BUTTON_EQUIP_1);
    bt:SetLuaDelegate(p.OnUIEventEvolution);
	bt = GetButton(p.layer,ui.ID_CTRL_BUTTON_EQUIP_2);
    bt:SetLuaDelegate(p.OnUIEventEvolution);
		
	--ID_CTRL_TEXT_EQUIP1 T_EQUIP 装备名称
	local pLableEquip1 = GetLabel(p.layer,ui.ID_CTRL_TEXT_EQUIP1);
	local pLableEquip2 = GetLabel(p.layer,ui.ID_CTRL_TEXT_EQUIP2);
	
	--装备图片
	local pEquipPic1 = GetImage(p.layer,ui.ID_CTRL_EQUIP_PIC_1);
	local pEquipPicBg1 = GetButton( p.layer, ui.ID_CTRL_BUTTON_EQUIP_1 );
	if p.equip1 and tonumber(p.equip1.equipId) ~= 0 and p.equip1.itemInfo then
		--local aniIndex = "item."..p.equip1.itemInfo.equip_id;
		local pEquipInfo= SelectRowInner( T_EQUIP, "id", p.equip1.itemInfo.equip_id); 
		if pEquipInfo ~= nil then
			pEquipPic1:SetPicture( GetPictureByAni(pEquipInfo.item_pic,0) );
			pEquipPicBg1:SetImage( nil );
			pLableEquip1:SetText(pEquipInfo.name);	
		else
			WriteConErr("equip.ini error id="..tostring(p.equip1.itemInfo.equip_id));
			pEquipPic1:SetPicture(nil);
			pEquipPicBg1:SetImage( GetPictureByAni( "ui.card_equip_bg", 0 ) );
			pLableEquip1:SetText("");
		end
	else
		pEquipPic1:SetPicture(nil);
		pEquipPicBg1:SetImage( GetPictureByAni( "ui.card_equip_bg", 0 ) );
		pLableEquip1:SetText("");
	end
	
	local pEquipPic2 = GetImage(p.layer,ui.ID_CTRL_EQUIP_PIC_2);
	local pEquipPicBg2 = GetButton( p.layer, ui.ID_CTRL_BUTTON_EQUIP_2 );
	if p.equip2 and tonumber(p.equip2.equipId) ~= 0 and p.equip2.itemInfo then
		--local aniIndex = "item."..p.equip2.itemInfo.equip_id;
		local pEquipInfo= SelectRowInner( T_EQUIP, "id", p.equip2.itemInfo.equip_id); 
		pEquipPic2:SetPicture( GetPictureByAni(pEquipInfo.item_pic,0) );
		pEquipPicBg2:SetImage( nil );
		pLableEquip2:SetText(pEquipInfo.name);
	else
		pEquipPic2:SetPicture( nil);
		pEquipPicBg2:SetImage( GetPictureByAni( "ui.card_equip_bg", 1 ) );
		pLableEquip2:SetText("");
	end
	
	--卡牌等级
	local pLabCardGrad = GetLabel(p.layer,ui.ID_CTRL_CARD_GRADE);
	pLabCardGrad:SetText(tostring(p.cardInfo.Level));
	
	--卡牌HP
	local pLabCardHP = GetLabel(p.layer,ui.ID_CTRL_CARD_HP);
	pLabCardHP:SetText(tostring(tonumber(p.cardInfo.Hp) + p.attribute.HpEffect) );
	

	--卡牌攻击
	local pLabCardAttack = GetLabel(p.layer,ui.ID_CTRL_CARD_ATTACK);
	pLabCardAttack:SetText(tostring(tonumber(p.cardInfo.Attack) + p.attribute.AtkEffect));
	
	--卡牌速度
	local pLabCardSpeed = GetLabel(p.layer,ui.ID_CTRL_CARD_SPEED);
	pLabCardSpeed:SetText(tostring(tonumber(p.cardInfo.Speed) + p.attribute.SpeedEffect));
	
	--卡牌防御
	local pLabCardDefense = GetLabel(p.layer,ui.ID_CTRL_CARD_DEFENSE);
	pLabCardDefense:SetText(tostring(tonumber(p.cardInfo.Defence) + p.attribute.DefEffect));
	
	--卡牌Type type =1平衡型（各属性均衡成长）type =2耐力型（HP成长+10%，攻击成长-10%）type=3破坏型（攻击成长+10%，防御成长-10%）type=4守护型（防御成长+10%，攻击成长-10%）

	--[[
	local pLabCardType = GetLabel(p.layer,ui.ID_CTRL_TEXT_TYPE);
	WriteCon("type = ".. tostring(p.cardInfo.type));
	if tonumber(p.cardInfo.type) == 1 then
		pLabCardType:SetText(GetStr("card_type")..tostring("  ")..GetStr("card_type1"));
	elseif tonumber(p.cardInfo.type) == 2 then
		pLabCardType:SetText(GetStr("card_type")..tostring("  ")..GetStr("card_type2"));
	elseif tonumber(p.cardInfo.type) == 3 then
		pLabCardType:SetText(GetStr("card_type")..tostring("  ")..GetStr("card_type3"));
	elseif tonumber(p.cardInfo.type) == 4 then
		pLabCardType:SetText(GetStr("card_type")..tostring("  ")..GetStr("card_type4"));
	else
		pLabCardType:SetText(GetStr("card_type")..tostring("  "));
	end
	--]]
	
	local pImageCardType = GetImage( p.layer, ui.ID_CTRL_PICTURE_38 );
	local cardtype = tonumber(p.cardInfo.type) or 0;
	if cardtype ~= 0 then
		local picData = GetPictureByAni( "ui.card_equip_type", cardtype - 1 );
		pImageCardType:SetPicture( picData );
	else
		pImageCardType:SetPicture( nil );
	end

	--距离升级的经验是多少
	--[[
	local pLabCardUpExp = GetLabel(p.layer,ui.ID_CTRL_TEXT_LEVELUPEXP);
	
	local upExp = tonumber(pCardUpLevelInfo.exp)-tonumber(p.cardInfo.Exp);
	pLabCardUpExp:SetText(GetStr("card_up_level").." "..tostring(p.cardInfo.Exp).."/"..tostring(pCardUpLevelInfo.exp));
	--]]
	
	local pLabSkillName = GetLabel(p.layer,ui.ID_CTRL_TEXT_SKILLNAME);
	local lLabSkillNote = GetLabel(p.layer,ui.ID_CTRL_TEXT_81);
	--local pLabSkillInfo = GetLabel(p.layer,ui.ID_CTRL_DOWER_INTRO);
	--技能
	if  tonumber(pCardInfo2.skill) ~= 0 and  pCardInfo2.skill ~= nil then
		WriteCon("pCardInfo2.skill = "..tostring(pCardInfo2.skill));
		local pCardSkill= SelectRowInner( T_SKILL, "id", pCardInfo2.skill);
		if pCardSkill ~= nil then
			pLabSkillName:SetText(pCardSkill.name); 
			
			lLabSkillNote:SetText(pCardSkill.description);
			--pLabSkillInfo:SetText(pCardSkill.description); 
		end

	end
	
	--经验条
	local expBar = GetExp( p.layer, ui.ID_CTRL_EXP_44 );
	expBar:SetTextStyle( 2 );
	local expSstartNum = tonumber(p.cardInfo.Exp);
	local expLeast = 0;
	expbar_move_effect.showEffect(expBar,expLeast,tonumber(pCardUpLevelInfo.exp),expSstartNum,0);
	-------------------------------------------------------------------------------------------------
	
	local pCardInfo= nil;
			
end

function p.rookie_12_4()
	local bt = GetButton(p.layer,ui.ID_CTRL_BUTTON_EQUIP_1);
	p.OnUIEventEvolution(bt,NUIEventType.TE_TOUCH_CLICK)
end

function p.OnUIEventEvolution(uiNode, uiEventType, param)
	
	--local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardInfo.CardID); --从表中获取卡牌详细信息	
	--local pLabDowerIntro = GetLabel(p.layer,ui.ID_CTRL_DOWER_INTRO);
	--	
	--WriteCon("card_id = "..p.cardInfo.CardID);
	--以上log不要写,会产生错误
	
	if IsClickEvent( uiEventType ) then
		local pCardRare= SelectRowInner( T_CARD_LEVEL_LIMIT, "star", p.cardInfo.Rare); --从表中获取卡牌详细信息
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_BACK == tag then
			dlg_menu.ShowUI();
			p.CloseUI();
			if card_bag_mian.layer ~= nil then
				WriteCon("card_bag_mian.layer ~= nil ");
				card_bag_mian.ShowUI();
				card_bag_mgr.LoadAllCard(card_bag_mian.layer);
			else 
				maininterface.ShowUI();
			end
			
		elseif ui.ID_CTRL_BTN_INTENSIFY == tag then
			--卡牌星级上限 tonumber( p.baseCardInfo.Level) >= tonumber(pCardLevelMax.level_limit) then
			if tonumber( p.cardInfo.Level) >= tonumber(pCardRare.level_limit) then
				dlg_msgbox.ShowOK(GetStr("card_box_intensify"),tostring(p.cardInfo.Rare)..GetStr("card_intensify_no_level1")..tostring(pCardRare.level_limit)..GetStr("card_intensify_no_level2"),p.OnMsgCallback,p.layer);
			else
				dlg_menu.ShowUI();
				--卡牌强化
				--card_intensify2.OnSendReq();
				card_rein.ShowUI(p.cardInfo);
				p.HideUI();
			end
					
		elseif ui.ID_CTRL_BTN_SALE == tag then
			--卡牌卖出
			if p.cardInfo.Item_Id1 ~= 0 or  p.cardInfo.Gem1 ~= 0 then
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_sale_isitem"),p.OnMsgCallback,p.layer);
			elseif p.cardInfo.Team_marks== 1 then
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_sale_team"),p.OnMsgCallback,p.layer);
			elseif p.cardInfo.Rare >=  5 then
					dlg_msgbox.ShowYesNo(GetStr("card_caption"),GetStr("card_sale_rare")..tostring(p.cardInfo.Price)..GetStr("card_sale_sure"),p.OnMsgBoxCallback,p.layer);
			else	
				dlg_msgbox.ShowYesNo(GetStr("card_caption"),GetStr("card_sale_money_a")..tostring(p.cardInfo.Price)..GetStr("card_sale_money")..GetStr("card_sale_sure"),p.OnMsgBoxCallback,p.layer);
							
			end
			
		elseif ui.ID_CTRL_BTN_ARRT == tag then
			--卡牌详细
			dlg_card_attr.ShowUI(p.cardInfo.CardID);
		elseif ui.ID_CTRL_BUTTON_EQUIP_1 == tag then
			if p.equip1 and tonumber(p.equip1.equipId) ~= 0 and p.equip1.itemInfo then
				local item = p.PasreCardDetail(p.cardInfo, p.equip1, "1");
				dlg_card_equip_detail.ShowUI4CardEquip(item,p.showEquipDetailCallback,p.redirectCallback);
			else
				p.HideUI();
				dlg_menu.ShowUI();
				equip_dress_select.ShowUI(p.cardInfo.UniqueId, 1, p.showEquipDetailCallback, nil)
				--card_equip_select_list.ShowUI(card_equip_select_list.INTENT_ADD , p.cardInfo.UniqueId, 1, nil);
			end
			
		elseif ui.ID_CTRL_BUTTON_EQUIP_2 == tag then
			if p.equip2 and tonumber(p.equip2.equipId) ~= 0 and p.equip2.itemInfo then
				local item = p.PasreCardDetail(p.cardInfo, p.equip2, "2");
				dlg_card_equip_detail.ShowUI4CardEquip(item,p.showEquipDetailCallback,p.redirectCallback);
			else
				p.HideUI();
				dlg_menu.ShowUI();
				equip_dress_select.ShowUI(p.cardInfo.UniqueId, 2, p.showEquipDetailCallback, nil)
			end

		elseif ui.ID_CTRL_BUTTON_REPLACE == tag then
			--替换，显示星灵列表
			card_bag_mian.ShowUI( true, p.mainUIFlag );
			p.CloseUI();
		end
	end
end

function p.rookieIntensify()
	dlg_menu.ShowUI();
	card_rein.ShowUI(p.cardInfo);
	p.HideUI();
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
		--p.equip3 = {};
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
	item.itemId 	= itemInfo.equip_id;
	item.itemUid	= itemInfo.id;
	item.itemType	= pos;
	item.itemLevel 	= itemInfo.equip_level;
	item.itemExp	= itemInfo.equip_exp;
	item.itemRank	= itemInfo.rare
	item.attrType	= itemInfo.attribute_type1;
	item.attrValue	= itemInfo.attribute_value1;
	item.attrGrow	= itemInfo.Attribute_grow;
	item.exType1 	= itemInfo.attribute_type2;
	item.exValue1 	= itemInfo.attribute_value2;
	--item.exType2 	= itemInfo.Extra_type2;
	--item.exValue2 	= itemInfo.Extra_value2;
	--item.exType3	= itemInfo.Extra_type3;
	--item.exValue3	= itemInfo.Extra_value3;
	--preItemUid="xxxx"  --穿戴装备id
	return item;
end

--重新重新卡的信息
function p.RefreshCardDetail()
	local lCardInfo = p.cardInfo;
	if lCardInfo ~= nil then
		p.LoadCardDetail(lCardInfo.UniqueId);
	end;
end

function p.redirectCallback()
	p.HideUI();
	dlg_menu.ShowUI();
end

function p.showEquipDetailCallback(changed)
	if changed == true then
		p.RefreshCardDetail();
	end
	
	dlg_menu.HideUI();
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	
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

--计算某个装备的所有属性加成
function p.EquipAddEffect(lattribute, itemInfo)
	if itemInfo ~= nil then
		for i = 1,2 do
			local ltype = itemInfo["attribute_type"..tostring(i)];
			local lval  = itemInfo["attribute_value"..tostring(i)];
			if ltype == EQUIP_ATTRIBTYPE_ATK	then
				lattribute.AtkEffect = lattribute.AtkEffect + lval
			elseif ltype == EQUIP_ATTRIBTYPE_DEF then
				lattribute.DefEffect = lattribute.DefEffect + lval
			elseif ltype == EQUIP_ATTRIBTYPE_SPEED then
				lattribute.SpeedEffect = lattribute.SpeedEffect + lval
			elseif ltype == EQUIP_ATTRIBTYPE_LIFE then
				lattribute.HpEffect = lattribute.HpEffect + lval;
			end	
		end;
	end;
end;

--计算装备的加成
function p.CalEquipEffect()
	p.attribute = {AtkEffect = 0,
				   DefEffect = 0,
				   SpeedEffect = 0,
				   HpEffect = 0,}
	if p.equip1 and tonumber(p.equip1.equipId) ~= 0 and p.equip1.itemInfo then
		p.EquipAddEffect(p.attribute, p.equip1.itemInfo)

	end;
	
	if p.equip2 and tonumber(p.equip2.equipId) ~= 0 and p.equip2.itemInfo then
		p.EquipAddEffect(p.attribute, p.equip2.itemInfo)
	end
end;

--网络返回卡详细信息
function p.OnLoadCardDetail(msg)
	if p.layer == nil then --or p.layer:IsVisible() ~= true then
		return;
	end
	if msg.result == true then
		p.cardDetail = msg.card_info or {};
		p.equip1 = {};
		p.equip2 = {};
		--p.equip3 = {};
		if msg.card_info then
			p.equip1.equipId = msg.card_info.Item_id1;
			p.equip1.itemInfo = msg.item1_info;
			p.equip2.equipId = msg.card_info.Item_id2;
			p.equip2.itemInfo = msg.item2_info;
			p.CalEquipEffect(); --计算装备带来的属性加成
			--p.equip3.equipId = msg.card_info.Item_id3;
			--p.equip3.itemInfo = msg.item3_info;
		end
		p.cardInfo  = msg.card_info;
		p.cardInfo.UniqueId = p.cardInfo.UniqueId or p.cardInfo.UniqueID
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

end

function p.UIDisappear()
	p.CloseUI();
	card_rein.CloseUI();
	card_intensify.CloseUI();
	card_intensify2.CloseUI();
	card_intensify_succeed.CloseUI();
	equip_dress_select.CloseUI();
	equip_rein_list.CloseUI();
	maininterface.BecomeFirstUI();
end
