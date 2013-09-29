--------------------------------------------------------------
-- FileName: 	dlg_friend_chat.lua
-- author:		zjj, 2013/08/22
-- purpose:		好友聊天界面
--------------------------------------------------------------

dlg_friend_chat = {}
local p = dlg_friend_chat;

p.layer = nil;
p.chatList = nil;
p.friendList = nil;

p.canRefresh = true;
p.idTimerRefresh = nil;
p.idTimerText = nil;
p.idTimerChatReqTime = nil;

p.refreshBtn = nil;
p.refreshTime = tonumber(GetStr( "chat_refresh_time" ))-1;

p.chatEdit = nil;
p.chatText = nil;

p.reqNum = 1;

--存放聊天记录
p.chatlog = {};
--存放聊天好友ID
p.friend_id = {};
--存放聊天内容
p.chattext = nil;
--存放聊天发送时间
p.chattime = nil;


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
    LoadDlg("dlg_friend_chat.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
end

--显示聊天内容
function p.ShowChatList( chatlog , name , friend_id )

    p.chatlog = chatlog;
    p.friend_id = friend_id;

    p.chatList = GetListBoxVert(p.layer ,ui_dlg_friend_chat.ID_CTRL_VERTICAL_LIST_CHAT);
    p.chatList:ClearView();
  
    if #chatlog == 0 then
        WriteCon( "no chat log .." );
        return;
    end
    
    for i=1, #chatlog do
        local view = createNDUIXView();
        view:Init();
        
        local log = nil
        if chatlog[i] ~= nil then
           log = chatlog[i];
        end
        
        if  tonumber(log.send_user) == GetUID() then  -- 玩家聊天消息
            LoadUI( "friend_chat_me_view.xui", view, nil );
            local bg = GetUiNode( view, ui_friend_chat_me_view.ID_CTRL_PICTURE_BG );
            view:SetViewSize( bg:GetFrameSize());
            
            --名称
            local nameLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_NAME );
            nameLab:SetText( tostring( msg_cache.msg_player.user_name) );
            
            --时间
            local timeLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_CHAT_TIME);
            local timeText = log.date .. GetStr( "day_ago" ) .. log.send_time;
            if tonumber(log.date) == 0 then
                timeText = GetStr( "today" ) ..log.send_time;
            end
            timeLab:SetText(timeText);
            
            --内容
            local chatTextLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_CHATTEXT );
            chatTextLab:SetText( tostring( log.text ));
            
            --头像
            local iconPic = GetImage( view,ui_friend_chat_me_view.ID_CTRL_PICTURE_ICON );
            
        else --好友聊天信息
            
            LoadUI( "friend_chat_friend_view.xui", view, nil );
            local bg = GetUiNode( view, ui_friend_chat_friend_view.ID_CTRL_PICTURE_BG );
            view:SetViewSize( bg:GetFrameSize());
            
            --名称
            local nameLab = GetLabel( view, ui_friend_chat_friend_view.ID_CTRL_TEXT_NAME );
            nameLab:SetText( tostring(name) );
            
            --时间
            local timeLab = GetLabel( view, ui_friend_chat_friend_view.ID_CTRL_TEXT_CHAT_TIME);
            local timeText = log.date .. GetStr( "day_ago" ) .. log.send_time;
            if tonumber(log.date) == 0 then
                timeText = GetStr( "today" ) ..log.send_time;
            end
            timeLab:SetText(timeText);
            
            --内容
            local chatTextLab = GetLabel( view, ui_friend_chat_friend_view.ID_CTRL_TEXT_CHATTEXT );
            chatTextLab:SetText( tostring( log.text ));
            
            --头像
            local iconPic = GetImage( view,ui_friend_chat_friend_view.ID_CTRL_PICTURE_ICON );
            
        end
        p.chatList:AddView(view);
    end
    p.chatList:MoveToLast();
end

