--------------------------------------------------------------
-- FileName: 	msg_change_equip_result.lua
-- author:		Zjj, 2013/08/05
-- purpose:		卡牌更换装备结果消息
--------------------------------------------------------------

msg_change_equip_result = msg_base:new();
local p = msg_change_equip_result;
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
    self.idMsg = MSG_CHANGE_EQUIP_RESULT; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_change_equip_result = self;
	WriteConWarning( "** msg_change_equip_result:Process() called" );
	dlg_card_equip_select.ChangeEquipResult();
end
