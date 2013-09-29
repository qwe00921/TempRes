--------------------------------------------------------------
-- FileName: 	dlg_friend.lua
-- author:		zjj, 2013/08/22
-- purpose:		���ѽ���
--------------------------------------------------------------

dlg_friend = {}
local p = dlg_friend;

p.layer = nil;
p.intent = nil;

--����ؼ�����
p.pkNumLab = nil; --�д���
p.friendNumLab = nil; --������
p.friendList = nil; --�����б�
p.friendApplyList = nil; --���������б�
p.friendRecommendList = nil; --�����Ƽ��б�

p.friendListBtn = nil; --�����б�ť
p.friendApplyBtn = nil; -- �������밴ť
p.friendRecommendBtn = nil; -- �����Ƽ���ť

p.friendSearchEdit = nil;--������ҿ�
p.friendSearchBtn = nil; --������Ұ�ť
p.recommendAgainBtn = nil; -- �����Ƽ���ť
p.applyNumLab = nil; --��ʾ�ѷ���������
p.backBtn = nil; --���ذ�ť

p.friendviewList = {}; --�����б�view����

p.pkIndex = nil;
p.frienddata = nil; --��ź�����Ϣ
p.applydata = nil; --���������Ϣ
p.recommenddata = nil --����Ƽ���Ϣ

p.friendsNum = nil; --��ʱ��ź�������
p.friendNum_limit = nil;

--��ʾUI
function p.ShowUI(intent)
    
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
    LoadDlg("dlg_friend.xui", layer, nil);
	
	if intent ~= nil then
	   p.intent = intent;
	end
	p.layer = layer;
	p.Init();
	p.SetDelegate();
	friend_mgr.ReqFriendList();
	p.SetUIByViewID( ui_dlg_friend.ID_CTRL_BUTTON_FIREND );
end

--��ʼ���ؼ�
function p.Init()

	p.pkNumLab = GetLabel( p.layer, ui_dlg_friend.ID_CTRL_TEXT_PK_NUM ); --pk����
	p.friendNumLab = GetLabel( p.layer, ui_dlg_friend.ID_CTRL_TEXT_FRIEND_NUM ); -- ������
    p.applyNumLab = GetLabel( p.layer, ui_dlg_friend.ID_CTRL_TEXT_APPLY_NUM );
    
    p.friendList = GetListBoxVert(p.layer ,ui_dlg_friend.ID_CTRL_VERTICAL_LIST_FRIEND);  -- �����б�
    p.friendList:ClearView();
    p.friendList:SetVisible( false );
	p.friendList:SetName( "friend_list" );
    
    p.friendApplyList = GetListBoxVert(p.layer ,ui_dlg_friend.ID_CTRL_VERTICAL_LIST_FRIEND_APPLY);  -- ���������б�
    p.friendApplyList:ClearView();
    p.friendApplyList:SetVisible( false );
	p.friendApplyList:SetName( "friend_apply_list" );
    
    p.friendRecommendList = GetListBoxVert(p.layer ,ui_dlg_friend.ID_CTRL_VERTICAL_LIST_RECOMMEND);  -- �����Ƽ��б�
    p.friendRecommendList:ClearView();
    p.friendRecommendList:SetVisible( false );
	p.friendApplyList:SetName( "friend_recommend_list" );
	
	p.friendSearchEdit = GetEdit(p.layer,ui_dlg_friend.ID_CTRL_INPUT_BUTTON_SEARCH_NAME); --�����༭��
end

