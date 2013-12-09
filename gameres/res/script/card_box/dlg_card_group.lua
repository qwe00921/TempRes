--------------------------------------------------------------
-- FileName: 	dlg_card_group.lua
-- author:		zjj, 2013/09/05
-- purpose:		�������
--------------------------------------------------------------

dlg_card_group = {}
local p = dlg_card_group;

p.layer = nil;
p.groupList = nil;

--��ſ�Ƭ�ؼ�
p.cardsList = {};
p.groupTemp = {};

--��ŵ�����Ʊ��
p.team = nil;
p.number = nil;
--��¼�޸Ĺ������
p.editGruopIndex = {0,0,0,0,0,0,0};

--��ʾUI
function p.ShowUI()
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		PlayMusic_ShopUI();
		return;
	end
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_card_group.xui", layer, nil);
	
	p.layer = layer;
    p.SetDelegate();
    p.LoadTeamData();
	PlayMusic_ShopUI();
end



function p.ShowGruopList( grouplist )
    local list = GetListBoxVert(p.layer ,ui_dlg_card_group.ID_CTRL_VERTICAL_LIST_GRUOP);
    list:ClearView();
    
    if #grouplist == 0 then
        WriteCon( "no group !!!!!!" );
    end
    
    p.groupList = grouplist;
    
    for i = 1,7 do
        local view = createNDUIXView();
        view:Init();
        LoadUI( "group_list_view.xui", view, nil );
        local bg = GetUiNode( view, ui_group_list_view.ID_CTRL_PICTURE_BG );
        view:SetViewSize( bg:GetFrameSize());
        view:SetId( i );
        
        --��ö���
        
        local group = grouplist[ i ];
        local card = {id=nil};
        if group == nil then 
            group = {id="0",team_no=nil,attack="0",defence="0",user_skill={id="0"},battle_flag="0",user_cards={card,card,card,card,card}};
            grouplist[ i ] = group;
        end
        --���鹥����
        local atkLab = GetLabel( view , ui_group_list_view.ID_CTRL_TEXT_ATK );
        atkLab:SetText( tostring( group.attack ));
        --���������
        local defLab = GetLabel( view , ui_group_list_view.ID_CTRL_TEXT_DEF );
        defLab:SetText( tostring( group.defence ));
        
        --�������Ʊ���ͼ��
        local groupNameBgPic = GetImage( view ,ui_group_list_view.ID_CTRL_PICTURE_NAME_BG );
        if i == 1 then
            groupNameBgPic:SetPicture( GetPictureByAni("ui.gruop_name_bg", 0));
        end
        --��������ͼƬ
        local gruopNamePic = GetImage( view, ui_group_list_view.ID_CTRL_PICTURE_GRUOP_NAME );
        gruopNamePic:SetPicture( GetPictureByAni("ui.gruop_name_pic", i - 1));
        
        --���ܰ�ť
        local skillBtn = GetButton( view,ui_group_list_view.ID_CTRL_BUTTON_SKILL);
        skillBtn:SetLuaDelegate(p.OnCardGroupUIEvent);
        
        --------------��ʾ�����Ա----------------------
        p.ShowGruopCardList( view, group , i )
        
        if group.user_skill ~= nil and group.user_skill.id ~= "0" then
            skillBtn:SetImage( GetPictureByAni("card.card_box_db_new", 1)); 
        end
        list:AddView( view );
    end
end

