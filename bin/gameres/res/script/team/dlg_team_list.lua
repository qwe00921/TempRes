--------------------------------------------------------------
-- FileName: 	dlg_team_list.lua
-- author:		zjj, 2013/07/22
-- purpose:		队伍列表界面
--------------------------------------------------------------

dlg_team_list = {}
local p = dlg_team_list;

p.layer = nil;
p.msg = nil;
p.teamNum = 0;
p.selectTeam = 1;
p.teamlist = {};
p.isSetBattle = false;

--显示UI
function p.ShowUI()
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_team_list.xui", layer, nil);
	
	p.LoadTeamData();
	p.SetDelegate(layer);
	p.layer = layer;
	
end


--显示队伍数据
function p.ShowTeamList(teamlist)
	local list = GetListBoxHorz(p.layer,ui_dlg_team_list.ID_CTRL_LIST_3);
	list:ClearView();
    list:SetMarginX( 10 );
    list:SetMarginY( 10 );
	list:SetSingleMode(true);
	
	p.teamlist = teamlist;
	
	--队伍数量
	local teamNum = 0;
	if teamlist ~= nil and #teamlist > 0 then
		teamNum = #teamlist;
		--设置出战按钮
		if teamlist[1].battle_flag == 1 then
			p.BattleBtnSetEnabled(false);
		end
	end
	
	for i = 1, teamNum + 1 do
		local view = createNDUIXView();
		view:Init();
		LoadUI("team_list_view.xui", view, nil);
		local bg = GetUiNode(view,ui_team_list_view.ID_CTRL_PICTURE_BG);
		view:SetViewSize( bg:GetFrameSize());
		view:SetLuaDelegate(p.OnViewEvent);  
		view:SetId(i);
		
		local team = teamlist[i];
		if team ~= nil then
			--生命u
			local hp = GetLabel( view, ui_team_list_view.ID_CTRL_TEXT_3);
			hp:SetText(tostring(team.battle_flag));
			--攻击
			local atk = GetLabel( view, ui_team_list_view.ID_CTRL_TEXT_4);
			atk:SetText(tostring(team.attack));
			--防御
			local def = GetLabel( view, ui_team_list_view.ID_CTRL_TEXT_5);
			def:SetText(tostring(team.defence));
			--技能
			
			--队伍按钮
			local btn = GetButton(view, ui_team_list_view.ID_CTRL_BUTTON_7);
			btn:SetLuaDelegate(p.OnTeamMainUIEvent);
			btn:SetText(tostring(team.team_no));
			btn:SetId(i);
			
		end
		
		--添加队伍按钮
		local addbtn = GetButton(view, ui_team_list_view.ID_CTRL_BUTTON_29);
		addbtn:SetLuaDelegate(p.OnTeamMainUIEvent);
		addbtn:SetId(i);
		
		--隐藏添加队伍按钮
		if i <= teamNum then
			addbtn:SetVisible(false);
		end	
		--限制队伍数量
		if i == 8 then
			break;
		end
	
		list:AddView(view);
	end
	
end

--列表滑动事件
function p.OnViewEvent(uiNode, uiEventType, param)	
	if IsActiveViewEvent( uiEventType ) then
		--设置当前队伍
		p.selectTeam = param + 1;
		--设置出战按钮
		p.BattleBtnSetEnabled(false);
		if p.teamlist[p.selectTeam] ~= nil then
			if p.teamlist[p.selectTeam].battle_flag == 0 then
				p.BattleBtnSetEnabled(true);
			end
		end
		local idlist = Split(uiNode:GetDataStr(),",");
		for i=1, #idlist do
			
		end
	end
	
end
--设置事件处理
function p.SetDelegate(layer)
	--首页按钮
	local topBtn = GetButton(layer,ui_dlg_team_list.ID_CTRL_BUTTON_1);
    topBtn:SetLuaDelegate(p.OnTeamMainUIEvent);
	--继续任务按钮
	local topBack = GetButton(layer,ui_dlg_team_list.ID_CTRL_BUTTON_2);
    topBack:SetLuaDelegate(p.OnTeamMainUIEvent);
	--设置出战
	local setBattleBtn = GetButton(layer,ui_dlg_team_list.ID_CTRL_BUTTON_5);
	setBattleBtn:SetLuaDelegate(p.OnTeamMainUIEvent);

end

--设置出战按钮可用
function p.BattleBtnSetEnabled( bEnabled )
	local setBattleBtn = GetButton(p.layer,ui_dlg_team_list.ID_CTRL_BUTTON_5);
	setBattleBtn:SetEnabled( bEnabled );   
end

function p.OnTeamMainUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ( ui_team_list_view.ID_CTRL_BUTTON_7 == tag ) then	
			WriteCon("click team btn = "..uiNode:GetId());
			p.selectTeam = uiNode:GetId();
			dlg_team_member.ShowUI(p.teamlist[uiNode:GetId()],p.selectTeam);
			p.HideUI(false);
		elseif ( ui_dlg_team_list.ID_CTRL_BUTTON_1 == tag ) then
			WriteCon("To top UI");
			--task_map_mainui.ShowUI();
			p.CloseUI();
		elseif ( ui_dlg_team_list.ID_CTRL_BUTTON_2 == tag ) then
			WriteCon("back to questUI");
			--task_map_mainui.ShowUI();
			p.CloseUI();
		elseif ( ui_team_list_view.ID_CTRL_BUTTON_29 == tag ) then
			WriteCon("add new team -----------------"  .. p.selectTeam );
			p.selectTeam = uiNode:GetId();
			dlg_team_member.ShowUI(nil,p.selectTeam);
			p.HideUI(false);
		elseif ( ui_dlg_team_list.ID_CTRL_BUTTON_5 == tag ) then
			--设置出战队伍
			WriteCon("set battle flag");
			p.isSetBattle = true;
			p.SetBattleFlag();
		end				
	end
end

--请求队伍数据
function p.LoadTeamData()
    WriteCon("**请求队伍数据**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    SendReq("Team","GetTeamsInfo",uid,"");
end

--请求设置出战数据
function p.SetBattleFlag()
	WriteCon("**请求设置出战队伍数据**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
	local selectTeamid = p.teamlist[p.selectTeam].id;
	local param = "&team_id=" .. selectTeamid;
	SendReq("Team","SetBattleFlag",uid,param);
end

--修改队伍回调，更新队伍信息
function p.UpdateTeam(team)
	p.HideUI(true);
	--判断时候为设置出战回调
	if p.isSetBattle then
		p.OKMsgBox(p.layer);
		--修改出战标记
		for i=1, #p.teamlist do
			if p.teamlist[i].battle_flag == 1 then
				p.teamlist[i].battle_flag = 0;
			end
		end
	end
	WriteCon("**更新队伍数据**"  );
	p.teamlist[p.selectTeam] = team;
	p.ReloadTeamList();	
end

--重载队伍信息
function p.ReloadTeamList()
	p.ShowTeamList(p.teamlist);
end

--设置可见
function p.HideUI(isvisible)
	if p.layer ~= nil then
		p.layer:SetVisible( isvisible );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

--测试消息提示框
function p.OKMsgBox(layer)
	dlg_msgbox.ShowOK( ToUtf8("提示"), ToUtf8("成功设置出战"), p.OnMsgBoxCallback , p.layer );
end

--消息框回调
function p.OnMsgBoxCallback( result )
	
end