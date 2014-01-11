card_rein = {}
local p = card_rein;
p.layer = nil;
p.baseCardInfo = nil;

p.cardListInfo = nil;
p.selectNum = 0;
p.consumeMoney = 0;
p.selectCardId = {};
p.userMoney = 0;
p.addExp = 0;
p.nowExp = 0;

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
		p.ShowUI(card_info);
		return;
	end	
end;	

function p.GetRefreshCardUI()
	if p.baseCardInfo ~= nil then
		card_intensify2.OnSendCardDetail(tostring(p.baseCardInfo.UniqueID))
	end
end;

function p.getCardListInfo()
	return p.cardListInfo;
end;	

function p.setCardListInfo(cardListInfo)
	p.cardListInfo = cardListInfo;
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

function p.InitUI(card_info)

	if card_info ~= nil then
		if card_info.UniqueID ~= nil then
			card_info.UniqueId = tonumber(card_info.UniqueID); --属性缺少
		else
			card_info.UniqueID = tostring(card_info.UniqueId)
		end;
	end;
	p.baseCardInfo = p.copyTab(card_info);  --表的COPY
	p.InitAllCardInfo(); --初始化所有卡牌
	p.ShowCardCost();
	if card_info == nil then --挡板的设置
		local selBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_CARD_CHOOSE);
		selBtn:SetVisible(true);
	else
		local selBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_CARD_CHOOSE);
		selBtn:SetVisible(false);		
		
		card_intensify2.CloseUI();	
		
		--头像 CTRL_PICTURE_231			CTRL_BUTTON_MAIN	 GetPictureByAni("w_battle.intensify_"..lcardId,0) 
		local lCardResRowInfo= SelectRowInner( T_CHAR_RES, "card_id", card_info.CardID); --从表中获取卡牌详细信息			
		local lHeadPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_231);
		--lHeadPic:SetPicture( GetPictureByAni(lCardResRowInfo.head_pic, 0) );	
		lHeadPic:SetPicture(GetPictureByAni("w_battle.intensify_"..card_info.CardID,0));
			
		--名字 CTRL_TEXT_252
		local lCardRowInfo= SelectRowInner( T_CARD, "id", card_info.CardID); --从表中获取卡牌详细信息					
		local lTextName = GetLabel(p.layer, ui.ID_CTRL_TEXT_252);
		lTextName:SetText(tostring(lCardRowInfo.name));
		
		--当前经验值更新
		p.nowExp = tonumber(card_info.Exp);
		
		--等级 ID_CTRL_TEXT_LEVEL		
		local lTextLev = GetLabel(p.layer, ui.ID_CTRL_TEXT_LEVEL);
		local llevel = card_info.Level;
		lTextLev:SetText( tostring(card_info.Level) );

		--当前的经验值条 ID_CTRL_EXP_CARDEXP
		local lCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", card_info.Level);
		local lCardExp = GetExp(p.layer, ui.ID_CTRL_EXP_CARDEXP);
		lCardExp:SetTotal(tonumber(lCardLeveInfo.exp));
		lCardExp:SetProcess(tonumber(card_info.Exp));
		lCardExp:SetNoText();
				
		p.SetExp(card_info);
		--local pCardUpLevelInfo= SelectRowInner( T_CARD_LEVEL, "level", tonumber(p.cardInfo.Level)+1);
		--local expSstartNum = tonumber(card_info.Exp);
		--local expLeast = 0;
		--expbar_move_effect.showEffect(lCardExp,expLeast,tonumber(pCardUpLevelInfo.exp),expSstartNum,0);
		--[[
		--经验值 ID_CTRL_TEXT_EXP
		local lCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "card_level", card_info.Level);
		local lTextExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_EXP);
		lTextExp:SetText(tostring(card_info.Exp).."( +"..tostring(p.addExp).." ) ".."/"..tostring(lCardLeveInfo.exp));
		

		--加上经验后的经验条
		local lCardExp = GetExp(p.layer, ui.ID_CTRL_EXP_CARDADD);
		local laddAllExp = tonumber(card_info.Exp) + p.addExp;
		if laddAllExp > tonumber(lCardLeveInfo.exp) then
			laddAllExp = tonumber(lCardLeveInfo.exp)
		end;
		lCardExp:SetTotal(tonumber(lCardLeveInfo.exp));
		lCardExp:SetProcess(tonumber(laddAllExp));
		lCardExp:SetNoText();
		]]--
		--生命值 ID_CTRL_TEXT_HP
		local lTextHP = GetLabel(p.layer, ui.ID_CTRL_TEXT_HP);
		lTextHP:SetText(tostring(card_info.Hp));
		WriteCon("HP = "..card_info.Hp);
		--攻击值 ID_CTRL_TEXT_ATTACK
		local lTextAttack = GetLabel(p.layer, ui.ID_CTRL_TEXT_ATTACK);
		lTextAttack:SetText(tostring(card_info.Attack));		
		
		--防御值 ID_CTRL_TEXT_DEFENCE
		local lTextDeffnce = GetLabel(p.layer, ui.ID_CTRL_TEXT_DEFENCE);
		lTextDeffnce:SetText(tostring(card_info.Defence));		
		
		--队伍 ID_CTRL_PICTURE_TEAM
		local lPicTeam = GetImage(p.layer, ui.ID_CTRL_PICTURE_TEAM);
		if tonumber(card_info.Team_marks) == 1 then
			lPicTeam:SetVisible(true);				
			lPicTeam:SetPicture( GetPictureByAni("common_ui.teamName", 0) );
		elseif tonumber(card_info.Team_marks) == 2 then
			lPicTeam:SetVisible(true);				
			lPicTeam:SetPicture( GetPictureByAni("common_ui.teamName", 1) );
		elseif tonumber(card_info.Team_marks) == 3 then
			lPicTeam:SetVisible(true);				
			lPicTeam:SetPicture( GetPictureByAni("common_ui.teamName", 2) );
		else
			lPicTeam:SetVisible( false );
		end		
		
		--速度 ID_CTRL_TEXT_247
		local lTextSpeed = GetLabel(p.layer, ui.ID_CTRL_TEXT_247);
		lTextSpeed:SetText(tostring(card_info.Speed));		
		
		--暴击 ID_CTRL_TEXT_248
		--local lTextCrit = GetLabel(p.layer, ui.ID_CTRL_TEXT_248);
		--lTextCrit:SetText(tostring(card_info.Crit));
	end
