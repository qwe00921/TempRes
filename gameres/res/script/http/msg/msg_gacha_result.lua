--------------------------------------------------------------
-- FileName: 	msg_gacha_result.lua
-- author:		Zjj, 2013/08/07
-- purpose:		Ť�������Ϣ
--------------------------------------------------------------

msg_gacha_result = msg_base:new();
local p = msg_gacha_result;
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
	msg_cache.msg_gacha_result = self;
	WriteConWarning( "** msg_gacha_result:Process() called" );
	dlg_gacha_result.ShowUI(self);
	
end