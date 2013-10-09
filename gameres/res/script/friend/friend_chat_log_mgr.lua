--------------------------------------------------------------
-- FileName: 	friend_chat_log_mgr.lua
-- author:		zjj, 2013/08/23
-- purpose:		聊天消息管理器
--------------------------------------------------------------

friend_chat_log_mgr = {}
local p = friend_chat_log_mgr;

--发送聊天记录请求
function p.ReqChatList( friend_id )
    WriteCon("**请求好友列表数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Friend","GetChatMessage",uid, "&friend_id=" .. friend_id);
end

--显示聊天记录
function p.ShowChatLog( chatlog )
	dlg_friend_chat.ShowChatList( chatlog.result, chatlog.friend_name ,chatlog.friend_id );
	
	dlg_friend_chat.ShowFriendList( chatlog.friends );
end


--发送聊天信息请求
function p.ReqSendChatLog(friend_id, chat_text)
	WriteCon("**请求好友列表数据**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Friend","SendChatMessage",uid, "&friend_id=" .. friend_id .. "&text=" .. chat_text );
end

--聊天发送返回处理
function p.ResultForSend( msg )
    if msg.result == "false" then
        WriteCon( "send failed ..!" );
        return;
    end
	dlg_friend_chat.AddChatView();
end