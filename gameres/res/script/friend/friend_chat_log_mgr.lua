--------------------------------------------------------------
-- FileName: 	friend_chat_log_mgr.lua
-- author:		zjj, 2013/08/23
-- purpose:		������Ϣ������
--------------------------------------------------------------

friend_chat_log_mgr = {}
local p = friend_chat_log_mgr;

--���������¼����
function p.ReqChatList( friend_id )
    WriteCon("**��������б�����**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Friend","GetChatMessage",uid, "&friend_id=" .. friend_id);
end

--��ʾ�����¼
function p.ShowChatLog( chatlog )
	dlg_friend_chat.ShowChatList( chatlog.result, chatlog.friend_name ,chatlog.friend_id );
	
	dlg_friend_chat.ShowFriendList( chatlog.friends );
end


--����������Ϣ����
function p.ReqSendChatLog(friend_id, chat_text)
	WriteCon("**��������б�����**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("Friend","SendChatMessage",uid, "&friend_id=" .. friend_id .. "&text=" .. chat_text );
end

--���췢�ͷ��ش���
function p.ResultForSend( msg )
    if msg.result == "false" then
        WriteCon( "send failed ..!" );
        return;
    end
	dlg_friend_chat.AddChatView();
end