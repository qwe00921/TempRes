--------------------------------------------------------------
-- FileName: 	msg_create_player.lua
-- author:		xyd, 2013/07/12
-- purpose:		���������Ϣ
--------------------------------------------------------------

msg_create_player = msg_base:new();
local p = msg_create_player;
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
    self.idMsg = MSG_CREATE_PLAYER; --��Ϣ��
	self.user_id = 0;
	self.created_time = 0;
	self.ErrorMsg = "";
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_create_player:Process() called" );
	dlg_create_player.RefreshUI(self);
end
