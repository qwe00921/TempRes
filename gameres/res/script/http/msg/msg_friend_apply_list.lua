--------------------------------------------------------------
-- FileName: 	msg_friend_apply_list.lua
-- author:		Zjj, 2013/08/28
-- purpose:		����������Ϣ
--------------------------------------------------------------

msg_friend_apply_list = msg_base:new();
local p = msg_friend_apply_list;
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
    self.idMsg = MSG_FRIEND_APPLY_LIST; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_friend_apply_list = self;
	WriteConWarning( "** msg_friend_apply_list:Process() called" );
	friend_mgr.ShowFriendApplyUI( self );
end