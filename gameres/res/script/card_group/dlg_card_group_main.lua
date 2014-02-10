
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

p.server_user_team = nil;
p.nowTeam	= 1;
p.serverTeam = 1;
p.selTeam = 1;
p.selTeamPos = 1;

p.m_list = nil;
p.isAlive = nil;

p.missionId = nil;
p.stageId = nil;
p.missionTeamID = nil;
p.imageList = {};


local ui = ui_card_group;

--拖动控制
p.beginDragId = nil;
p.beginPos = nil;
p.beginRect = nil;
p.beginPlayer = nil;


function p.ShowUI(missionId,stageId,missionTeamId)
	if missionId ~= nil and stageId ~= nil then
		p.missionId = missionId;
		p.stageId = stageId;
		p.missionTeamID = missionTeamId;
	end
	
	dlg_menu.SetNewUI( p );
	p.isAlive = true;
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_9 );
		local bg =  GetImage( p.layer, ui.ID_CTRL_PICTURE_DRAG_BG );
		local v = list:GetEnableMove();
		if v == false then
			bg:SetVisible(true);
		else 
			bg:SetVisible(false);
		end
		PlayMusic_ShopUI();
		return;
	end
	
	--[[
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	layer:NoMask();
    layer:Init();
	layer:SetSwallowTouch(false);
    GetUIRoot():AddDlg( layer );
	
    LoadDlg("card_group.xui" , layer , nil );
	]]--
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
	GetUIRoot():AddChild(layer);
	LoadUI("card_group.xui", layer, nil);
	
	maininterface.HideUI();
	
	p.layer = layer;
    p.SetDelegate();
	p.ShowTeamList();
	p.RequestData();
	PlayMusic_ShopUI();
	
end

--设置回调
function p.SetDelegate()
	local backBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_BACK );
	backBtn:SetLuaDelegate( p.OnBtnClick );
	
	local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_LEFT );
	bt:SetLuaDelegate( p.OnBtnClick );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_RIGHT );
	bt:SetLuaDelegate( p.OnBtnClick );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_110 );
	bt:SetLuaDelegate( p.OnBtnClick );
	
	--local image = GetImage( p.layer, ui.ID_CTRL_PICTURE_22 );
	--table.insert( p.imageList, image );
	--image = GetImage( p.layer, ui.ID_CTRL_PICTURE_23 );
	--table.insert( p.imageList, image );
	--image = GetImage( p.layer, ui.ID_CTRL_PICTURE_24 );
	--table.insert( p.imageList, image );
	
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
	if p.layer == nil then
		--界面未开启，可能是主界面直接进行出战卡组编辑
		return;
	end

	p.SetData( dataSource );
	if p.user_teams ~= nil then
		if p.server_user_team == nil then
			p.server_user_team = p.CopyUserTeam(p.user_teams);
		end
	end
	p.ShowTeamList();
	
	local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_9 );
	if list == nil then
		return;
	end
	local teamid = tonumber( p.nowTeam ) or 1;
	if teamid <= 0 then
		teamid = 0;
	else
		teamid = teamid - 1;
	end
	if p.missionTeamID ~= nil then
		teamid = p.missionTeamID - 1
		p.missionTeamID = nil;
	end
	list:SetActiveView(teamid);
end

