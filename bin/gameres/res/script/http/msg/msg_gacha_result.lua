--------------------------------------------------------------
-- FileName: 	msg_gacha_result.lua
-- author:		Zjj, 2013/08/07
-- purpose:		扭蛋结果消息
--------------------------------------------------------------

msg_gacha_result = msg_base:new();
local p = msg_gacha_result;
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
    self.idMsg = MSG_EQUIP_LIST; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_gacha_result = self;
	WriteConWarning( "** msg_gacha_result:Process() called" );
	dlg_gacha_result.ShowUI(self);
	
end
