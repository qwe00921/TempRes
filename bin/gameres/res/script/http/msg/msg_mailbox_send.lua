--------------------------------------------------------------
-- FileName: 	msg_mailbox_send.lua
-- author:		Zjj, 2013/09/26
-- purpose:		�����ʼ������Ϣ
--------------------------------------------------------------

msg_mailbox_send = msg_base:new();
local p = msg_mailbox_send;
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
    self.idMsg = MSG_MAILBOX_SEND; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_mailbox_send = self;
	WriteConWarning( "** msg_mailbox_send:Process() called" );
	mailbox_mgr.SendSuccess();
end
