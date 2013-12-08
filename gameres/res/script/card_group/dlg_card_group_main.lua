
dlg_card_group_main = {};
local p = dlg_card_group_main;

p.layer = nil;
p.source = nil;
p.user_teams = nil;
p.cardlist = nil;
p.petlist = nil;

p.card_team = nil;

p.team_data = nil;
p.modify_team_id = nil;
p.pos_no = nil;

local ui = ui_card_group;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end

	--layer:NoMask();
    layer:Init();
    GetUIRoot():AddDlg( layer );
    LoadDlg ("card_group.xui" , layer , nil );

	p.layer = layer;
    p.SetDelegate();
	p.RequestData();
end

--设置回调
function p.SetDelegate()
	local backBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_BACK );
	backBtn:SetLuaDelegate( p.OnBtnClick );
end

--请求数据
function p.RequestData()
	local uid = GetUID();
	if uid == nil or uid == 0 then
		return;
	end
	
	--请求卡组数据
	SendReq( "Team", "GetTeamsInfo", uid, "" );
end

--刷新UI
function p.RefreshUI( source )
	p.source = source;--原始数据
	
	p.UpdateListData();
end

--更新数据
function p.UpdateListData( dataSource )
	WriteCon( "asdasdasdasd");
	p.SetData( dataSource );
	p.ShowTeamList();
end

--处理服务端下发数据，方便调用
function p.SetData( dataSource )
	if dataSource ~= nil then
		p.user_teams = dataSource.user_teams;
	else
		p.user_teams = p.source.user_teams;
	end
	
	if p.user_teams ~= nil then
		p.card_team = {};
		p.team_data = {};
		for _, v in pairs(p.user_teams) do
			p.team_data[v.Team_id] = v;
			
			for i = 1, 6 do
				if tonumber(v["Pos_unique"..i]) ~= 0 then
					p.card_team[v["Pos_unique"..i]] = v.Team_id;
				end
			end
		end
	end
	
	if p.source.cardlist ~= nil then
		p.cardlist = {};
		for _, v in pairs(p.source.cardlist) do
			p.cardlist[v.UniqueID] = v;
		end
	end
	
	if p.source.petlist ~= nil then
		p.petlist = {};
		for _, v in pairs(p.source.petlist) do
			p.petlist[v.id] = v;
		end
	end
end

--显示list
function p.ShowTeamList()
	local list = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_6 );
	if list == nil then
		return;
	end
	
	local user_teams = p.user_teams;

	local count = list:GetViewCount() or 0;
	if count > 0 then
		for i = 1, count do
			local view = list:GetViewAt(i-1);
			if view then
				p.SetTeamInfo( view, user_teams[i] );
			end
		end
		return;
	end
	
	list:ClearView();

	for i = 1, #user_teams do
		local view = createNDUIXView();
        view:Init();
		
        LoadUI( "card_group_node.xui", view, nil );
        local bg = GetUiNode( view, ui_card_group_node.ID_CTRL_PICTURE_BG );
        view:SetViewSize( bg:GetFrameSize());
		
		p.SetTeamInfo( view, user_teams[i] );
		
		view:SetId( tonumber(user_teams[i].Team_id) );
		list:AddView( view );
	end
end

