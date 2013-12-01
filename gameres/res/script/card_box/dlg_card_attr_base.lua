--------------------------------------------------------------
-- FileName: 	dlg_card_attr_base.lua
-- author:		hst, 2013/11/29
-- purpose:		���ƻ�����Ϣ����
--------------------------------------------------------------
dlg_card_attr_base = {}
local p = dlg_card_attr_base;
p.layer = nil;
p.cardInfo = nil;
--id��UniqueId
function p.ShowUI(cardInfo)
	WriteCon(cardInfo.CardID.."************");
	  if cardInfo == nil then
    	return;
	  end
	p.cardInfo = cardInfo;
	 if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	--layer:NoMask();
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_card_attr_base.xui", layer, nil);
	p.layer = layer;
    p.SetDelegate(layer);
end

function p.SetDelegate(layer)
	layer = layer or p.layer;
	
	
	T_CHAR_RES     = LoadTable( "char_res.ini" );
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardInfo.CardID); --�ӱ��л�ȡ������ϸ��Ϣ	
	if pCardInfo ==nil then
		WriteCon("**====pCardInfo == nil ====**"..p.cardInfo.CardID);
	end
	--����
    local pBtnBack = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BUTTON_BACK);
    pBtnBack:SetLuaDelegate(p.OnUIEventEvolution);
	
	--�츳����ͼƬ
	local pBtnDower = GetImage(layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_PIC);
	--��Ϊ�����Ǵ�������ȸ�Ϊ ==nil 
	if pCardInfo.dower_intro_1 == nil then 
		pBtnDower:SetPicture(GetPictureByAni(pCardInfo.dower_pic_1,0))
	end
	--�츳����
	local pLabDowerIntro = GetLabel(layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_INTRO);
	if pCardInfo.dower_intro_1 ~= nil then 
		pLabDowerIntro:SetText(tostring(pCardInfo.dower_intro_1));
	else
		pLabDowerIntro:SetText(ToUtf8("û���츳����"));
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
	
	
	
	T_ITEM     = LoadTable( "item.ini" );
	local pCardInfo= nil;
	
	--local cardInfo = msg.cardInfo;
	--װ��
	local pEquipPic1 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_1);
	if p.cardInfo.Item_Id1 ~= 0 then
		pCardInfo= SelectRowInner( T_ITEM, "item_id", p.cardInfo.Item_Id1); --�ӱ��л�ȡ������ϸ��Ϣ	
		pEquipPic1:SetImage(GetPictureByAni(pCardInfo.item_pic,0))
		
	end
	local pEquipPic2 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_2);
	if p.cardInfo.Item_Id2 ~= 0 then
		pCardInfo= SelectRowInner( T_ITEM, "item_id", p.cardInfo.Item_Id2); --�ӱ��л�ȡ������ϸ��Ϣ	
		pEquipPic2:SetImage(GetPictureByAni(pCardInfo.item_pic,0))
	end
	
	
	local pEquipPic3 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_3);
	if p.cardInfo.Item_Id3 ~= 0 then
		pCardInfo= SelectRowInner( T_ITEM, "item_id", p.cardInfo.Item_Id3); --�ӱ��л�ȡ������ϸ��Ϣ	
		pEquipPic3:SetImage(GetPictureByAni(pCardInfo.item_pic,0))
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
	pLabCardGrad:SetText(ToUtf8("�ȼ�  ")..tostring(p.cardInfo.Level));
	
	--����HP
	local pLabCardHP = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_HP);
	pLabCardHP:SetText(ToUtf8("����  ")..tostring(p.cardInfo.Hp));
	
	--���ƹ���
	local pLabCardAttack = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_ATTACK);
	pLabCardAttack:SetText(ToUtf8("����  ")..tostring(p.cardInfo.Attack));
	
	--�����ٶ�
	local pLabCardSpeed = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_SPEED);
	pLabCardSpeed:SetText(ToUtf8("�ٶ�  ")..tostring(p.cardInfo.Speed));
	
	--���Ʒ���
	local pLabCardDefense = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_DEFENSE);
	pLabCardDefense:SetText(ToUtf8("����  ")..tostring(p.cardInfo.Defence));
	
	--���Ʊ���
	local pLabCardCritical = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_CRITICAL);
	pLabCardCritical:SetText(ToUtf8("����  ")..tostring(p.cardInfo.Crit));
	
	
	
