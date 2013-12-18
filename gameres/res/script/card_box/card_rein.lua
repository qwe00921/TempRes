card_rein = {}
local p = card_rein;
p.layer = nil;
p.baseCardInfo = nil;

p.cardListInfo = nil;
p.selectNum = 0;
p.consumeMoney = 0;
p.selectCardId = {};
p.userMoney = 0;

local ui = ui_card_rein;



function p.ShowUI(card_info)
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		p.InitUI(card_info);
		return;
	end
	
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	layer:NoMask();
    layer:Init();   
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddDlg(layer);
    LoadDlg("card_rein.xui", layer, nil);

    p.layer = layer;
    p.SetDelegate(layer);	
	p.InitUI(card_info);
end

function p.SetCardData(card_info)
	if p.layer ~= nil then 
		p.ShowUI(card_info)
		return;
	end	
end;	

function p.getCardListInfo()
	return p.cardListInfo;
end;	

function p.setCardListInfo(cardListInfo)
	p.cardListInfo = cardListInfo;
end;	


function p.InitUI(card_info)
	p.baseCardInfo = card_info;
	p.InitAllCardInfo(); --初始化所有卡牌
	p.ShowCardCost();
	if card_info == nil then --挡板的设置
		local selBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_CARD_CHOOSE);
		selBtn:SetVisible(true);
	else
		local selBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_CARD_CHOOSE);
		selBtn:SetVisible(false);		
		
		card_intensify2.CloseUI();	
		
		--头像 CTRL_PICTURE_231				
		local lCardResRowInfo= SelectRowInner( T_CHAR_RES, "card_id", card_info.CardID); --从表中获取卡牌详细信息			
		local lHeadPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_231);
		lHeadPic:SetPicture( GetPictureByAni(lCardResRowInfo.head_pic, 0) );		
			
		--名字 CTRL_TEXT_252
		local lCardRowInfo= SelectRowInner( T_CARD, "id", card_info.CardID); --从表中获取卡牌详细信息					
		local lTextName = GetLabel(p.layer, ui.ID_CTRL_TEXT_252);
		lTextName:SetText(tostring(lCardRowInfo.name));
		
		--等级 ID_CTRL_TEXT_LEVEL		
		local lTextLev = GetLabel(p.layer, ui.ID_CTRL_TEXT_LEVEL);
		local llevel = card_info.Level;
		lTextLev:SetText( tostring(card_info.Level) );
		
		--经验值 ID_CTRL_TEXT_EXP
		local lCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "card_level", card_info.Level);
		local lTextExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_EXP);
		lTextExp:SetText(tostring(card_info.Exp).."/"..tostring(lCardLeveInfo.exp));
		
		--经验值条 ID_CTRL_EXP_CARDEXP
		local lCardExp = GetExp(p.layer, ui.ID_CTRL_EXP_CARDEXP);
		lCardExp:SetTotal(tonumber(lCardLeveInfo.exp));
		lCardExp:SetProcess(tonumber(card_info.Exp));
		
		--生命值 ID_CTRL_TEXT_HP
		local lTextHP = GetLabel(p.layer, ui.ID_CTRL_TEXT_HP);
		lTextHP:SetText(tostring(card_info.Hp));
		
		--攻击值 ID_CTRL_TEXT_ATTACK
		local lTextAttack = GetLabel(p.layer, ui.ID_CTRL_TEXT_ATTACK);
		lTextAttack:SetText(tostring(card_info.Attack));		
		
		--防御值 ID_CTRL_TEXT_DEFENCE
		local lTextDeffnce = GetLabel(p.layer, ui.ID_CTRL_TEXT_DEFENCE);
		lTextDeffnce:SetText(tostring(card_info.Defence));		
		
		--队伍 ID_CTRL_PICTURE_TEAM
		local lPicTeam = GetImage(p.layer, ui.ID_CTRL_PICTURE_TEAM);
		if card_info.Team_marks == 1 then
			lPicTeam:SetVisible(true);				
			lPicTeam:SetPicture( GetPictureByAni("common_ui.teamName", 0) );
		elseif card_info.Team_marks == 2 then
			lPicTeam:SetVisible(true);				
			lPicTeam:SetPicture( GetPictureByAni("common_ui.teamName", 1) );
		elseif card_info.Team_marks == 3 then
			lPicTeam:SetVisible(true);				
			lPicTeam:SetPicture( GetPictureByAni("common_ui.teamName", 2) );
		else
			lPicTeam:SetVisible( false );
		end		
		

		
		--速度 ID_CTRL_TEXT_247
		local lTextSpeed = GetLabel(p.layer, ui.ID_CTRL_TEXT_247);
		lTextSpeed:SetText(tostring(card_info.Speed));		
		
		--暴击 ID_CTRL_TEXT_248
		local lTextCrit = GetLabel(p.layer, ui.ID_CTRL_TEXT_248);
		lTextCrit:SetText(tostring(card_info.Crit));
	end
end	

function p.setSelCardList(cardIDList)
	local lCount=0;
	for k,v in pairs(cardIDList) do
		local lUniqueId = v;
		for i=1,table.maxn(p.cardListInfo) do
		   local lcardInfo = p.cardListInfo[i];
		   if lUniqueId == lcardInfo.UniqueId then
				lCount = lCount + 1;
				p.SetCardInfo(lCount,lcardInfo);
				break;
		   end;
		end
	end
	
	p.ShowCardCost();
end;	