--��ʾ�����б�
function p.ShowFriendList(friendlist)
    p.friendList:ClearView();
    if #friendlist == 0 then
        WriteCon( "no friend" );
        return;
    end
    p.SetUIByViewID( ui_dlg_friend.ID_CTRL_BUTTON_FIREND );
    
    for i=1,#friendlist do
        local view = createNDUIXView();
        view:Init();
        LoadUI( "friend_list_view.xui", view, nil );
        local bg = GetUiNode( view, ui_friend_list_view.ID_CTRL_PICTURE_BG );
        view:SetViewSize( bg:GetFrameSize());
       
        local friend = nil;
        if friendlist[i] ~= nil then
            friend = friendlist[i];
        end
        
        view:SetId(tonumber(friend.UserId)); --��¼userid
        view:SetData( i ); --��¼λ��id
        
        --��������
        local nameLab = GetLabel( view , ui_friend_list_view.ID_CTRL_TEXT_NAME );
        nameLab:SetText(tostring(friend.UserName));
        
        --���ѵȼ�
        local lvLab = GetLabel( view, ui_friend_list_view.ID_CTRL_TEXT_LV );
        lvLab:SetText(tostring(friend.Level));
        
        --��������
        local numLab = GetLabel( view, ui_friend_list_view.ID_CTRL_TEXT_FRIEND_NUM );
        numLab:SetText(tostring(friend.FriendNum) .. "/" .. tostring(friend.FriendLimit));
        
        --�������
        local lastDateLab = GetLabel( view , ui_friend_list_view.ID_CTRL_TEXT_LAST_LOGIN_TIME);
        lastDateLab:SetText( tostring(friend.Date) .. GetStr( "day_ago" ));
        if tonumber(friend.Date) == 0 then
            lastDateLab:SetText( GetStr( "today" ));
        end
        
        --���찴ť
        local chatBtn = GetButton( view ,ui_friend_list_view.ID_CTRL_BUTTON_CHAT);
        chatBtn:SetLuaDelegate(p.OnFriendUIEvent);
        
        --PK��ť
        local pkBtn = GetButton( view, ui_friend_list_view.ID_CTRL_BUTTON_FRIEND_PK);
        pkBtn:SetLuaDelegate(p.OnFriendUIEvent);
        if tonumber(friend.pk_flag ) == 1 then
            pkBtn:SetEnabled( false )
        end
        
        --ɾ������
        local delBtn = GetButton( view ,ui_friend_list_view.ID_CTRL_BUTTON_DEL_FRIEND);
        delBtn:SetLuaDelegate(p.OnFriendUIEvent);
        
        p.friendviewList[i] = view;
        p.friendList:AddView(view);
    end
end

--��ʾ���������б�
function p.ShowFriendApplyList(applylist)
    p.friendApplyList:ClearView();
    if #applylist == 0 then
        WriteCon( "no apply" );
        return;
    end
    p.SetUIByViewID( ui_dlg_friend.ID_CTRL_BUTTON_FRIEND_APPLY );
    
	for i=1,#applylist do
        local view = createNDUIXView();
        view:Init();
        LoadUI( "friend_apply_list_view.xui", view, nil );
        local bg = GetUiNode( view, ui_friend_apply_list_view.ID_CTRL_9SLICES_BG );
        view:SetViewSize( bg:GetFrameSize());
        
        local friendapply = nil;
        if applylist[i] ~= nil then
            friendapply = applylist[i];
        end
        view:SetId( tonumber( friendapply.UserId ));
        --�����������
        local nameLab = GetLabel( view, ui_friend_apply_list_view.ID_CTRL_TEXT_NAME );
        nameLab:SetText(tostring( friendapply.UserName));
        
        --������ѵȼ�
        local lvLab = GetLabel( view, ui_friend_apply_list_view.ID_CTRL_TEXT_LV );
        lvLab:SetText(tostring(friendapply.Level));
        
        --�����������
        local friendNumLab = GetLabel( view, ui_friend_apply_list_view.ID_CTRL_TEXT_FRIEND_NUM );
        friendNumLab:SetText(tostring(friendapply.FriendNum).. "/" .. tostring(friendapply.FriendLimit));
        
        --��������
        local applyDateLab = GetLabel( view , ui_friend_apply_list_view.ID_CTRL_TEXT_APPLY_DATE);
        applyDateLab:SetText( tostring(friendapply.Date) .. GetStr( "day_ago" ));
        if tonumber(friendapply.Date) == 0 then
            applyDateLab:SetText( GetStr( "today" ));
        end
        
        --���ܰ�ť
        local acceptBtn = GetButton(view ,ui_friend_apply_list_view.ID_CTRL_BUTTON_ACCEPT);
        acceptBtn:SetLuaDelegate(p.OnFriendUIEvent); 
        
        --�ܾ���ť
        local refuseBtn = GetButton(view ,ui_friend_apply_list_view.ID_CTRL_BUTTON_REFUSE);
        refuseBtn:SetLuaDelegate(p.OnFriendUIEvent);
        
        p.friendApplyList:AddView(view);
    end
