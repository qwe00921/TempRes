--------------------------------------------------------------
-- FileName: 	msg_change_equip_result.lua
-- author:		Zjj, 2013/08/05
-- purpose:		���Ƹ���װ�������Ϣ
--------------------------------------------------------------

msg_change_equip_result = msg_base:new();
local p = msg_change_equip_result;
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
    self.idMsg = MSG_CHANGE_EQUIP_RESULT; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_change_equip_result = self;
	WriteConWarning( "** msg_change_equip_result:Process() called" );
	dlg_card_equip_select.ChangeEquipResult();
end