--��ʾ�����Ա
function p.ShowGruopCardList( view, group , i )
    local card1 = GetButton( view ,ui_group_list_view.ID_CTRL_BUTTON_CARD1);
    local card2 = GetButton( view ,ui_group_list_view.ID_CTRL_BUTTON_CARD2);
    local card3 = GetButton( view ,ui_group_list_view.ID_CTRL_BUTTON_CARD3);
    local card4 = GetButton( view ,ui_group_list_view.ID_CTRL_BUTTON_CARD4);
    local card5 = GetButton( view ,ui_group_list_view.ID_CTRL_BUTTON_CARD5);
    local skill = GetButton( view ,ui_group_list_view.ID_CTRL_BUTTON_SKILL);
    
    p.groupTemp[1] = card1;
    p.groupTemp[2] = card2;
    p.groupTemp[3] = card3;
    p.groupTemp[4] = card4;
    p.groupTemp[5] = card5;
    p.groupTemp[6] = skill;
    
    for k = 1,6 do
        p.groupTemp[ k ]:SetId( k );
        p.groupTemp[ k ]:SetLuaDelegate(p.OnCardGroupUIEvent);
    
    end
	p.cardsList[i] = p.groupTemp;   --���濨�ư�ť
	
	for j = 1, #group.user_cards do
	   local card = group.user_cards[ j ];
	   if card.id ~= nil then
           local pic = GetCardPicById( card.card_id );
           if pic ~= nil then
               p.groupTemp[j]:SetImage( pic );
           end
	   end
	end
	p.groupTemp = {};
end

--�����¼�����
function p.SetDelegate()
	local backBtn = GetButton(p.layer,ui_dlg_card_group.ID_CTRL_BUTTON_BACK);
	backBtn:SetLuaDelegate(p.OnCardGroupUIEvent);
end

function p.OnCardGroupUIEvent(uiNode, uiEventType, param)
 local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui_dlg_card_group.ID_CTRL_BUTTON_BACK == tag ) then
            p.ReqUpdateGroupInfo();
            p.CloseUI();
        
        --�������
        elseif ( ui_group_list_view.ID_CTRL_BUTTON_CARD1 == tag  or ui_group_list_view.ID_CTRL_BUTTON_CARD2 == tag 
                   or ui_group_list_view.ID_CTRL_BUTTON_CARD3 == tag or ui_group_list_view.ID_CTRL_BUTTON_CARD4 == tag 
                    or ui_group_list_view.ID_CTRL_BUTTON_CARD5 == tag) then
            p.ReSetPoint();
            p.team = uiNode:GetParent():GetId();
            p.number = uiNode:GetId();
--            WriteCon( "�������λ�ã�" .. p.team .."---"..p.number );
            dlg_card_box_mainui.ShowUI( CARD_INTENT_GETONE , dlg_card_group);
            
        --�������    
        elseif ( ui_group_list_view.ID_CTRL_BUTTON_SKILL == tag ) then
            p.ReSetPoint();
            p.team = uiNode:GetParent():GetId();
            p.number = uiNode:GetId();
--            WriteCon( "������ܿ���"  );
            dlg_user_skill.ShowUI(SKILL_INTENT_GETONE, dlg_card_group);
        end
    end
end

--�����Ա������ѡ��ص�����
function p.LoadSelectData( card )
    --�õ�����
    dump_obj(card);
--    WriteCon( "�������λ�ã�" .. p.team .."---"..p.number );
    p.editGruopIndex[ p.team ] = 1;
    --���ܿ�Ƭ
    if p.number == 6 then 
        local team = p.cardsList[ p.team ];
        team[ p.number ]:SetImage( GetPictureByAni("card.card_box_db_new", 1)); 
        if  p.groupList[ p.team ].user_skill == nil then
            p.groupList[ p.team ].user_skill = card;
        else
             p.groupList[ p.team ].user_skill.id = card.id;        
        end
        return;
    end
    local team = p.cardsList[ p.team ];
    local pic = GetCardPicById( card.card_id );
    if pic ~= nil then
        team[ p.number ]:SetImage( pic ); 
    end
    p.RefreshAtkAndDef(p.team ,  p.number , card) ;
end

