--------------------------------------------------------------
-- FileName: 	load_db.lua
-- author:		zhangwq, 2013/05/25
-- purpose:		�������ݿ�
--------------------------------------------------------------

T_TEST          = LoadTable( "test.ini" );

--��ͼ��
T_CHAPTER_MAP   = LoadTable( "chapter_map.ini" );
T_STAGE_MAP     = LoadTable( "stage_map.ini" );
T_TRAVEL_MAP    = LoadTable( "travel_map.ini" );
T_CHAPTER_OPEN_CHECK    = LoadTable( "chapter_open_check.ini" );
T_STAGE_OPEN_CHECK      = LoadTable( "stage_open_check.ini" );
T_TRAVEL_DUNGEON_INFO   = LoadTable( "travel_dungeon_info.ini" );

--���߱�
T_ITEM          = LoadTable( "item.ini" );
--������ϸ��
T_CHAR_RES      = LoadTable( "char_res.ini" );
--������Ϣ��
T_MISSION		= LoadTable( "mission.ini" );

--�����½ڱ�
T_STAGE			= LoadTable( "Stage.ini" );

--����ǿ������Ľ���Ծ����
T_CARD_GROW     = LoadTable( "card_grow.ini" );

--����
T_CARD     = LoadTable( "card.ini" );

--���Ƶȼ���
T_CARD_LEVEL   = LoadTable( "card_level.ini" );

--���ñ����������������Ǯ..��
T_CONFIG     = LoadTable( "config.ini" );

--���ܱ�
T_SKILL     = LoadTable( "skill.ini" );

--װ���ɳ���
T_EQUIPMENT_GROW	=LoadTable( "equipment_grow.ini" );

--gacha��
T_GACHA    =LoadTable( "gacha.ini" );

-- ���ܳɳ���
T_SKILL_GROW = LoadTable( "skill_grow.ini" );

-- ��Ϣ��ʾ��
T_EVENT_MESSAGE = LoadTable( "event_message.ini" );

-- ��ҳɳ���
T_PLAYER_GROW = LoadTable( "player_grow.ini" );

-- �̳���Ʒ��
T_SHOP        = LoadTable( "shop.ini");

-- �����
T_GIFT        = LoadTable( "gift.ini");

--����
T_STORY_INFO  = LoadTable( "story_info.ini");

--�ٻ��ޱ�
T_PET			= LoadTable( "Pet.ini" );

--�ٻ���������
T_PET_LEVEL		= LoadTable( "Pet_Level.ini" );

--�ٻ�����Դ��
T_PET_RES		= LoadTable( "Pet_res.ini" );