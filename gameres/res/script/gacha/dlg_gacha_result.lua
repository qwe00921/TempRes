--------------------------------------------------------------
-- FileName: 	dlg_gacha_result.lua
-- author:		zjj, 2013/07/22
-- purpose:		扭蛋结果界面
--------------------------------------------------------------

dlg_gacha_result = {}
local p = dlg_gacha_result;

p.layer = nil;
p.cardIndex = 1;
p.gacharesult = nil;
p.againBtn = nil;
p.showboxflag = false;

local ui = ui_gacha_result;

function p.ShowUI( gacharesult )
	p.gacharesult = gacharesult;
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		if p.showboxflag then
			dlg_msgbox.ShowOK( "提示", "背包已满，请查看系统邮件", nil, p.layer );
			p.showboxflag = false;
		end
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddDlg( layer );
	LoadDlg( "gacha_result.xui", layer, nil );
	p.layer = layer;
	
	p.SetDelegate();
	
	p.cardIndex = 1;
	p.ShowCardInfo();
	
	if p.showboxflag then
		dlg_msgbox.ShowOK( "提示", "背包已满，请查看系统邮件", nil, p.layer );
		p.showboxflag = false;
	end
end

function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_LEFT );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_START );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RIGHT );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--再扭一次
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_MORE );
	btn:SetVisible( false );
	btn:SetLuaDelegate( p.OnBtnClick );
	p.againBtn = btn;
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_LEFT == tag then
			p.cardIndex = p.cardIndex - 1;
			p.cardIndex = math.max( p.cardIndex, 1 );
			p.ShowCardInfo();
		elseif ui.ID_CTRL_BUTTON_START == tag then
			WriteCon( "返回" );
			p.CloseUI();
			dlg_menu.ShowUI();
			dlg_gacha.ShowUI();
			dlg_gacha.ReqGachaData();
			
			local user = msg_cache.msg_player;
			dlg_userinfo.ShowUI( user );
			
		elseif ui.ID_CTRL_BUTTON_RIGHT == tag then
			p.cardIndex = p.cardIndex + 1;
			p.ShowCardInfo();
		elseif ui.ID_CTRL_BUTTON_MORE == tag then
			WriteCon( "再次扭蛋" );
			p.GachaAgain();
		end
	end
end

function p.GachaAgain()
	p.CloseUI();
	dlg_menu.ShowUI();
	dlg_gacha.ShowUI();
	local user = msg_cache.msg_player;
	dlg_userinfo.ShowUI( user );
	dlg_gacha.ReqGachaData();
	
	local charge_type = dlg_gacha.charge_type;
	local gacha_id = dlg_gacha.gacha_id;
	local gacha_type = dlg_gacha.gacha_type;
	if charge_type == nil or gacha_id == nil or gacha_type == nil then	
		return;
	end
	
	--免费扭蛋不能再扭
	if  charge_type == 1 then
		return;
	end
	
	local cache = msg_cache.msg_player or {};
	local emoney = tonumber( cache.Emoney ) or 0;
	local needEmoney = tonumber( SelectCell( T_GACHA, gacha_id, gacha_type == 1 and "single_gacha_cost" or "complex_gacha_cost" ) ) or 0;
	if emoney == 0 or emoney < needEmoney then
		dlg_msgbox.ShowYesNo( "提示", "您身上的宝石不足，是否进行充值？", dlg_gacha.DidAddEmoney, dlg_gacha.layer );
		return;
	end
	
	local uid = GetUID();
    if uid == 0 then uid = 100 end; 
	local param = string.format( "&gacha_id=%d&charge_type=%d&gacha_type=%d", gacha_id, charge_type, gacha_type);
	WriteCon( "扭蛋参数：" .. param );
	SendReq("Gacha","Start",uid, param);
end

