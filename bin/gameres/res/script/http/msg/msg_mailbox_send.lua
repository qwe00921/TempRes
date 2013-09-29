--------------------------------------------------------------
-- FileName: 	msg_mailbox_send.lua
-- author:		Zjj, 2013/09/26
-- purpose:		发送邮件结果消息
--------------------------------------------------------------

msg_mailbox_send = msg_base:new();
local p = msg_mailbox_send;
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
    self.idMsg = MSG_MAILBOX_SEND; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_mailbox_send = self;
	WriteConWarning( "** msg_mailbox_send:Process() called" );
	mailbox_mgr.SendSuccess();
end
