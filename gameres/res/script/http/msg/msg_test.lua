--------------------------------------------------------------
-- FileName: 	msg_test.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		��Ϣ����
--------------------------------------------------------------

msg_test = msg_base:new();
local p = msg_test;
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
    self.idMsg = 1; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_test:Process() called" );
	mainnui.RefreshUI(self);
end
