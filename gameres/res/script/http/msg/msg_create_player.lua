--------------------------------------------------------------
-- FileName: 	msg_create_player.lua
-- author:		xyd, 2013/07/12
-- purpose:		创建玩家消息
--------------------------------------------------------------

msg_create_player = msg_base:new();
local p = msg_create_player;
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
    self.idMsg = MSG_CREATE_PLAYER; --消息号
	self.user_id = 0;
	self.created_time = 0;
	self.ErrorMsg = "";
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_create_player:Process() called" );
	dlg_create_player.RefreshUI(self);
end
