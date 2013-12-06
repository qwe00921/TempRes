--------------------------------------------------------------
-- FileName:    msg_battle.lua
-- author:      hst, 2013/12/6
-- purpose:     PVE
--------------------------------------------------------------

msg_battle_pve = msg_base:new();
local p = msg_battle_pve;
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
    self.idMsg = MSG_BATTLE; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteCon( "** msg_battle:Process() called" );
    n_battle_mgr.ReceiveStartPVERes( self );
end

--[[
msg_battle = msg_base:new();
local p = msg_battle;
local super = msg_base;

--事件类型
local EVENT_TYPE_BATTLE_BEGIN = 1; --战斗开始
local EVENT_TYPE_BATTLE_END = 2;   --战斗结束

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
    self.idMsg = MSG_BATTLE; --消息号
    self.event_type = 0;
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteCon( "** msg_battle:Process() called" );
end
--]]