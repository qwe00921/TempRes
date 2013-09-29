--------------------------------------------------------------
-- FileName: 	dlg_friend.lua
-- author:		zjj, 2013/08/22
-- purpose:		好友界面
--------------------------------------------------------------

dlg_friend = {}
local p = dlg_friend;

p.layer = nil;
p.intent = nil;

--界面控件定义
p.pkNumLab = nil; --切磋数
p.friendNumLab = nil; --好友数
p.friendList = nil; --好友列表
p.friendApplyList = nil; --好友申请列表
p.friendRecommendList = nil; --好友推荐列表

p.friendListBtn = nil; --好友列表按钮
p.friendApplyBtn = nil; -- 好友申请按钮
p.friendRecommendBtn = nil; -- 好友推荐按钮

p.friendSearchEdit = nil;--搜索玩家框
p.friendSearchBtn = nil; --搜索玩家按钮
p.recommendAgainBtn = nil; -- 重新推荐按钮
p.applyNumLab = nil; --显示已发起申请数
p.backBtn = nil; --返回按钮

p.friendviewList = {}; --好友列表view容器

p.pkIndex = nil;
p.frienddata = nil; --存放好友信息
p.applydata = nil; --存放申请信息
p.recommenddata = nil --存放推荐信息

p.friendsNum = nil; --临时存放好友数量
p.friendNum_limit = nil;

--显示UI
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

--初始化控件
function p.Init()

	p.pkNumLab = GetLabel( p.layer, ui_dlg_friend.ID_CTRL_TEXT_PK_NUM ); --pk次数
	p.friendNumLab = GetLabel( p.layer, ui_dlg_friend.ID_CTRL_TEXT_FRIEND_NUM ); -- 好友数
    p.applyNumLab = GetLabel( p.layer, ui_dlg_friend.ID_CTRL_TEXT_APPLY_NUM );
    
    p.friendList = GetListBoxVert(p.layer ,ui_dlg_friend.ID_CTRL_VERTICAL_LIST_FRIEND);  -- 好友列表
    p.friendList:ClearView();
    p.friendList:SetVisible( false );
	p.friendList:SetName( "friend_list" );
    
    p.friendApplyList = GetListBoxVert(p.layer ,ui_dlg_friend.ID_CTRL_VERTICAL_LIST_FRIEND_APPLY);  -- 好友申请列表
    p.friendApplyList:ClearView();
    p.friendApplyList:SetVisible( false );
	p.friendApplyList:SetName( "friend_apply_list" );
    
    p.friendRecommendList = GetListBoxVert(p.layer ,ui_dlg_friend.ID_CTRL_VERTICAL_LIST_RECOMMEND);  -- 好友推荐列表
    p.friendRecommendList:ClearView();
    p.friendRecommendList:SetVisible( false );
	p.friendApplyList:SetName( "friend_recommend_list" );
	
	p.friendSearchEdit = GetEdit(p.layer,ui_dlg_friend.ID_CTRL_INPUT_BUTTON_SEARCH_NAME); --搜索编辑框
end

--显示好友列表
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
        
        view:SetId(tonumber(friend.UserId)); --记录userid
        view:SetData( i ); --记录位置id
        
        --好友名称
        local nameLab = GetLabel( view , ui_friend_list_view.ID_CTRL_TEXT_NAME );
        nameLab:SetText(tostring(friend.UserName));
        
        --好友等级
        local lvLab = GetLabel( view, ui_friend_list_view.ID_CTRL_TEXT_LV );
        lvLab:SetText(tostring(friend.Level));
        
        --好友人数
        local numLab = GetLabel( view, ui_friend_list_view.ID_CTRL_TEXT_FRIEND_NUM );
        numLab:SetText(tostring(friend.FriendNum) .. "/" .. tostring(friend.FriendLimit));
        
        --最后上线
        local lastDateLab = GetLabel( view , ui_friend_list_view.ID_CTRL_TEXT_LAST_LOGIN_TIME);
        lastDateLab:SetText( tostring(friend.Date) .. GetStr( "day_ago" ));
        if tonumber(friend.Date) == 0 then
            lastDateLab:SetText( GetStr( "today" ));
        end
        
        --聊天按钮
        local chatBtn = GetButton( view ,ui_friend_list_view.ID_CTRL_BUTTON_CHAT);
        chatBtn:SetLuaDelegate(p.OnFriendUIEvent);
        
        --PK按钮
        local pkBtn = GetButton( view, ui_friend_list_view.ID_CTRL_BUTTON_FRIEND_PK);
        pkBtn:SetLuaDelegate(p.OnFriendUIEvent);
        if tonumber(friend.pk_flag ) == 1 then
            pkBtn:SetEnabled( false )
        end
        
        --删除好友
        local delBtn = GetButton( view ,ui_friend_list_view.ID_CTRL_BUTTON_DEL_FRIEND);
        delBtn:SetLuaDelegate(p.OnFriendUIEvent);
        
        p.friendviewList[i] = view;
        p.friendList:AddView(view);
    end
