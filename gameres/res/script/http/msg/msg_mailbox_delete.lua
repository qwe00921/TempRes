--------------------------------------------------------------
-- FileName: 	msg_mailbox_delete.lua
-- author:		Zjj, 2013/09/25
-- purpose:		删除邮件消息
--------------------------------------------------------------

msg_mailbox_delete = msg_base:new();
local p = msg_mailbox_delete;
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
    self.idMsg = MSG_MAILBOX_DELETE; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_mailbox_delete = self;
	WriteConWarning( "** msg_mailbox_delete:Process() called" );
	mailbox_mgr.RefreshForDel( self.success );
end
