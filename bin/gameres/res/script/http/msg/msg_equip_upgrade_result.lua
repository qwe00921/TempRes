--------------------------------------------------------------
-- FileName: 	msg_equip_upgrade_result.lua
-- author:		Zjj, 2013/08/08
-- purpose:		װ�����������Ϣ
--------------------------------------------------------------

msg_equip_upgrade_result = msg_base:new();
local p = msg_equip_upgrade_result;
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
    self.idMsg = MSG_EQUIP_UPGRADE_RESULT; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_equip_upgrade_result = self;
	WriteConWarning( "** msg_equip_upgrade_result:Process() called" );
	dlg_equip_upgrade_result.ShowUI(self);
end
