--------------------------------------------------------------
-- FileName: 	msg_friend_action_result.lua
-- author:		Zjj, 2013/08/29
-- purpose:		好友操作返回消息
--------------------------------------------------------------

msg_friend_action_result = msg_base:new();
local p = msg_friend_action_result;
local super = msg_base;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_FRIEND_ACTION_RESULT; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_friend_action_result = self;
	WriteConWarning( "** msg_friend_action_result:Process() called" );
	friend_mgr.FriendActionCallback( self );
end