--处理服务端下发数据，方便调用
function p.SetData( dataSource )
	if dataSource ~= nil then
		p.user_teams = dataSource.user_teams;
		p.nowTeam = dataSource.nowteam;
		p.serverTeam = dataSource.nowteam;
	else
		p.user_teams = p.source.user_teams;
		p.nowTeam = p.source.nowteam;
		p.serverTeam = p.source.nowteam;
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
			p.cardlist[v.UniqueID or v.UniqueId] = v;
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
	local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_9 );
	if list == nil then
		return;
	end
	
	list:SetSingleMode(true);
	--list:SetLuaDelegate( p.OnListScrolled );
	
	local user_teams = p.user_teams or {{},{},{}};

	--local count = list:GetViewCount() or 0;
	--if count > 0 then
	--	for i = 1, count do
	--		local view = list:GetViewAt(i-1);
	--		if view then
	--			p.SetTeamInfo( view, user_teams[i] );
	--		end
	--	end
	--	return;
	--end
	
	list:ClearView();
	p.listViewCach = {};
	for i = 1, #user_teams do
		local view = createNDUIXView();
        view:Init();
		
        LoadUI( "card_group_node.xui", view, nil );
        local bg = GetUiNode( view, ui_card_group_node.ID_CTRL_PICTURE_BG );
        view:SetViewSize( bg:GetFrameSize());
		
		p.SetTeamInfo( view, user_teams[i] );
		
		view:SetId( tonumber(user_teams[i].Team_id or "0") );
		view:SetTag(i);
		list:AddView( view );
		
	end
	
	--local act = list:GetActiveView();
	--WriteCon("activty:" ..act);

	p.m_list = list;
	list:SetEnableMove(true);
	local bg =  GetImage( p.layer, ui.ID_CTRL_PICTURE_DRAG_BG );
	bg:SetVisible(false);
	
	local teamid = tonumber( p.nowTeam ) or 1;
	if teamid <= 0 then
		teamid = 0;
	else
		teamid = teamid - 1;
	end
	list:SetActiveView(teamid);

end

