--------------------------------------------------------------
-- FileName: 	msg_watch_player.lua
-- author:		Zjj, 2013/09/03
-- purpose:		������Ϣ��Ϣ
--------------------------------------------------------------

msg_watch_player = msg_base:new();
local p = msg_watch_player;
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
    self.idMsg = MSG_WATCH_PLAYER; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_watch_player = self;
	WriteConWarning( "** msg_watch_player:Process() called" );
	dlg_watch_player.InitAndShowUI( self );
end
