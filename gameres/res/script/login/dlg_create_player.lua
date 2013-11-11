--------------------------------------------------------------
-- FileName: 	dlg_create_player.lua
-- author:		xyd, 2013/07/09
-- purpose:		人物创建
--------------------------------------------------------------

dlg_create_player = {}
local p = dlg_create_player;

p.layer = nil;

p.playerIcon_1 = nil;
p.playerIcon_2 = nil;
p.playerIcon_3 = nil;

p.playerBtnMale = nil;
p.playerBtnFemale = nil;
p.playerRandomBtn = nil;
p.playerCreateBtn = nil;
p.playerInputBtn = nil;


p.curHumanChoose = 0;  	--[0 : 男性	 1：女性]
p.curPlayerChoose = nil;
p.curUserName = nil;
p.create_user_id = 0;

--显示UI
function p.ShowUI()
	p.curPlayerChoose = 1;

	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end

	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end

	layer:Init(layer);
	GetUIRoot():AddDlg(layer);
	LoadUI("dlg_create_player.xui", layer, nil);

	p.Init(layer);
	p.layer = layer;
end

function p.Init(layer)

	p.playerIcon_1 = GetButton(layer,ui_dlg_create_player.ID_CTRL_BUTTON_1 );
	p.playerIcon_2 = GetButton(layer,ui_dlg_create_player.ID_CTRL_BUTTON_2 );
	p.playerIcon_3 = GetButton(layer,ui_dlg_create_player.ID_CTRL_BUTTON_3 );
	p.playerIcon_1:SetImage( GetPictureByAni("lancer.player_bg", 1) );
	p.playerIcon_1:SetTouchDownImage( GetPictureByAni("lancer.player_bg", 1) );
	p.playerIcon_2:SetImage( GetPictureByAni("lancer.player_bg", 2) );
	p.playerIcon_3:SetImage( GetPictureByAni("lancer.player_bg", 3) );
	p.playerIcon_1:SetLuaDelegate(p.OnUIEventPlayer);
	p.playerIcon_2:SetLuaDelegate(p.OnUIEventPlayer);
	p.playerIcon_3:SetLuaDelegate(p.OnUIEventPlayer);

	p.playerIcon_1:AddFgEffect("lancer_cmb.player_bg_eft");

	p.playerBtnMale = GetButton(layer,ui_dlg_create_player.ID_CTRL_BUTTON_4 );
	p.playerBtnFemale = GetButton(layer,ui_dlg_create_player.ID_CTRL_BUTTON_5 );
	p.playerBtnMale:SetImage( GetPictureByAni("lancer.player_select_bg", 1) );
	p.playerBtnFemale:SetImage( GetPictureByAni("lancer.player_select_bg", 0) );
	p.playerBtnMale:SetLuaDelegate(p.OnUIEventChoose);
	p.playerBtnFemale:SetLuaDelegate(p.OnUIEventChoose);

	p.playerRandomBtn = GetButton(layer,ui_dlg_create_player.ID_CTRL_BUTTON_7 );
	p.playerRandomBtn:SetLuaDelegate(p.OnUIEventPlayerRandom);

	p.playerCreateBtn = GetButton(layer,ui_dlg_create_player.ID_CTRL_BUTTON_8 );
	p.playerCreateBtn:SetLuaDelegate(p.OnUIEventPlayerCreate);

	p.playerInputBtn = GetLabel( layer,ui_dlg_create_player.ID_CTRL_TEXT_13 )
	p.curUserName = GetRandomMaleName();
	p.playerInputBtn:SetText(p.curUserName);
end

