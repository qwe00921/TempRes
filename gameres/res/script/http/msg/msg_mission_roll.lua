--------------------------------------------------------------
-- FileName:    msg_mission_roll.lua
-- author:      hst, 2013/07/10
-- purpose:     卡箱数据
--------------------------------------------------------------

msg_mission_roll = msg_base:new();
local p = msg_mission_roll;
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
    self.idMsg = MSG_MISSION_ROLL; --消息号
    
    self.roll_num = nil;
    self.mission_point = nil;
    self.mission_point_max = nil;
    self.recover_mission_point = nil;
    self.recover_full_time = nil;
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteConWarning( "** msg_mission_roll:Process() called" );
    task_map.RefreshUI(self);
end
