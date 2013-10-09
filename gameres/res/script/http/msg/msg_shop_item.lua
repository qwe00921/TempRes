--------------------------------------------------------------
-- FileName: 	msg_shop_item.lua
-- author:		Zjj, 2013/08/13
-- purpose:		扭蛋消息
--------------------------------------------------------------

msg_shop_item = msg_base:new();
local p = msg_shop_item;
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
    self.idMsg = MSG_SHOP_ITEM; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_shop_item = self;
	WriteConWarning( "** msg_shop_item:Process() called" );
	--如果是商城信息
	if tonumber( self.type ) == 1 then
	   dlg_gacha.ShowShopData( self );
	elseif tonumber( self.type ) == 2 then 
	   dlg_gacha.ShowGiftPackData( self );
	end
end
