--------------------------------------------------------------
-- FileName: 	msg_travel_item.lua
-- author:		xyd, 2013/07/19
-- purpose:		���е�ͼ��Ϣ��ϸ
--------------------------------------------------------------

msg_travel_item = msg_base:new();
local p = msg_travel_item;
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
    self.idMsg = MSG_TRAVEL_ITEM; --��Ϣ��
	self.mission_rules = {};
	self.ErrorMsg = "";
end

--��ʼ��
function p:Init()
	
end

--������Ϣ
function p:Process()
	msg_cache.msg_travel_item = self;
	WriteConWarning( "** msg_travel_item:Process() called" );
	task_map.RefreshUI(self);
end
