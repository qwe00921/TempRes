--------------------------------------------------------------
-- FileName:    msg_sell_user_item.lua
-- author:      hst, 2013/07/31
-- purpose:     出售道具
--------------------------------------------------------------

msg_sell_user_item = msg_base:new();
local p = msg_sell_user_item;
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
    self.idMsg = MSG_EQUIP_SELL_ITEM; --消息号
    
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
    WriteConWarning( "** msg_sell_user_item:Process() called" );
    back_pack_mgr.RefreshUIBySell(self);
end