end



function p.OnUIEventEvolution(uiNode, uiEventType, param)
	
	T_CHAR_RES     = LoadTable( "char_res.ini" );
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardInfo.cardID); --�ӱ��л�ȡ������ϸ��Ϣ	
	local pLabDowerIntro = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_INTRO);
	
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui_dlg_card_attr_base.ID_CTRL_BUTTON_BACK == tag then
			p.CloseUI();
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_INTENSIFY == tag then
			--����ǿ��
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_SALE == tag then
			--��������
			if p.cardInfo.Item_Id1 ~= 0 or  p.cardInfo.Gem1 ~= 0 then
				dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),ToUtf8("�˿������ϴ��е��ߣ��޷�������"),p.OnMsgCallback,p.layer);
			elseif p.cardInfo.Team_marks== 1 then
				dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),ToUtf8("�˿��Ƶ�ǰ����һ�������У��޷�������"),p.OnMsgCallback,p.layer);
			elseif p.cardInfo.Rare >=  5 then
					dlg_msgbox.ShowYesNo(ToUtf8("ȷ����ʾ��"),ToUtf8("���ſ�ƬΪϡ�п�Ƭ��ȷ��Ҫ������")..tostring(p.cardInfo.Price)..ToUtf8("ȷ��Ҫ������"),p.OnMsgBoxCallback,p.layer);
			else	
				dlg_msgbox.ShowYesNo(ToUtf8("ȷ����ʾ��"),ToUtf8("���������۸��ǣ�")..tostring(p.cardInfo.Price)..ToUtf8("��ң�ȷ��Ҫ������"),p.OnMsgBoxCallback,p.layer);
				--��������
				
				--������ص��Ĵ���
				--p.SaleKO(); 
				
			end
			
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_ARRT == tag then
			--������ϸ
			dlg_card_attr.ShowUI(p.cardInfo.CardID);
		elseif ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_1 == tag then
			card_equip_select_list.ShowUI();
			if p.cardInfo and p.cardInfo.Item_id1 and tonumber(p.cardInfo.Item_id1) ~= 0 then
				
			else
				
			end
		elseif ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_2 == tag then
			if p.cardInfo and p.cardInfo.Item_id2 and tonumber(p.cardInfo.Item_id2) ~= 0 then
			else
				dlg_card_equip_detail.ShowUI();
			end
		elseif ui_dlg_card_attr_base.ID_CTRL_BUTTON_EQUIP_3 == tag then
			if p.cardInfo and p.cardInfo.Item_id3 and tonumber(p.cardInfo.Item_id3) ~= 0 then
			else
				
			end
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
		uid = 10002;
		if uid ~= nil and uid > 0 then
			--ģ��  Action 
			local param = string.format("&id=%d", p.cardInfo.UniqueId);
			SendReq("CardList","Sell",uid,param);
		end
	
	end
	
end

--������ص��Ĵ���
function p.SaleKO(msg)
		
	
	T_CARD    = LoadTable( "card.ini" );
	local pCardbase= SelectRowInner( T_CARD, "id", p.cardInfo.CardID); --�ӱ��л�ȡ������ϸ��Ϣ
	
	if pCardbase==nil then
		WriteCon("pCardbase==nil");
	end
	dlg_msgbox.ShowOK(ToUtf8("ȷ����ʾ��"),ToUtf8("��������")..ToUtf8(pCardbase.name)..ToUtf8("�����")..tostring(msg.money.Add)..ToUtf8("��ң�"),p.OnMsgCallbackCloseUI,p.layer);
	
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
		
    end
    
end

---------------------------------------����-----------------------------------------------------------

function p.OnNetCallback(msg)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg == nil then
		return;
	end
	
	if msg.idMsg == MSG_CARD_ROLE_DETAIL then
		p.OnLoadCardDetail(msg);
	end
	
end

--��ȡ����ϸ��Ϣ
function p.LoadCardDetail(cardUniqueId)
	local uid = GetUID();
	if uid == 0 or uid == nil or cardUniqueId == nil then
		return ;
	end;
	
	local param = string.format("&card_unique_id=%s",cardUniqueId)
	SendReq("Item","CardDetailShow",uid,param);		
end
--���緵�ؿ���ϸ��Ϣ
function p.OnLoadCardDetail(msg)
	
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		p.cardInfo = msg.card_info or {};
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