end

--显示好友申请列表
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
        --申请好友名称
        local nameLab = GetLabel( view, ui_friend_apply_list_view.ID_CTRL_TEXT_NAME );
        nameLab:SetText(tostring( friendapply.UserName));
        
        --申请好友等级
        local lvLab = GetLabel( view, ui_friend_apply_list_view.ID_CTRL_TEXT_LV );
        lvLab:SetText(tostring(friendapply.Level));
        
        --申请好友人数
        local friendNumLab = GetLabel( view, ui_friend_apply_list_view.ID_CTRL_TEXT_FRIEND_NUM );
        friendNumLab:SetText(tostring(friendapply.FriendNum).. "/" .. tostring(friendapply.FriendLimit));
        
        --申请日期
        local applyDateLab = GetLabel( view , ui_friend_apply_list_view.ID_CTRL_TEXT_APPLY_DATE);
        applyDateLab:SetText( tostring(friendapply.Date) .. GetStr( "day_ago" ));
        if tonumber(friendapply.Date) == 0 then
            applyDateLab:SetText( GetStr( "today" ));
        end
        
        --接受按钮
        local acceptBtn = GetButton(view ,ui_friend_apply_list_view.ID_CTRL_BUTTON_ACCEPT);
        acceptBtn:SetLuaDelegate(p.OnFriendUIEvent); 
        
        --拒绝按钮
        local refuseBtn = GetButton(view ,ui_friend_apply_list_view.ID_CTRL_BUTTON_REFUSE);
        refuseBtn:SetLuaDelegate(p.OnFriendUIEvent);
        
        p.friendApplyList:AddView(view);
    end
end

--显示好友推荐列表
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
        
        --名称
        local nameLab = GetLabel( view, ui_friend_recommend_list_view.ID_CTRL_TEXT_NAME);
        nameLab:SetText( tostring(friendrecommend.UserName));
        
        --等级
        local lvLab = GetLabel( view, ui_friend_recommend_list_view.ID_CTRL_TEXT_LV);
        lvLab:SetText( tostring(friendrecommend.Level));
        
        --好友数
        local friendNumLab = GetLabel( view, ui_friend_recommend_list_view.ID_CTRL_TEXT_FRIEND_NUM);
        friendNumLab:SetText( tostring(friendrecommend.FriendNum).. "/" .. tostring(friendrecommend.FriendLimit) );
        
        --最后上线
        local lastDateLab = GetLabel( view, ui_friend_recommend_list_view.ID_CTRL_TEXT_LAST_LOGIN_DATE);
        lastDateLab:SetText( tostring(friendrecommend.Date) .. GetStr( "day_ago" ));
        if tonumber(friendrecommend.Date) == 0 then
            lastDateLab:SetText( GetStr( "today" ));
        end
        
        --申请按钮
        local applyBtn = GetButton( view, ui_friend_recommend_list_view.ID_CTRL_BUTTON_APPLY );
        applyBtn:SetLuaDelegate(p.OnFriendUIEvent); 
        
        --判断时候申请过好友
        for i=1, #friend_mgr.aleadyApplyId do
            if tonumber( friend_mgr.aleadyApplyId[i]) == tonumber( friendrecommend.UserId) then
                applyBtn:SetEnabled( false );
                applyBtn:SetText( GetStr( "is_recommend" ));
            end
        end
        p.friendRecommendList:AddView(view);
    end
end

--设置事件处理
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
    
    --默认为好友列表界面
    p.SetUIByViewID( ui_dlg_friend.ID_CTRL_BUTTON_FIREND );
    
end

