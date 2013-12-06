--------------------------------------------------------------
-- FileName:    n_battle_inc.lua
-- author:      hst, 2013/11/26
-- purpose:     战斗常量定义
--------------------------------------------------------------
N_BATTLE_PVP = 1;
N_BATTLE_PVE = 2;

--对战最多为10个回合
N_BATTLE_ROUND_1 = 1;
N_BATTLE_ROUND_2 = 2;
N_BATTLE_ROUND_3 = 3;
N_BATTLE_ROUND_4 = 4;
N_BATTLE_ROUND_5 = 5;
N_BATTLE_ROUND_6 = 6;
N_BATTLE_ROUND_7 = 7;
N_BATTLE_ROUND_8 = 8;
N_BATTLE_ROUND_9 = 9;
N_BATTLE_ROUND_10 = 10;
N_BATTLE_MAX_ROUND = 10;

N_BATTLE_CAMP_CARD_NUM = 6;--阵营中的卡牌数量上限

MIN_RAGE_NUM = 0;--宠物怒气值
MAX_RAGE_NUM = 100;--宠物怒气值

--对战阶段
N_BATTLE_STAGE_LOADING = 1;--战斗加载
N_BATTLE_STAGE_PERMANENT_BUFF = 2;--永久BUFF阶段
N_BATTLE_STAGE_ROUND = 3;--回合阶段
N_BATTLE_STAGE_END = 4;--结束阶段

N_BATTLE_ROUND_STAGE_PET = 1;--召唤兽 
N_BATTLE_ROUND_STAGE_BUFF = 2;--BUFF表现
N_BATTLE_ROUND_STAGE_ATK = 3;--互殴
N_BATTLE_ROUND_STAGE_CLEARING = 4;--结算

--buff
N_BUFF_TYPE_0 = 0;--没BUFF
N_BUFF_TYPE_1 = 1;--晕眩
N_BUFF_TYPE_2 = 2;--冰冻
N_BUFF_TYPE_3 = 3;--缠绕
N_BUFF_TYPE_4 = 4;--中毒
N_BUFF_TYPE_5 = 5;--燃烧
N_BUFF_TYPE_6 = 6;
N_BUFF_TYPE_7 = 7;
N_BUFF_TYPE_8 = 8;
N_BUFF_TYPE_9 = 9;--恢复

N_BUFF_TYPE_101 = 101;--攻击增强
N_BUFF_TYPE_102 = 102;--防御增强
N_BUFF_TYPE_103 = 103;--暴击增强

N_BUFF_TYPE_201 = 201;--攻击减弱
N_BUFF_TYPE_202 = 202;--防御减弱
N_BUFF_TYPE_203 = 203;--暴击减弱

--skill type
N_SKILL_TYPE_1 = 1;--主动伤害技能
N_SKILL_TYPE_2 = 2;--主动恢复技能
N_SKILL_TYPE_3 = 3;--属性加成技能
N_SKILL_TYPE_4 = 4;--被动触发技
N_SKILL_TYPE_5 = 5;--主动复活技能

--技能攻击目标
N_SKILL_TARGET_TYPE_1 = 1;--敌方单体
N_SKILL_TARGET_TYPE_2 = 2;--敌方群体：远程攻击位置：中间
N_SKILL_TARGET_TYPE_3 = 3;--敌方直线：远程攻击位置：中间
N_SKILL_TARGET_TYPE_4 = 4;--敌方横排
N_SKILL_TARGET_TYPE_5 = 5;--敌方穿越

N_SKILL_TARGET_TYPE_11 = 11;--自己
N_SKILL_TARGET_TYPE_12 = 12;--己方群体
N_SKILL_TARGET_TYPE_13 = 13;--己方随机一个已死亡单位

N_BATTLE_DISTANCE_1 = 1;--近战攻击
N_BATTLE_DISTANCE_2 = 2;--远程攻击

N_BATTLE_BULLET_0 = 0;--无弹道
N_BATTLE_BULLET_1 = 1;--有弹道


