--------------------------------------------------------------
-- FileName: 	msg_billboard.lua
-- author:		xyd, 2013/07/19
-- purpose:		�����
--------------------------------------------------------------

msg_billboard = msg_base:new();
local p = msg_billboard;
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
    self.idMsg = MSG_MISC_BILLBOARD; --��Ϣ��
end

--��ʼ��
function p:Init()
	
end

--������Ϣ
function p:Process()
	msg_cache.msg_billboard = self;
	WriteConWarning( "** msg_billboard:Process() called" );
	billboard.RefreshMessage(self);
end
