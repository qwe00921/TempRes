--------------------------------------------------------------
-- FileName: 	msg_skillpiece_result.lua
-- author:		Zjj, 2013/08/02
-- purpose:		��Ƭ�ϳɽ����Ϣ
--------------------------------------------------------------

msg_skillpiece_result = msg_base:new();
local p = msg_skillpiece_result;
local super = msg_base;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	
	o:ctor();
	return o;
end

--���캯��
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_SKILLPIECE; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_skillpiece_result = self;
	WriteConWarning( "** msg_skillpiece_result:Process() called" );
	dlg_skill_piece_combo_result.ShowUI(self);
end
