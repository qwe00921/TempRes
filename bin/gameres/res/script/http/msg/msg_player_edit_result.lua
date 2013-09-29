--------------------------------------------------------------
-- FileName: 	msg_player_edit_result.lua
-- author:		Zjj, 2013/09/16
-- purpose:		个人信息修改结果消息
--------------------------------------------------------------

msg_player_edit_result = msg_base:new();
local p = msg_player_edit_result;
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
    self.idMsg = MSG_PLAYER_EDIT_RESULT; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_player_edit_result = self;
	WriteConWarning( "** msg_player_edit_result:Process() called" );
	dlg_watch_player.ForEditSuccess();
end
