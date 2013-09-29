--------------------------------------------------------------
-- FileName:    msg_dungeon_explore.lua
-- author:      hst, 2013/08/19
-- purpose:     副本地图旅行
--------------------------------------------------------------

msg_dungeon_explore = msg_base:new();
local p = msg_dungeon_explore;
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
    self.idMsg = MSG_DUNGEON_EXPLORE; --消息号
    
    --[[
    self.explore_result = nil
    self.refresh_map = nil
    --]]
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteConWarning( "** msg_dungeon_explore:Process() called" );
    task_map.ExploreRefresh(self);
end