end

--��ʾ�����Ƽ��б�
function p.ShowFriendRecommendList( recommendlist)
    p.friendRecommendList:ClearView();
    if #recommendlist == 0 then
        WriteCon( "no recommend" );
        return;
    end
    p.SetUIByViewID( ui_dlg_friend.ID_CTRL_BUTTON_FRIEND_RECOMMEND );
    
    for i=1,#recommendlist do
        local view = createNDUIXView();
        view:Init();
        LoadUI( "friend_recommend_list_view.xui", view, nil );
        local bg = GetUiNode( view, ui_friend_recommend_list_view.ID_CTRL_9SLICES_BG );
        view:SetViewSize( bg:GetFrameSize());
        
        local friendrecommend = nil;
        if recommendlist[i] ~= nil then
            friendrecommend = recommendlist[i];
        end
        view:SetId(friendrecommend.UserId);
        
        --����
        local nameLab = GetLabel( view, ui_friend_recommend_list_view.ID_CTRL_TEXT_NAME);
        nameLab:SetText( tostring(friendrecommend.UserName));
        
        --�ȼ�
        local lvLab = GetLabel( view, ui_friend_recommend_list_view.ID_CTRL_TEXT_LV);
        lvLab:SetText( tostring(friendrecommend.Level));
        
        --������
        local friendNumLab = GetLabel( view, ui_friend_recommend_list_view.ID_CTRL_TEXT_FRIEND_NUM);
        friendNumLab:SetText( tostring(friendrecommend.FriendNum).. "/" .. tostring(friendrecommend.FriendLimit) );
        
        --�������
        local lastDateLab = GetLabel( view, ui_friend_recommend_list_view.ID_CTRL_TEXT_LAST_LOGIN_DATE);
        lastDateLab:SetText( tostring(friendrecommend.Date) .. GetStr( "day_ago" ));
        if tonumber(friendrecommend.Date) == 0 then
            lastDateLab:SetText( GetStr( "today" ));
        end
        
        --���밴ť
        local applyBtn = GetButton( view, ui_friend_recommend_list_view.ID_CTRL_BUTTON_APPLY );
        applyBtn:SetLuaDelegate(p.OnFriendUIEvent); 
        
        --�ж�ʱ�����������
        for i=1, #friend_mgr.aleadyApplyId do
            if tonumber( friend_mgr.aleadyApplyId[i]) == tonumber( friendrecommend.UserId) then
                applyBtn:SetEnabled( false );
                applyBtn:SetText( GetStr( "is_recommend" ));
            end
        end
        p.friendRecommendList:AddView(view);
    end
end

--�����¼�����
function p.SetDelegate()

    p.friendListBtn = GetButton(p.layer,ui_dlg_friend.ID_CTRL_BUTTON_FIREND);
    p.friendListBtn:SetLuaDelegate(p.OnFriendUIEvent);
    
    p.friendApplyBtn =GetButton(p.layer,ui_dlg_friend.ID_CTRL_BUTTON_FRIEND_APPLY);
    p.friendApplyBtn:SetLuaDelegate(p.OnFriendUIEvent);
    
    p.friendRecommendBtn = GetButton(p.layer,ui_dlg_friend.ID_CTRL_BUTTON_FRIEND_RECOMMEND);
    p.friendRecommendBtn:SetLuaDelegate(p.OnFriendUIEvent);
    
    p.friendSearchBtn = GetButton(p.layer,ui_dlg_friend.ID_CTRL_BUTTON_SEARCH_PLAYER);
    p.friendSearchBtn:SetLuaDelegate(p.OnFriendUIEvent);
    
    p.recommendAgainBtn = GetButton(p.layer,ui_dlg_friend.ID_CTRL_BUTTON_RECOMMEND_AGAIN);
    p.recommendAgainBtn:SetLuaDelegate(p.OnFriendUIEvent);
    
    p.backBtn = GetButton(p.layer,ui_dlg_friend.ID_CTRL_BUTTON_BACK);
    p.backBtn:SetLuaDelegate(p.OnFriendUIEvent);
    
    --Ĭ��Ϊ�����б����
    p.SetUIByViewID( ui_dlg_friend.ID_CTRL_BUTTON_FIREND );
    
