--------------------------------------------------------------
-- FileName: 	dlg_team_member.lua
-- author:		zjj, 2013/07/22
-- purpose:		�����Ա����
--------------------------------------------------------------

dlg_team_member = {}
local p = dlg_team_member;

p.layer = nil;
p.selectCard = nil;
p.team = nil;
p.cardidlist = {0,0,0,0,0};
--������
p.team_no = 0;
--��ս��ʶ
p.battle_flag = 0;
--����id
p.team_id = 0;
--���鼼��id
p.skill_id = 0 ;

p.OKBtn = nil;

--��ʾUI
function p.ShowUI(team,teamnum)
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	layer:Init();
	--layer:SetFrameRectFull();
	--layer:SetSwallowTouch(true);
    
	layer:Init();	
	GetUIRoot():AddDlg(layer);

    LoadDlg("dlg_team_member.xui", layer, nil);
	
	p.SetDelegate(layer);
	p.layer = layer;
	
	WriteCon( "team id in" .. teamnum);
	p.team = team;
	p.team_no = teamnum;
	p.ShowMemberList(team);
end

--��ʾ��Ա�������б�
function p.ShowMemberList(team)
	local list = GetListBoxVert(p.layer,ui_dlg_team_member.ID_CTRL_VERTICAL_LIST_1);
	list:ClearView();
    list:SetMarginX( 10 );
    list:SetMarginY( 10 );
	
	--��Ա��
	local memberNum = 0;
	--����cardid
	if team ~= nil then
		for i=1, #team.user_cards do
			if p.team.user_cards[i].id ~= nil then
				WriteCon( "one member");
				p.cardidlist[i] = p.team.user_cards[i].id;
				memberNum = memberNum + 1 ;
			end
		end
		--����skill_id
		if team.user_skill ~= nil then
			p.skill_id = team.user_skill.id;
		end
	end
	
	WriteCon( "team num = " .. memberNum);
	for i=1, 5 do
		local view = createNDUIXView();
		view:Init();
		LoadUI("team_cardlist_view.xui", view, nil);
		local bg = GetUiNode(view,ui_team_cardlist_view.ID_CTRL_PICTURE_1);
		view:SetViewSize( bg:GetFrameSize());
		view:SetId(i);
		local btn = GetButton(view,ui_team_cardlist_view.ID_CTRL_BUTTON_12);
		btn:SetLuaDelegate(p.OnUIEventTeamList);
		
		local addbtn = GetButton(view,ui_team_cardlist_view.ID_CTRL_BUTTON_34);
		addbtn:SetLuaDelegate(p.OnUIEventTeamList);
		
		--���ض�Ա��������Ӱ�ť		
		if i <= memberNum then
			p.RefreshMember(view,team.user_cards[i]);
			addbtn:SetVisible(false);
		end		
		list:AddView(view);	
	end
	
	--���鼼����
	local view = createNDUIXView();
	view:Init();
	LoadUI("team_skilllist_view.xui", view, nil);

	local bg = GetUiNode(view,ui_team_skilllist_view.ID_CTRL_PICTURE_23);
	view:SetViewSize( bg:GetFrameSize());
	view:SetId(6);
	--ѡ���ܰ�ť
	local btn = GetButton(view,ui_team_skilllist_view.ID_CTRL_BUTTON_28);
	btn:SetLuaDelegate(p.OnUIEventTeamList);
	--��Ӽ��ܰ�ť
	local addbtn = GetButton(view,ui_team_skilllist_view.ID_CTRL_BUTTON_ADD);
	addbtn:SetLuaDelegate(p.OnUIEventTeamList);
	--������Ӱ�ť
	if p.skill_id ~= 0 then
		addbtn:SetVisible(false);
		local skill = team.user_skill;
		
		--ˢ�¼�����Ϣ
		p.RefreshSkillInfo(view ,skill);
	end
	list:AddView(view);	
end
	

--�����¼�����
function p.SetDelegate(layer)
	--���ذ�ť
	local topBtn = GetButton(layer,ui_dlg_team_member.ID_CTRL_BUTTON_2);
    topBtn:SetLuaDelegate(p.OnUIEventTeamList);
	--ȷ�ϰ�ť
	p.OKBtn = GetButton(layer,ui_dlg_team_member.ID_CTRL_BUTTON_3);
    p.OKBtn:SetLuaDelegate(p.OnUIEventTeamList);
	p.OKBtn:SetEnabled( false );  
end

function p.OnBtnClicked()
    WriteCon( "on btn clicked" );
end

