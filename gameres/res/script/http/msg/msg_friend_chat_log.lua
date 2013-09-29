--------------------------------------------------------------
-- FileName: 	msg_friend_chat_log.lua
-- author:		Zjj, 2013/09/02
-- purpose:		玩家聊天记录消息
--------------------------------------------------------------

msg_friend_chat_log = msg_base:new();
local p = msg_friend_chat_log;
local super = msg_base;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_FRIEND_CHAT_LOG; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_friend_chat_log = self;
	WriteConWarning( "** msg_friend_chat_log:Process() called" );
    friend_chat_log_mgr.ShowChatLog( self );
end