end

function p.OnFriendUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
	   if ( ui_dlg_friend.ID_CTRL_BUTTON_BACK == tag ) then  --����
	       p.CloseUI();
	   elseif( ui_dlg_friend.ID_CTRL_BUTTON_FIREND == tag ) then -- �����б�
	       p.SetUIByViewID( tag );
	       friend_mgr.ReqFriendList();
	       
	   elseif( ui_dlg_friend.ID_CTRL_BUTTON_FRIEND_APPLY == tag ) then -- ��������
	       p.SetUIByViewID( tag );
	       friend_mgr.ReqFriendApplyList();
	       
	   elseif( ui_dlg_friend.ID_CTRL_BUTTON_FRIEND_RECOMMEND == tag ) then --�����Ƽ�
	       p.SetUIByViewID( tag );
	       friend_mgr.ReqFriendRecommendList(); 
	        
	   elseif( ui_dlg_friend.ID_CTRL_BUTTON_SEARCH_PLAYER == tag ) then --�������
	   
	   elseif( ui_dlg_friend.ID_CTRL_BUTTON_RECOMMEND_AGAIN == tag ) then --�����Ƽ�
	   
	   elseif( ui_friend_list_view.ID_CTRL_BUTTON_CHAT == tag ) then --���찴ť
	       local friendid = uiNode:GetParent():GetId();
	       friend_chat_log_mgr.ReqChatList( friendid );
	       dlg_friend_chat.ShowUI();
	   
	   elseif(  ui_friend_list_view.ID_CTRL_BUTTON_FRIEND_PK == tag ) then --pk��ť
	       p.pkIndex = uiNode:GetParent():GetData();
	       local result = math.random(1,2);
	       if result == 1 then  dlg_pk_result.ShowUI(true);  end
	       if result == 2 then  dlg_pk_result.ShowUI(false);  end
	       
	   elseif( ui_friend_list_view.ID_CTRL_BUTTON_DEL_FRIEND == tag ) then --ɾ�����Ѱ�ť
	       local friendid = uiNode:GetParent():GetId();
           friend_mgr.DeleteFriend( FriendAction , DELETE_FRIEND );
           
       elseif( ui_friend_recommend_list_view.ID_CTRL_BUTTON_APPLY == tag ) then --������Ѱ�ť
           local friendid = uiNode:GetParent():GetId();
           friend_mgr.FriendAction( friendid , APPLY_FRIEND );
           
       elseif( ui_friend_apply_list_view.ID_CTRL_BUTTON_ACCEPT == tag ) then --���ܺ��Ѱ�ť
           local friendid = uiNode:GetParent():GetId();
           friend_mgr.FriendAction( friendid , ACCEPT_FRIEND );
           
       elseif( ui_friend_apply_list_view.ID_CTRL_BUTTON_REFUSE == tag ) then --�ܾ����Ѱ�ť
           local friendid = uiNode:GetParent():GetId();
           friend_mgr.FriendAction( friendid , REFUSE_FRIEND );
	   end
	end
end

function p.SetPkBtn()
    WriteCon( "����pk��ť" .. tostring(p.pkIndex) );
	if p.pkIndex ~= nil then
	   local view = p.friendviewList[p.pkIndex];
	   
	   local pkBtn = GetButton(view,ui_friend_list_view.ID_CTRL_BUTTON_FRIEND_PK);
	   pkBtn:SetEnabled( false );
	end
end

