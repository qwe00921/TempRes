--------------------------------------------------------------
-- FileName: 	msg_collect.lua
-- author:		xyd, 2013/09/13
-- purpose:		图鉴系统
--------------------------------------------------------------

msg_collect = msg_base:new();
local p = msg_collect;
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
    self.idMsg = MSG_COLLECT_START; --消息号
end

--初始化
function p:Init()
	
end

--处理消息
function p:Process()
	msg_cache.msg_collect = self;
	WriteConWarning( "** msg_collect:Process() called");
end
