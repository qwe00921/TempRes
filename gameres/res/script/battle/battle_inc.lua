--------------------------------------------------------------
-- FileName: 	battle_inc.lua
-- author:		zhangwq, 2013/05/18
-- purpose:		战斗常量定义
--------------------------------------------------------------

--阵营
E_CARD_CAMP_HERO  = 1;
E_CARD_CAMP_ENEMY = 2;


--战场元素Tag
E_BATTLE_TAG_GROUND			= 1;	--地面
E_BATTLE_TAG_GROUND_FX		= 2;	--地面特效
E_BATTLE_TAG_HERO_FIGHTER	= 3;	--hero
E_BATTLE_TAG_ENEMY_FIGHTER	= 4;	--enemy
E_BATTLE_TAG_BOSS_FIGHTER	= 5;	--boss
E_BATTLE_TAG_BULLET			= 6;	--子弹


--战场元素Z序
E_BATTLE_Z_GROUND			= -20;	--战场地面
E_BATTLE_Z_GROUND_FX		= -10;	--战场地面特效
E_BATTLE_Z_NORMAL			= 0;	--普通
E_BATTLE_Z_ENEMY_FIGHTER	= 10;	--Enemy战士
E_BATTLE_Z_BULLET			= 20;	--子弹
E_BATTLE_Z_HERO_FIGHTER		= 30;	--Hero战士
E_BATTLE_Z_BLACK_MASK		= 70;	--放大招的遮挡
E_BATTLE_Z_ULT_SKILL_FIGHTER = 100;  --放大招的时候战士

--战斗阶段
E_BATTLE_STAGE_NONE             = 0;
E_BATTLE_STAGE_LOADING          = 1;    --加载阶段
E_BATTLE_STAGE_INIT             = 2;    --起手阶段
E_BATTLE_STAGE_TURN             = 3;    --回合阶段
E_BATTLE_STAGE_END              = 4;    --结束阶段

--回合阶段
E_BATTLE_TURN_STAGE_NONE    = 0;
E_BATTLE_TURN_STAGE_HERO    = 1;    --英雄回合  即上半场
E_BATTLE_TURN_STAGE_ENEMY   = 2;    --守方阶段  即下半场
E_BATTLE_TURN_STAGE_END     = 3;    --回合结束

--回合子阶段
E_BATTLE_TURN_SUBSTAGE_NONE     = 0;    
E_BATTLE_TURN_SUBSTAGE_DOT      = 1;
E_BATTLE_TURN_SUBSTAGE_SKILL    = 2;
E_BATTLE_TURN_SUBSTAGE_ATK      = 3;

--角色朝向
E_LOOKAT_RIGHT				= 0;	
E_LOOKAT_LEFT				= 1;

--demo版本
E_DEMO_VER = 5;

--角色攻击类型
MELEE_ATTACK = 1	--近战物理攻击
RANGED_ATTACK = 2	--远程物理攻击
MAGIC_ATTACK = 3	--魔法攻击

--批次阶段标识
E_BATCH_STAGE_BEGIN			= 1;
E_BATCH_STAGE_ATK_BEGIN		= 2;
E_BATCH_STAGE_ATK_END		= 3;
E_BATCH_STAGE_HURT_BEGIN	= 4;
E_BATCH_STAGE_HURT_END		= 5;
E_BATCH_STAGE_END			= 6;
