--------------------------------------------------------------
-- FileName: 	msg_test.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		消息测试
--------------------------------------------------------------

msg_test = msg_base:new();
local p = msg_test;
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
    self.idMsg = 1; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_test:Process() called" );
	mainnui.RefreshUI(self);
end
