--------------------------------------------------------------
-- FileName: 	msg_shop_item.lua
-- author:		Zjj, 2013/08/13
-- purpose:		Ť����Ϣ
--------------------------------------------------------------

msg_shop_item = msg_base:new();
local p = msg_shop_item;
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
	msg_cache.msg_shop_item = self;
	WriteConWarning( "** msg_shop_item:Process() called" );
	--������̳���Ϣ
	if tonumber( self.type ) == 1 then
	   dlg_gacha.ShowShopData( self );
	elseif tonumber( self.type ) == 2 then 
	   dlg_gacha.ShowGiftPackData( self );
	end
end
