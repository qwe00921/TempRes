--------------------------------------------------------------
-- FileName: 	dlg_team_member.lua
-- author:		zjj, 2013/07/22
-- purpose:		队伍成员界面
--------------------------------------------------------------

dlg_team_member = {}
local p = dlg_team_member;

p.layer = nil;
p.selectCard = nil;
p.team = nil;
p.cardidlist = {0,0,0,0,0};
--队伍编号
p.team_no = 0;
--出战标识
p.battle_flag = 0;
--队伍id
p.team_id = 0;
--队伍技能id
p.skill_id = 0 ;

p.OKBtn = nil;

--显示UI
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

--显示队员及技能列表
function p.ShowMemberList(team)
	local list = GetListBoxVert(p.layer,ui_dlg_team_member.ID_CTRL_VERTICAL_LIST_1);
	list:ClearView();
    list:SetMarginX( 10 );
    list:SetMarginY( 10 );
	
	--成员数
	local memberNum = 0;
	--保存cardid
	if team ~= nil then
		for i=1, #team.user_cards do
			if p.team.user_cards[i].id ~= nil then
				WriteCon( "one member");
				p.cardidlist[i] = p.team.user_cards[i].id;
				memberNum = memberNum + 1 ;
			end
		end
		--保存skill_id
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
		
		--加载队员、隐藏添加按钮		
		if i <= memberNum then
			p.RefreshMember(view,team.user_cards[i]);
			addbtn:SetVisible(false);
		end		
		list:AddView(view);	
	end
	
	--队伍技能项
	local view = createNDUIXView();
	view:Init();
	LoadUI("team_skilllist_view.xui", view, nil);

	local bg = GetUiNode(view,ui_team_skilllist_view.ID_CTRL_PICTURE_23);
	view:SetViewSize( bg:GetFrameSize());
	view:SetId(6);
	--选择技能按钮
	local btn = GetButton(view,ui_team_skilllist_view.ID_CTRL_BUTTON_28);
	btn:SetLuaDelegate(p.OnUIEventTeamList);
	--添加技能按钮
	local addbtn = GetButton(view,ui_team_skilllist_view.ID_CTRL_BUTTON_ADD);
	addbtn:SetLuaDelegate(p.OnUIEventTeamList);
	--隐藏添加按钮
	if p.skill_id ~= 0 then
		addbtn:SetVisible(false);
		local skill = team.user_skill;
		
		--刷新技能信息
		p.RefreshSkillInfo(view ,skill);
	end
	list:AddView(view);	
end
	

--设置事件处理
function p.SetDelegate(layer)
	--返回按钮
	local topBtn = GetButton(layer,ui_dlg_team_member.ID_CTRL_BUTTON_2);
    topBtn:SetLuaDelegate(p.OnUIEventTeamList);
	--确认按钮
	p.OKBtn = GetButton(layer,ui_dlg_team_member.ID_CTRL_BUTTON_3);
    p.OKBtn:SetLuaDelegate(p.OnUIEventTeamList);
	p.OKBtn:SetEnabled( false );  
end

function p.OnBtnClicked()
    WriteCon( "on btn clicked" );
end

--事件处理
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
		--选择队员
		elseif ( ui_team_cardlist_view.ID_CTRL_BUTTON_12 == tag ) then
			WriteCon("dlg_team_member: select team card");
			p.selectCard = uiNode:GetParent();
			dlg_card_box_mainui.ShowUI(CARD_INTENT_GETONE,dlg_team_member);
		--添加新队员
		elseif ( ui_team_cardlist_view.ID_CTRL_BUTTON_34 == tag) then
			WriteCon("dlg_team_member: add team member");
			p.selectCard = uiNode:GetParent();
			dlg_card_box_mainui.ShowUI(CARD_INTENT_GETONE,dlg_team_member);
		--选择技能
		elseif ( ui_team_skilllist_view.ID_CTRL_BUTTON_28 == tag) then
			WriteCon("dlg_team_member: select team skill");
			p.selectCard = uiNode:GetParent();
            dlg_user_skill.ShowUI(SKILL_INTENT_GETONE,dlg_team_member);
		--添加新技能
		elseif ( ui_team_skilllist_view.ID_CTRL_BUTTON_ADD == tag) then
			WriteCon("dlg_team_member: add team skill");
			p.selectCard = uiNode:GetParent();
			dlg_user_skill.ShowUI(SKILL_INTENT_GETONE,dlg_team_member);
		end					
	end
end

--队伍成员及技能选择回调函数
function p.LoadSelectData( card )
	--得到卡牌
	dump_obj(card);
	local view = p.selectCard;
	--技能卡片
	if p.selectCard:GetId() == 6 then 
		
		local btn = GetButton(view,ui_team_skilllist_view.ID_CTRL_BUTTON_ADD);
        btn:SetVisible(false);
        p.RefreshSkillInfo( view,card);
        p.skill_id = card.id;
        --确认按钮可用
        p.OKBtn:SetEnabled( true ); 
		return;
	end
	p.cardidlist[p.selectCard:GetId()] = card.id;
	--移除添加按钮
	local btn = GetButton(view,ui_team_cardlist_view.ID_CTRL_BUTTON_34);
	btn:SetVisible(false);
	p.RefreshMember( view ,card);
	--确认按钮可用
	p.OKBtn:SetEnabled( true ); 
	 
end

--刷新技能信息
function p.RefreshSkillInfo(view , skill)
	--技能星级
	local rareLab = GetLabel( view, ui_team_skilllist_view.ID_CTRL_TEXT_SKILL_RARE );
	rareLab:SetText( tostring(skill.rare) );
	--技能名称
	local nameLab = GetLabel( view, ui_team_skilllist_view.ID_CTRL_TEXT_SKILL_NAME );
	nameLab:SetText( SelectCell( T_SKILL, tostring(skill.skill_id), "name" ));
	--技能威力
	local powerLab = GetLabel( view, ui_team_skilllist_view.ID_CTRL_TEXT_SKILL_POWER);
	powerLab:SetText( tostring(skill.skill_power) );
	--技能等级
	local lvLab = GetLabel( view, ui_team_skilllist_view.ID_CTRL_TEXT_SKILL_LEVEL );
	lvLab:SetText( tostring(skill.level) );
	--技能描述
	local descriptionLab = GetLabel( view, ui_team_skilllist_view.ID_CTRL_TEXT_SKILL_DESCRIPTION );
	descriptionLab:SetText( SelectCell( T_SKILL, skill.skill_id, "description" ) );
end

--刷新队员信息
function p.RefreshMember(view,card)
	--卡牌名称
	local cardname = SelectCell( T_CARD, card.card_id, "name" );
	local cardnameLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_3);
	cardnameLbl:SetText(cardname);
	--稀有度
	local cardrareLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_4);
	cardrareLbl:SetText(tostring(card.rare));
	--等级
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
	--宠物类型
	local cardtypeLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_26);
	cardtypeLbl:SetText(tostring(card.pierce));
	--所属部队
	local cardteamnoLbl = GetLabel( view, ui_team_cardlist_view.ID_CTRL_TEXT_12);
	cardteamnoLbl:SetText(tostring(card.team_no));
end

function p.UpdateTeamInfo()
	--修改队伍参数
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