--�¼�����
function p.OnUIEventTeamList(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	WriteCon( "on btn clicked" .. tag );
	if IsClickEvent( uiEventType ) then
        if ( ui_dlg_team_member.ID_CTRL_BUTTON_2 == tag ) then	
			WriteCon("click team btn");
			p.CloseUI();
			dlg_team_list.HideUI(true);	
		elseif ( ui_dlg_team_member.ID_CTRL_BUTTON_3 == tag ) then
			WriteCon("back to teammainUI");
			p.UpdateTeamInfo();	
		--ѡ���Ա
		elseif ( ui_team_cardlist_view.ID_CTRL_BUTTON_12 == tag ) then
			WriteCon("dlg_team_member: select team card");
			p.selectCard = uiNode:GetParent();
			dlg_card_box_mainui.ShowUI(CARD_INTENT_GETONE,dlg_team_member);
		--����¶�Ա
		elseif ( ui_team_cardlist_view.ID_CTRL_BUTTON_34 == tag) then
			WriteCon("dlg_team_member: add team member");
			p.selectCard = uiNode:GetParent();
			dlg_card_box_mainui.ShowUI(CARD_INTENT_GETONE,dlg_team_member);
		--ѡ����
		elseif ( ui_team_skilllist_view.ID_CTRL_BUTTON_28 == tag) then
			WriteCon("dlg_team_member: select team skill");
			p.selectCard = uiNode:GetParent();
            dlg_user_skill.ShowUI(SKILL_INTENT_GETONE,dlg_team_member);
		--����¼���
		elseif ( ui_team_skilllist_view.ID_CTRL_BUTTON_ADD == tag) then
			WriteCon("dlg_team_member: add team skill");
			p.selectCard = uiNode:GetParent();
			dlg_user_skill.ShowUI(SKILL_INTENT_GETONE,dlg_team_member);
		end					
	end
end

--�����Ա������ѡ��ص�����
function p.LoadSelectData( card )
	--�õ�����
	dump_obj(card);
	local view = p.selectCard;
	--���ܿ�Ƭ
	if p.selectCard:GetId() == 6 then 
		
		local btn = GetButton(view,ui_team_skilllist_view.ID_CTRL_BUTTON_ADD);
        btn:SetVisible(false);
        p.RefreshSkillInfo( view,card);
        p.skill_id = card.id;
        --ȷ�ϰ�ť����
        p.OKBtn:SetEnabled( true ); 
		return;
	end
	p.cardidlist[p.selectCard:GetId()] = card.id;
	--�Ƴ���Ӱ�ť
	local btn = GetButton(view,ui_team_cardlist_view.ID_CTRL_BUTTON_34);
	btn:SetVisible(false);
	p.RefreshMember( view ,card);
	--ȷ�ϰ�ť����
	p.OKBtn:SetEnabled( true ); 
	 
end

--ˢ�¼�����Ϣ
function p.RefreshSkillInfo(view , skill)
	--�����Ǽ�
	local rareLab = GetLabel( view, ui_team_skilllist_view.ID_CTRL_TEXT_SKILL_RARE );
	rareLab:SetText( tostring(skill.rare) );
	--��������
	local nameLab = GetLabel( view, ui_team_skilllist_view.ID_CTRL_TEXT_SKILL_NAME );
	nameLab:SetText( SelectCell( T_SKILL, tostring(skill.skill_id), "name" ));
	--��������
	local powerLab = GetLabel( view, ui_team_skilllist_view.ID_CTRL_TEXT_SKILL_POWER);
	powerLab:SetText( tostring(skill.skill_power) );
	--���ܵȼ�
	local lvLab = GetLabel( view, ui_team_skilllist_view.ID_CTRL_TEXT_SKILL_LEVEL );
	lvLab:SetText( tostring(skill.level) );
	--��������
	local descriptionLab = GetLabel( view, ui_team_skilllist_view.ID_CTRL_TEXT_SKILL_DESCRIPTION );
	descriptionLab:SetText( SelectCell( T_SKILL, skill.skill_id, "description" ) );
end

--ˢ�¶�Ա��Ϣ
function p.RefreshMember(view,card)
	--��������
	local cardname = SelectCell( T_CARD, card.card_id, "name" );
	local cardnameLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_3);
	cardnameLbl:SetText(cardname);
	--ϡ�ж�
	local cardrareLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_4);
	cardrareLbl:SetText(tostring(card.rare));
	--�ȼ�
	local cardlvLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_5);
	cardlvLbl:SetText(tostring(card.level));
	--hp
	local cardhpLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_6);
	cardhpLbl:SetText(tostring(card.hp));
	--atk
	local cardatkLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_7);
	cardatkLbl:SetText(tostring(card.attack));
	--def
	local carddefLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_8);
	carddefLbl:SetText(tostring(card.defence));
	--exp
	local cardlvLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_27);
	cardlvLbl:SetText(tostring(card.exp));
	--��������
	local cardtypeLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_26);
	cardtypeLbl:SetText(tostring(card.pierce));
	--��������
	local cardteamnoLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_12);
	cardteamnoLbl:SetText(tostring(card.team_no));
end

function p.UpdateTeamInfo()
	--�޸Ķ������
	if p.team ~= nil then
		p.battle_flag = p.team.battle_flag;
		p.team_id = p.team.id;
	end
	WriteCon("team id".. p.team_no);
	local teamparam = string.format("&team_no=%d&battle_flag=%d&user_card_ids=%s,%s,%s,%s,%s&user_skill_id=%d&team_id=%d",
	p.team_no,p.battle_flag,p.cardidlist[1],p.cardidlist[2],p.cardidlist[3],p.cardidlist[4],p.cardidlist[5],p.skill_id,p.team_id);
	local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
	WriteCon("params".. teamparam);
	SendReq("Team","UpdateTeamInfo",uid,teamparam);
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