--显示单个节点
function p.SetTeamInfo( view, user_teamData )
	local teamIndex = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_TEAM );
	teamIndex:SetText( ToUtf8( string.format( "队伍%s", user_teamData.Team_id ) ) );
	
	local cardNum = 0;
	for i = 1, 6 do
		local cardBtn = GetButton( view, ui_card_group_node["ID_CTRL_BUTTON_CARD_" .. i] );
		local levLabel = GetLabel( view, ui_card_group_node["ID_CTRL_TEXT_LEV_" .. i] );
		
		cardBtn:SetLuaDelegate( p.OnListBtnClick );
		cardBtn:SetId( i );
		
		if tonumber(user_teamData["Pos_unique"..i]) ~= 0 then
			cardNum = cardNum + 1;
			cardBtn:SetVisible( true );
			levLabel:SetVisible( true );
			
			cardBtn:SetImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", user_teamData["Pos_card"..i] , "head_pic" ), 0 ) );
			cardBtn:SetTouchDownImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", user_teamData["Pos_card"..i] , "head_pic" ), 0 ) );
			cardBtn:SetDisabledImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", user_teamData["Pos_card"..i] , "head_pic" ), 0 ) );
			
			local data = p.cardlist[user_teamData["Pos_unique"..i]];
			if data then
				levLabel:SetText( string.format("Lv %s", data.Level) );
			end
			
			--[[增加星级显示]]--
		else
			cardBtn:SetImage( GetPictureByAni( "ui.default_card_btn", 0 ) );
			cardBtn:SetTouchDownImage( GetPictureByAni( "ui.default_card_btn", 1 ) );
			
			levLabel:SetVisible( false );
		end
	end
	
	local cardNumLab = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_CARD_NUM );
	cardNumLab:SetText( string.format( "%d/%d", cardNum, 6) );
	--[[
	local formationTitleLab = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_26 );
	formationTitleLab:SetText( ToUtf8( "战\n术" ) );
	
	local petLabel = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_28 );
	petLabel:SetText( ToUtf8( "召\n唤\n兽" ) );
	--]]
	local formationBtn = GetButton( view, ui_card_group_node.ID_CTRL_BUTTON_FORMATION );
	formationBtn:SetLuaDelegate( p.OnListBtnClick );
	
	local formationLabel = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_27 );
	formationLabel:SetText( ToUtf8("选择战术") );
	
	local petBtn1 = GetButton( view, ui_card_group_node.ID_CTRL_BUTTON_PET_1 );
	petBtn1:SetLuaDelegate( p.OnListBtnClick );
	petBtn1:SetId( 7 );
	
	local petBtn2 = GetButton( view, ui_card_group_node.ID_CTRL_BUTTON_PET_2 );
	petBtn2:SetLuaDelegate( p.OnListBtnClick );
	petBtn2:SetId( 8 );
	
	local petName1 = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_PET_NAME_1 );
	if tonumber(user_teamData.Pet_card1) ~= 0 then
		petName1:SetText( ToUtf8( SelectRowInner( T_PET, "pet_type", user_teamData.Pet_card1, "name" ) ) );
		
		petBtn1:SetImage( GetPictureByAni( SelectCell( T_PET_RES, user_teamData.Pet_card1, "face_pic" ), 0 ) );
		petBtn1:SetTouchDownImage( GetPictureByAni( SelectCell( T_PET_RES, user_teamData.Pet_card1, "face_pic" ), 0 ) );
	else
		petName1:SetText( ToUtf8("选择召唤兽") );
		
		petBtn1:SetImage( GetPictureByAni( "ui.default_pet_btn", 0 ) );
		petBtn1:SetTouchDownImage( GetPictureByAni( "ui.default_pet_btn", 1 ));
	end
	
	local petName2 = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_PET_NAME_2 );
	if tonumber(user_teamData.Pet_card2) ~= 0 then
		petName2:SetText( ToUtf8( SelectRowInner( T_PET, "pet_type", user_teamData.Pet_card2, "name" ) ) );
		
		petBtn2:SetImage( GetPictureByAni( SelectCell( T_PET_RES, user_teamData.Pet_card2, "face_pic" ), 0 ) );
		petBtn2:SetTouchDownImage( GetPictureByAni( SelectCell( T_PET_RES, user_teamData.Pet_card2, "face_pic" ), 0 ) );
	else
		petName2:SetText( ToUtf8("选择召唤兽") );
		
		petBtn2:SetImage( GetPictureByAni( "ui.default_pet_btn", 0 ) );
		petBtn2:SetTouchDownImage( GetPictureByAni( "ui.default_pet_btn", 1 ));
	end
	
	local fightBtn = GetButton( view, ui_card_group_node.ID_CTRL_BUTTON_SETFIGHT );
	fightBtn:SetLuaDelegate( p.OnListBtnClick );
	local flag = tonumber(user_teamData.Team_id) == tonumber(p.source.nowteam)
	fightBtn:SetChecked( flag );
	local str = flag and ToUtf8("出战中") or ToUtf8("出战");
	fightBtn:SetText( str );
end

