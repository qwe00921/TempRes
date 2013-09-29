--------------------------------------------------------------
-- FileName: 	msg_skillpiece.lua
-- author:		Zjj, 2013/07/09
-- purpose:		碎片消息
--------------------------------------------------------------

msg_skillpiece = msg_base:new();
local p = msg_skillpiece;
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
	msg_cache.msg_skillpiece = self;
	WriteConWarning( "** msg_skillpiece:Process() called" );
	dlg_skill_piece_combo.ShowPieceList(self.skill_items);
end
