--------------------------------------------------------------
-- FileName: 	dlg_card_attr_base.lua
-- author:		hst, 2013/11/29
-- purpose:		���ƻ�����Ϣ����
--------------------------------------------------------------
dlg_card_attr_base = {}
local p = dlg_card_attr_base;
p.layer = nil;
p.cardID = nil;
p.cardInfo = nil;
p.id = nil;
--id��UniqueId
function p.ShowUI(cardID,id)
	WriteCon(cardID.."************"..id);
	  if cardID == nil or id == nil then
    	return;
	  end
	p.cardID = cardID;
	p.id = id;
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
	p.SendReqUserInfo();
end

function p.SendReqUserInfo()

	WriteCon("**���󿨰�����**");
    local uid = GetUID();
    if uid ~= nil and uid > 0 then
		--ģ��  Action 
        SendReq("CardList","List",10002,"");
	end
end

function p.SetDelegate(layer)
	
	
	
	T_CHAR_RES     = LoadTable( "char_res.ini" );
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardID); --�ӱ��л�ȡ������ϸ��Ϣ	
	if pCardInfo ==nil then
		WriteCon("**====pCardInfo == nil ====**"..p.cardID);
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
	--local pImage = GetPictureByAni(pCardInfo.card_pic,0)--����ͼƬ
	--pImgCardPic:SetPicture(pImage);
	
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
	
end

function p.RefreshUI(msg)
	WriteCon("---------RefreshUI---------------------");
	if p.layer == nil then
		WriteCon("p.layer == nil \n");
		return;
	end

	for k, v in ipairs(msg.cardlist) do
		if msg.cardlist[k].UniqueId==p.id then
			p.cardInfo = msg.cardlist[k];
			break
		end
    end	
	
	WriteCon("p.cardInfo.Exp = "..p.cardInfo.Exp);
	
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
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardID); --�ӱ��л�ȡ������ϸ��Ϣ	
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
			dlg_card_attr.ShowUI(p.cardID);
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
		WriteCon("**���������������**");
		local uid = GetUID();
		if uid ~= nil and uid > 0 then
			--ģ��  Action 
			local param = string.format("&id=%d", p.id);
			SendReq("CardList","Sell",10002,param);
		end
	
	end
	
end

--������ص��Ĵ���
function p.SaleKO(msg)
		
	
	T_CARD    = LoadTable( "card.ini" );
	local pCardbase= SelectRowInner( T_CARD, "id", p.cardID); --�ӱ��л�ȡ������ϸ��Ϣ
	
	if pCardbase==nil then
		WriteCon("pCardbase==nil");
	end
	dlg_msgbox.ShowYesNo(ToUtf8("ȷ����ʾ��"),ToUtf8("��������")..ToUtf8(pCardbase.name)..ToUtf8("�����")..tostring(msg.money.Add)..ToUtf8("��ң�"),p.OnMsgBoxCallback,p.layer);
	
	
	
end


--���ÿɼ�
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.cardID = nil;
		p.cardInfo = nil;
		p.id = nil;
	    p.layer:LazyClose();
        p.layer = nil;
		
    end
    
end