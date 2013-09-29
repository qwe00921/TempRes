--------------------------------------------------------------
-- FileName:    msg_card_evolution.lua
-- author:      hst, 2013/07/29
-- purpose:     卡牌进化
--------------------------------------------------------------

msg_card_evolution = msg_base:new();
local p = msg_card_evolution;
local super = msg_base;

--创建新实例
function p:new()    
    o = {}
    setmetatable( o, self );
    self.__index = self;
    
    o:ctor();
    return o;
end

--构造函数
function p:ctor()
    super.ctor(self);
    self.idMsg = MSG_CARDBOX_EVOLUTION; --消息号
    
    self.exp = nil;
    self.user_card_id = nil;
    self.user_id = nil;
    self.hp = nil;
    self.defence = nil;
    self.card_id = nil;
    self.level = nil;
    self.attack = nil;
    self.gold = nil;
    
    
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    --WriteConWarning( "** msg_card_evolution:Process() called" );
    --dump_obj(self);
    dlg_card_evolution_result.RefreshUI(self);
end
