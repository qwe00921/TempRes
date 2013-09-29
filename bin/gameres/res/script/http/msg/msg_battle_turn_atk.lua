--------------------------------------------------------------
-- FileName: 	msg_battle_turn_atk.lua
-- author:		zhangwq, 2013/08/22
-- purpose:		战斗：对应回合普通攻击阶段
--------------------------------------------------------------

msg_battle_turn_atk = msg_base:new();
local p = msg_battle_turn_atk;
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
    self.idMsg = MSG_BATTLE_TURN_ATK; --消息号
	self.event = {};	

	if true then
	    self.event = {};
	    
		self.event[1] = {};
		local event = self.event[1];
		
		event.id_atk = 101;			--攻击者（可选）
		event.id_target = 201;		--受击者（可选）
		
		event.life_change = nil;	--血量变化（可选），大于0加血，小于0扣血
		event.status_change = nil;	--状态变化（可选），大于0的id表示加状态，小于0的id表示去除状态
		
		event.is_dodge = nil;		--是否闪避（可选）
		event.is_critical = nil;	--是否暴击（可选）
		event.is_block = nil;		--是否格挡（可选）
		event.is_dead = nil;		--是否导致目标死亡（可选）	
		event.is_target_fight_back = nil; --目标是否反击了（可选）
		
		self.event[2] = {};
        local event = self.event[2];
        
        event.id_atk = 102;         --攻击者（可选）
        event.id_target = 202;      --受击者（可选）
        
        event.life_change = nil;    --血量变化（可选），大于0加血，小于0扣血
        event.status_change = nil;  --状态变化（可选），大于0的id表示加状态，小于0的id表示去除状态
        
        event.is_dodge = nil;       --是否闪避（可选）
        event.is_critical = nil;    --是否暴击（可选）
        event.is_block = nil;       --是否格挡（可选）
        event.is_dead = nil;        --是否导致目标死亡（可选）  
        event.is_target_fight_back = nil; --目标是否反击了（可选）
        
        self.event[3] = {};
        local event = self.event[3];
        
        event.id_atk = 103;         --攻击者（可选）
        event.id_target = 203;      --受击者（可选）
        
        event.life_change = nil;    --血量变化（可选），大于0加血，小于0扣血
        event.status_change = nil;  --状态变化（可选），大于0的id表示加状态，小于0的id表示去除状态
        
        event.is_dodge = nil;       --是否闪避（可选）
        event.is_critical = nil;    --是否暴击（可选）
        event.is_block = nil;       --是否格挡（可选）
        event.is_dead = nil;        --是否导致目标死亡（可选）  
        event.is_target_fight_back = nil; --目标是否反击了（可选）
        
        self.event[4] = {};
        local event = self.event[4];
        
        event.id_atk = 104;         --攻击者（可选）
        event.id_target = 204;      --受击者（可选）
        
        event.life_change = nil;    --血量变化（可选），大于0加血，小于0扣血
        event.status_change = nil;  --状态变化（可选），大于0的id表示加状态，小于0的id表示去除状态
        
        event.is_dodge = nil;       --是否闪避（可选）
        event.is_critical = nil;    --是否暴击（可选）
        event.is_block = nil;       --是否格挡（可选）
        event.is_dead = nil;        --是否导致目标死亡（可选）  
        event.is_target_fight_back = nil; --目标是否反击了（可选）
        
        self.event[5] = {};
        local event = self.event[5];
        
        event.id_atk = 105;         --攻击者（可选）
        event.id_target = 205;      --受击者（可选）
        
        event.life_change = nil;    --血量变化（可选），大于0加血，小于0扣血
        event.status_change = nil;  --状态变化（可选），大于0的id表示加状态，小于0的id表示去除状态
        
        event.is_dodge = nil;       --是否闪避（可选）
        event.is_critical = nil;    --是否暴击（可选）
        event.is_block = nil;       --是否格挡（可选）
        event.is_dead = nil;        --是否导致目标死亡（可选）  
        event.is_target_fight_back = nil; --目标是否反击了（可选）
        
	end
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_battle_turn_atk:Process() called" );
	card_battle_mgr.ReceiveBattle_SubTurnStage_AtkRes( self );
end
