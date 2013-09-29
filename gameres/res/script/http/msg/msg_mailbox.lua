--------------------------------------------------------------
-- FileName: 	msg_mailbox.lua
-- author:		Zjj, 2013/09/23
-- purpose:		�ʼ���Ϣ
--------------------------------------------------------------

msg_mailbox = msg_base:new();
local p = msg_mailbox;
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
    self.idMsg = MSG_MAILBOX; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_mailbox = self;
	WriteConWarning( "** msg_mailbox:Process() called" );
	mailbox_mgr.SaveData( self.mails );
end