--显示单个节点
function p.SetTeamInfo( view, user_teamData )
	--local ui_card_group_node = ui_card_group_node2; 
	local teamid = tonumber( user_teamData.Team_id ) or 0;
	for i = 1, 3 do
		local teamPic = GetImage( view, ui_card_group_node["ID_CTRL_PICTURE_TEAM"..i] );
		if teamPic then
			teamPic:SetVisible( i == teamid );
		end
	end
	
	local cardNum = 0;
	for i = 1, 6 do
		local cardBtn = GetButton( view, ui_card_group_node["ID_CTRL_BUTTON_CHA" .. i] );
		local levLabel = GetLabel( view, ui_card_group_node["ID_CTRL_TEXT_LV" .. i] );
		local hpLabel  = GetLabel( view, ui_card_group_node["ID_CTRL_TEXT_HP" .. i] );
		local speedLabel=GetLabel( view, ui_card_group_node["ID_CTRL_TEXT_SPEED" .. i] );
		local atkLabel  = GetLabel( view, ui_card_group_node["ID_CTRL_TEXT_ATTACK" .. i] );
		local defLabel  = GetLabel( view, ui_card_group_node["ID_CTRL_TEXT_DEFENCE" .. i] );
		local pic = GetPlayer ( view, ui_card_group_node["ID_CTRL_SPRITE_CHA" .. i] );--GetImage( view, ui_card_group_node["ID_CTRL_PICTURE_"..i] );
		
		local pPicCardNature = GetImage( view, ui_card_group_node["ID_CTRL_PICTURE_TYPE_"..i] );
		
		
		
		cardBtn:SetLuaDelegate( p.OnListItemClick );
		cardBtn:SetId( i );
		pic:SetId( i )
		
		if user_teamData["Pos_unique"..i] and tonumber(user_teamData["Pos_unique"..i]) ~= 0 then
			cardNum = cardNum + 1;
			cardBtn:SetVisible( true );
			levLabel:SetVisible( true );
			pic:SetVisible( true );
			hpLabel:SetVisible( true );
			speedLabel:SetVisible( true );
			atkLabel:SetVisible( true );
			defLabel:SetVisible( true );
			
			--cardBtn:SetImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", user_teamData["Pos_card"..i] , "head_pic" ), 0 ) );
			--cardBtn:SetTouchDownImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", user_teamData["Pos_card"..i] , "head_pic" ), 0 ) );
			--cardBtn:SetDisabledImage( GetPictureByAni( SelectRowInner( T_CHAR_RES, "card_id", user_teamData["Pos_card"..i] , "head_pic" ), 0 ) );
			
			local data = p.cardlist[tonumber(user_teamData["Pos_unique"..i])];
			if data then
				levLabel:SetText( string.format("%s", tostring(data.Level)) );
				hpLabel:SetText( string.format("%s", tostring(data.Hp)) );
				speedLabel:SetText( string.format(GetStr("card_group_prp_speed"), tostring(data.Speed)) );
				atkLabel:SetText( string.format(GetStr("card_group_prp_atk"), tostring(data.Attack)) );
				defLabel:SetText( string.format(GetStr("card_group_prp_def"), tostring(data.Defence)) );
				if tonumber(data.element) == 1 then
					pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",0));
				elseif tonumber(data.element) == 2 then
					pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",1));
				elseif tonumber(data.element) == 3 then
					pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",2));
				elseif tonumber(data.element) == 4 then
					pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",3));
				elseif tonumber(data.element) == 5 then
					pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",4));
				elseif tonumber(data.element) == 6 then
					pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",5));
				elseif tonumber(data.element) == 7 then
					pPicCardNature:SetPicture(GetPictureByAni("ui.card_nature",6));
				else
					pPicCardNature:SetPicture(nil);
				end
			end
			 
			
			pic:UseConfig( tostring(user_teamData["Pos_card"..i]) );
			pic:SetLookAt(E_LOOKAT_LEFT);
			pic:Standby("");
			pic:SetEnableSwapDrag(true);
			pic:SetLuaDelegate(p.OnDragEvent);
			pic:SetScaleX(GetUIScale());
			--pic.SetScaleY(2.0);
			
			
			
			--[[增加星级显示]]--
		else
			--cardBtn:SetImage( GetPictureByAni( "ui.default_card_btn", 0 ) );
			--cardBtn:SetTouchDownImage( GetPictureByAni( "ui.default_card_btn", 1 ) );
			--cardBtn:SetVisible( false );
			pPicCardNature:SetPicture(nil);
			levLabel:SetVisible( false );
			pic:SetVisible( false );
			hpLabel:SetVisible( false );
			speedLabel:SetVisible( false );
			atkLabel:SetVisible( false );
			defLabel:SetVisible( false );
			pic:SetEnableSwapDrag(true);
			pic:SetLuaDelegate(p.OnDragEvent);
		end
	end
	
	--local cardNumLab = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_CARD_NUM );
	--cardNumLab:SetText( string.format( "%d/%d", cardNum, 6) );

	--local formationBtn = GetButton( view, ui_card_group_node.ID_CTRL_BUTTON_FORMATION );
	--formationBtn:SetLuaDelegate( p.OnListBtnClick );
	
	--local formationLabel = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_27 );
	--formationLabel:SetText( ToUtf8("选择战术") );
	
	--local petBtn1 = GetButton( view, ui_card_group_node.ID_CTRL_BUTTON_PET_1 );
	--petBtn1:SetLuaDelegate( p.OnListBtnClick );
	--petBtn1:SetId( 7 );
	
	--local petBtn2 = GetButton( view, ui_card_group_node.ID_CTRL_BUTTON_PET_2 );
	--petBtn2:SetLuaDelegate( p.OnListBtnClick );
	--petBtn2:SetId( 8 );
	
	--local petName1 = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_PET_NAME_1 );
	--if tonumber(user_teamData.Pet_card1) ~= 0 then
	--	petName1:SetText( ToUtf8( SelectRowInner( T_PET, "id", user_teamData.Pet_card1, "name" ) ) );
		
	--	petBtn1:SetImage( GetPictureByAni( SelectCell( T_PET_RES, user_teamData.Pet_card1, "face_pic" ), 0 ) );
	--	petBtn1:SetTouchDownImage( GetPictureByAni( SelectCell( T_PET_RES, user_teamData.Pet_card1, "face_pic" ), 0 ) );
	--else
	--	petName1:SetText( ToUtf8("选择召唤兽") );
		
	--	petBtn1:SetImage( GetPictureByAni( "ui.default_pet_btn", 0 ) );
	--	petBtn1:SetTouchDownImage( GetPictureByAni( "ui.default_pet_btn", 1 ));
	--end
	
	--local petName2 = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_PET_NAME_2 );
	--if tonumber(user_teamData.Pet_card2) ~= 0 then
	--[[	petName2:SetText( ToUtf8( SelectRowInner( T_PET, "id", user_teamData.Pet_card2, "name" ) ) );
		
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
	--local str = flag and ToUtf8("出战中") or ToUtf8("出战");
	--fightBtn:SetText( str );
	
	local atkLabel = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_TOTAL_ATK );
	atkLabel:SetText(  tostring( p.TotalData( user_teamData, "Attack" )) );
	
	local defLabel = GetLabel( view, ui_card_group_node.ID_CTRL_TEXT_TOTAL_DEF );
	defLabel:SetText( tostring( p.TotalData( user_teamData, "Defence" )) );
	]]--