--显示好友列表
function p.ShowFriendList( friends )
	
	p.friendList = GetListBoxVert(p.layer ,ui_dlg_friend_chat.ID_CTRL_VERTICAL_LIST_FRIEND);
    p.friendList:ClearView();
    
    if #friends == 0 then
       WriteCon( "no friends ..!" );
    end
    
    for i = 1, #friends  do
        local view = createNDUIXView();
        view:Init();
        LoadUI( "chat_friend_list_view.xui", view, nil );
        local bg = GetUiNode( view, ui_chat_friend_list_view.ID_CTRL_PICTURE_BG );
        view:SetViewSize( bg:GetFrameSize());
        view:SetLuaDelegate(p.OnViewEvent); 
        view:EnableSelImage( true );
      
        local friend = nil;
        if friends[i] ~= nil then 
            friend = friends[i];
        end
        
        view:SetId( tonumber( friend.friend_id ));
        local nameLab = GetLabel( view, ui_chat_friend_list_view.ID_CTRL_TEXT_NAME );
        nameLab:SetText( tostring( friend.friend_name ));

        p.friendList:AddView( view );
        if tonumber( p.friend_id  ) == tonumber( friend.friend_id ) then
            p.friendList:SetFirstVisibleIndex( i );
            view:SetSelected( true );
        end
    end
end

function p.OnViewEvent(uiNode, uiEventType, param)
    local view = ConverToView(uiNode);
    if IsClickEvent(uiEventType) then
        --发送新聊天记录请求
        p.SendChatLogReq( uiNode:GetId() ,view);
    end 
end

function p.SendChatLogReq( friend_id ,view )
    WriteCon( "请求数" .. p.reqNum);
	if p.reqNum < 4 then
	   --发送请求
	   friend_chat_log_mgr.ReqChatList( friend_id );
	   if p.reqNum == 1 then p.RefreshChatReqTime(); end
	   p.reqNum = p.reqNum + 1;
	   view:SetSelected( true );
	   return;
	end
	dlg_msgbox.ShowOK( GetStr( "msg_title_tips" ), GetStr( "your_operation_too_often" ) , p.OnMsgBoxCallback, p.layer );
end

function p.OnMsgBoxCallback(result)
	
end

--设置事件处理
function p.SetDelegate()
    --发送聊天
    local sendChatMsgBtn = GetButton(p.layer,ui_dlg_friend_chat.ID_CTRL_BUTTON_SEND);
    sendChatMsgBtn:SetLuaDelegate(p.OnChatUIEvent);
    
    --返回按钮
    local backBtn = GetButton(p.layer,ui_dlg_friend_chat.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnChatUIEvent);
    
    --刷新按钮
    p.refreshBtn = GetButton(p.layer,ui_dlg_friend_chat.ID_CTRL_BUTTON_REFRESH); 
    p.refreshBtn:SetLuaDelegate(p.OnChatUIEvent);
    
    --聊天输入框
    p.chatEdit = GetEdit(p.layer,ui_dlg_friend_chat.ID_CTRL_INPUT_BUTTON_CHATTEXT);
    p.chatEdit:SetMaxLength( 40 );
    
end

function p.OnChatUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	
	if IsClickEvent( uiEventType ) then
	   if ( ui_dlg_friend_chat.ID_CTRL_BUTTON_BACK == tag ) then  --返回
	       p.CloseUI();
	   
	   elseif (ui_dlg_friend_chat.ID_CTRL_BUTTON_SEND == tag ) then --发送按钮
	       --获取时间并保存
	       local array = Split( os.date() , " ");
	       p.chattime = array[2];
	       
	       --去除空格并判断时候为空消息
	       p.chattext = p.trim( p.chatEdit:GetText() );
	       if p.chattext == "" then
	           WriteCon( "不能发送空字符串" );
	           dlg_msgbox.ShowOK( GetStr( "msg_title_tips" ), GetStr( "can_not_send_empty_str" ), p.OnMsgBoxCallback, p.layer );
	           return;
	       end
	       friend_chat_log_mgr.ReqSendChatLog( p.friend_id , p.chattext);
    	    
       elseif (ui_dlg_friend_chat.ID_CTRL_BUTTON_REFRESH == tag) then
           p.RefreshChat();      
        
	   end
	end
