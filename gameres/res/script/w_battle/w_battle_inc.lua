--------------------------------------------------------------
-- FileName:    w_battle_inc.lua
-- author:      hst, 2013/11/26
-- purpose:     战斗常量定义
--------------------------------------------------------------
W_BATTLE_PVP = 1;
W_BATTLE_PVE = 2;

--对战最多为10个回合
W_BATTLE_ROUND_1 = 1;
W_BATTLE_ROUND_2 = 2;
W_BATTLE_ROUND_3 = 3;
W_BATTLE_ROUND_4 = 4;
W_BATTLE_ROUND_5 = 5;
W_BATTLE_ROUND_6 = 6;
W_BATTLE_ROUND_7 = 7;
W_BATTLE_ROUND_8 = 8;
W_BATTLE_ROUND_9 = 9;
W_BATTLE_ROUND_10 = 10;
W_BATTLE_MAX_ROUND = 10;

W_BATTLE_CAMP_CARD_NUM = 6;--阵营中的卡牌数量上限

MIN_RAGE_NUM = 0;--宠物怒气值
MAX_RAGE_NUM = 100;--宠物怒气值

--对战阶段
W_BATTLE_STAGE_LOADING = 1;--战斗加载
W_BATTLE_STAGE_PERMANENT_BUFF = 2;--永久BUFF阶段
W_BATTLE_STAGE_ROUND = 3;--回合阶段
W_BATTLE_STAGE_END = 4;--结束阶段

W_BATTLE_ROUND_STAGE_PET = 1;--召唤兽 
W_BATTLE_ROUND_STAGE_BUFF = 2;--BUFF表现
W_BATTLE_ROUND_STAGE_ATK = 3;--互殴
W_BATTLE_ROUND_STAGE_CLEARING = 4;--结算

--buff
W_BUFF_TYPE_0 = 0;--没BUFF
W_BUFF_TYPE_1 = 1;--晕眩
W_BUFF_TYPE_2 = 2;--冰冻
W_BUFF_TYPE_3 = 3;--缠绕
W_BUFF_TYPE_4 = 4;--麻痹
W_BUFF_TYPE_5 = 5;--石化
W_BUFF_TYPE_6 = 6;--中毒 Hp总值x%
W_BUFF_TYPE_7 = 7;--燃烧 Hp总值x%
W_BUFF_TYPE_8 = 8;--诅咒
W_BUFF_TYPE_9 = 9;--恢复 Hp总值x%

W_BUFF_TYPE_101 = 101;--攻击增强
W_BUFF_TYPE_102 = 102;--防御增强
W_BUFF_TYPE_103 = 103;--暴击增强

W_BUFF_TYPE_201 = 201;--攻击减弱
W_BUFF_TYPE_202 = 202;--防御减弱
W_BUFF_TYPE_203 = 203;--暴击减弱

W_BUFF_TYPE_301 = 301;--复活

--各种BUFF的最低值
W_BUFF_ATKMIN   = 0
W_BUFF_DEFMIN   = 0
W_BUFF_CRITMIN  = 0.001   

--skill type
W_SKILL_TYPE_1 = 1;--主动伤害技能
W_SKILL_TYPE_2 = 2;--主动恢复技能
W_SKILL_TYPE_3 = 3;--属性加成技能
W_SKILL_TYPE_4 = 4;--被动触发技
W_SKILL_TYPE_5 = 5;--主动复活技能

--技能攻击目标
W_SKILL_TARGET_TYPE_1 = 1;--敌方单体
W_SKILL_TARGET_TYPE_2 = 2;--敌方群体：远程攻击位置：中间
W_SKILL_TARGET_TYPE_3 = 3;--敌方直线：
W_SKILL_TARGET_TYPE_4 = 4;--敌方横排: 远程攻击位置：中间
W_SKILL_TARGET_TYPE_5 = 5;--敌方穿越

W_SKILL_TARGET_TYPE_11 = 11;--自己
W_SKILL_TARGET_TYPE_12 = 12;--己方群体
W_SKILL_TARGET_TYPE_13 = 13;--己方随机一个已死亡单位

W_BATTLE_DISTANCE_NoArcher = 1;--近战攻击
W_BATTLE_DISTANCE_Archer = 2;--远程攻击


W_BATTLE_BULLET_0 = 0;--无弹道
W_BATTLE_BULLET_1 = 1;--有弹道

W_BATTLE_HERO = 0;  --玩家方英雄
W_BATTLE_ENEMY = 1; --怪物方敌人
--属性
--[[
W_BATTLE_PROP_ICE = 0;  --冰
W_BATTLE_PROP_FIRE = 1;  --火
W_BATTLE_PROP_WIND = 2;  --风
W_BATTLE_PROP_WOOD = 3;  --树
]]--

--无金木水火土
W_BATTLE_ELEMENT_NULL  = 0;
W_BATTLE_ELEMENT_GOLD  = 1;
W_BATTLE_ELEMENT_WOOD  = 2;
W_BATTLE_ELEMENT_WATER = 3;
W_BATTLE_ELEMENT_FIRE  = 4;
W_BATTLE_ELEMENT_EARTH = 5;

W_BATTLE_ELEMENT_LIGHT = 6; --光
W_BATTLE_ELEMENT_DARK  = 7; --暗


--合击时间的间隔
W_BATTLE_JOINATK_TIME = 1; 

--站位标置
W_BATTLE_POS_TAG_1 = 1;
W_BATTLE_POS_TAG_2 = 2;
W_BATTLE_POS_TAG_3 = 3;
W_BATTLE_POS_TAG_4 = 4;
W_BATTLE_POS_TAG_5 = 5;
W_BATTLE_POS_TAG_6 = 6;

--动画攻击时间
W_BATTLE_ATKTIME   =  0.5;
--怪物延迟时间攻击
W_BATTLE_ENEMYTIME = 0.7;

--行动状态
W_BATTLE_NOT_TURN = 0;  --未行动
W_BATTLE_TURN     = 1;  --行动中 
W_BATTLE_TURNEND  = 2;  --已行动

--掉落
W_DROP_ATKTYPE1  = 1;  --普攻
W_DROP_ATKTYPE2  = 2;  --技能
W_DROP_ATKTYPE3  = 3;  --暴击
W_DROP_ATKTYPE4  = 4;  --合击
W_DROP_ATKTYPE5  = 5;  --超量


--战斗物品使用
W_MATERIAL_TYPE1 = 1;   --药水类型
W_MATERIAL_TYPE2 = 2;   --材料类型

--药水类型
W_MATERIAL_SUBTYPE1 = 1; --恢复类
W_MATERIAL_SUBTYPE2 = 2; --解状态类
W_MATERIAL_SUBTYPE3 = 3; --属性类

--物品目标
W_MATERIAL_TARGET1  = 1;  --单个目标
W_MATERIAL_TARGET2  = 2;  --全体目标

W_BATTLE_REVIVAL     = 9999; --复活状态
W_BATTLE_DELAYTIME   = 0.5;  --相隔0.5秒出手

W_SHOWBUFF_STATE     = 3;  --BUFF状态轮流显示的时间
--平台判断
W_PLATFORM_WIN32     = 1
W_PLATFORM_IOS       = 2

--战斗所用到的像素
W_BATTLE_JUMPSTAR = 220 * 2;     --人物进场动画偏移
W_BATTLE_DAMAGE_OFFSETY = 60 --掉血数字的起始偏移
W_BATTLE_DROP_H = 16;  --战斗中掉落物品的图片的宽高是一样的
W_BATTLE_PASSBG_INIT = 740;  --过场动画的进度条的偏移值