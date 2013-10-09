--------------------------------------------------------------
-- FileName: 	msg_billboard.lua
-- author:		xyd, 2013/07/19
-- purpose:		跑马灯
--------------------------------------------------------------

msg_billboard = msg_base:new();
local p = msg_billboard;
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
    self.idMsg = MSG_MISC_BILLBOARD; --消息号
end

--初始化
function p:Init()
	
end

--处理消息
function p:Process()
	msg_cache.msg_billboard = self;
	WriteConWarning( "** msg_billboard:Process() called" );
	billboard.RefreshMessage(self);
end
