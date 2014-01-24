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
local ui = ui_gacha_result;

function p.ShowUI( gacharesult )
	p.gacharesult = gacharesult;
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
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
end

function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_LEFT );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_START );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RIGHT );
	btn:SetLuaDelegate( p.OnBtnClick );
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
		end
	end
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
		
		local rareImg = GetImage( p.layer, ui.ID_CTRL_PICTURE_75 );
		local rare = tonumber(SelectCell( T_CARD, cardId, "rare" )) or 1;
		rareImg:SetPicture( GetPictureByAni( "ui.card_star", rare - 1 ) );
		
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
	end
end	
