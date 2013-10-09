--------------------------------------------------------------
-- FileName: 	msg_drama.lua
-- author:		
-- purpose:		剧情消息
--------------------------------------------------------------

msg_drama = msg_base:new();
local p = msg_drama;
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
    self.idMsg = MSG_MISC_DRAMA; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_drama:Process() called" );
end
