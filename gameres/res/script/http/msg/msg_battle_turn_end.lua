--------------------------------------------------------------
-- FileName: 	msg_battle_turn_end.lua
-- author:		zhangwq, 2013/08/22
-- purpose:		ս�����غϽ���
-- ������±��غ�fighter�ļ���CD��buf��status��ŭ��ֵ��
--------------------------------------------------------------

msg_battle_turn_end = msg_base:new();
local p = msg_battle_turn_end;
local super = msg_base;


--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_BATTLE_TURN_END; --��Ϣ��

	if false then
		self.event = {};
		self.event[0] = {};
		local event = self.event[0];
		
		event.id_fighter = nil;		--�¼���ص�fighter����ѡ��	
		--event.id_skill = nil;		--����id����ѡ��
		--event.id_status = nil;		--״̬id����ѡ��
		--event.turn_amount = 0;		--ʣ��غϸ�������ʾ����CD���м����غϣ�����״̬buf���м����غϣ�
		
		--����cd����
		--buf����
		--״̬����
		--ŭ��ֵ
	end
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_battle_turn_end:Process() called" );
	card_battle_mgr.ReceiveBattle_TurnStage_EndRes(self);
end