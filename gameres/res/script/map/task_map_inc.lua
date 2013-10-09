--------------------------------------------------------------
-- FileName: 	task_map_inc.lua
-- author:		zhangwq, 2013/08/08
-- purpose:		任务地图常量定义
--------------------------------------------------------------

-----------------------------------------------
--对应C++定义的物件类型
E_TILE_OBJ_BG		= 2;--背景图片
E_TILE_OBJ_PATH		= 4;--路径点
E_TILE_OBJ_PORTAL	= 8;--传送点
E_TILE_OBJ_PLAYER	= 16;--玩家自己
E_TILE_OBJ_DYNAMIC	= 32;--动态物件

--Lua自定义类型（符合幂次方规则）
E_TILE_OBJ_BOX		    = 64;--箱子
E_TILE_OBJ_CARD		    = 128;--卡片

E_TILE_OBJ_MONSTER	    = 256;--怪物
E_TILE_OBJ_BOSS		    = 512;--BOSS
E_TILE_OBJ_FINAL_BOSS   = 1024;--最终BOSS

E_TILE_OBJ_PORTER	    = 2048;--传送点
E_TILE_OBJ_NEXTMAP	    = 4096;--下一张图

E_TILE_OBJ_CHAPTER	    = 8192;--世界地图的章节
E_TILE_OBJ_BEGINPOINT   = 16384;

-----------------------------------------------
--服务器下发的物品类型
E_RULES_TYPE_GENERAL            = 1;--普通格子
E_RULES_TYPE_CARD               = 2;--卡片
E_RULES_TYPE_MAGIC_CIRCLE       = 3;--魔法传送阵
E_RULES_TYPE_BOX	            = 4;--普通宝箱
E_RULES_TYPE_SILVER_BOX         = 5;--白银宝箱
E_RULES_TYPE_GOLD_BOX           = 6;--黄金宝箱
E_RULES_TYPE_ITEM               = 7;--任务道具宝箱
E_RULES_TYPE_MONSTER            = 8;--怪物
E_RULES_TYPE_ACTION_POINT       = 9;--体力值恢复点
E_RULES_TYPE_COMBAT_POINT       = 10;--战斗值恢复点
E_RULES_TYPE_HP                 = 11;--生命之泉
E_RULES_TYPE_NEXTMAP            = 12;--终点(普通形态)
E_RULES_TYPE_FINAL_BOSS         = 13;--最终BOSS形态
E_RULES_TYPE_BOSS	            = 14;--中途BOSS形态
E_RULES_TYPE_NPC                = 15;--任务NPC
E_RULES_TYPE_BEGIN_POINT        = 99;--起始点
-----------------------------------------------

--地图元素Ani配置索引
MAP_ELEM_CARD                       = 0;
MAP_ELEM_BOX                        = 1;
MAP_ELEM_MONSTER                    = 2;
MAP_ELEM_NEXT_MAP                   = 3;
MAP_ELEM_BOSS                       = 4;
MAP_ELEM_FINAL_BOSS                 = 5;
MAP_ELEM_BEGIN_POINT                = 6;

------------------------------------------------
ENTER_MAP_TASK      = 1;--进入任务地图
ENTER_MAP_DUNGEON   = 2;--进入副本地图