function p.ShowCardInfo()
	p.gacharesult = p.gacharesult or {};
	local cardList = p.gacharesult.card_ids or {};
	local cardinfo = cardList[p.cardIndex];
	if cardinfo ~= nil then
		local cardId = cardinfo.id or 0;
		local pic = GetImage( p.layer, ui.ID_CTRL_PICTURE_CARD );
		local path = SelectRowInner( T_CHAR_RES, "card_id", cardId, "card_pic" );
		if path then
			pic:SetPicture( GetPictureByAni( path, 0 ) );
		end
		
		--local rareImg = GetImage( p.layer, ui.ID_CTRL_PICTURE_75 );
		--local rare = tonumber(SelectCell( T_CARD, cardId, "rare" )) or 1;
		--rareImg:SetPicture( GetPictureByAni( "ui.card_star", rare - 1 ) );
		
		local hpLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_9 );
		hpLab:SetText( string.format( "血量：%s", tostring( SelectCell( T_CARD, cardId, "hp" ) or "" ) ) );
		
		local atkLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_10 );
		atkLab:SetText( string.format( "攻击：%s", tostring( SelectCell( T_CARD, cardId, "attack" or "" ) ) ) );
		
		local defLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_11 );
		defLab:SetText( string.format( "防御：%s", tostring( SelectCell( T_CARD, cardId, "defence" or "" ) ) ) );
		
		local speedLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_12 );
		speedLab:SetText( string.format( "速度：%s", tostring( SelectCell( T_CARD, cardId, "speed" or "" ) ) ) );
		
		local critLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_13 );
		critLab:SetText( string.format( "暴击：%s", tostring( SelectCell( T_CARD, cardId, "crit" or "" ) ) ) );
		
		local skillLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_14 );
		local skillid = SelectCell( T_CARD, cardId, "skill" ) or 0;
		local skillname =SelectCell( T_SKILL, skillid, "name" ) or "";
		
		skillLab:SetText( skillname );
		
		local descLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_WORD );
		descLab:SetText( string.format( "%s", tostring( SelectCell( T_CARD, cardId, "description" ) or "" ) ) );
	end
	p.ShowOtherCardBtn();
end

function p.ShowOtherCardBtn()
	p.gacharesult = p.gacharesult or {};
	local cardList = p.gacharesult.card_ids or {};
	if p.cardIndex <= 1 then
		local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_LEFT );
		btn:SetVisible( false );
	else
		local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_LEFT );
		btn:SetVisible( true );
	end
	
	if cardList[p.cardIndex+1] == nil then
		local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RIGHT );
		btn:SetVisible( false );
	else
		local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RIGHT );
		btn:SetVisible( true );
	end
	
	p.againBtn = p.againBtn or GetButton( p.layer, ui.ID_CTRL_BUTTON_MORE );
	if p.againBtn ~= nil then
		local charge_type = dlg_gacha.charge_type or 1;
		local gacha_id = dlg_gacha.gacha_id or 0;
		local gacha_type = dlg_gacha.gacha_type or 1;
		
		p.againBtn:SetImage( gacha_type == 1 and GetPictureByAni( "common_ui.gacha_again", 0 ) or GetPictureByAni( "common_ui.gacha_again", 1 ) );
		
		p.againBtn:SetVisible( false );
		if charge_type ~= 1 then
			local cache = msg_cache.msg_player or {};
			local emoney = tonumber( cache.Emoney ) or 0;
			local needEmoney = tonumber( SelectCell( T_GACHA, gacha_id, gacha_type == 1 and "single_gacha_cost" or "complex_gacha_cost" ) ) or 0;
			if emoney ~= 0 and emoney >= needEmoney then
				p.againBtn:SetVisible( true );
			end
		end
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.cardIndex = 1;
		p.gacharesult = nil;
		p.showboxflag = false;
	end
end	

function p.ShowMsgBox()
	if p.layer == nil then
		p.showboxflag = true;
		return;
	end
	
	dlg_msgbox.ShowOK( "提示", "背包已满，请查看系统邮件", nil, p.layer );
end