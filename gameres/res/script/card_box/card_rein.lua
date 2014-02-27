card_rein = {}
local p = card_rein;
p.layer = nil;
p.baseCardInfo = nil;

p.cardListInfo = nil;
p.selectNum = 0;
p.consumeMoney = 0;
p.selectCardId = {};
--p.userMoney = 0;
p.addExp = 0;
p.nowExp = 0;
p.maskLayer = nil;

p.result = nil;

local ui = ui_card_rein;

function p.ShowUI(card_info)
	maininterface.HideUI();
	card_intensify.CloseUI();
	card_intensify_succeed.CloseUI();
	
	local cache = msg_cache.msg_player;
	dlg_userinfo.ShowUI( cache );
	
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		if card_info~= nil then
			p.InitUI(card_info);
		end
		return;
	end
	
	if dlg_card_attr_base.layer == nil then
		WriteCon("card_bag_mian.layer == nil ");
		dlg_menu.SetNewUI( p );
	end
	
	maininterface.HideUI();
	
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	layer:NoMask();
    layer:Init();   
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddChildZ(layer,0);
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


function p.UpdateUserMoney()
	local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
	moneyLab:SetText(tostring(msg_cache.msg_player.Money));
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
	
	local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
	moneyLab:SetText(tostring(msg_cache.msg_player.Money));
	
	local dontimg = GetImage(p.layer, ui.ID_CTRL_PICTURE_186);
	local txtlab = GetLabel(p.layer, ui.ID_CTRL_TEXT_416);
	if card_info == nil then --挡板的设置
		
		dontimg:SetPicture(GetPictureByAni("ui.ui_bg",0));
	else
			
		dontimg:SetVisible(false);
		
		txtlab:SetText("");
		card_intensify2.CloseUI();	
		--头像 CTRL_PICTURE_231			CTRL_BUTTON_MAIN	 GetPictureByAni("w_battle.intensify_"..lcardId,0) 
		local lCardResRowInfo= SelectRowInner( T_CHAR_RES, "card_id", card_info.CardID); --从表中获取卡牌详细信息			
		local lHeadPic = GetPlayer(p.layer, ui.ID_CTRL_SPRITE_CARD);	
		--lHeadPic:SetPicture(GetPictureByAni("w_battle.intensify_"..card_info.CardID,0));
		--lHeadPic:SetScaleX(GetUIScale());
	
		lHeadPic:UseConfig(tostring(card_info.CardID));
		lHeadPic:SetLookAt(E_LOOKAT_LEFT);
		lHeadPic:Standby("");
		lHeadPic:SetEnableSwapDrag(true);
		lHeadPic:SetScaleX(GetUIScale());
	
		--lHeadPic:SetScaleX(2.0);
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
			
		--经验值 ID_CTRL_TEXT_EXP
		local lTextExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_EXP);
		lTextExp:SetText(tostring(card_info.Exp).."/"..tostring(lCardLeveInfo.exp));

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
	cardCount:SetText(tostring(p.addExp)); 
	
	local cardMoney = GetLabel(p.layer,ui.ID_CTRL_TEXT_32);
	cardMoney:SetText(tostring(p.consumeMoney)); 
	
	local moneyLab = GetLabel(p.layer,ui.ID_CTRL_TEXT_31);
	moneyLab:SetText(tostring(msg_cache.msg_player.Money));	
	
	if tonumber(msg_cache.msg_player.Money) < tonumber(p.consumeMoney) then
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
	local lLevelStr 	= "ID_CTRL_TEXT_CARDLEVEL"..pIndex;--等级
	local lCardPic 	= "ID_CTRL_BUTTON_CHA"..pIndex;--cardpic
	local lCardName 	= "ID_CTRL_TEXT_NAME"..pIndex;--cardpic
	local lCardSprite 	= "ID_CTRL_SPRITE_"..pIndex;--cardpic
	local lCardStar = "ID_CTRL_PICTURE_"..tostring(127+pIndex);	
	
	WriteCon("SetCardInfoWS"..pIndex.."  LEVELE : "..pCardInfo.Level);
	local cardLevText = GetLabel(p.layer, ui[lLevelStr]);
	cardLevText:SetVisible(true);
	cardLevText:SetText("LV "..tostring(pCardInfo.Level));
			
	local cardButton = GetButton(p.layer, ui[lCardPic]);
	local lcardId = tonumber(pCardInfo.CardID);
	local lCardRowInfo= SelectRowInner( T_CHAR_RES, "card_id", lcardId); --从表中获取卡牌详细信息	

	local CardStar = GetImage(p.layer, ui[lCardStar]);
    CardStar:SetVisible(true);
	local lstarNum = pCardInfo.Rare;
	CardStar:SetPicture(GetPictureByAni("common_ui.equipStar",lstarNum));
	
	WriteCon("********    =  "..lCardSprite);	
	
	local cardSprite = GetPlayer(p.layer, ui[lCardSprite]);
	cardSprite:SetVisible(true);
	cardSprite:UseConfig(tostring(lcardId));
	cardSprite:SetLookAt(E_LOOKAT_LEFT);
	cardSprite:Standby("");
	WriteCon("FWEFWEFWEFWEFWEFWE");
	cardSprite:SetEnableSwapDrag(true);
	cardSprite:SetScaleX(GetUIScale());
		
	--cardButton:SetImage( GetPictureByAni("n_battle.attack_"..lcardId,0) );
	--cardButton:SetImage( GetPictureByAni("w_battle.intensify_"..lcardId,0) );
	--cardButton:SetScaleX(GetUIScale());
	--cardButton:SetScaleX(2.0);
	local lCardInfo = SelectRowInner( T_CARD, "id", lcardId);
	
	local cardName = GetLabel(p.layer, ui[lCardName]);
	cardName:SetText(tostring(lCardInfo.name));
	cardName:SetVisible( false );
	
	p.selectNum = p.selectNum+1;
	p.selectCardId[#p.selectCardId + 1] = pCardInfo.UniqueId;
	
	local lCardLeveInfo;
	if pCardInfo.Level == 0 then
		lCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", 1);
	else
		lCardLeveInfo= SelectRowInner( T_CARD_LEVEL, "level", pCardInfo.Level);
	end		
	
	--p.consumeMoney = p.consumeMoney + lCardLeveInfo.feed_money or 0 + tonumber(pCardInfo.Level or 1)*tonumber(pCardInfo.Level or 1);	
	
	--p.addExp = p.addExp + lCardInfo.feedbase_exp or 0 + lCardLeveInfo.feed_exp or 0;

	local feed_money = 0;
	if lCardLeveInfo.feed_money ~= nil then
		feed_money = tonumber(lCardLeveInfo.feed_money);
	end

	p.consumeMoney = p.consumeMoney + feed_money;
	
	local feedbase_exp = 0;
	if lCardInfo.feedbase_exp ~= nil then
		feedbase_exp = tonumber(lCardInfo.feedbase_exp);
	end
	
	local feed_exp = 0;
	if lCardLeveInfo.feed_exp ~= nil then
		feed_exp = tonumber(lCardLeveInfo.feed_exp);
	end
	
	p.addExp = p.addExp + feedbase_exp + feed_exp;	
	--WriteCon("addExp="..tostring(p.addExp));
end;

function p.InitAllCardInfo()
		
	local i;
	for i=1,10 do
		
		local tLevel= "ID_CTRL_TEXT_CARDLEVEL"..tostring(i);--按钮
		local tName = "ID_CTRL_TEXT_NAME"..tostring(i);--装备图背景
		local lCardPic 	= "ID_CTRL_BUTTON_CHA"..tostring(i);--cardpic
		local lCardSprite 	= "ID_CTRL_SPRITE_"..tostring(i);--cardpic
        local lCardStar = "ID_CTRL_PICTURE_"..tostring(127+i);
		
		local cardLevText = GetLabel(p.layer, ui[tLevel]);
		cardLevText:SetVisible(false);

		local cardButton = GetButton(p.layer, ui[lCardPic]); 
		cardButton:SetImage(nil);
		
		local cardName = GetLabel(p.layer,ui[tName]);
		cardName:SetText("");
		
		local cardSprite = GetPlayer(p.layer, ui[lCardSprite]);
		cardSprite:SetVisible(false);
		
		local cardStar = GetImage(p.layer, ui[lCardStar]);
		cardStar:SetVisible(false);
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
		--p.userMoney = 0;
		p.selectCardId = {};
		p.consumeMoney = 0;
		p.selectNum = 0;
		p.nowExp = 0;
		p.addExp = 0;
		p.result = nil;
    end
	
	if p.maskLayer ~= nil then
		p.maskLayer:LazyClose();
		p.maskLayer = nil;
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
		local lCardPic 	= "ID_CTRL_BUTTON_CHA"..tostring(i);--cardpic
		local lCardBtn = GetButton(layer, ui[lCardPic]);
		lCardBtn:SetLuaDelegate(p.OnButtonEvent);
	end
end
	
function p.OnButtonEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	if IsClickEvent(uiEventType) then
		if p.baseCardInfo ~= nil then
			local pCardRare= SelectRowInner( T_CARD_LEVEL_LIMIT, "star",p.baseCardInfo.Rare); --从表中获取卡牌详细信息	
			if tonumber( p.baseCardInfo.Level) >= tonumber(pCardRare.level_limit) then
				dlg_msgbox.ShowOK(GetStr("card_box_intensify"),tostring(p.baseCardInfo.Rare)..GetStr("card_intensify_no_level1")..tostring(pCardRare.level_limit)..GetStr("card_intensify_no_level2"),p.OnMsgCallback,p.layer);
			else
				card_intensify.ShowUI(p.baseCardInfo); 
				p.HideUI();
			end
			
		end
		
	end
end

function p.rookieStep()
	card_intensify.ShowUI(p.baseCardInfo); 
	p.HideUI();
end
function p.rookieStart()
	local starBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_START);
	p.OnUIClickEvent(starBtn, NUIEventType.TE_TOUCH_CLICK)
