--------------------------------------------------------------
-- FileName: 	msg_travel_explore.lua
-- author:		xyd, 2013/07/19
-- purpose:		�����ͼ̽��
--------------------------------------------------------------

msg_travel_explore = msg_base:new();
local p = msg_travel_explore;
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
    self.idMsg = MSG_TRAVEL_EXPLORE; --��Ϣ��
end

--��ʼ��
function p:Init()
	
end

--������Ϣ
function p:Process()
	msg_cache.msg_travel_explore = self;
	WriteConWarning( "** msg_travel_explore:Process() called" );	
	task_map.ExploreRefresh(self);
end
