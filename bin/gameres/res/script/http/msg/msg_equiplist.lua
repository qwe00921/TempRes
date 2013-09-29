--------------------------------------------------------------
-- FileName: 	msg_equiplist.lua
-- author:		Zjj, 2013/08/07
-- purpose:		装备列表消息
--------------------------------------------------------------

msg_equiplist = msg_base:new();
local p = msg_equiplist;
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
	msg_cache.msg_equiplist = self;
	WriteConWarning( "** msg_equiplist:Process() called" );
	equip_select_mgr.RefershUI(self.user_items);
	
end
