--------------------------------------------------------------
-- FileName: 	load_db.lua
-- author:		zhangwq, 2013/05/25
-- purpose:		加载数据库
--------------------------------------------------------------

T_TEST          = LoadTable( "test.ini" );

--地图表
T_CHAPTER_MAP   = LoadTable( "chapter_map.ini" );
T_STAGE_MAP     = LoadTable( "stage_map.ini" );
T_TRAVEL_MAP    = LoadTable( "travel_map.ini" );
T_CHAPTER_OPEN_CHECK    = LoadTable( "chapter_open_check.ini" );
T_STAGE_OPEN_CHECK      = LoadTable( "stage_open_check.ini" );
T_TRAVEL_DUNGEON_INFO   = LoadTable( "travel_dungeon_info.ini" );

--道具表
T_ITEM          = LoadTable( "item.ini" );
--金币表
T_MONEY			= LoadTable( "money.ini" );
--卡牌详细表
T_CHAR_RES      = LoadTable( "char_res.ini" );
--任务信息表
T_MISSION		= LoadTable( "mission.ini" );
T_MISSION_REWARD = LoadTable( "mission_reward.ini")
T_MISSION_RES	= LoadTable("mission_res.ini")
--任务章节表
T_STAGE			= LoadTable( "Stage.ini" );

--卡牌强化所需的金币以经验表
T_CARD_GROW     = LoadTable( "card_grow.ini" );

--卡牌
T_CARD     = LoadTable( "card.ini" );

--卡牌等级表
T_CARD_LEVEL   = LoadTable( "card_level.ini" );

--卡牌等级表
T_CARD_LEVEL_LIMIT   = LoadTable( "card_level_limit.ini" );

--配置表【包括：进化所需金钱..】
T_CONFIG     = LoadTable( "config.ini" );

--技能表
T_SKILL     = LoadTable( "skill.ini" );

--技能资源
T_SKILL_RES		= 	LoadTable( "skill_res.ini" );
--装备表
T_EQUIP			=  	LoadTable( "equip.ini" );
--装备成长表
T_EQUIPMENT_GROW	=LoadTable( "equipment_grow.ini" );

--gacha表
T_GACHA    =LoadTable( "gacha.ini" );

-- 技能成长表
T_SKILL_GROW = LoadTable( "skill_grow.ini" );

-- 消息提示表
T_EVENT_MESSAGE = LoadTable( "event_message.ini" );

-- 玩家成长表
T_PLAYER_GROW = LoadTable( "player_grow.ini" );

-- 商城商品表
T_SHOP        = LoadTable( "shop.ini");

-- 礼物表
T_GIFT        = LoadTable( "gift.ini");

--剧情
T_STORY_INFO  = LoadTable( "story_info.ini");

--新手引导
T_ROOKIE_GUIDE  = LoadTable( "rookie_guide_conf.ini");

--召唤兽表
T_PET			= LoadTable( "Pet.ini" );

--召唤兽升级表
T_PET_LEVEL		= LoadTable( "Pet_Level.ini" );

--召唤兽资源表
T_PET_RES		= LoadTable( "Pet_res.ini" );

--技能资源表
T_SKILL_RES       = LoadTable( "skill_res.ini" );

--装备等级表
T_EQUIP_LEVEL	= LoadTable("equip_level.ini");

--玩家等级配置表
T_PLAYER_LEVEL	= LoadTable("player_level.ini");

--技能音效
T_SKILL_SOUND  = LoadTable("skill_sound.ini");

--卡牌普通攻击音效
T_CARD_ATK_SOUND  = LoadTable("card_atk_sound.ini");

--村庄
T_BUILDING		= LoadTable("building.ini");

--采集掉落数据
T_MATERIAL_DROP	= LoadTable("material_drop.ini");

--材料表
T_MATERIAL		= LoadTable("material.ini");

T_MATERIAL_RES  = LoadTable("material_res.ini");

--合成表
T_DRUG_MIX		= LoadTable("drug_mix.ini");

--掉落机率表
T_DROP_POBILITY = LoadTable("battle_drop_pobility.ini");

--掉落数据表
T_DROP_VAL		= LoadTable("battle_drop_value.ini");

--任务掉落物品
--T_MONSTER_DROP	= LoadTable("monster_drop.ini");

--BUFF表
T_BUFF			= LoadTable("buff.ini");
