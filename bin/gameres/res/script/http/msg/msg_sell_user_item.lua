--------------------------------------------------------------
-- FileName:    msg_sell_user_item.lua
-- author:      hst, 2013/07/31
-- purpose:     ���۵���
--------------------------------------------------------------

msg_sell_user_item = msg_base:new();
local p = msg_sell_user_item;
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
    self.idMsg = MSG_EQUIP_SELL_ITEM; --��Ϣ��
    
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
    WriteConWarning( "** msg_sell_user_item:Process() called" );
    back_pack_mgr.RefreshUIBySell(self);
end
