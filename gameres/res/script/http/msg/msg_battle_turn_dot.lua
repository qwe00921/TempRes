--------------------------------------------------------------
-- FileName: 	msg_battle_turn_dot.lua
-- author:		zhangwq, 2013/08/14
-- purpose:		战斗：对应回合的DOT阶段
-- 在回合开始时，处理状态引起的伤害等
--------------------------------------------------------------

msg_battle_turn_dot = msg_base:new();
local p = msg_battle_turn_dot;
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
    self.idMsg = MSG_BATTLE_TURN_DOT; --消息号
	self.event = {};	

	if false then
		self.event[0] = {};
		local event = self.event[0];
		
		event.id_fighter = 101;		--事件相关的fighter（可选）	
		event.id_status = nil;		--状态id（可选）
		
		event.life_change = 100;	--血量变化（可选），大于0加血，小于0扣血
		event.mana_change = nil;	--魔量变化（可选），大于0加魔，小于0扣魔
		event.is_dead = false;		--是否导致目标死亡（可选）
		
		self.event[1] = {};
        local event2 = self.event[1];
        event2.id_fighter = 105; 
        event2.id_status = nil;
        event2.life_change = 80;
        event2.mana_change = nil;
        event2.is_dead = false;
	end
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_battle_turn:Process() called" );
	card_battle_mgr.ReceiveBattle_SubTurnStage_Dot( self );
end
