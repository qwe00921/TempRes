--------------------------------------------------------------
-- FileName:    msg_mission_roll.lua
-- author:      hst, 2013/07/10
-- purpose:     ��������
--------------------------------------------------------------

msg_mission_roll = msg_base:new();
local p = msg_mission_roll;
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
    self.idMsg = MSG_MISSION_ROLL; --��Ϣ��
    
    self.roll_num = nil;
    self.mission_point = nil;
    self.mission_point_max = nil;
    self.recover_mission_point = nil;
    self.recover_full_time = nil;
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
    WriteConWarning( "** msg_mission_roll:Process() called" );
    task_map.RefreshUI(self);
end