--按钮回调
function p.OnBtnClick(uiNode, uiEventType, param)
	WriteCon("feawfawe\n");
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ui.ID_CTRL_BUTTON_BACK == tag then
			WriteCon("关闭");
			p.CloseUI();
			maininterface.BecomeFirstUI();
		end
	end
end

--列表节点的按钮
function p.OnListBtnClick(uiNode, uiEventType, param)
	
	local node = uiNode:GetParent();
	local id = node:GetId();
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ui_card_group_node.ID_CTRL_BUTTON_SETFIGHT == tag then
			if id  ~= tonumber(p.source.nowteam) then
				--变更出战队伍
				p.SetBattleFlag( id );
			end
		elseif ui_card_group_node.ID_CTRL_BUTTON_CARD_1 == tag or ui_card_group_node.ID_CTRL_BUTTON_CARD_2 == tag or ui_card_group_node.ID_CTRL_BUTTON_CARD_3 == tag or ui_card_group_node.ID_CTRL_BUTTON_CARD_4 == tag or ui_card_group_node.ID_CTRL_BUTTON_CARD_5 == tag or ui_card_group_node.ID_CTRL_BUTTON_CARD_6 == tag then
			p.ShowCardInfo( tostring( id ), uiNode:GetId() );
		elseif ui_card_group_node.ID_CTRL_BUTTON_PET_1 == tag or ui_card_group_node.ID_CTRL_BUTTON_PET_2 == tag then
			p.modify_team_id = id;
			p.pos_no = uiNode:GetId();
			
			dlg_beast_main.ShowUI( true );
		end
	end
end

--显示卡牌
function p.ShowCardInfo( teamid, index )
	if index == nil or index == 0 then
		return;
	end
	
	local team_data = p.team_data[tostring(teamid)];
	if team_data == nil then
		dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("该卡组不存在"), nil, dlg_card_group_main.layer );
		return;
	end
	
	p.modify_team_id = teamid;
	p.pos_no = index;
	
	local cardinfo = nil;
	if tonumber(team_data["Pos_unique"..index]) ~= 0 then
		cardinfo = {};
		for i,v in pairs(p.cardlist[team_data["Pos_unique"..index]]) do
			cardinfo[i] = tonumber(v);
		end
	end
	if cardinfo then
		dlg_card_attr_base.ShowUI( cardinfo , true );
	else
		--直接显示星灵列表
		card_bag_mian.ShowUI( true );
	end
end

--变更出战队伍
function p.SetBattleFlag( teamid )
	local team_data = p.team_data[tostring(teamid)];
	if team_data == nil then
		dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("该卡组不存在"), nil, dlg_card_group_main.layer );
		return;
	end
	
	if tonumber(team_data["Pos_unique1"]) == 0 and tonumber(team_data["Pos_unique2"]) == 0 and tonumber(team_data["Pos_unique3"]) == 0 and tonumber(team_data["Pos_unique4"]) == 0 and tonumber(team_data["Pos_unique5"]) == 0 and tonumber(team_data["Pos_unique6"]) == 0 and tonumber(team_data["Pet_unique1"]) == 0 and tonumber(team_data["Pet_unique2"]) == 0 then
		dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("该卡组不存在"), nil, dlg_card_group_main.layer );
		return;
	end

	local uid = GetUID();
	if uid == nil or uid == 0 then
		return;
	end
	--请求卡组数据
	SendReq( "Team", "SetBattleFlag", uid, "&team_id=".. tostring(teamid) );
end

--刷新出战按钮
function p.RefreshBattleBtn( data )
	p.source.nowteam = data.nowteam;
	
	local list = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_6 );
	if list == nil then
		return;
	end
	
	local count = list:GetViewCount() or 0;
	for i = 1, count do
		local view = list:GetViewAt( i-1 );
		if view then
			local id = view:GetId();
			
			local fightBtn = GetButton( view, ui_card_group_node.ID_CTRL_BUTTON_SETFIGHT );
			fightBtn:SetLuaDelegate( p.OnListBtnClick );
			local flag = tonumber(id) == tonumber( data.nowteam )
			fightBtn:SetChecked( flag );
			local str = flag and ToUtf8("出战中") or ToUtf8("出战");
			fightBtn:SetText( str );
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

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end



