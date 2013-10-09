--------------------------------------------------------------
-- FileName: 	user_skill_inc.lua
-- author:		xyd, 2013/08/02
-- purpose:		技能常量配置
--------------------------------------------------------------

-- 技能角色类型
SKILL_OWNER_SKILL = 1; -- 技能卡
SKILL_OWNER_EXP = 4; -- 技能经验卡

--卡牌分类
SKILL_PIERCE_1 = 1; --主动技能
SKILL_PIERCE_2 = 2; --被动技能
SKILL_PIERCE_3 = 4; --经验卡片
SKILL_PIERCE_4 = 5; --全部

-- 排序分类
SKILL_SORT_LEVEL = 1; --按level排序
SKILL_SORT_RARE  = 2; --按rare排序

--进入技能意图
SKILL_INTENT_PREVIEW 			= 1;--预览卡牌
SKILL_INTENT_GETONE 			= 2;--获取单张卡牌
SKILL_INTENT_GETLIST 			= 3;--选取素材卡

-- 素材卡选择数量上限
MATERIAL_SELECT_MAX_NUM          = 4;

-- 卡包卡片上限
SKILL_CARD_MAX_NUM               = 70;

-- 技能卡牌强化意图
INTENSIFY_INTENT_PREVIEW                 = 1;
INTENSIFY_INTENT_MATERIAL_SELECT         = 2;
INTENSIFY_INTENT_MATERIAL_RESULT         = 3;
