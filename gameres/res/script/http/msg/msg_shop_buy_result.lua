--------------------------------------------------------------
-- FileName: 	msg_shop_buy_result.lua
-- author:		Zjj, 2013/09/12
-- purpose:		Ť����Ϣ
--------------------------------------------------------------

msg_shop_buy_result = msg_base:new();
local p = msg_shop_buy_result;
local super = msg_base;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_SHOP_ITEM; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_shop_buy_result = self;
	WriteConWarning( "** msg_shop_buy_result:Process() called" );
	if tonumber( self.type ) == 1 then
       dlg_buy_num.BuySuccessResult( self );
    elseif tonumber( self.type ) == 2 then 
       
    end
end
