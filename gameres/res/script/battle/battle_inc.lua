--------------------------------------------------------------
-- FileName: 	battle_inc.lua
-- author:		zhangwq, 2013/05/18
-- purpose:		ս����������
--------------------------------------------------------------

--��Ӫ
E_CARD_CAMP_HERO  = 1;
E_CARD_CAMP_ENEMY = 2;


--ս��Ԫ��Tag
E_BATTLE_TAG_GROUND			= 1;	--����
E_BATTLE_TAG_GROUND_FX		= 2;	--������Ч
E_BATTLE_TAG_HERO_FIGHTER	= 3;	--hero
E_BATTLE_TAG_ENEMY_FIGHTER	= 4;	--enemy
E_BATTLE_TAG_BOSS_FIGHTER	= 5;	--boss
E_BATTLE_TAG_BULLET			= 6;	--�ӵ�


--ս��Ԫ��Z��
E_BATTLE_Z_GROUND			= -20;	--ս������
E_BATTLE_Z_GROUND_FX		= -10;	--ս��������Ч
E_BATTLE_Z_NORMAL			= 0;	--��ͨ
E_BATTLE_Z_ENEMY_FIGHTER	= 10;	--Enemyսʿ
E_BATTLE_Z_BULLET			= 20;	--�ӵ�
E_BATTLE_Z_HERO_FIGHTER		= 30;	--Heroսʿ
E_BATTLE_Z_BLACK_MASK		= 70;	--�Ŵ��е��ڵ�
E_BATTLE_Z_ULT_SKILL_FIGHTER = 100;  --�Ŵ��е�ʱ��սʿ

--ս���׶�
E_BATTLE_STAGE_NONE             = 0;
E_BATTLE_STAGE_LOADING          = 1;    --���ؽ׶�
E_BATTLE_STAGE_INIT             = 2;    --���ֽ׶�
E_BATTLE_STAGE_TURN             = 3;    --�غϽ׶�
E_BATTLE_STAGE_END              = 4;    --�����׶�

--�غϽ׶�
E_BATTLE_TURN_STAGE_NONE    = 0;
E_BATTLE_TURN_STAGE_HERO    = 1;    --Ӣ�ۻغ�  ���ϰ볡
E_BATTLE_TURN_STAGE_ENEMY   = 2;    --�ط��׶�  ���°볡
E_BATTLE_TURN_STAGE_END     = 3;    --�غϽ���

--�غ��ӽ׶�
E_BATTLE_TURN_SUBSTAGE_NONE     = 0;    
E_BATTLE_TURN_SUBSTAGE_DOT      = 1;
E_BATTLE_TURN_SUBSTAGE_SKILL    = 2;
E_BATTLE_TURN_SUBSTAGE_ATK      = 3;

--��ɫ����
E_LOOKAT_RIGHT				= 0;	
E_LOOKAT_LEFT				= 1;

--demo�汾
E_DEMO_VER = 5;

--��ɫ��������
MELEE_ATTACK = 1	--��ս������
RANGED_ATTACK = 2	--Զ��������
MAGIC_ATTACK = 3	--ħ������

--���ν׶α�ʶ
E_BATCH_STAGE_BEGIN			= 1;
E_BATCH_STAGE_ATK_BEGIN		= 2;
E_BATCH_STAGE_ATK_END		= 3;
E_BATCH_STAGE_HURT_BEGIN	= 4;
E_BATCH_STAGE_HURT_END		= 5;
E_BATCH_STAGE_END			= 6;
