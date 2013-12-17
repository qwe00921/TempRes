--------------------------------------------------------------
-- FileName: 	dlg_card_attr_base.lua
-- author:		hst, 2013/11/29
-- purpose:		���ƻ�����Ϣ����
--------------------------------------------------------------
dlg_card_attr_base = {}
local p = dlg_card_attr_base;
p.layer = nil;
p.cardInfo = nil;
p.cardDetail = nil;

p.groupFlag = false;
p.mainUIFlag = false;

--id��UniqueId
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
	
	
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardInfo.CardID); --�ӱ��л�ȡ������ϸ��Ϣ	
	local pCardInfo2= SelectRowInner( T_CARD, "id", p.cardInfo.CardID);
	local skill_res = nil;
	local cardSkillInfo = nil;
	if pCardInfo2.skill ~= 0 then
		skill_res = SelectRowInner(T_SKILL_RES,"id",pCardInfo2.skill);
		cardSkillInfo = SelectRowInner(T_SKILL,"id",pCardInfo2.skill);	
	end
	
	if pCardInfo ==nil then
		WriteCon("**====pCardInfo == nil ====**"..p.cardInfo.CardID);
	end
	--����
    local pBtnBack = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BUTTON_BACK);
    pBtnBack:SetLuaDelegate(p.OnUIEventEvolution);
	
	--�츳����ͼƬ
	local pBtnDower = GetImage(layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_PIC);
	--�츳����
	local pLabDowerIntro = GetLabel(layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_INTRO);
	--��Ϊ�����Ǵ�������ȸ�Ϊ ==nil 
	if skill_res ~= nil then 
		pBtnDower:SetImage(GetPictureByAni(skill_res.icon,0))
		pLabDowerIntro:SetText(tostring(pCardInfo.dower_intro_1));
	else
		pLabDowerIntro:SetText(GetStr("card_no_dower"));
	end
	
	--����ͼƬ
	local pImgCardPic = GetImage(layer, ui_dlg_card_attr_base.ID_CTRL_CARD_PICTURE); --����ͼƬ�ؼ�
	local pImage = GetPictureByAni(pCardInfo.card_pic,0)--����ͼƬ
	pImgCardPic:SetPicture(pImage);
	
	--Ե��
	local pLabLuckIntro = GetLabel(layer,ui_dlg_card_attr_base.ID_CTRL_LUCK_INTRO);
	pLabLuckIntro:SetText(tostring(pCardInfo.luck_intro));
	
	--ǿ��
	local pBtnIntensify = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BTN_INTENSIFY);
    pBtnIntensify:SetLuaDelegate(p.OnUIEventEvolution);
	
	--����
	local pBtnSale = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BTN_SALE);
    pBtnSale:SetLuaDelegate(p.OnUIEventEvolution);
	pBtnSale:SetVisible( not p.groupFlag );
	
	--�滻
	local pBtnReplace = GetButton( layer, ui_dlg_card_attr_base.ID_CTRL_BUTTON_REPLACE );
	pBtnReplace:SetLuaDelegate( p.OnUIEventEvolution );
	pBtnReplace:SetVisible( p.groupFlag );
	
	local pPic = GetImage( layer, ui_dlg_card_attr_base.ID_CTRL_PICTURE_101 );
	pPic:SetVisible( p.groupFlag );
	
	--��ϸ
	local pBtnArrt = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BTN_ARRT);
    pBtnArrt:SetLuaDelegate(p.OnUIEventEvolution);
	
	--װ��
	local bt = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_1);
    bt:SetLuaDelegate(p.OnUIEventEvolution);
	bt = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_2);
    bt:SetLuaDelegate(p.OnUIEventEvolution);
	bt = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_3);
    bt:SetLuaDelegate(p.OnUIEventEvolution);
	
	
	
	--local T_ITEM     = LoadTable( "item.ini" );
	local pCardInfo= nil;
	
	--local cardInfo = msg.cardInfo;
	--װ��
	local pEquipPic1 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_1);
	if p.equip1 and tonumber(p.equip1.equipId) ~= 0 and p.equip1.itemInfo then
		local aniIndex = "item."..p.equip1.itemInfo.Item_id;
		pEquipPic1:SetPicture( GetPictureByAni(aniIndex,0) );
	else
		pEquipPic1:SetPicture(nil);
	end
	
	local pEquipPic2 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_2);
	if p.equip2 and tonumber(p.equip2.equipId) ~= 0 and p.equip2.itemInfo then
		local aniIndex = "item."..p.equip2.itemInfo.Item_id;
		pEquipPic2:SetPicture( GetPictureByAni(aniIndex,0) );
	else
		pEquipPic2:SetPicture(nil);
	end
	
	
	local pEquipPic3 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_3);
	if p.equip3 and tonumber(p.equip3.equipId) ~= 0 and p.equip3.itemInfo then
		local aniIndex = "item."..p.equip3.itemInfo.Item_id;
		pEquipPic3:SetPicture( GetPictureByAni(aniIndex,0) );
	else
		pEquipPic3:SetPicture(nil);
	end
	
	
	--��ʯ
	local pGemPic1 = GetImage(p.layer,ui_dlg_card_attr_base .ID_CTRL_GEM_PIC_1);
	if p.cardInfo.Gem1 ~= 0 then
		pGemPic1:SetImage(GetPictureByAni(p.cardInfo.Gem1,0))
	end
	
	local pGemPic2 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_GEM_PIC_2);
	if p.cardInfo.Gem2 ~= 0 then
		pGemPic2:SetImage(GetPictureByAni(p.cardInfo.Gem2,0))
	end
	
	local pGemPic3 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_GEM_PIC_3);
	if p.cardInfo.Gem3 ~= 0 then
		pGemPic3:SetImage(GetPictureByAni(p.cardInfo.Gem3,0))
	end
	
	
	--���Ƶȼ�
	local pLabCardGrad = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_GRADE);
	pLabCardGrad:SetText(GetStr("card_level")..tostring("  ")..tostring(p.cardInfo.Level));
	
	--����HP
	local pLabCardHP = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_HP);
	pLabCardHP:SetText(GetStr("card_hp")..tostring("  ")..tostring(p.cardInfo.Hp));
	
	--���ƹ���
	local pLabCardAttack = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_ATTACK);
	pLabCardAttack:SetText(GetStr("card_attack")..tostring("  ")..tostring(p.cardInfo.Attack));
	
	--�����ٶ�
	local pLabCardSpeed = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_SPEED);
	pLabCardSpeed:SetText(GetStr("card_speed")..tostring("  ")..tostring(p.cardInfo.Speed));
	
	--���Ʒ���
	local pLabCardDefense = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_DEFENSE);
	pLabCardDefense:SetText(GetStr("card_defence")..tostring("  ")..tostring(p.cardInfo.Defence));
	
	--���Ʊ���
	local pLabCardCritical = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_CRITICAL);
	pLabCardCritical:SetText(GetStr("card_crit")..tostring("  ")..tostring(p.cardInfo.Crit));
	
	
	
