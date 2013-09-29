--------------------------------------------------------------
-- FileName:    msg_dungeon.lua
-- author:      hst, 2013/08/19
-- purpose:     副本信息
--------------------------------------------------------------

msg_dungeon = msg_base:new();
local p = msg_dungeon;
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
    self.idMsg = MSG_DUNGEON; --消息号
    
    --[[
    self.id = nil;
    self.chapter_id = nil;
    self.stage_id = nil;
    self.difficulty = nil;
    self.travel_num = nil;
    self.travel_max = nil;
    self.need_mission_point = nil;
    self.exp = nil;
    self.map_id = nil;
    self.travel_map_treasure_rule = nil;
    self.travel_map_series_random = nil;
    self.start_point_x = nil;
    self.start_point_y = nil;
    --]]
       
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteConWarning( "** msg_dungeon:Process() called" );
    --dump_obj(self.user_cards);
    task_map.RefreshUI(self);
end
