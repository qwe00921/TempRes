--------------------------------------------------------------
-- FileName: 	msg_battle_turn_end.lua
-- author:		zhangwq, 2013/08/22
-- purpose:		战斗：回合结束
-- 负责更新本回合fighter的技能CD、buf、status、怒气值等
--------------------------------------------------------------

msg_battle_turn_end = msg_base:new();
local p = msg_battle_turn_end;
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
    self.idMsg = MSG_BATTLE_TURN_END; --消息号

	if false then
		self.event = {};
		self.event[0] = {};
		local event = self.event[0];
		
		event.id_fighter = nil;		--事件相关的fighter（可选）	
		--event.id_skill = nil;		--技能id（可选）
		--event.id_status = nil;		--状态id（可选）
		--event.turn_amount = 0;		--剩余回合个数（表示技能CD还有几个回合，或者状态buf还有几个回合）
		
		--技能cd数组
		--buf数组
		--状态数组
		--怒气值
	end
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_battle_turn_end:Process() called" );
	card_battle_mgr.ReceiveBattle_TurnStage_EndRes(self);
end