--���ݰ�ť��ʾ����
function p.SetUIByViewID( id )

    --�����б�
	if ui_dlg_friend.ID_CTRL_BUTTON_FIREND == id then
	 
	   p.friendList:SetVisible( true );
	   p.friendApplyList:SetVisible( false );
       p.friendRecommendList:SetVisible( false );
       
       p.friendSearchEdit:SetVisible( false );
       p.friendSearchBtn:SetVisible( false );
       p.recommendAgainBtn:SetVisible( false );
       p.applyNumLab:SetVisible( false );
       p.pkNumLab:SetVisible( true );
       
       p.friendListBtn:SetEnabled( false );
       p.friendApplyBtn:SetEnabled( true );
       p.friendRecommendBtn:SetEnabled( true );
       
	--��������
	elseif ui_dlg_friend.ID_CTRL_BUTTON_FRIEND_APPLY == id then
	
	   p.friendList:SetVisible( false );
       p.friendApplyList:SetVisible( true );
       p.friendRecommendList:SetVisible( false );
       
       p.friendSearchEdit:SetVisible( false );
       p.friendSearchBtn:SetVisible( false );
       p.recommendAgainBtn:SetVisible( false );
       p.applyNumLab:SetVisible( false );
       p.pkNumLab:SetVisible( false );
       
       p.friendListBtn:SetEnabled( true )
       p.friendApplyBtn:SetEnabled( false );
       p.friendRecommendBtn:SetEnabled( true );
       
	--�����Ƽ�
	elseif ui_dlg_friend.ID_CTRL_BUTTON_FRIEND_RECOMMEND == id then
	  
	   p.friendList:SetVisible( false );
       p.friendApplyList:SetVisible( false );
       p.friendRecommendList:SetVisible( true );
       
       p.friendSearchEdit:SetVisible( true );
       p.friendSearchBtn:SetVisible( true );
       p.recommendAgainBtn:SetVisible( true );
       p.applyNumLab:SetVisible( true );
       p.pkNumLab:SetVisible( false );
       
       p.friendListBtn:SetEnabled( true )
       p.friendApplyBtn:SetEnabled( true );
       p.friendRecommendBtn:SetEnabled( false );
       
	end
end

--��ʾ����UI
function p.ShowFriendUI(frienddata)
    p.frienddata = frienddata; --���������Ϣ
    --����PK��
    p.pkNumLab:SetText( GetStr( "today_pk_num" )..tostring(frienddata.pk_num) .. "/" .. tostring(frienddata.pk_limit));
    --������
    p.friendNumLab:SetText(tostring(frienddata.friends_num) .. "/" .. tostring(frienddata.friends_limit));
    --�����б�
	p.ShowFriendList(frienddata.friends);
end

--��ʾ�������UI
function p.ShowFriendApplyUI( applydata )
    p.applydata = applydata; --�������������Ϣ
	--������
    p.friendNumLab:SetText(tostring(applydata.friends_num) .. "/" .. tostring(applydata.friends_limit));
    --�����б�
    p.ShowFriendApplyList(applydata.confirms);
end

--��ʾ�����Ƽ�UI
function p.ShowRecommendUI( recommenddata)
    p.recommenddata = recommenddata.consumes; --�����Ƽ���Ϣ
    friend_mgr.aleadyApplyId = {}; --�������ɹ�id
    --������
    --�ѷ�������
    --�Ƽ��б�
    p.ShowFriendRecommendList( recommenddata.consumes );
end

--���غ���UI
function p.ReloadFriendUI()
	p.ShowFriendList( p.frienddata.friends );
	p.friendNumLab:SetText(tostring( p.friendsNum ) .. "/" .. tostring(p.frienddata.friends_limit));
end

--�����Ƽ�UI
function p.ReloadRecommendUI()
	p.ShowFriendRecommendList( p.recommenddata );
	p.friendNumLab:SetText(tostring( p.friendsNum ) .. "/" .. tostring(p.frienddata.friends_limit));
end

--��������UI
function p.ReloadApplyUI()
	p.ShowFriendApplyList(p.applydata.confirms);
	p.friendNumLab:SetText(tostring( p.friendsNum ) .. "/" .. tostring(p.frienddata.friends_limit));
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
        p.pkNumLab = nil; 
        p.friendNumLab = nil; 
        p.friendList = nil; 
        p.friendApplyList = nil; 
        p.friendRecommendList = nil; 
        p.friendListBtn = nil; 
        p.friendApplyBtn = nil; 
        p.friendRecommendBtn = nil;
        p.friendSearchEdit = nil;
        p.friendSearchBtn = nil; 
        p.recommendAgainBtn = nil; 
        p.applyNumLab = nil; 
        p.backBtn = nil; 
        p.friendviewList = {}; 
        p.pkIndex = nil;
        p.frienddata = nil; 
        p.applydata = nil; 
        p.recommenddata = nil 
        p.friendsNum = nil; 
        p.friendNum_limit = nil;
    end
end

