--------------------------------------------------------------
-- FileName: 	msg_drama.lua
-- author:		
-- purpose:		������Ϣ
--------------------------------------------------------------

msg_drama = msg_base:new();
local p = msg_drama;
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
    self.idMsg = MSG_MISC_DRAMA; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_drama:Process() called" );
end
