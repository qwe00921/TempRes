--------------------------------------------------------------
-- FileName: 	msg_travel_battle.lua
-- author:		hst, 2013/07/10
-- purpose:		���е�ͼ��BOSS
--------------------------------------------------------------

msg_travel_battle = msg_base:new();
local p = msg_travel_battle;
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
    self.idMsg = MSG_TRAVEL_BATTLE; --��Ϣ��
    
    --[[
    self.refresh_map = nil;��һ�ŵ�ͼ��ʶ
    self.stage_clear = nil;ͨ�ر�ʶ
    --]]
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_travel_battle:Process() called" );
	--dump_obj(self.user_cards);
	task_map.BattleRefresh(self)
end
