--------------------------------------------------------------
-- FileName: 	resp_test.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		响应测试
--------------------------------------------------------------

resp_test = resp_base:new();
local p = resp_test;
local super = resp_base;

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
    self.idResponse = 1; --响应号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** resp_test:Process() called" );
	super.Process( self );
end