end

function p.OnListScrolled()
	local listindex = p.scrollList:GetCurrentIndex();
	local index = math.mod(listindex, 3)+1;
	
	for i = 1, #p.imageList do
		local node = p.imageList[i];
		if node then
			local frame = i == index and 1 or 0;
			local picData = GetPictureByAni( "ui.list_node_effect", frame );
			if picData then
				node:SetPicture( picData );
			end
		end
	end
end


function p.OnDragEvent(uiNode, uiEventType, param)
	
	if nil ~= p.m_list then
		local n = p.m_list:GetActiveView();
		WriteCon(string.format("Now View Index Is %d",n));
		local v = p.m_list:GetEnableMove(); --处于滚动状态不响应
		if(v== true) then
			return;
		end
	else
		return;
	end
	
	if IsDraging(uiEventType) then
		local pPoint = param;
		WriteCon(string.format("Now Draging: %d,%d",pPoint.x,pPoint.y));
	elseif IsDragBegin(uiEventType) then
		local pPoint = param;
		p.beginDragId = uiNode:GetId();
		p.beginPos = uiNode:GetFramePos();
		p.beginRect = uiNode:GetScreenRect();
		p.beginPlayer =  ConverToPlayer(uiNode);
		WriteCon(string.format("Now Drag Begin : %d,%d,,,,%d,%d ",pPoint.x,pPoint.y,p.beginPos.x,p.beginPos.y));
	elseif IsDragEnd(uiEventType) then
		local pPoint = param;
		WriteCon(string.format("Now Drag End: %d,%d",pPoint.x,pPoint.y));
		local n = p.m_list:GetActiveView();
		local cView = p.m_list:GetViewAt(n);
		local toIndex = 0;
		local toPlayer = nil;
		for i =1, 6 do
			local player = GetPlayer ( cView, ui_card_group_node["ID_CTRL_SPRITE_CHA" .. i] );
			local id = player:GetId();
			local rect = player:GetScreenRect();
			--WriteCon(string.format("Now Drag End id%d: %d,%d,%d,%d",id,i,rect.origin.x,rect.origin.y,rect.size.w,rect.size.h));
			if id ~= p.beginDragId
				 and pPoint.x > rect.origin.x and pPoint.x < (rect.origin.x + rect.size.w) 
				and pPoint.y > rect.origin.y and pPoint.y < (rect.origin.y + rect.size.h) then
				toIndex = i;
				toPlayer = player;
				break;
			end
			
		end
		
		if toIndex > 0 and p.beginDragId then
			local team = p.user_teams[n+1];
			local orgUni = team["Pos_unique"..p.beginDragId];
			local orgCardId = team["Pos_card"..p.beginDragId];
			team["Pos_unique"..p.beginDragId] = team["Pos_unique"..toIndex]
			team["Pos_card"..p.beginDragId] = team["Pos_card"..toIndex]
			team["Pos_unique"..toIndex] = orgUni
			team["Pos_card"..toIndex] = orgCardId
			
			
			if toPlayer and tonumber(orgUni) ~= 0 and tonumber(orgCardId) ~= 0 then
				toPlayer:UseConfig(tostring(orgCardId) );
				toPlayer:SetLookAt(E_LOOKAT_LEFT);
				toPlayer:Standby("");
				toPlayer:SetVisible( true );
				
			elseif toPlayer then
				toPlayer:SetVisible( false );
			end
			
			if p.beginPlayer and tonumber(team["Pos_unique"..p.beginDragId]) ~= 0 and tonumber(team["Pos_card"..p.beginDragId]) ~= 0 then
				p.beginPlayer:UseConfig(tostring(team["Pos_card"..p.beginDragId]));
				p.beginPlayer:SetLookAt(E_LOOKAT_LEFT);
				p.beginPlayer:Standby("");
				p.beginPlayer:SetVisible( true );
			elseif p.beginPlayer then
				p.beginPlayer:SetVisible( false );
			end
		end
		
		if p.beginPos then
			uiNode:SetFramePos(p.beginPos);
		end
		
		if toIndex > 0 then
			p.SetTeamInfo( cView,  p.user_teams[n+1] )
		end
		
	end
