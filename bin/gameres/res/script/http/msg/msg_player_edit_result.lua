--------------------------------------------------------------
-- FileName: 	msg_player_edit_result.lua
-- author:		Zjj, 2013/09/16
-- purpose:		������Ϣ�޸Ľ����Ϣ
--------------------------------------------------------------

msg_player_edit_result = msg_base:new();
local p = msg_player_edit_result;
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
    self.idMsg = MSG_PLAYER_EDIT_RESULT; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_player_edit_result = self;
	WriteConWarning( "** msg_player_edit_result:Process() called" );
	dlg_watch_player.ForEditSuccess();
end