end
function p.OnUIClickEvent(uiNode, uiEventType, param)
	WriteCon("OnUIClickEvent....");	
	local tag = uiNode:GetTag();
	WriteCon("tag = "..tag);
	WriteCon("ui.ID_CTRL_BUTTON_CHA1 : "..ui.ID_CTRL_BUTTON_CHA1);
	
	if IsClickEvent(uiEventType) then
		if(ui.ID_CTRL_BUTTON_RETURN == tag) then --返回
			p.CloseUI();
			--dlg_menu.HideUI();
			if dlg_card_attr_base.layer ~= nil then
				WriteCon("card_bag_mian.layer ~= nil ");
				dlg_card_attr_base.ShowUI();
			else 
				maininterface.ShowUI();
			end
			
		elseif(ui.ID_CTRL_BUTTON_CARD_CHOOSE == tag) or (ui.ID_CTRL_BUTTON_CHOOSE_BG == tag) then --选择卡牌
			card_intensify2.ShowUI(p.baseCardInfo);
			p.HideUI();
		elseif(ui.ID_CTRL_BUTTON_START == tag) then --强化
			if tonumber(msg_cache.msg_player.Money) < tonumber(p.consumeMoney) then
				dlg_msgbox.ShowOK(GetStr("card_caption"),GetStr("card_intensify_money"),p.OnMsgCallback,p.layer);
			else
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
			end
			
			
		
		end;
	end
