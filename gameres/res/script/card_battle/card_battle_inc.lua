--------------------------------------------------------------
-- FileName: 	card_battle_inc.lua
-- author:		zhangwq, 2013/08/14
-- purpose:		卡牌战斗：常量定义
--------------------------------------------------------------


--回合内战斗表现相关的effect type
BATTLE_EFFECT_TYPE_NONE				= 0;

BATTLE_EFFECT_TYPE_ATK				= 1; -- 攻击/反击
BATTLE_EFFECT_TYPE_SKILL			= 2; -- 技能(施放者)立即效果
BATTLE_EFFECT_TYPE_SKILL_TARGET		= 3; -- 技能(承受者)立即效果
BATTLE_EFFECT_TYPE_LIFE				= 4;			-- 生命
BATTLE_EFFECT_TYPE_MANA				= 5;			-- 气势
BATTLE_EFFECT_TYPE_DODGE			= 6;			-- 闪避
BATTLE_EFFECT_TYPE_DRITICAL			= 7;		-- 暴击
BATTLE_EFFECT_TYPE_BLOCK			= 8;			-- 格挡
BATTLE_EFFECT_TYPE_COMBO			= 9;			-- 连击
BATTLE_EFFECT_TYPE_STATUS_ADD		= 10;		-- 加状态
BATTLE_EFFECT_TYPE_STATUS_LOST		= 11;		-- 取消状态
BATTLE_EFFECT_TYPE_STATUS_LIFE		= 12;		-- 状态去血
BATTLE_EFFECT_TYPE_DEAD				= 13;

EFFECT_TYPE_TURN_END				= 14;				-- 回合结束
EFFECT_TYPE_BATTLE_BEGIN			= 15;			-- 战斗开始
EFFECT_TYPE_BATTLE_END				= 16;				-- 战斗结束

BATTLE_EFFECT_TYPE_CTRL				= 17;			--受控--暂不处理
BATTLE_EFFECT_TYPE_ESCORTING		= 18;		--护驾----显示文字特效而已
BATTLE_EFFECT_TYPE_COOPRATION_HIT	= 19;	--合击----显示文字特效而已
BATTLE_EFFECT_TYPE_CHANGE_POSTION	= 20;	--移位--中军移动到后军==

BATTLE_EFFECT_TYPE_SKILL_EFFECT_TARGET	= 21;	-- 技能附加效果目标
BATTLE_EFFECT_TYPE_SKILL_EFFECT		= 22;		-- 技能附加效果
BATTLE_EFFECT_TYPE_STATUS_MANA 		= 23;			-- 状态去气
BATTLE_EFFECT_TYPE_RESIST			= 24;				-- 免疫

--BUFF效果类型
BATTLE_BUFF_EFFECT      = 1;--增益状态
BATTLE_DEBUFF_EFFECT    = 2;--减益状态

BATTLE_BUFF_TYPE_LIFE           = 1; --生命
BATTLE_BUFF_TYPE_DEF            = 2; --防御      
BATTLE_BUFF_TYPE_ATK            = 3; --攻击 
BATTLE_BUFF_TYPE_MAX_LIFE       = 4; --生命上限
BATTLE_BUFF_TYPE_SKILL_CD       = 5; --技能冷却数
BATTLE_BUFF_TYPE_DAMAGE         = 6; --伤害数值
BATTLE_BUFF_TYPE_SHIELD         = 7; --生命护盾
BATTLE_BUFF_TYPE_DODGE          = 8; --闪避率
BATTLE_BUFF_TYPE_DRITICAL       = 9; --暴击
BATTLE_BUFF_TYPE_COUNTER_ATK    = 10;--反击
BATTLE_BUFF_TYPE_COMBO          = 11;--连击
BATTLE_BUFF_TYPE_SUCK_LIFE      = 12;--吸血
BATTLE_BUFF_TYPE_DRITICAL       = 13;--自爆
