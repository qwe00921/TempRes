--------------------------------------------------------------
-- FileName: 	msg_collect.lua
-- author:		xyd, 2013/09/13
-- purpose:		ͼ��ϵͳ
--------------------------------------------------------------

msg_collect = msg_base:new();
local p = msg_collect;
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
    self.idMsg = MSG_COLLECT_START; --��Ϣ��
end

--��ʼ��
function p:Init()
	
end

--������Ϣ
function p:Process()
	msg_cache.msg_collect = self;
	WriteConWarning( "** msg_collect:Process() called");
end