end		

function p.OnMsgCallback()
	
end

function p.OnSendReqIntensify(msg)
	local uid = GetUID();
	--uid = 10002;
	if uid ~= nil and uid > 0 then
		--模块  Action idm = 饲料卡牌unique_ID (1000125,10000123) 
		local param = string.format("&card_id=%d&idm="..msg, tonumber(p.baseCardInfo.UniqueId));
		SendReq("Card","Feedwould",uid,param);
		--card_intensify_succeed.ShowUI(p.baseCardInfo);
		--p.HideUI();
		--p.ClearData();
	end
end

function p.OnServerBack( data )
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
	for i = 1, #p.selectCardId do
		local seq1 = batch1:AddSerialSequence();
		local node1 = GetImage( p.layer, ui["ID_CTRL_PICTURE_NODE".. i] );
		local cmd1 = createCommandEffect():AddFgEffect( 0.8, node1, "lancer.card_intensify_effect_1" );
		seq1:AddCommand( cmd1 );
		
		local cmdLua = createCommandLua():SetCmd( "card_rein_effect_end", i, 1, "" );
		seq1:AddCommand( cmdLua );
		
		cmd = cmd1;
	end
	
	local batch2 = battle_show.GetNewBatch();
	local seq2 = batch2:AddSerialSequence();
	local node2 = GetImage( p.layer, ui.ID_CTRL_PICTURE_125 );
	local cmd2 = createCommandEffect():AddFgEffect( 1.5, node2, "lancer.card_intensify_effect_2" );
	seq2:AddCommand( cmd2 );
	seq2:SetWaitEnd( cmd );
	
	local luaBatch = battle_show.GetNewBatch();
	local luaSeq = luaBatch:AddSerialSequence();
	local cmdLua = createCommandLua():SetCmd( "card_rein_converged", 1, 1, "" );
	luaSeq:AddCommand( cmdLua );
	luaSeq:SetWaitEnd( cmd2 );
	
	local batch3 = battle_show.GetNewBatch();
	local seq3 = batch3:AddSerialSequence();
	local node3 = GetImage( p.layer, ui.ID_CTRL_PICTURE_127 );
	node3:SetFrameRect( node2:GetFrameRect() );
	local cmd3 = createCommandEffect():AddActionEffect( 0.35, node3, "lancer_cmb.card_intensify_move" );
	seq3:AddCommand( cmd3 );
	seq3:SetWaitEnd( cmd2 );
	
	local env = cmd3:GetVarEnv();
	
	local center1 = node3:GetCenterPos();
	local card = GetPlayer( p.layer, ui.ID_CTRL_SPRITE_CARD );	
	local center2 = card:GetCenterPos();
	env:SetFloat( "$1", center2.x - center1.x );
	env:SetFloat( "$2", center2.y - center1.y );
	
	local luaBatch1 = battle_show.GetNewBatch();
	local luaSeq1 = luaBatch1:AddSerialSequence();
	local cmdLua1 = createCommandLua():SetCmd( "card_rein_move_end", 1, 1, "" );
	luaSeq1:AddCommand( cmdLua1 );
	luaSeq1:SetWaitEnd( cmd3 );
end

function p.ConvergedEnd()
	local node = GetImage( p.layer, ui.ID_CTRL_PICTURE_127 );
	local node1 = GetImage( p.layer, ui.ID_CTRL_PICTURE_125 );
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

	card_intensify_succeed.ShowUI(p.baseCardInfo);
	card_intensify_succeed.ShowCardLevel( p.result );
	p.HideUI();
end

function p.HideSelectCard( id, num )
	local lCardSprite = "ID_CTRL_SPRITE_"..tostring(id);--cardpic
	local cardSprite = GetPlayer(p.layer, ui[lCardSprite]);
	cardSprite:SetVisible(false);
end

function p.ClearData()
	p.selectNum = 0;
	p.selectCardId = {};
	p.cardListInfo = nil;
	p.cardListByProf = {};
	p.result = nil;
	p.InitAllCardInfo();
end

function p.ClearSelData()
	p.selectNum = 0;
	p.consumeMoney = 0;
	p.selectCardId = {};
	p.addExp = 0;
	p.InitAllCardInfo();
end

function p.UIDisappear()
	p.CloseUI();
	card_intensify.CloseUI();
	card_intensify2.CloseUI();
	card_intensify_succeed.CloseUI();
	maininterface.BecomeFirstUI();
end
