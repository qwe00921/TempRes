--------------------------------------------------------------
-- FileName: 	msg_shop_buy_result.lua
-- author:		Zjj, 2013/09/12
-- purpose:		扭蛋消息
--------------------------------------------------------------

msg_shop_buy_result = msg_base:new();
local p = msg_shop_buy_result;
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
	msg_cache.msg_shop_buy_result = self;
	WriteConWarning( "** msg_shop_buy_result:Process() called" );
	if tonumber( self.type ) == 1 then
       dlg_buy_num.BuySuccessResult( self );
    elseif tonumber( self.type ) == 2 then 
       
    end
end
