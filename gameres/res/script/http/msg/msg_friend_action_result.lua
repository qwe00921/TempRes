--------------------------------------------------------------
-- FileName: 	msg_friend_action_result.lua
-- author:		Zjj, 2013/08/29
-- purpose:		���Ѳ���������Ϣ
--------------------------------------------------------------

msg_friend_action_result = msg_base:new();
local p = msg_friend_action_result;
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
    self.idMsg = MSG_FRIEND_ACTION_RESULT; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_friend_action_result = self;
	WriteConWarning( "** msg_friend_action_result:Process() called" );
	friend_mgr.FriendActionCallback( self );
end
