--------------------------------------------------------------
-- FileName: 	msg_base.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		��Ϣ����
--------------------------------------------------------------

msg_base = {}
local p = msg_base;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
    self.idMsg = 0; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
    WriteConWarning( "** msg_base:Process() called" );
end