--------------------------------------------------------------
-- FileName: 	msg_skillpiece_result.lua
-- author:		Zjj, 2013/08/02
-- purpose:		碎片合成结果消息
--------------------------------------------------------------

msg_skillpiece_result = msg_base:new();
local p = msg_skillpiece_result;
local super = msg_base;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	
	o:ctor();
	return o;
end

--构造函数
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_SKILLPIECE; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_skillpiece_result = self;
	WriteConWarning( "** msg_skillpiece_result:Process() called" );
	dlg_skill_piece_combo_result.ShowUI(self);
end