end

function p.TotalData( user_teamData, str )
	local num = 0;
	if user_teamData == nil then
		return num;
	end
	
	for i = 1, 6 do
		if tonumber(user_teamData["Pos_unique"..i]) ~= 0 then
			local obj = p.cardlist[user_teamData["Pos_unique"..i]];
			if obj and obj[str] then
				num = num + tonumber(obj[str]);
			end
		end
	end
	return num;
end

--按钮回调
function p.OnBtnClick(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ui.ID_CTRL_BUTTON_BACK == tag then
			if (p.missionId ~= nil and p.stageId ~= nil) then
				local id = p.m_list:GetActiveView() + 1
				p.CloseUI();
				quest_team_item.ShowUI(p.missionId,p.stageId,id)
				p.missionId = nil;
				p.stageId = nil;
			else
				WriteCon("关闭");
				p.CloseUI();
				maininterface.BecomeFirstUI();
				maininterface.ShowUI();
				
				dlg_menu.SetSelectButton( -1 );
			end
		elseif ui.ID_CTRL_BUTTON_LEFT == tag then
			local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_9 );
			list:MoveToPrevView();
		elseif ui.ID_CTRL_BUTTON_RIGHT == tag then
			local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_9 );
			list:MoveToNextView();
		elseif ui.ID_CTRL_BUTTON_110 == tag then
			local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_9 );
			local bg =  GetImage( p.layer, ui.ID_CTRL_PICTURE_DRAG_BG );
			local v = list:GetEnableMove();
			local bt = ConverToButton(uiNode);
			if v == false then
				v = true;
				bg:SetVisible(false);
				bt:SetText(GetStr("card_group_drag"));
			else 
				v = false;
				bg:SetVisible(true);
				bt:SetText(GetStr("card_group_drag_cancel"));
				
			end
			list:SetEnableMove(v );
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

--列表节点的按钮
function p.OnListItemClick(uiNode, uiEventType, param)
	
	local list = GetListBoxHorz( p.layer, ui.ID_CTRL_LIST_9 );
	if list:GetEnableMove() ~= true then
		return;
	end
	
	local node = uiNode:GetParent();
	local id = node:GetId();
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) and p.user_teams ~= nil then		
		p.selTeam = id;
		p.selTeamPos = uiNode:GetId();
		local hasRemove = false;
		if p.user_teams[p.selTeam] and tonumber(p.user_teams[p.selTeam]["Pos_unique"..p.selTeamPos] or 0) ~= 0 then
			for i = 1,6 do
				if i ~= p.selTeamPos and tonumber(p.user_teams[p.selTeam]["Pos_unique"..i] or 0) ~= 0 then
					hasRemove = true;
					break
				end
			end
		end
		p.HideUI();
		card_bag_mian.ShouReplaceUI(p.OnSelectReplaceCallback, hasRemove);
	end
	
	p.nowTeam = p.m_list:GetActiveView() + 1;
end

