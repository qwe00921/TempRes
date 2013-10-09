--------------------------------------------------------------
-- FileName: 	msg_card_equip.lua
-- author:		Zjj, 2013/08/05
-- purpose:		卡牌装备消息
--------------------------------------------------------------

msg_card_equip = msg_base:new();
local p = msg_card_equip;
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
    self.idMsg = MSG_TEAM_UPDATE; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_card_equip = self;
	WriteConWarning( "** msg_card_equip:Process() called" );
	dlg_card_equip.ShowEquipInfo(self.card_items);
end