end



function p.OnUIEventEvolution(uiNode, uiEventType, param)
	
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardInfo.cardID); --�ӱ��л�ȡ������ϸ��Ϣ	
	local pLabDowerIntro = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_INTRO);
	
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui_dlg_card_attr_base.ID_CTRL_BUTTON_BACK == tag then
			p.CloseUI();
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_INTENSIFY == tag then
			--����ǿ��
			card_intensify.ShowUI(p.cardInfo);
			p.CloseUI();
			
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_SALE == tag then
			--��������
			if p.cardInfo.Item_Id1 ~= 0 or  p.cardInfo.Gem1 ~= 0 then
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_sale_isitem"),p.OnMsgCallback,p.layer);
			elseif p.cardInfo.Team_marks== 1 then
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_sale_team"),p.OnMsgCallback,p.layer);
			elseif p.cardInfo.Rare >=  5 then
					dlg_msgbox.ShowYesNo(GetStr("card_caption"),GetStr("card_sale_rare")..tostring(p.cardInfo.Price)..GetStr("card_sale_sure"),p.OnMsgBoxCallback,p.layer);
			else	
				dlg_msgbox.ShowYesNo(GetStr("card_caption"),GetStr("card_sale_money_a")..tostring(p.cardInfo.Price)..GetStr("card_sale_money")..GetStr("card_sale_sure"),p.OnMsgBoxCallback,p.layer);
				--��������
				
				--������ص��Ĵ���
				--p.SaleKO(); 
				
			end
			
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_ARRT == tag then
			--������ϸ
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
			--�滻����ʾ�����б�
			card_bag_mian.ShowUI( true, p.mainUIFlag );
			p.CloseUI();
		end
	end
end

--����������ʾ��ص�����
function p.OnMsgCallback(result)
	
	WriteCon("OnMsgCallback");
	
end
--������ʾ��ص�����
function p.OnMsgBoxCallback(result)
	if result then
		
		local uid = GetUID();
		WriteCon("**���������������**"..uid);
		--uid = 10002;
		if uid ~= nil and uid > 0 then
			--ģ��  Action 
			local param = string.format("&id=%d", p.cardInfo.UniqueId);
			SendReq("CardList","Sell",uid,param);
		end
	
	end
	
end

--������ص��Ĵ���
function p.SaleKO(msg)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	--local T_CARD    = LoadTable( "card.ini" );
	local pCardbase= SelectRowInner( T_CARD, "id", p.cardInfo.CardID); --�ӱ��л�ȡ������ϸ��Ϣ
	
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


--���ÿɼ�
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
    end
end

--��װdlg_card_equip_detail��Ҫ���ֶ�
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
	--preItemUid="xxxx"  --����װ��id
	return item;
end

--�������¿�����Ϣ
function p.RefreshCardDetail()
	p.LoadCardDetail(p.cardInfo.UniqueId);
end

---------------------------------------����-----------------------------------------------------------


--��ȡ����ϸ��Ϣ
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
--���緵�ؿ���ϸ��Ϣ
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

function p.UIDisappear()
	p.CloseUI();
end