function p.OnUIEventPlayerCreate(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then

		if ( ui_dlg_create_player.ID_CTRL_BUTTON_8 == tag ) then

			if ( p.curPlayerChoose ~= nil and p.curUserName ~= nil) then

                --发Utf8编码的中文串给服务端
				--local ansiName = FromUtf8( p.curUserName );
				--local user_id = GetNameID( ansiName );
				local user_id = GetNameID( p.curUserName );
				local param = string.format("character=%d&user_name=%s&sex=%d", p.curPlayerChoose, p.curUserName, p.curHumanChoose);
				SendReq( "User","Create",user_id,param );
				p.create_user_id = user_id;
			else
				WriteCon("请选择喜欢的角色!");
			end
		end
	end
end

function p.OnUIEventPlayerRandom(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_dlg_create_player.ID_CTRL_BUTTON_7 == tag ) then
			if ( 0 == p.curHumanChoose ) then
				p.curUserName = GetRandomMaleName();
			elseif ( 1 == p.curHumanChoose ) then
				p.curUserName = GetRandomFemaleName();
			end
			p.playerInputBtn:SetText(p.curUserName);
		end
	end
end

function p.OnUIEventPlayer(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then

		p.clearAllEffect();

		if (0 == p.curHumanChoose) then

			if ( ui_dlg_create_player.ID_CTRL_BUTTON_1 == tag ) then
				WriteCon( "男1");
				p.playerIcon_1:AddFgEffect("lancer_cmb.player_bg_eft");
				p.curPlayerChoose = 1;
			elseif ( ui_dlg_create_player.ID_CTRL_BUTTON_2 == tag ) then
				WriteCon( "男2");
				p.playerIcon_2:AddFgEffect("lancer_cmb.player_bg_eft");
				p.curPlayerChoose = 2;
			elseif ( ui_dlg_create_player.ID_CTRL_BUTTON_3 == tag ) then
				WriteCon( "男3");
				p.playerIcon_3:AddFgEffect("lancer_cmb.player_bg_eft");
				p.curPlayerChoose = 3;
			end

		elseif (1 == p.curHumanChoose) then

			if ( ui_dlg_create_player.ID_CTRL_BUTTON_1 == tag ) then
				WriteCon( "女1");
				p.playerIcon_1:AddFgEffect("lancer_cmb.player_bg_eft");
				p.curPlayerChoose = 4;
			elseif ( ui_dlg_create_player.ID_CTRL_BUTTON_2 == tag ) then
				WriteCon( "女2");
				p.playerIcon_2:AddFgEffect("lancer_cmb.player_bg_eft");
				p.curPlayerChoose = 5;
			elseif ( ui_dlg_create_player.ID_CTRL_BUTTON_3 == tag ) then
				WriteCon( "女3");
				p.playerIcon_3:AddFgEffect("lancer_cmb.player_bg_eft");
				p.curPlayerChoose = 6;
			end
		end

	end
end

function p.OnUIEventChoose(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then

		if ( ui_dlg_create_player.ID_CTRL_BUTTON_4 == tag ) then
			p.playerBtnMale:SetImage( GetPictureByAni("lancer.player_select_bg", 1) );
			p.playerBtnFemale:SetImage( GetPictureByAni("lancer.player_select_bg", 0) );

			p.playerIcon_1:SetImage( GetPictureByAni("lancer.player_bg", 1) );
			p.playerIcon_2:SetImage( GetPictureByAni("lancer.player_bg", 2) );
			p.playerIcon_3:SetImage( GetPictureByAni("lancer.player_bg", 3) );

			p.playerInputBtn:SetText(GetRandomMaleName());
			p.curHumanChoose = 0;

		elseif ( ui_dlg_create_player.ID_CTRL_BUTTON_5 == tag ) then
			p.playerBtnMale:SetImage( GetPictureByAni("lancer.player_select_bg", 0) );
			p.playerBtnFemale:SetImage( GetPictureByAni("lancer.player_select_bg", 1) );

			p.playerIcon_1:SetImage( GetPictureByAni("lancer.player_bg", 4) );
			p.playerIcon_2:SetImage( GetPictureByAni("lancer.player_bg", 5) );
			p.playerIcon_3:SetImage( GetPictureByAni("lancer.player_bg", 6) );

			p.playerInputBtn:SetText(GetRandomFemaleName());
			p.curHumanChoose = 1;
		end
	end
end

function p.clearAllEffect()

	p.playerIcon_1:DelAniEffect("lancer_cmb.player_bg_eft");
	p.playerIcon_2:DelAniEffect("lancer_cmb.player_bg_eft");
	p.playerIcon_3:DelAniEffect("lancer_cmb.player_bg_eft");

end

function p.RefreshUI(msg)

	if (msg.created_time > 0) then
		SetUID( p.create_user_id );
		GetUserConfig():Save();
		--提示框
		dlg_msgbox.ShowOK( GetStr("create_player"), GetStr("create_player_ok"), p.OnMsgBoxSuccess );
	end
end

function p.OnMsgBoxSuccess()
	p.CloseUI();
	game_main.main();
end

function p.OnMsgBoxFaild()
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
	end
end

--创建角色失败
function p.CreatePlayerFaild(msg)
	dlg_msgbox.ShowOK( GetStr("create_player"), msg:GetErrText(), p.OnMsgBoxFaild );
end