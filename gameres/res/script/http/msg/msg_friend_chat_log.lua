--------------------------------------------------------------
-- FileName: 	msg_friend_chat_log.lua
-- author:		Zjj, 2013/09/02
-- purpose:		��������¼��Ϣ
--------------------------------------------------------------

msg_friend_chat_log = msg_base:new();
local p = msg_friend_chat_log;
local super = msg_base;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_FRIEND_CHAT_LOG; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_friend_chat_log = self;
	WriteConWarning( "** msg_friend_chat_log:Process() called" );
    friend_chat_log_mgr.ShowChatLog( self );
end
