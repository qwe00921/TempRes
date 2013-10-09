--------------------------------------------------------------
-- FileName: 	card_battle_inc.lua
-- author:		zhangwq, 2013/08/14
-- purpose:		����ս������������
--------------------------------------------------------------


--�غ���ս��������ص�effect type
BATTLE_EFFECT_TYPE_NONE				= 0;

BATTLE_EFFECT_TYPE_ATK				= 1; -- ����/����
BATTLE_EFFECT_TYPE_SKILL			= 2; -- ����(ʩ����)����Ч��
BATTLE_EFFECT_TYPE_SKILL_TARGET		= 3; -- ����(������)����Ч��
BATTLE_EFFECT_TYPE_LIFE				= 4;			-- ����
BATTLE_EFFECT_TYPE_MANA				= 5;			-- ����
BATTLE_EFFECT_TYPE_DODGE			= 6;			-- ����
BATTLE_EFFECT_TYPE_DRITICAL			= 7;		-- ����
BATTLE_EFFECT_TYPE_BLOCK			= 8;			-- ��
BATTLE_EFFECT_TYPE_COMBO			= 9;			-- ����
BATTLE_EFFECT_TYPE_STATUS_ADD		= 10;		-- ��״̬
BATTLE_EFFECT_TYPE_STATUS_LOST		= 11;		-- ȡ��״̬
BATTLE_EFFECT_TYPE_STATUS_LIFE		= 12;		-- ״̬ȥѪ
BATTLE_EFFECT_TYPE_DEAD				= 13;

EFFECT_TYPE_TURN_END				= 14;				-- �غϽ���
EFFECT_TYPE_BATTLE_BEGIN			= 15;			-- ս����ʼ
EFFECT_TYPE_BATTLE_END				= 16;				-- ս������

BATTLE_EFFECT_TYPE_CTRL				= 17;			--�ܿ�--�ݲ�����
BATTLE_EFFECT_TYPE_ESCORTING		= 18;		--����----��ʾ������Ч����
BATTLE_EFFECT_TYPE_COOPRATION_HIT	= 19;	--�ϻ�----��ʾ������Ч����
BATTLE_EFFECT_TYPE_CHANGE_POSTION	= 20;	--��λ--�о��ƶ������==

BATTLE_EFFECT_TYPE_SKILL_EFFECT_TARGET	= 21;	-- ���ܸ���Ч��Ŀ��
BATTLE_EFFECT_TYPE_SKILL_EFFECT		= 22;		-- ���ܸ���Ч��
BATTLE_EFFECT_TYPE_STATUS_MANA 		= 23;			-- ״̬ȥ��
BATTLE_EFFECT_TYPE_RESIST			= 24;				-- ����

--BUFFЧ������
BATTLE_BUFF_EFFECT      = 1;--����״̬
BATTLE_DEBUFF_EFFECT    = 2;--����״̬

BATTLE_BUFF_TYPE_LIFE           = 1; --����
BATTLE_BUFF_TYPE_DEF            = 2; --����      
BATTLE_BUFF_TYPE_ATK            = 3; --���� 
BATTLE_BUFF_TYPE_MAX_LIFE       = 4; --��������
BATTLE_BUFF_TYPE_SKILL_CD       = 5; --������ȴ��
BATTLE_BUFF_TYPE_DAMAGE         = 6; --�˺���ֵ
BATTLE_BUFF_TYPE_SHIELD         = 7; --��������
BATTLE_BUFF_TYPE_DODGE          = 8; --������
BATTLE_BUFF_TYPE_DRITICAL       = 9; --����
BATTLE_BUFF_TYPE_COUNTER_ATK    = 10;--����
BATTLE_BUFF_TYPE_COMBO          = 11;--����
BATTLE_BUFF_TYPE_SUCK_LIFE      = 12;--��Ѫ
BATTLE_BUFF_TYPE_DRITICAL       = 13;--�Ա�
