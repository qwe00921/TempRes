--------------------------------------------------------------
-- FileName:    msg_card_depot_store.lua
-- author:      hst, 2013/08/01
-- purpose:     ���Ʋֿ����
--------------------------------------------------------------

msg_card_depot_store = msg_base:new();
local p = msg_card_depot_store;
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
    self.idMsg = MSG_DEPOT_STORE; --��Ϣ��
    
    self.store_num = nil;
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
    WriteConWarning( "** msg_card_box:Process() called" );
    --dump_obj(self);
    dlg_card_depot.RefreshStore(self);
end
