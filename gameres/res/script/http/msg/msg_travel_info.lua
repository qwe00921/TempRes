--------------------------------------------------------------
-- FileName: 	msg_travel_info.lua
-- author:		xyd, 2013/07/19
-- purpose:		���е�ͼ��Ϣ�嵥
--------------------------------------------------------------

msg_travel_info = msg_base:new();
local p = msg_travel_info;
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
    self.idMsg = MSG_TRAVEL_INFO; --��Ϣ��
	self.mission_info={};
	self.ErrorMsg = "";
end

--��ʼ��
function p:Init()
	
end

--������Ϣ
function p:Process()
	msg_cache.msg_travel_info = self;
	WriteConWarning( "** msg_travel_info:Process() called" );
	task_map.RefreshUI(self);
end
