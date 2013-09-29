--------------------------------------------------------------
-- FileName: 	msg_battle_turn_skill.lua
-- author:		zhangwq, 2013/08/22
-- purpose:		战斗：对应技能阶段
-- 				包括玩家技能、卡牌技能
--------------------------------------------------------------

msg_battle_turn_skill = msg_base:new();
local p = msg_battle_turn_skill;
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
    self.idMsg = MSG_BATTLE_USER_SKILL; --消息号
	self.id_skill = 0;

	
	if true then
	    self.event = {};
	   
		self.event[1] = {};
		local event = self.event[1];
		
		event.id_atk = 105;			--攻击者（可选）
		event.id_target = 202;		--受击者（可选）
		event.id_skill = nil;		--技能id（可选）
		
		event.life_change = -80;	--血量变化（可选），大于0加血，小于0扣血
		event.status_change = nil;	--状态变化（可选），大于0的id表示加状态，小于0的id表示去除状态
		
		event.is_dodge = false;		--是否闪避（可选）
		event.is_critical = false;	--是否暴击（可选）
		event.is_block = false;		--是否格挡（可选）
		event.is_dead = false;		--是否导致目标死亡（可选）
		
		self.event[2] = {};
        local event = self.event[2];
        
        event.id_atk = 105;         
        event.id_target = 203;     
        event.id_skill = nil;       
        
        event.life_change = -80;    
        event.status_change = nil;  
        
        event.is_dodge = false;     
        event.is_critical = false;  
        event.is_block = false;     
        event.is_dead = false;        	
	end	
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_battle_turn_skill:Process() called" );
	card_battle_mgr.ReceiveBattle_Hero_SkillRes(self);
end
