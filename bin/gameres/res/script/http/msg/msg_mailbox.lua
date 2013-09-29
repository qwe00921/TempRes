--------------------------------------------------------------
-- FileName: 	msg_mailbox.lua
-- author:		Zjj, 2013/09/23
-- purpose:		邮件消息
--------------------------------------------------------------

msg_mailbox = msg_base:new();
local p = msg_mailbox;
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
    self.idMsg = MSG_MAILBOX; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_mailbox = self;
	WriteConWarning( "** msg_mailbox:Process() called" );
	mailbox_mgr.SaveData( self.mails );
end
