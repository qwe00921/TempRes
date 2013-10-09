--------------------------------------------------------------
-- FileName: 	task_map_inc.lua
-- author:		zhangwq, 2013/08/08
-- purpose:		�����ͼ��������
--------------------------------------------------------------

-----------------------------------------------
--��ӦC++������������
E_TILE_OBJ_BG		= 2;--����ͼƬ
E_TILE_OBJ_PATH		= 4;--·����
E_TILE_OBJ_PORTAL	= 8;--���͵�
E_TILE_OBJ_PLAYER	= 16;--����Լ�
E_TILE_OBJ_DYNAMIC	= 32;--��̬���

--Lua�Զ������ͣ������ݴη�����
E_TILE_OBJ_BOX		    = 64;--����
E_TILE_OBJ_CARD		    = 128;--��Ƭ

E_TILE_OBJ_MONSTER	    = 256;--����
E_TILE_OBJ_BOSS		    = 512;--BOSS
E_TILE_OBJ_FINAL_BOSS   = 1024;--����BOSS

E_TILE_OBJ_PORTER	    = 2048;--���͵�
E_TILE_OBJ_NEXTMAP	    = 4096;--��һ��ͼ

E_TILE_OBJ_CHAPTER	    = 8192;--�����ͼ���½�
E_TILE_OBJ_BEGINPOINT   = 16384;

-----------------------------------------------
--�������·�����Ʒ����
E_RULES_TYPE_GENERAL            = 1;--��ͨ����
E_RULES_TYPE_CARD               = 2;--��Ƭ
E_RULES_TYPE_MAGIC_CIRCLE       = 3;--ħ��������
E_RULES_TYPE_BOX	            = 4;--��ͨ����
E_RULES_TYPE_SILVER_BOX         = 5;--��������
E_RULES_TYPE_GOLD_BOX           = 6;--�ƽ���
E_RULES_TYPE_ITEM               = 7;--������߱���
E_RULES_TYPE_MONSTER            = 8;--����
E_RULES_TYPE_ACTION_POINT       = 9;--����ֵ�ָ���
E_RULES_TYPE_COMBAT_POINT       = 10;--ս��ֵ�ָ���
E_RULES_TYPE_HP                 = 11;--����֮Ȫ
E_RULES_TYPE_NEXTMAP            = 12;--�յ�(��ͨ��̬)
E_RULES_TYPE_FINAL_BOSS         = 13;--����BOSS��̬
E_RULES_TYPE_BOSS	            = 14;--��;BOSS��̬
E_RULES_TYPE_NPC                = 15;--����NPC
E_RULES_TYPE_BEGIN_POINT        = 99;--��ʼ��
-----------------------------------------------

--��ͼԪ��Ani��������
MAP_ELEM_CARD                       = 0;
MAP_ELEM_BOX                        = 1;
MAP_ELEM_MONSTER                    = 2;
MAP_ELEM_NEXT_MAP                   = 3;
MAP_ELEM_BOSS                       = 4;
MAP_ELEM_FINAL_BOSS                 = 5;
MAP_ELEM_BEGIN_POINT                = 6;

------------------------------------------------
ENTER_MAP_TASK      = 1;--���������ͼ
ENTER_MAP_DUNGEON   = 2;--���븱����ͼ
