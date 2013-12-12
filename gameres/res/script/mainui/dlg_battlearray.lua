
dlg_battlearray = {};
local p = dlg_battlearray;

local ui = ui_main_battlearray_bg;
p.layer = nil;
p.modify_team_id = nil;
p.pos_no = nil;

p.mainUIFlag = false;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_13 );
		if list  then
			list:SetVisible(true);
		end
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init(layer);
	layer:SetSwallowTouch(false);
    
	GetUIRoot():AddChild(layer);
	LoadUI("main_battlearray_bg.xui", layer, nil);
    
	p.layer = layer;
	--p.SetDelegate();
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		
		p.modify_team_id = nil;
		p.pos_no = nil;
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
		local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_13 );
		if list  then
			list:SetVisible(false);
		end
	end
end

function p.RefreshUI(user_team)
	user_team = user_team or {};
	p.modify_team_id = tonumber( msg_cache.msg_player.CardTeam );
	
	local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_13 );
	if list == nil then
		return;
	end
	list:ClearView();
	
	local view = createNDUIXView();
	view:Init();
	LoadUI( "main_battlearray.xui", view, nil );
	
	local bg = GetUiNode( view, ui_main_battlearray.ID_CTRL_PICTURE_BG );
    view:SetViewSize( bg:GetFrameSize());
	
	if user_team.Formation ~= nil then
		local formation = user_team.Formation;
		for i = 1, 6 do
			local obj = formation["Pos"..i];
			local btn = GetButton( view, ui_main_battlearray["ID_CTRL_BUTTON_ROLE_"..i] );
			local frameBtn = GetButton( view, ui_main_battlearray["ID_CTRL_BUTTON_"..(i+9)] );
			frameBtn:SetLuaDelegate( p.OnBtnClick );
			frameBtn:SetId( i );
				
			if obj then
				local id = obj.CardID or 0;
				if id ~= nil and tonumber(id) ~= 0 then
					if btn ~= nil then
						btn:SetImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", tostring(id), "head_pic" ), 0 ) );
						btn:SetTouchDownImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", tostring(id), "head_pic" ), 0 ) );
						btn:SetDisabledImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", tostring(id), "head_pic" ), 0 ) );
					end
				end
			else
				if btn ~= nil then
					btn:SetVisible( false );
				end
				
				if frameBtn ~= nil then
					frameBtn:SetImage( GetPictureByAni( "ui.default_card_btn", 0 ) );
					frameBtn:SetTouchDownImage( GetPictureByAni( "ui.default_card_btn", 1 ) );
				end
			end
		end
	end
	
	for i = 1, 2 do
		local id = user_team["Pet_card"..i];
		local btn = GetButton( view, ui_main_battlearray["ID_CTRL_BUTTON_ROLE_"..(i+6)] );
		local frameBtn = GetButton( view, ui_main_battlearray["ID_CTRL_BUTTON_"..(i+6+9)] );
		frameBtn:SetLuaDelegate( p.OnBtnClick );
		frameBtn:SetId( i+6 );
		
		if id ~= nil and tonumber(id) ~= 0 then
			if btn ~= nil then
				btn:SetImage( GetPictureByAni( SelectCell( T_PET_RES, tostring( id ), "face_pic" ), 0 ) );
				btn:SetTouchDownImage( GetPictureByAni( SelectCell( T_PET_RES, tostring( id ), "face_pic" ), 0 ) );
				btn:SetDisabledImage( GetPictureByAni( SelectCell( T_PET_RES, tostring( id ), "face_pic" ), 0 ) );
			end
		else
			if btn ~= nil then
				btn:SetVisible( false );
			end
			
			if frameBtn ~= nil then
				frameBtn:SetImage( GetPictureByAni( "ui.default_pet_btn", 0 ) );
				frameBtn:SetTouchDownImage( GetPictureByAni( "ui.default_pet_btn", 1 ) );
			end
		end
	end
	
	list:AddView( view );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui_main_battlearray.ID_CTRL_BUTTON_16 == tag or ui_main_battlearray.ID_CTRL_BUTTON_17 == tag then
			--召唤兽按钮
			local id = uiNode:GetId();
			p.pos_no = id;
			
			dlg_beast_main.ShowUI( true , true );
		else
			--卡牌按钮
			local formation;
			if msg_cache.msg_player and msg_cache.msg_player.User_Team and msg_cache.msg_player.User_Team.Formation then
				formation = msg_cache.msg_player.User_Team.Formation;
			end
			if formation ~= nil then
				local id = uiNode:GetId();
				p.pos_no = id;
				
				local cardInfo = formation["Pos"..id];
				if cardInfo then
					p.mainUIFlag = true;
					dlg_card_attr_base.ShowUI( cardInfo , true , true );
				else
					--直接显示星灵列表
					p.mainUIFlag = true;
					card_bag_mian.ShowUI( true, true );
				end
			end
		end
	end	
end

--卡牌选择回调、召唤兽选择回调
function p.UpdatePosCard( cardId )
	if cardId == nil or p.modify_team_id == nil or p.pos_no == nil then
		return;
	end
	
	--WriteCon( tostring( cardId ));
	
	local uid = GetUID();
	if uid == nil or uid == 0 then
		return;
	end
	
	local param = "&team_id=".. p.modify_team_id .."&flag=1&pos_no=".. p.pos_no .."&uid=".. cardId;
	--请求卡组数据
	SendReq( "Team", "UpdateTeamInfo", uid, param );
end

function p.UpdateListData( dataSource )
	if p.mainUIFlag then
		p.mainUIFlag = false;
		dlg_msgbox.ShowOK( ToUtf8( "提示" ), ToUtf8( "成功替换" ), p.OnMsgBoxCallback, maininterface.layer );
	end
end

function p.OnMsgBoxCallback()
	card_bag_mian.CloseUI();
	
	dlg_beast_main.CloseUI();
	beast_mgr.ClearData();
	
	dlg_userinfo.ShowUI();
end

