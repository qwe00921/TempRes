--------------------------------------------------------------
-- FileName: 	msg_equiplist.lua
-- author:		Zjj, 2013/08/07
-- purpose:		װ���б���Ϣ
--------------------------------------------------------------

msg_equiplist = msg_base:new();
local p = msg_equiplist;
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
    self.idMsg = MSG_EQUIP_LIST; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_equiplist = self;
	WriteConWarning( "** msg_equiplist:Process() called" );
	equip_select_mgr.RefershUI(self.user_items);
	
end
