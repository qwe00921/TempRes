--------------------------------------------------------------
-- FileName: 	msg_mailbox_one.lua
-- author:		Zjj, 2013/09/26
-- purpose:		��һ�ʼ���Ϣ
--------------------------------------------------------------

msg_mailbox_one = msg_base:new();
local p = msg_mailbox_one;
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
    self.idMsg = MSG_MAILBOX_ONE; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_mailbox_one = self;
	WriteConWarning( "** msg_mailbox_one:Process() called" );
	dlg_mailbox_person_detail.ShowContent( self.mails );
end
