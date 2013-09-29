--------------------------------------------------------------
-- FileName: 	msg_mailbox_one.lua
-- author:		Zjj, 2013/09/26
-- purpose:		单一邮件消息
--------------------------------------------------------------

msg_mailbox_one = msg_base:new();
local p = msg_mailbox_one;
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
    self.idMsg = MSG_MAILBOX_ONE; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_mailbox_one = self;
	WriteConWarning( "** msg_mailbox_one:Process() called" );
	dlg_mailbox_person_detail.ShowContent( self.mails );
end
