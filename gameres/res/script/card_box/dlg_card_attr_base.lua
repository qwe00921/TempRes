--------------------------------------------------------------
-- FileName: 	dlg_card_attr_base.lua
-- author:		hst, 2013/11/29
-- purpose:		卡牌基本信息界面
--------------------------------------------------------------
dlg_card_attr_base = {}
local p = dlg_card_attr_base;
p.layer = nil;
p.cardID = nil;
p.cardInfo = nil;
p.id = nil;
--id是UniqueId
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

	WriteCon("**请求卡包数据**");
    local uid = GetUID();
	WriteCon("**请求卡包数据**"..uid);
	--uid = 10002;
    if uid ~= nil and uid > 0 then
		--模块  Action 
        SendReq("CardList","List",uid,"");
	end
end

function p.SetDelegate(layer)
	
	
	
	T_CHAR_RES     = LoadTable( "char_res.ini" );
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardID); --从表中获取卡牌详细信息	
	if pCardInfo ==nil then
		WriteCon("**====pCardInfo == nil ====**"..p.cardID);
	end
	--返回
    local pBtnBack = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BUTTON_BACK);
    pBtnBack:SetLuaDelegate(p.OnUIEventEvolution);
	
	--天赋技能图片
	local pBtnDower = GetImage(layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_PIC);
	--因为数据是错的所以先改为 ==nil 
	if pCardInfo.dower_intro_1 == nil then 
		pBtnDower:SetPicture(GetPictureByAni(pCardInfo.dower_pic_1,0))
	end
	--天赋介绍
	local pLabDowerIntro = GetLabel(layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_INTRO);
	if pCardInfo.dower_intro_1 ~= nil then 
		pLabDowerIntro:SetText(tostring(pCardInfo.dower_intro_1));
	else
		pLabDowerIntro:SetText(ToUtf8("没有天赋技能"));
	end
	
	--卡牌图片
	local pImgCardPic = GetImage(layer, ui_dlg_card_attr_base.ID_CTRL_CARD_PICTURE); --卡牌图片控件
	--local pImage = GetPictureByAni(pCardInfo.card_pic,0)--卡牌图片
	--pImgCardPic:SetPicture(pImage);
	
	--缘份
	local pLabLuckIntro = GetLabel(layer,ui_dlg_card_attr_base.ID_CTRL_LUCK_INTRO);
	pLabLuckIntro:SetText(tostring(pCardInfo.luck_intro));
	
	--强化
	local pBtnIntensify = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BTN_INTENSIFY);
    pBtnIntensify:SetLuaDelegate(p.OnUIEventEvolution);
	
	--卖出
	local pBtnSale = GetButton(layer,ui_dlg_card_attr_base.ID_CTRL_BTN_SALE);
    pBtnSale:SetLuaDelegate(p.OnUIEventEvolution);
	
	--详细
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
	--装备
	local pEquipPic1 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_1);
	if p.cardInfo.Item_Id1 ~= 0 then
		pCardInfo= SelectRowInner( T_ITEM, "item_id", p.cardInfo.Item_Id1); --从表中获取卡牌详细信息	
		pEquipPic1:SetImage(GetPictureByAni(pCardInfo.item_pic,0))
		
	end
	local pEquipPic2 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_2);
	if p.cardInfo.Item_Id2 ~= 0 then
		pCardInfo= SelectRowInner( T_ITEM, "item_id", p.cardInfo.Item_Id2); --从表中获取卡牌详细信息	
		pEquipPic2:SetImage(GetPictureByAni(pCardInfo.item_pic,0))
	end
	
	
	local pEquipPic3 = GetImage(p.layer,ui_dlg_card_attr_base.ID_CTRL_EQUIP_PIC_3);
	if p.cardInfo.Item_Id3 ~= 0 then
		pCardInfo= SelectRowInner( T_ITEM, "item_id", p.cardInfo.Item_Id3); --从表中获取卡牌详细信息	
		pEquipPic3:SetImage(GetPictureByAni(pCardInfo.item_pic,0))
	end
	
	
	--宝石
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
	
	
	--卡牌等级
	local pLabCardGrad = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_GRADE);
	pLabCardGrad:SetText(ToUtf8("等级  ")..tostring(p.cardInfo.Level));
	
	--卡牌HP
	local pLabCardHP = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_HP);
	pLabCardHP:SetText(ToUtf8("生命  ")..tostring(p.cardInfo.Hp));
	
	--卡牌攻击
	local pLabCardAttack = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_ATTACK);
	pLabCardAttack:SetText(ToUtf8("攻击  ")..tostring(p.cardInfo.Attack));
	
	--卡牌速度
	local pLabCardSpeed = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_SPEED);
	pLabCardSpeed:SetText(ToUtf8("速度  ")..tostring(p.cardInfo.Speed));
	
	--卡牌防御
	local pLabCardDefense = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_DEFENSE);
	pLabCardDefense:SetText(ToUtf8("防御  ")..tostring(p.cardInfo.Defence));
	
	--卡牌暴击
	local pLabCardCritical = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_CARD_CRITICAL);
	pLabCardCritical:SetText(ToUtf8("暴击  ")..tostring(p.cardInfo.Crit));
end

function p.OnUIEventEvolution(uiNode, uiEventType, param)
	
	T_CHAR_RES     = LoadTable( "char_res.ini" );
	local pCardInfo= SelectRowInner( T_CHAR_RES, "card_id", p.cardID); --从表中获取卡牌详细信息	
	local pLabDowerIntro = GetLabel(p.layer,ui_dlg_card_attr_base.ID_CTRL_DOWER_INTRO);
	
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui_dlg_card_attr_base.ID_CTRL_BUTTON_BACK == tag then
			p.CloseUI();
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_INTENSIFY == tag then
			--卡牌强化
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_SALE == tag then
			--卡牌卖出
			if p.cardInfo.Item_Id1 ~= 0 or  p.cardInfo.Gem1 ~= 0 then
				dlg_msgbox.ShowOK(ToUtf8("确认提示框"),ToUtf8("此卡牌身上穿有道具，无法卖出！"),p.OnMsgCallback,p.layer);
			elseif p.cardInfo.Team_marks== 1 then
				dlg_msgbox.ShowOK(ToUtf8("确认提示框"),ToUtf8("此卡牌当前处于一个队伍中，无法卖出！"),p.OnMsgCallback,p.layer);
			elseif p.cardInfo.Rare >=  5 then
					dlg_msgbox.ShowYesNo(ToUtf8("确认提示框"),ToUtf8("这张卡片为稀有卡片，确定要卖出吗？")..tostring(p.cardInfo.Price)..ToUtf8("确定要卖出吗？"),p.OnMsgBoxCallback,p.layer);
			else	
				dlg_msgbox.ShowYesNo(ToUtf8("确认提示框"),ToUtf8("卡牌卖出价格是：")..tostring(p.cardInfo.Price)..ToUtf8("金币，确定要卖出吗？"),p.OnMsgBoxCallback,p.layer);
				--卖出卡牌
				
				--卖出后回调的窗口
				--p.SaleKO(); 
				
			end
			
		elseif ui_dlg_card_attr_base.ID_CTRL_BTN_ARRT == tag then
			--卡牌详细
			dlg_card_attr.ShowUI(p.cardID);
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
			local param = string.format("&id=%d", p.id);
			SendReq("CardList","Sell",uid,param);
		end
	
	end
	
end

--卖出后回调的窗口
function p.SaleKO(msg)
		
	
	T_CARD    = LoadTable( "card.ini" );
	local pCardbase= SelectRowInner( T_CARD, "id", p.cardID); --从表中获取卡牌详细信息
	
	if pCardbase==nil then
		WriteCon("pCardbase==nil");
	end
	dlg_msgbox.ShowYesNo(ToUtf8("确认提示框"),ToUtf8("您卖出了")..ToUtf8(pCardbase.name)..ToUtf8("获得了")..tostring(msg.money.Add)..ToUtf8("金币！"),p.OnMsgBoxCallback,p.layer);
	
	
	
end


--设置可见
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