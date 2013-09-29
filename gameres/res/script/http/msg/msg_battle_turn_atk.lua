--------------------------------------------------------------
-- FileName: 	msg_battle_turn_atk.lua
-- author:		zhangwq, 2013/08/22
-- purpose:		ս������Ӧ�غ���ͨ�����׶�
--------------------------------------------------------------

msg_battle_turn_atk = msg_base:new();
local p = msg_battle_turn_atk;
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
    self.idMsg = MSG_BATTLE_TURN_ATK; --��Ϣ��
	self.event = {};	

	if true then
	    self.event = {};
	    
		self.event[1] = {};
		local event = self.event[1];
		
		event.id_atk = 101;			--�����ߣ���ѡ��
		event.id_target = 201;		--�ܻ��ߣ���ѡ��
		
		event.life_change = nil;	--Ѫ���仯����ѡ��������0��Ѫ��С��0��Ѫ
		event.status_change = nil;	--״̬�仯����ѡ��������0��id��ʾ��״̬��С��0��id��ʾȥ��״̬
		
		event.is_dodge = nil;		--�Ƿ����ܣ���ѡ��
		event.is_critical = nil;	--�Ƿ񱩻�����ѡ��
		event.is_block = nil;		--�Ƿ�񵲣���ѡ��
		event.is_dead = nil;		--�Ƿ���Ŀ����������ѡ��	
		event.is_target_fight_back = nil; --Ŀ���Ƿ񷴻��ˣ���ѡ��
		
		self.event[2] = {};
        local event = self.event[2];
        
        event.id_atk = 102;         --�����ߣ���ѡ��
        event.id_target = 202;      --�ܻ��ߣ���ѡ��
        
        event.life_change = nil;    --Ѫ���仯����ѡ��������0��Ѫ��С��0��Ѫ
        event.status_change = nil;  --״̬�仯����ѡ��������0��id��ʾ��״̬��С��0��id��ʾȥ��״̬
        
        event.is_dodge = nil;       --�Ƿ����ܣ���ѡ��
        event.is_critical = nil;    --�Ƿ񱩻�����ѡ��
        event.is_block = nil;       --�Ƿ�񵲣���ѡ��
        event.is_dead = nil;        --�Ƿ���Ŀ����������ѡ��  
        event.is_target_fight_back = nil; --Ŀ���Ƿ񷴻��ˣ���ѡ��
        
        self.event[3] = {};
        local event = self.event[3];
        
        event.id_atk = 103;         --�����ߣ���ѡ��
        event.id_target = 203;      --�ܻ��ߣ���ѡ��
        
        event.life_change = nil;    --Ѫ���仯����ѡ��������0��Ѫ��С��0��Ѫ
        event.status_change = nil;  --״̬�仯����ѡ��������0��id��ʾ��״̬��С��0��id��ʾȥ��״̬
        
        event.is_dodge = nil;       --�Ƿ����ܣ���ѡ��
        event.is_critical = nil;    --�Ƿ񱩻�����ѡ��
        event.is_block = nil;       --�Ƿ�񵲣���ѡ��
        event.is_dead = nil;        --�Ƿ���Ŀ����������ѡ��  
        event.is_target_fight_back = nil; --Ŀ���Ƿ񷴻��ˣ���ѡ��
        
        self.event[4] = {};
        local event = self.event[4];
        
        event.id_atk = 104;         --�����ߣ���ѡ��
        event.id_target = 204;      --�ܻ��ߣ���ѡ��
        
        event.life_change = nil;    --Ѫ���仯����ѡ��������0��Ѫ��С��0��Ѫ
        event.status_change = nil;  --״̬�仯����ѡ��������0��id��ʾ��״̬��С��0��id��ʾȥ��״̬
        
        event.is_dodge = nil;       --�Ƿ����ܣ���ѡ��
        event.is_critical = nil;    --�Ƿ񱩻�����ѡ��
        event.is_block = nil;       --�Ƿ�񵲣���ѡ��
        event.is_dead = nil;        --�Ƿ���Ŀ����������ѡ��  
        event.is_target_fight_back = nil; --Ŀ���Ƿ񷴻��ˣ���ѡ��
        
        self.event[5] = {};
        local event = self.event[5];
        
        event.id_atk = 105;         --�����ߣ���ѡ��
        event.id_target = 205;      --�ܻ��ߣ���ѡ��
        
        event.life_change = nil;    --Ѫ���仯����ѡ��������0��Ѫ��С��0��Ѫ
        event.status_change = nil;  --״̬�仯����ѡ��������0��id��ʾ��״̬��С��0��id��ʾȥ��״̬
        
        event.is_dodge = nil;       --�Ƿ����ܣ���ѡ��
        event.is_critical = nil;    --�Ƿ񱩻�����ѡ��
        event.is_block = nil;       --�Ƿ�񵲣���ѡ��
        event.is_dead = nil;        --�Ƿ���Ŀ����������ѡ��  
        event.is_target_fight_back = nil; --Ŀ���Ƿ񷴻��ˣ���ѡ��
        
	end
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_battle_turn_atk:Process() called" );
	card_battle_mgr.ReceiveBattle_SubTurnStage_AtkRes( self );
end
