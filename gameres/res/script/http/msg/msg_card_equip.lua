--------------------------------------------------------------
-- FileName: 	msg_card_equip.lua
-- author:		Zjj, 2013/08/05
-- purpose:		����װ����Ϣ
--------------------------------------------------------------

msg_card_equip = msg_base:new();
local p = msg_card_equip;
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
    self.idMsg = MSG_TEAM_UPDATE; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_card_equip = self;
	WriteConWarning( "** msg_card_equip:Process() called" );
	dlg_card_equip.ShowEquipInfo(self.card_items);
end
