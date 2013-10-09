--------------------------------------------------------------
-- FileName: 	msg_base.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		消息基类
--------------------------------------------------------------

msg_base = {}
local p = msg_base;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
    self.idMsg = 0; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteConWarning( "** msg_base:Process() called" );
end