--------------------------------------------------------------
-- FileName: 	dlg_friend_chat.lua
-- author:		zjj, 2013/08/22
-- purpose:		�����������
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

--��������¼
p.chatlog = {};
--����������ID
p.friend_id = {};
--�����������
p.chattext = nil;
--������췢��ʱ��
p.chattime = nil;


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
    LoadDlg("dlg_friend_chat.xui", layer, nil);
	
	p.layer = layer;
	p.SetDelegate();
end

--��ʾ��������
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
        
        if  tonumber(log.send_user) == GetUID() then  -- ���������Ϣ
            LoadUI( "friend_chat_me_view.xui", view, nil );
            local bg = GetUiNode( view, ui_friend_chat_me_view.ID_CTRL_PICTURE_BG );
            view:SetViewSize( bg:GetFrameSize());
            
            --����
            local nameLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_NAME );
            nameLab:SetText( tostring( msg_cache.msg_player.user_name) );
            
            --ʱ��
            local timeLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_CHAT_TIME);
            local timeText = log.date .. GetStr( "day_ago" ) .. log.send_time;
            if tonumber(log.date) == 0 then
                timeText = GetStr( "today" ) ..log.send_time;
            end
            timeLab:SetText(timeText);
            
            --����
            local chatTextLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_CHATTEXT );
            chatTextLab:SetText( tostring( log.text ));
            
            --ͷ��
            local iconPic = GetImage( view,ui_friend_chat_me_view.ID_CTRL_PICTURE_ICON );
            
        else --����������Ϣ
            
            LoadUI( "friend_chat_friend_view.xui", view, nil );
            local bg = GetUiNode( view, ui_friend_chat_friend_view.ID_CTRL_PICTURE_BG );
            view:SetViewSize( bg:GetFrameSize());
            
            --����
            local nameLab = GetLabel( view, ui_friend_chat_friend_view.ID_CTRL_TEXT_NAME );
            nameLab:SetText( tostring(name) );
            
            --ʱ��
            local timeLab = GetLabel( view, ui_friend_chat_friend_view.ID_CTRL_TEXT_CHAT_TIME);
            local timeText = log.date .. GetStr( "day_ago" ) .. log.send_time;
            if tonumber(log.date) == 0 then
                timeText = GetStr( "today" ) ..log.send_time;
            end
            timeLab:SetText(timeText);
            
            --����
            local chatTextLab = GetLabel( view, ui_friend_chat_friend_view.ID_CTRL_TEXT_CHATTEXT );
            chatTextLab:SetText( tostring( log.text ));
            
            --ͷ��
            local iconPic = GetImage( view,ui_friend_chat_friend_view.ID_CTRL_PICTURE_ICON );
            
        end
        p.chatList:AddView(view);
    end
    p.chatList:MoveToLast();
end

--��ʾ�����б�
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
        --�����������¼����
        p.SendChatLogReq( uiNode:GetId() ,view);
    end 
end

function p.SendChatLogReq( friend_id ,view )
    WriteCon( "������" .. p.reqNum);
	if p.reqNum < 4 then
	   --��������
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

--�����¼�����
function p.SetDelegate()
    --��������
    local sendChatMsgBtn = GetButton(p.layer,ui_dlg_friend_chat.ID_CTRL_BUTTON_SEND);
    sendChatMsgBtn:SetLuaDelegate(p.OnChatUIEvent);
    
    --���ذ�ť
    local backBtn = GetButton(p.layer,ui_dlg_friend_chat.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnChatUIEvent);
    
    --ˢ�°�ť
    p.refreshBtn = GetButton(p.layer,ui_dlg_friend_chat.ID_CTRL_BUTTON_REFRESH); 
    p.refreshBtn:SetLuaDelegate(p.OnChatUIEvent);
    
    --���������
    p.chatEdit = GetEdit(p.layer,ui_dlg_friend_chat.ID_CTRL_INPUT_BUTTON_CHATTEXT);
    p.chatEdit:SetMaxLength( 40 );
    
end

function p.OnChatUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	
	if IsClickEvent( uiEventType ) then
	   if ( ui_dlg_friend_chat.ID_CTRL_BUTTON_BACK == tag ) then  --����
	       p.CloseUI();
	   
	   elseif (ui_dlg_friend_chat.ID_CTRL_BUTTON_SEND == tag ) then --���Ͱ�ť
	       --��ȡʱ�䲢����
	       local array = Split( os.date() , " ");
	       p.chattime = array[2];
	       
	       --ȥ���ո��ж�ʱ��Ϊ����Ϣ
	       p.chattext = p.trim( p.chatEdit:GetText() );
	       if p.chattext == "" then
	           WriteCon( "���ܷ��Ϳ��ַ���" );
	           dlg_msgbox.ShowOK( GetStr( "msg_title_tips" ), GetStr( "can_not_send_empty_str" ), p.OnMsgBoxCallback, p.layer );
	           return;
	       end
	       friend_chat_log_mgr.ReqSendChatLog( p.friend_id , p.chattext);
    	    
       elseif (ui_dlg_friend_chat.ID_CTRL_BUTTON_REFRESH == tag) then
           p.RefreshChat();      
        
	   end
	end
end


--���һ���������¼
function p.AddChatView()
	local view = createNDUIXView();
    view:Init();
    LoadUI( "friend_chat_me_view.xui", view, nil );
    local bg = GetUiNode( view, ui_friend_chat_me_view.ID_CTRL_PICTURE_BG );
    view:SetViewSize( bg:GetFrameSize());
    
    local textLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_CHATTEXT );
    textLab:SetText(p.chattext);
    
    --����
    local nameLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_NAME );
    nameLab:SetText( tostring( msg_cache.msg_player.user_name) );
    
    --ʱ��
    local timeLab = GetLabel( view, ui_friend_chat_me_view.ID_CTRL_TEXT_CHAT_TIME);
    local timeText = GetStr( "today" ) .. p.chattime;
    timeLab:SetText(timeText);
    
    p.chatList:AddView(view);
    p.chatEdit:SetText("");
    p.chattext = nil;
    p.chattime = nil;
end


--ˢ�������¼ 
function p.RefreshChat()
	if p.canRefresh then
	
	   --��������
	   friend_chat_log_mgr.ReqChatList( p.friend_id );
	   
	   --ˢ��ʱ�����
	   p.refreshBtn:SetText( GetStr( "refresh" ).. "("..GetStr( "chat_refresh_time" )..")");
	   p.canRefresh = false;
	   p.refreshBtn:SetEnabled( false );
	   
	   --ɾ����ʱ
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

--ˢ������������Ӧ����ʱ��
function p.RefreshChatReqTime()
    if p.idTimerChatReqTime ~= nil then
        p.idTimerChatReqTime = nil;
    end
    p.idTimerChatReqTime = SetTimerOnce(p.onRefreshReqTime, 10);
end

--�����������
function p.onRefreshReqTime()
    if p.layer ~= nil then
        p.reqNum = 1;
    end
end


--ˢ���ı�
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

--����ˢ�°�ť
function p.onReSetSign()
    if p.layer ~= nil then
        p.canRefresh = true;
        p.refreshBtn:SetEnabled( true );
        p.refreshBtn:SetText(GetStr( "refresh" ));
    end
end

--ȥ�ո�
function p.trim(str)
   if str == nil then
        return nil, "the string parameter is nil" ;
   end
   str = string.gsub(str , " " , "");
   return str;
end

function p.OnMsgBoxCallback(result)
	
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

