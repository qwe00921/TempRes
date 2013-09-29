--------------------------------------------------------------
-- FileName: 	dlg_team_list.lua
-- author:		zjj, 2013/07/22
-- purpose:		�����б����
--------------------------------------------------------------

dlg_team_list = {}
local p = dlg_team_list;

p.layer = nil;
p.msg = nil;
p.teamNum = 0;
p.selectTeam = 1;
p.teamlist = {};
p.isSetBattle = false;

--��ʾUI
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


--��ʾ��������
function p.ShowTeamList(teamlist)
	local list = GetListBoxHorz(p.layer,ui_dlg_team_list.ID_CTRL_LIST_3);
	list:ClearView();
    list:SetMarginX( 10 );
    list:SetMarginY( 10 );
	list:SetSingleMode(true);
	
	p.teamlist = teamlist;
	
	--��������
	local teamNum = 0;
	if teamlist ~= nil and #teamlist > 0 then
		teamNum = #teamlist;
		--���ó�ս��ť
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
			--����u
			local hp = GetLabel( view, ui_team_list_view.ID_CTRL_TEXT_3);
			hp:SetText(tostring(team.battle_flag));
			--����
			local atk = GetLabel( view, ui_team_list_view.ID_CTRL_TEXT_4);
			atk:SetText(tostring(team.attack));
			--����
			local def = GetLabel( view, ui_team_list_view.ID_CTRL_TEXT_5);
			def:SetText(tostring(team.defence));
			--����
			
			--���鰴ť
			local btn = GetButton(view, ui_team_list_view.ID_CTRL_BUTTON_7);
			btn:SetLuaDelegate(p.OnTeamMainUIEvent);
			btn:SetText(tostring(team.team_no));
			btn:SetId(i);
			
		end
		
		--��Ӷ��鰴ť
		local addbtn = GetButton(view, ui_team_list_view.ID_CTRL_BUTTON_29);
		addbtn:SetLuaDelegate(p.OnTeamMainUIEvent);
		addbtn:SetId(i);
		
		--������Ӷ��鰴ť
		if i <= teamNum then
			addbtn:SetVisible(false);
		end	
		--���ƶ�������
		if i == 8 then
			break;
		end
	
		list:AddView(view);
	end
	
end

--�б����¼�
function p.OnViewEvent(uiNode, uiEventType, param)	
	if IsActiveViewEvent( uiEventType ) then
		--���õ�ǰ����
		p.selectTeam = param + 1;
		--���ó�ս��ť
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
--�����¼�����
function p.SetDelegate(layer)
	--��ҳ��ť
	local topBtn = GetButton(layer,ui_dlg_team_list.ID_CTRL_BUTTON_1);
    topBtn:SetLuaDelegate(p.OnTeamMainUIEvent);
	--��������ť
	local topBack = GetButton(layer,ui_dlg_team_list.ID_CTRL_BUTTON_2);
    topBack:SetLuaDelegate(p.OnTeamMainUIEvent);
	--���ó�ս
	local setBattleBtn = GetButton(layer,ui_dlg_team_list.ID_CTRL_BUTTON_5);
	setBattleBtn:SetLuaDelegate(p.OnTeamMainUIEvent);

end

--���ó�ս��ť����
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
			--���ó�ս����
			WriteCon("set battle flag");
			p.isSetBattle = true;
			p.SetBattleFlag();
		end				
	end
end

--�����������
function p.LoadTeamData()
    WriteCon("**�����������**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    SendReq("Team","GetTeamsInfo",uid,"");
end

--�������ó�ս����
function p.SetBattleFlag()
	WriteCon("**�������ó�ս��������**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
	local selectTeamid = p.teamlist[p.selectTeam].id;
	local param = "&team_id=" .. selectTeamid;
	SendReq("Team","SetBattleFlag",uid,param);
end

--�޸Ķ���ص������¶�����Ϣ
function p.UpdateTeam(team)
	p.HideUI(true);
	--�ж�ʱ��Ϊ���ó�ս�ص�
	if p.isSetBattle then
		p.OKMsgBox(p.layer);
		--�޸ĳ�ս���
		for i=1, #p.teamlist do
			if p.teamlist[i].battle_flag == 1 then
				p.teamlist[i].battle_flag = 0;
			end
		end
	end
	WriteCon("**���¶�������**"  );
	p.teamlist[p.selectTeam] = team;
	p.ReloadTeamList();	
end

--���ض�����Ϣ
function p.ReloadTeamList()
	p.ShowTeamList(p.teamlist);
end

--���ÿɼ�
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

--������Ϣ��ʾ��
function p.OKMsgBox(layer)
	dlg_msgbox.ShowOK( ToUtf8("��ʾ"), ToUtf8("�ɹ����ó�ս"), p.OnMsgBoxCallback , p.layer );
end

--��Ϣ��ص�
function p.OnMsgBoxCallback( result )
	
end