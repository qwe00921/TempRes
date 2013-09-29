--------------------------------------------------------------
-- FileName: 	msg_battle_turn_skill.lua
-- author:		zhangwq, 2013/08/22
-- purpose:		ս������Ӧ���ܽ׶�
-- 				������Ҽ��ܡ����Ƽ���
--------------------------------------------------------------

msg_battle_turn_skill = msg_base:new();
local p = msg_battle_turn_skill;
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
    self.idMsg = MSG_BATTLE_USER_SKILL; --��Ϣ��
	self.id_skill = 0;

	
	if true then
	    self.event = {};
	   
		self.event[1] = {};
		local event = self.event[1];
		
		event.id_atk = 105;			--�����ߣ���ѡ��
		event.id_target = 202;		--�ܻ��ߣ���ѡ��
		event.id_skill = nil;		--����id����ѡ��
		
		event.life_change = -80;	--Ѫ���仯����ѡ��������0��Ѫ��С��0��Ѫ
		event.status_change = nil;	--״̬�仯����ѡ��������0��id��ʾ��״̬��С��0��id��ʾȥ��״̬
		
		event.is_dodge = false;		--�Ƿ����ܣ���ѡ��
		event.is_critical = false;	--�Ƿ񱩻�����ѡ��
		event.is_block = false;		--�Ƿ�񵲣���ѡ��
		event.is_dead = false;		--�Ƿ���Ŀ����������ѡ��
		
		self.event[2] = {};
        local event = self.event[2];
        
        event.id_atk = 105;         
        event.id_target = 203;     
        event.id_skill = nil;       
        
        event.life_change = -80;    
        event.status_change = nil;  
        
        event.is_dodge = false;     
        event.is_critical = false;  
        event.is_block = false;     
        event.is_dead = false;        	
	end	
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_battle_turn_skill:Process() called" );
	card_battle_mgr.ReceiveBattle_Hero_SkillRes(self);
end