end	

function p.setSelCardList(cardIDList)
	p.ClearSelData();
	
	local lCount=0;
	for k,v in pairs(cardIDList) do
		local lUniqueId = v;
		local lNum = #(p.cardListInfo)
		for i=1,lNum do
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
	
	local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
	moneyLab:SetText(tostring(p.userMoney));	
	
	if tonumber(p.userMoney) < tonumber(p.consumeMoney) then
		--local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
		moneyLab:SetFontColor(ccc4(255,0,0,255));
    else	
		moneyLab:SetFontColor(ccc4(255,255,255,255));
	end		
end;	

function p.SetCardInfo(pIndex,pCardInfo)  --pIndex从1开始
	if pIndex > 10 then --正常不超过10
		return ;
	end
	WriteCon("SetCardInfoWS"..pIndex.."  LEVELE : "..pCardInfo.Level);
	local cardLevText = GetLabel(p.layer, ui.ID_CTRL_TEXT_CARDLEVEL1+pIndex-1);
	cardLevText:SetVisible(true);
	cardLevText:SetText("LV "..tostring(pCardInfo.Level));
	
	--local cardLevPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_111+pIndex-1);
	--cardLevPic:SetVisible(true);	
	
	
	
	local cardButton = GetImage(p.layer, ui.ID_CTRL_BUTTON_CHA1+pIndex-1);
	local lcardId = tonumber(pCardInfo.CardID);
	local lCardRowInfo= SelectRowInner( T_CHAR_RES, "card_id", lcardId); --从表中获取卡牌详细信息	
	
	
	--cardButton:SetImage( GetPictureByAni("n_battle.attack_"..lcardId,0) );
	cardButton:SetPicture( GetPictureByAni("w_battle.intensify_"..lcardId,0) );
	local lCardInfo = SelectRowInner( T_CARD, "id", lcardId);
	
	local cardName = GetLabel(p.layer, ui.ID_CTRL_TEXT_NAME1+pIndex-1);
	cardName:SetText(tostring(lCardInfo.name));
	
	p.selectNum = p.selectNum+1;
	p.selectCardId[#p.selectCardId + 1] = pCardInfo.UniqueId;
	
	local lCardLeveInfo;
	if pCardInfo.Level == 0 then
		lCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", 1);
	else
		lCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", pCardInfo.Level);
	end		
	p.consumeMoney = p.consumeMoney + lCardLeveInfo.feed_money;	
	
	
	
	p.addExp = p.addExp + lCardInfo.feedBase_exp + lCardLeveInfo.feed_exp;
	
	p.SetExp(pCardInfo);
end;

function p.SetExp(card_info)

	
	--经验值 ID_CTRL_TEXT_EXP
	local lCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", card_info.Level);
	local lTextExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_EXP);
	lTextExp:SetText(tostring(p.nowExp).."( +"..tostring(p.addExp).." ) ".."/"..tostring(lCardLeveInfo.exp));
	
	--[[--经验值条 ID_CTRL_EXP_CARDEXP
	local lCardExp = GetExp(p.layer, ui.ID_CTRL_EXP_CARDEXP);
	lCardExp:SetTotal(tonumber(lCardLeveInfo.exp));
	lCardExp:SetProcess(tonumber(p.nowExp));
	lCardExp:SetNoText();--]]

 --累加后的经验条	
	local lCardExp = GetExp(p.layer, ui.ID_CTRL_EXP_CARDADD);
	local laddAllExp = p.nowExp + p.addExp;
	if laddAllExp > tonumber(lCardLeveInfo.exp) then
		laddAllExp = tonumber(lCardLeveInfo.exp)
	end;
	lCardExp:SetTotal(tonumber(lCardLeveInfo.exp));
	lCardExp:SetProcess(tonumber(laddAllExp));
	lCardExp:SetNoText();	