--选择卡牌回调
function p.OnSelectReplaceCallback(cardData,unchanged)
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
	end
	
	if unchanged == true then
		return
	end
	

	local team = p.user_teams[p.selTeam]
	if team then
		local preUni = team["Pos_unique"..p.selTeamPos];
		local preCardId = team["Pos_card"..p.selTeamPos];
		local preCard = nil;
		
		if tonumber(preUni) ~= 0 then
			preCard = card_bag_mgr.findCard(preUni);
		end
			
		if cardData == nil then
			team["Pos_unique"..p.selTeamPos] = "0";
			team["Pos_card"..p.selTeamPos] = "0";
			if preCard then
				preCard.Team_marks = "0";
			end
		else
		
			--是否在同组
			
			local cardUni = tostring (cardData.UniqueID or cardData.UniqueId);
			local cardPos = nil;
			for i = 1, 6 do
				if tonumber(team["Pos_unique"..i]) == tonumber(cardUni) then
					cardPos = i;
					break;
				end
			end
			
			--同组则交换,不同组则直接给本组赋值
			if cardPos then
				team["Pos_unique"..cardPos] = team["Pos_unique"..p.selTeamPos];
				team["Pos_card"..cardPos] = team["Pos_card"..p.selTeamPos];
			end
		
			team["Pos_unique"..p.selTeamPos] = cardUni;
			team["Pos_card"..p.selTeamPos] = tostring(cardData.CardID);
			
			if tonumber(cardData.Team_marks) == 0 
				or tonumber(cardData.Team_marks) > tonumber(p.selTeam) then
				cardData.Team_marks = tostring(p.selTeam)
			end
			if preCard and cardPos == nil then
				preCard.Team_marks = "0";				
			end
			
			
			p.cardlist[cardUni] = cardData;
			
		end
		p.ShowTeamList();
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
	if team_data["Pos_unique"..index] and tonumber(team_data["Pos_unique"..index]) ~= 0 then
		cardinfo = {};
		if p.cardlist[team_data["Pos_unique"..index]] and type(p.cardlist[team_data["Pos_unique"..index]]) == "table" then
			for i,v in pairs(p.cardlist[team_data["Pos_unique"..index]]) do
				cardinfo[i] = tonumber(v);
			end
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
			--local str = flag and ToUtf8("出战中") or ToUtf8("出战");
			--fightBtn:SetText( str );
		end
	end
end

--卡牌选择回调、召唤兽选择回调
function p.UpdatePosCard( cardId )
	WriteCon( tostring(cardId) .. " "..tostring(p.modify_team_id) .." "..tostring(p.pos_no) );
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

--保存数据
function p.SaveData()
	local needUpload = false;
	
	if p.m_list == nil or p.user_teams == nil then
		return;
	end
	
	p.nowTeam = p.m_list:GetActiveView() + 1;
	
	if tonumber(p.nowTeam) ~= tonumber(p.serverTeam) then
		needUpload = true;
	else 
		for i = 1,3 do
			local newTeam = p.user_teams[i];
			local serverTeam = p.server_user_team[i];
			for k,v in pairs(newTeam) do
				--WriteCon("team "..i .. "key:" ..k .. "; V=" ..v .."," ..serverTeam[k]);
				if serverTeam[k] == nil or tonumber(v) ~= tonumber(serverTeam[k])then
					needUpload = true;
					break;
				end
			end
		end
	end
	
	if needUpload == true then
		p.UploadTeamSetting();
	end
end

--更新阵型
function p.UploadTeamSetting()
	local uid = GetUID();
	if uid == nil or uid == 0 then
		return;
	end
	
	--请求卡组数据
	local param = "&team_id=".. p.nowTeam;
	for i = 1,3 do
		param = param .."&idm"..i.."=";
		local team = p.user_teams[i];
		for j = 1, 6 do
			if j ~= 1 then
				param = param..","
			end
			param = param..team["Pos_unique"..j];
		end
	end
	local p = param;
	SendReq( "Team", "UpdateTeamInfo", uid, param );
end

-- 拷贝编数据
function p.CopyUserTeam(user_teams)
	if user_teams == nil then
		return nil;
	end
	local lst ={}
	for i,v in pairs(user_teams) do
		local vtyp = type(v);
        if (vtyp == "table") then
            lst[i] = p.CopyUserTeam(v);
        else
            lst[i] = v;
        end
    end
	return lst;
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--关闭UI
function p.CloseUI()
	if p.isAlive ~= true then
		return;
	end
	
	p.isAlive = nil;
	
	p.SaveData();
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
	
	p.modify_user_team = nil;
	card_bag_mian.CloseUI();
	p.user_teams = nil;
	-- if (p.missionId == nil and p.stageId == nil) then
		-- maininterface.ShowUI();
	-- end
end

function p.UIDisappear()
	p.CloseUI();
	dlg_beast_main.CloseUI();
	dlg_card_attr_base.CloseUI();
	
	maininterface.BecomeFirstUI();
end