end


--添加一条新聊天记录
function p.AddChatView()
	local view = createNDUIXView();
    view:Init();
    LoadUI( "friend_chat_me_view.xui", view, nil );
    local bg = GetUiNode( view, ui_friend_chat_me_view.ID_CTRL_PICTURE_BG );
    view:SetViewSize( bg:GetFrameSize());
    
    local textLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_CHATTEXT );
    textLab:SetText(p.chattext);
    
    --名称
    local nameLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_NAME );
    nameLab:SetText( tostring( msg_cache.msg_player.user_name) );
    
    --时间
    local timeLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_CHAT_TIME);
    local timeText = GetStr( "today" ) .. p.chattime;
    timeLab:SetText(timeText);
    
    p.chatList:AddView(view);
    p.chatEdit:SetText("");
    p.chattext = nil;
    p.chattime = nil;
end


--刷新聊天记录 
function p.RefreshChat()
	if p.canRefresh then
	
	   --发送请求
	   friend_chat_log_mgr.ReqChatList( p.friend_id );
	   
	   --刷新时间控制
	   p.refreshBtn:SetText( GetStr( "refresh" ).. "("..GetStr( "chat_refresh_time" )..")");
	   p.canRefresh = false;
	   p.refreshBtn:SetEnabled( false );
	   
	   --删除定时
       if p.idTimerRefresh ~= nil then
          p.idTimerRefresh = nil;
       end
       
       if p.idTimerText ~= nil then
          p.idTimerText = nil;
       end
       local time = tonumber(GetStr( "chat_refresh_time" ));
       p.idTimerRefresh = SetTimerOnce(p.onReSetSign, time ); 
       p.idTimerText = SetTimer(p.onRefreshText, 1.0);
       
	end
end

--刷新聊天请求响应限制时间
function p.RefreshChatReqTime()
    if p.idTimerChatReqTime ~= nil then
        p.idTimerChatReqTime = nil;
    end
    p.idTimerChatReqTime = SetTimerOnce(p.onRefreshReqTime, 10);
end

--重置请求次数
function p.onRefreshReqTime()
    if p.layer ~= nil then
        p.reqNum = 1;
    end
end


--刷新文本
function p.onRefreshText()
    if p.layer ~= nil then
        p.refreshBtn:SetText(GetStr( "refresh" ).. "(" .. tostring(p.refreshTime)..")");
        p.refreshTime = p.refreshTime -1 ;
        if p.refreshTime < 0 then
            KillTimer(p.idTimerText);
            p.idTimerText = nil;
            p.refreshBtn:SetText(GetStr( "refresh" ));
            p.refreshTime = tonumber(GetStr( "chat_refresh_time" )) - 1;
        end
    end
end

--重置刷新按钮
function p.onReSetSign()
    if p.layer ~= nil then
        p.canRefresh = true;
        p.refreshBtn:SetEnabled( true );
        p.refreshBtn:SetText(GetStr( "refresh" ));
    end
end

--去空格
function p.trim(str)
   if str == nil then
        return nil, "the string parameter is nil" ;
   end
   str = string.gsub(str , " " , "");
   return str;
end

function p.OnMsgBoxCallback(result)
	
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
        if p.idTimerText ~= nil then
            KillTimer(p.idTimerText);
        end
        p.chatList = nil;
        p.friendList = nil;
        p.canRefresh = true;
        p.idTimerRefresh = nil;
        p.idTimerText = nil;
        p.idTimerChatReqTime = nil;
        p.refreshBtn = nil;
        p.refreshTime = tonumber(GetStr( "chat_refresh_time" ))-1;
        p.chatEdit = nil;
        p.chatText = nil;
        p.reqNum = 1;
        p.chatlog = {};
        p.friend_id = {};
        p.chattext = nil;
        p.chattime = nil;
    end
end