end;	

function p.InitAllCardInfo()
		
	local i;
	for i=1,10 do
		
		local tLevel= "ID_CTRL_TEXT_CARDLEVEL"..tostring(i);--按钮
		--local btCard= "ID_CTRL_BUTTON_CHA"..tostring(i);--装备图
		local tName = "ID_CTRL_TEXT_NAME"..tostring(i);--装备图背景
		
		local cardLevText = GetLabel(p.layer, ui[tLevel]);
		cardLevText:SetVisible(false);
		WriteCon("~~~~~   i = "..i);
		--local cardPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_111+i-1);
		--cardPic:SetVisible(false);	
		
		--local cardBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_CARD1+i-1);
		--cardBtn:SetImage(GetPictureByAni("common_ui.cardBg", 0));
		--local cardButton = GetImage(p.layer, ui[btCard]);
		--cardButton:SetPicture(GetPictureByAni("common_ui.cardBg", 0) );
	
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
		card_intensify2.CloseUI();
	    p.layer:LazyClose();
        p.layer = nil;	
		p.baseCardInfo = nil;
		p.cardListInfo = nil;
		p.userMoney = 0;
		p.selectCardId = nil;
		p.consumeMoney = 0;
		p.selectNum = 0;
		p.nowExp = 0;
		p.addExp = 0;
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
		local lCardBtn = GetButton(layer, ui.ID_CTRL_BUTTON_CHA1+i-1);
		lCardBtn:SetLuaDelegate(p.OnButtonEvent);
	end
end
	
function p.OnButtonEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	if IsClickEvent(uiEventType) then
		card_intensify.ShowUI(p.baseCardInfo);  
	end
end

function p.OnUIClickEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	local tag = uiNode:GetTag();
	WriteCon("tag = "..tag);
	WriteCon("ui.ID_CTRL_BUTTON_CHA1 : "..ui.ID_CTRL_BUTTON_CHA1);
	
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			p.CloseUI();
		elseif(ui.ID_CTRL_BUTTON_CARD_CHOOSE == tag) or (ui.ID_CTRL_BUTTON_CHOOSE_BG == tag) then --选择卡牌
			card_intensify2.ShowUI(p.baseCardInfo);
		elseif(ui.ID_CTRL_BUTTON_START == tag) then --强化
			local param = "";
			for k,v in pairs(p.selectCardId) do
				if k == #p.selectCardId then
					param = param..tostring(v);
				else
					param = param..tostring(v)..",";
				end
			end
			if param ~= "" then
				p.OnSendReqIntensify(param);
			else
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_intensify_no_card"),p.OnMsgCallback,p.layer);
			end;
		--[[elseif((ui.ID_CTRL_BUTTON_CHA1 <= tag) and (ui.ID_CTRL_PICTURE_CHA10 >= tag)) then --卡牌点击
			--if p.baseCardInfo ~= nil then
				WriteCon("111111111111  ");
				card_intensify.ShowUI(p.baseCardInfo);  
			--else
				--未选择需强化的卡牌
			--end;]]--
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
	p.consumeMoney = 0;
	p.selectCardId = {};
	p.addExp = 0;
	p.InitAllCardInfo();
end

