--------------------------------------------------------------
-- FileName: 	msg_battle_turn_dot.lua
-- author:		zhangwq, 2013/08/14
-- purpose:		ս������Ӧ�غϵ�DOT�׶�
-- �ڻغϿ�ʼʱ������״̬������˺���
--------------------------------------------------------------

msg_battle_turn_dot = msg_base:new();
local p = msg_battle_turn_dot;
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
    self.idMsg = MSG_BATTLE_TURN_DOT; --��Ϣ��
	self.event = {};	

	if false then
		self.event[0] = {};
		local event = self.event[0];
		
		event.id_fighter = 101;		--�¼���ص�fighter����ѡ��	
		event.id_status = nil;		--״̬id����ѡ��
		
		event.life_change = 100;	--Ѫ���仯����ѡ��������0��Ѫ��С��0��Ѫ
		event.mana_change = nil;	--ħ���仯����ѡ��������0��ħ��С��0��ħ
		event.is_dead = false;		--�Ƿ���Ŀ����������ѡ��
		
		self.event[1] = {};
        local event2 = self.event[1];
        event2.id_fighter = 105; 
        event2.id_status = nil;
        event2.life_change = 80;
        event2.mana_change = nil;
        event2.is_dead = false;
	end
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_battle_turn:Process() called" );
	card_battle_mgr.ReceiveBattle_SubTurnStage_Dot( self );
end
