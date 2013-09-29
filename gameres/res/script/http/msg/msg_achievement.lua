--------------------------------------------------------------
-- FileName: 	msg_achievement.lua
-- author:		Zjj, 2013/07/09
-- purpose:		�ɾ���Ϣ
--------------------------------------------------------------

msg_achievement = msg_base:new();
local p = msg_achievement;
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
    self.idMsg = MSG_PLAYER; --��Ϣ��
	self.user_id = 0;
	self.user_name = "1111111";
	self.sex = 1;
	self.level = 0;
	self.exp = 0;
	self.mission_point = 0;
	self.mission_point_max = 0;
	self.arena_point = 0;
	self.arena_point_max = 0;
	self.chapter_id = 0;	
	self.stage_id = 0;
	self.travel_id = 0;
	self.position_x = 0;
	self.position_y = 0;
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_achievement = self;
	WriteConWarning( "** msg_achievement:Process() called" );
end
