--------------------------------------------------------------
-- FileName: 	msg_travel_explore.lua
-- author:		xyd, 2013/07/19
-- purpose:		世界地图探索
--------------------------------------------------------------

msg_travel_explore = msg_base:new();
local p = msg_travel_explore;
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
    self.idMsg = MSG_TRAVEL_EXPLORE; --消息号
end

--初始化
function p:Init()
	
end

--处理消息
function p:Process()
	msg_cache.msg_travel_explore = self;
	WriteConWarning( "** msg_travel_explore:Process() called" );	
	task_map.ExploreRefresh(self);
end