function p.OnFriendUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
	   if ( ui_dlg_friend.ID_CTRL_BUTTON_BACK == tag ) then  --返回
	       p.CloseUI();
	   elseif( ui_dlg_friend.ID_CTRL_BUTTON_FIREND == tag ) then -- 好友列表
	       p.SetUIByViewID( tag );
	       friend_mgr.ReqFriendList();
	       
	   elseif( ui_dlg_friend.ID_CTRL_BUTTON_FRIEND_APPLY == tag ) then -- 好友申请
	       p.SetUIByViewID( tag );
	       friend_mgr.ReqFriendApplyList();
	       
	   elseif( ui_dlg_friend.ID_CTRL_BUTTON_FRIEND_RECOMMEND == tag ) then --好友推荐
	       p.SetUIByViewID( tag );
	       friend_mgr.ReqFriendRecommendList(); 
	        
	   elseif( ui_dlg_friend.ID_CTRL_BUTTON_SEARCH_PLAYER == tag ) then --搜索玩家
	   
	   elseif( ui_dlg_friend.ID_CTRL_BUTTON_RECOMMEND_AGAIN == tag ) then --重新推荐
	   
	   elseif( ui_friend_list_view.ID_CTRL_BUTTON_CHAT == tag ) then --聊天按钮
	       local friendid = uiNode:GetParent():GetId();
	       friend_chat_log_mgr.ReqChatList( friendid );
	       dlg_friend_chat.ShowUI();
	   
	   elseif(  ui_friend_list_view.ID_CTRL_BUTTON_FRIEND_PK == tag ) then --pk按钮
	       p.pkIndex = uiNode:GetParent():GetData();
	       local result = math.random(1,2);
	       if result == 1 then  dlg_pk_result.ShowUI(true);  end
	       if result == 2 then  dlg_pk_result.ShowUI(false);  end
	       
	   elseif( ui_friend_list_view.ID_CTRL_BUTTON_DEL_FRIEND == tag ) then --删除好友按钮
	       local friendid = uiNode:GetParent():GetId();
           friend_mgr.DeleteFriend( FriendAction , DELETE_FRIEND );
           
       elseif( ui_friend_recommend_list_view.ID_CTRL_BUTTON_APPLY == tag ) then --申请好友按钮
           local friendid = uiNode:GetParent():GetId();
           friend_mgr.FriendAction( friendid , APPLY_FRIEND );
           
       elseif( ui_friend_apply_list_view.ID_CTRL_BUTTON_ACCEPT == tag ) then --接受好友按钮
           local friendid = uiNode:GetParent():GetId();
           friend_mgr.FriendAction( friendid , ACCEPT_FRIEND );
           
       elseif( ui_friend_apply_list_view.ID_CTRL_BUTTON_REFUSE == tag ) then --拒绝好友按钮
           local friendid = uiNode:GetParent():GetId();
           friend_mgr.FriendAction( friendid , REFUSE_FRIEND );
	   end
	end
end

function p.SetPkBtn()
    WriteCon( "设置pk按钮" .. tostring(p.pkIndex) );
	if p.pkIndex ~= nil then
	   local view = p.friendviewList[p.pkIndex];
	   
	   local pkBtn = GetButton(view,ui_friend_list_view.ID_CTRL_BUTTON_FRIEND_PK);
	   pkBtn:SetEnabled( false );
	end
end

--根据按钮显示界面
function p.SetUIByViewID( id )

    --好友列表
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
       
	--好友申请
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
       
	--好友推荐
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

--显示好友UI
function p.ShowFriendUI(frienddata)
    p.frienddata = frienddata; --保存好友信息
    --今日PK数
    p.pkNumLab:SetText( GetStr( "today_pk_num" )..tostring(frienddata.pk_num) .. "/" .. tostring(frienddata.pk_limit));
    --好友数
    p.friendNumLab:SetText(tostring(frienddata.friends_num) .. "/" .. tostring(frienddata.friends_limit));
    --好友列表
	p.ShowFriendList(frienddata.friends);
end

--显示申请好友UI
function p.ShowFriendApplyUI( applydata )
    p.applydata = applydata; --保存申请好友信息
	--好友数
    p.friendNumLab:SetText(tostring(applydata.friends_num) .. "/" .. tostring(applydata.friends_limit));
    --申请列表
    p.ShowFriendApplyList(applydata.confirms);
end

--显示好友推荐UI
function p.ShowRecommendUI( recommenddata)
    p.recommenddata = recommenddata.consumes; --保存推荐信息
    friend_mgr.aleadyApplyId = {}; --清空申请成功id
    --好友数
    --已发申请数
    --推荐列表
    p.ShowFriendRecommendList( recommenddata.consumes );
end

--重载好友UI
function p.ReloadFriendUI()
	p.ShowFriendList( p.frienddata.friends );
	p.friendNumLab:SetText(tostring( p.friendsNum ) .. "/" .. tostring(p.frienddata.friends_limit));
end

--重载推荐UI
function p.ReloadRecommendUI()
	p.ShowFriendRecommendList( p.recommenddata );
	p.friendNumLab:SetText(tostring( p.friendsNum ) .. "/" .. tostring(p.frienddata.friends_limit));
end

--重载申请UI
function p.ReloadApplyUI()
	p.ShowFriendApplyList(p.applydata.confirms);
	p.friendNumLab:SetText(tostring( p.friendsNum ) .. "/" .. tostring(p.frienddata.friends_limit));
end

--设置可见
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

