--------------------------------------------------------------
-- FileName: 	resp_test.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		��Ӧ����
--------------------------------------------------------------

resp_test = resp_base:new();
local p = resp_test;
local super = resp_base;

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
    self.idResponse = 1; --��Ӧ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** resp_test:Process() called" );
	super.Process( self );
end