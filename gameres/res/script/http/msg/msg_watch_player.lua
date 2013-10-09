--------------------------------------------------------------
-- FileName: 	msg_watch_player.lua
-- author:		Zjj, 2013/09/03
-- purpose:		个人信息消息
--------------------------------------------------------------

msg_watch_player = msg_base:new();
local p = msg_watch_player;
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
    self.idMsg = MSG_WATCH_PLAYER; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_watch_player = self;
	WriteConWarning( "** msg_watch_player:Process() called" );
	dlg_watch_player.InitAndShowUI( self );
end