--ɾ���ظ�����
function p.DelForRepeat( id )
    for i = 1, #p.groupList[p.team].user_cards do
        local team = p.groupList[ p.team ].user_cards;
        --�������������ͬ����,�Ҳ�Ϊ��ѡ��Ŀ��ƣ���ɾ��
        if team[i].id ~= nil and tonumber( team[i].id   ) == tonumber( id ) and i ~= p.number then
            local card = {id=nil};
            --���¶�����Ϣ
            p.groupList[p.team].attack = p.groupList[p.team].attack - p.groupList[p.team].user_cards[i].attack;
            p.groupList[p.team].defence = p.groupList[p.team].defence - p.groupList[p.team].user_cards[i].defence;
            p.groupList[p.team].user_cards[i] = card; --ɾ����Ƭ
        end
    end
end


function p.RefreshGroup()
	for i =1 ,5 do
	   WriteCon( tostring( p.groupList[p.team].user_cards[i].id) );
	   if p.groupList[p.team].user_cards[i].id == nil then
	       p.cardsList[p.team][i]:SetImage( nil );
	   end
	end
end

--ˢ�¹���������
function p.RefreshAtkAndDef(team , num , card)

    --ɾ���ظ�����
    p.DelForRepeat( card.id );
    
    --������Ϣ+�޸Ŀ�����Ϣ
    local teamattackNew = tonumber( p.groupList[team].attack) + tonumber( card.attack )
    local teamdefNew = tonumber( p.groupList[team].defence ) + tonumber( card.defence );
    
    --�жϸ�λ������п�Ƭ�����ȥԭ�п�������
    if p.groupList[team].user_cards[num].id ~= nil then
        local attackOld = tonumber( p.groupList[team].user_cards[num].attack );
        local defOld = tonumber( p.groupList[team].user_cards[num].defence );
        teamattackNew = teamattackNew -attackOld;
        teamdefNew = teamdefNew - defOld;
    end
    
    --���¿��Ƽ�������Ϣ
    p.groupList[team].user_cards[num] = card;
    p.groupList[team].attack = teamattackNew;
    p.groupList[team].defence = teamdefNew;
    
    --��λˢ�¶�������view
    local vl = p.cardsList[team];
    local view = vl[1]:GetParent();
    
    --���鹥����
    local atkLab = GetLabel( view , ui_group_list_view.ID_CTRL_TEXT_ATK );
    atkLab:SetText( tostring( teamattackNew ));
    --���������
    local defLab = GetLabel( view , ui_group_list_view.ID_CTRL_TEXT_DEF );
    defLab:SetText( tostring(teamdefNew ));
    --ˢ�¿���ͼƬ
    p.RefreshGroup();
end

function p.ReSetPoint()
	p.team = nil;
    p.number = nil;
end

--�����޸Ķ�������
function p.ReqUpdateGroupInfo()
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    for i=1, 7 do
       if p.editGruopIndex[i] == 1 then
          --����޸Ķ���
          local group = p.groupList[ i ];
          --����id
          local group_id = group.id;
          --����NO.
          local group_num = i ;
          --��ս���
          local battle_flag = group.battle_flag;
          --����
          local t = {"0","0","0","0","0"};
          for i=1,5 do
              if  group.user_cards[i].id ~= nil then
                  t[i] =  group.user_cards[i].id
              end
          end
          local group_card_ids = string.format("%s,%s,%s,%s,%s",t[1],t[2],t[3],t[4],t[5]);
          local skill = 0;
          if group.user_skill ~= nil then
                skill = group.user_skill.id;
          end
          local param = "&team_id="..group_id.."&team_no="..group_num.."&battle_flag="..battle_flag.."&user_card_ids="..group_card_ids.."&user_skill_id="..skill;
          WriteCon( "���Ͷ������---" .. param );
          SendReq("Team","UpdateTeamInfo",uid,param);
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


--���ÿɼ�
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
        p.groupList = nil;
        p.cardsList = {};
        p.groupTemp = {};
        p.team = nil;
        p.number = nil;
        p.editGruopIndex = {0,0,0,0,0,0,0};
    end
end

