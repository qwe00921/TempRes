--------------------------------------------------------------
-- FileName:    msg_card_depot_takeout.lua
-- author:      hst, 2013/08/01
-- purpose:     ���Ʋֿ�ȡ��
--------------------------------------------------------------

msg_card_depot_takeout = msg_base:new();
local p = msg_card_depot_takeout;
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
    self.idMsg = MSG_DEPOT_TAKEOUT; --��Ϣ��
    
    self.takeout_num = nil;
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
    WriteConWarning( "** msg_card_depot_takeout:Process() called" );
    --dump_obj(self);
    dlg_card_depot.RefreshTakeout(self);
end
