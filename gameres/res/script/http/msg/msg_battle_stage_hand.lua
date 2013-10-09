--------------------------------------------------------------
-- FileName:    msg_battle_stage_hand.lua
-- author:      hst, 2013/09/3
-- purpose:     战斗：起手阶段消息
--------------------------------------------------------------

msg_battle_stage_hand = msg_base:new();
local p = msg_battle_stage_hand;
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
    self.idMsg = MSG_BATTLE_HAND; --消息号
    
    if false then
        
        
    end
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteConWarning( "** msg_battle_fighters:Process() called" );
    card_battle_mgr.ReceiveBattle_Stage_HandRes( self );
end
