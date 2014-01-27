--------------------------------------------------------------
-- FileName:    w_battle_inc.lua
-- author:      hst, 2013/11/26
-- purpose:     ս����������
--------------------------------------------------------------
W_BATTLE_PVP = 1;
W_BATTLE_PVE = 2;

--��ս���Ϊ10���غ�
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

W_BATTLE_CAMP_CARD_NUM = 6;--��Ӫ�еĿ�����������

MIN_RAGE_NUM = 0;--����ŭ��ֵ
MAX_RAGE_NUM = 100;--����ŭ��ֵ

--��ս�׶�
W_BATTLE_STAGE_LOADING = 1;--ս������
W_BATTLE_STAGE_PERMANENT_BUFF = 2;--����BUFF�׶�
W_BATTLE_STAGE_ROUND = 3;--�غϽ׶�
W_BATTLE_STAGE_END = 4;--�����׶�

W_BATTLE_ROUND_STAGE_PET = 1;--�ٻ��� 
W_BATTLE_ROUND_STAGE_BUFF = 2;--BUFF����
W_BATTLE_ROUND_STAGE_ATK = 3;--��Ź
W_BATTLE_ROUND_STAGE_CLEARING = 4;--����

--buff
W_BUFF_TYPE_0 = 0;--ûBUFF
W_BUFF_TYPE_1 = 1;--��ѣ
W_BUFF_TYPE_2 = 2;--����
W_BUFF_TYPE_3 = 3;--����
W_BUFF_TYPE_4 = 4;--���
W_BUFF_TYPE_5 = 5;--ʯ��
W_BUFF_TYPE_6 = 6;--�ж� Hp��ֵx%
W_BUFF_TYPE_7 = 7;--ȼ�� Hp��ֵx%
W_BUFF_TYPE_8 = 8;--����
W_BUFF_TYPE_9 = 9;--�ָ� Hp��ֵx%

W_BUFF_TYPE_101 = 101;--������ǿ
W_BUFF_TYPE_102 = 102;--������ǿ
W_BUFF_TYPE_103 = 103;--������ǿ

W_BUFF_TYPE_201 = 201;--��������
W_BUFF_TYPE_202 = 202;--��������
W_BUFF_TYPE_203 = 203;--��������

W_BUFF_TYPE_301 = 301;--����

--����BUFF�����ֵ
W_BUFF_ATKMIN   = 0
W_BUFF_DEFMIN   = 0
W_BUFF_CRITMIN  = 0.001   

--skill type
W_SKILL_TYPE_1 = 1;--�����˺�����
W_SKILL_TYPE_2 = 2;--�����ָ�����
W_SKILL_TYPE_3 = 3;--���Լӳɼ���
W_SKILL_TYPE_4 = 4;--����������
W_SKILL_TYPE_5 = 5;--���������

--���ܹ���Ŀ��
W_SKILL_TARGET_TYPE_1 = 1;--�з�����
W_SKILL_TARGET_TYPE_2 = 2;--�з�Ⱥ�壺Զ�̹���λ�ã��м�
W_SKILL_TARGET_TYPE_3 = 3;--�з�ֱ�ߣ�
W_SKILL_TARGET_TYPE_4 = 4;--�з�����: Զ�̹���λ�ã��м�
W_SKILL_TARGET_TYPE_5 = 5;--�з���Խ

W_SKILL_TARGET_TYPE_11 = 11;--�Լ�
W_SKILL_TARGET_TYPE_12 = 12;--����Ⱥ��
W_SKILL_TARGET_TYPE_13 = 13;--�������һ����������λ

W_BATTLE_DISTANCE_NoArcher = 1;--��ս����
W_BATTLE_DISTANCE_Archer = 2;--Զ�̹���


W_BATTLE_BULLET_0 = 0;--�޵���
W_BATTLE_BULLET_1 = 1;--�е���

W_BATTLE_HERO = 0;  --��ҷ�Ӣ��
W_BATTLE_ENEMY = 1; --���﷽����
--����
--[[
W_BATTLE_PROP_ICE = 0;  --��
W_BATTLE_PROP_FIRE = 1;  --��
W_BATTLE_PROP_WIND = 2;  --��
W_BATTLE_PROP_WOOD = 3;  --��
]]--

--�޽�ľˮ����
W_BATTLE_ELEMENT_NULL  = 0;
W_BATTLE_ELEMENT_GOLD  = 1;
W_BATTLE_ELEMENT_WOOD  = 2;
W_BATTLE_ELEMENT_WATER = 3;
W_BATTLE_ELEMENT_FIRE  = 4;
W_BATTLE_ELEMENT_EARTH = 5;

W_BATTLE_ELEMENT_LIGHT = 6; --��
W_BATTLE_ELEMENT_DARK  = 7; --��


--�ϻ�ʱ��ļ��
W_BATTLE_JOINATK_TIME = 1; 

--վλ����
W_BATTLE_POS_TAG_1 = 1;
W_BATTLE_POS_TAG_2 = 2;
W_BATTLE_POS_TAG_3 = 3;
W_BATTLE_POS_TAG_4 = 4;
W_BATTLE_POS_TAG_5 = 5;
W_BATTLE_POS_TAG_6 = 6;

--��������ʱ��
W_BATTLE_ATKTIME   =  0.5;
--�����ӳ�ʱ�乥��
W_BATTLE_ENEMYTIME = 0.7;

--�ж�״̬
W_BATTLE_NOT_TURN = 0;  --δ�ж�
W_BATTLE_TURN     = 1;  --�ж��� 
W_BATTLE_TURNEND  = 2;  --���ж�

--����
W_DROP_ATKTYPE1  = 1;  --�չ�
W_DROP_ATKTYPE2  = 2;  --����
W_DROP_ATKTYPE3  = 3;  --����
W_DROP_ATKTYPE4  = 4;  --�ϻ�
W_DROP_ATKTYPE5  = 5;  --����


--ս����Ʒʹ��
W_MATERIAL_TYPE1 = 1;   --ҩˮ����
W_MATERIAL_TYPE2 = 2;   --��������

--ҩˮ����
W_MATERIAL_SUBTYPE1 = 1; --�ָ���
W_MATERIAL_SUBTYPE2 = 2; --��״̬��
W_MATERIAL_SUBTYPE3 = 3; --������

--��ƷĿ��
W_MATERIAL_TARGET1  = 1;  --����Ŀ��
W_MATERIAL_TARGET2  = 2;  --ȫ��Ŀ��

W_BATTLE_REVIVAL     = 9999; --����״̬
W_BATTLE_DELAYTIME   = 0.5;  --���0.5�����

W_SHOWBUFF_STATE     = 3;  --BUFF״̬������ʾ��ʱ��
--ƽ̨�ж�
W_PLATFORM_WIN32     = 1
W_PLATFORM_IOS       = 2

--ս�����õ�������
W_BATTLE_JUMPSTAR = 220 * 2;     --�����������ƫ��
W_BATTLE_DAMAGE_OFFSETY = 60 --��Ѫ���ֵ���ʼƫ��
W_BATTLE_DROP_H = 16;  --ս���е�����Ʒ��ͼƬ�Ŀ����һ����
W_BATTLE_PASSBG_INIT = 740;  --���������Ľ�������ƫ��ֵ