function p.ShowCardCost()
	
	local cardCount = GetLabel(p.layer,ui.ID_CTRL_TEXT_30);
	cardCount:SetText(tostring(p.selectNum).."/10"); 
	
	local cardMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_32);
	cardMoney:SetText(tostring(p.consumeMoney)); 
	
	if tonumber(p.userMoney) < tonumber(p.consumeMoney) then
		local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
		moneyLab:SetFontColor(ccc4(255,0,0,255));
	end		
end;	

function p.SetCardInfo(pIndex,pCardInfo)  --pIndex从1开始
	if pIndex > 10 then --正常不超过10
		return ;
	end

	local cardLevPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_111+pIndex-1);
	cardLevPic:SetVisible(true);	
												
	local cardLevText = GetLabel(p.layer, ui.ID_CTRL_TEXT_CARDLEVEL1+pIndex-1);
	cardLevText:SetVisible(true);
	cardLevText:SetText("LV"..tostring(pCardInfo.Level));
	
			
	local cardButton = GetButton(p.layer, ui.ID_CTRL_BUTTON_CARD1+pIndex-1);
	local lcardId = tonumber(pCardInfo.CardID);
	local lCardRowInfo= SelectRowInner( T_CHAR_RES, "card_id", lcardId); --从表中获取卡牌详细信息	
	cardButton:SetImage( GetPictureByAni(lCardRowInfo.card_pic, 0) );
	
	p.selectNum = p.selectNum+1;
	p.selectCardId[#p.selectCardId + 1] = pCardInfo.UniqueId;
	
	local lCardLeveInfo;
	if pCardInfo.Level == 0 then
		lCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "card_level", 1);
	else
		lCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "card_level", pCardInfo.Level);
	end		
	p.consumeMoney = p.consumeMoney + lCardLeveInfo.feed_money;	
	
end;	

function p.InitAllCardInfo()
		
	local i;
	for i=1,10 do
		local cardLevText = GetLabel(p.layer, ui.ID_CTRL_TEXT_CARDLEVEL1+i-1);
		cardLevText:SetVisible(false);
		
		local cardPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_111+i-1);
		cardPic:SetVisible(false);	
		
		local cardBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_CARD1+i-1);
		cardBtn:SetImage(GetPictureByAni("common_ui.cardBg", 0));
	end
	
end;	

function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end

function p.CloseUI()
    if p.layer ~= nil then
		card_intensify2.CloseUI();
	    p.layer:LazyClose();
        p.layer = nil;	
		p.baseCardInfo = nil;
		p.cardListInfo = nil;
		p.userMoney = 0;
		p.selectCardId = nil;
		p.consumeMoney = 0;
		p.selectNum = 0;
    end
end

function p.SetDelegate(layer)
	local selBtn = GetButton(layer, ui.ID_CTRL_BUTTON_CHOOSE_BG); --设置按扭事件,注意和遮挡的按扭不一样
	selBtn:SetLuaDelegate(p.OnUIClickEvent);
	
	local selBtnBg = GetButton(layer, ui.ID_CTRL_BUTTON_CARD_CHOOSE);
	selBtnBg:SetLuaDelegate(p.OnUIClickEvent);

	local starBtn = GetButton(layer, ui.ID_CTRL_BUTTON_START);
	starBtn:SetLuaDelegate(p.OnUIClickEvent);

	local closeBtn = GetButton(layer, ui.ID_CTRL_BUTTON_RETURN);
	closeBtn:SetLuaDelegate(p.OnUIClickEvent);

	for i=1,10 do
		local lCardBtn = GetButton(layer, ui.ID_CTRL_BUTTON_CARD1+i-1);
		lCardBtn:SetLuaDelegate(p.OnUIClickEvent);
	end
end
	
function p.OnUIClickEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	local tag = uiNode:GetTag();
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			p.CloseUI();
		elseif(ui.ID_CTRL_BUTTON_CARD_CHOOSE == tag) or (ui.ID_CTRL_BUTTON_CHOOSE_BG == tag) then --选择卡牌
			p.consumeMoney = 0;
			p.selectNum = 0;
			card_intensify2.ShowUI(p.baseCardInfo);
		elseif(ui.ID_CTRL_BUTTON_START == tag) then --强化
			local param = {};
			for k,v in pairs(p.selectCardId) do
				if k == #p.selectCardId then
					param = param..v;
				else
					param = param..v..",";
				end
			end
				p.OnSendReqIntensify(param);
		elseif((ui.ID_CTRL_BUTTON_CARD1 <= tag) and (ui.ID_CTRL_PICTURE_CARD10 >= tag)) then --卡牌点击
			card_intensify.ShowUI(p.baseCardInfo);  
		end;
	end
end		
	
function p.OnSendReqIntensify(msg)
	local uid = GetUID();
	--uid = 10002;
	if uid ~= nil and uid > 0 then
		--模块  Action idm = 饲料卡牌unique_ID (1000125,10000123) 
		local param = string.format("&card_id=%d&idm="..msg, tonumber(p.baseCardInfo.UniqueId));
		SendReq("Card","Feedwould",uid,param);
		card_intensify_succeed.ShowUI(p.baseCardInfo);
		p.ClearData();
	end
end

function p.ClearData()
	p.selectNum = 0;
	p.selectCardId = {};
	p.cardListInfo = nil;
	p.cardListByProf = {};
	p.InitAllCardInfo();
end

function p.ClearSelData()
	p.selectNum = 0;
	p.selectCardId = {};
	p.InitAllCardInfo();
end

