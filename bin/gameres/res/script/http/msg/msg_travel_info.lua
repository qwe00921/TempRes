--------------------------------------------------------------
-- FileName: 	msg_travel_info.lua
-- author:		xyd, 2013/07/19
-- purpose:		旅行地图消息清单
--------------------------------------------------------------

msg_travel_info = msg_base:new();
local p = msg_travel_info;
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
    self.idMsg = MSG_TRAVEL_INFO; --消息号
	self.mission_info={};
	self.ErrorMsg = "";
end

--初始化
function p:Init()
	
end

--处理消息
function p:Process()
	msg_cache.msg_travel_info = self;
	WriteConWarning( "** msg_travel_info:Process() called" );
	task_map.RefreshUI(self);
end
