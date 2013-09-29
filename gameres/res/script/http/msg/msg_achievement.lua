--------------------------------------------------------------
-- FileName: 	msg_achievement.lua
-- author:		Zjj, 2013/07/09
-- purpose:		成就消息
--------------------------------------------------------------

msg_achievement = msg_base:new();
local p = msg_achievement;
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
    self.idMsg = MSG_PLAYER; --消息号
	self.user_id = 0;
	self.user_name = "1111111";
	self.sex = 1;
	self.level = 0;
	self.exp = 0;
	self.mission_point = 0;
	self.mission_point_max = 0;
	self.arena_point = 0;
	self.arena_point_max = 0;
	self.chapter_id = 0;	
	self.stage_id = 0;
	self.travel_id = 0;
	self.position_x = 0;
	self.position_y = 0;
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_achievement = self;
	WriteConWarning( "** msg_achievement:Process() called" );
end
