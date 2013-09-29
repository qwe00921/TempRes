--------------------------------------------------------------
-- FileName:    msg_card_intensify.lua
-- author:      hst, 2013/07/25
-- purpose:     ����ǿ��
--------------------------------------------------------------

msg_card_intensify = msg_base:new();
local p = msg_card_intensify;
local super = msg_base;

--������ʵ��
function p:new()    
    o = {}
    setmetatable( o, self );
    self.__index = self;
    
    o:ctor();
    return o;
end

--���캯��
function p:ctor()
    super.ctor(self);
    self.idMsg = MSG_CARDBOX_INTENSIFY; --��Ϣ��
    
    self.user_id = nil;
    self.gold = nil;
    self.user_card_id = nil;
    self.card_id = nil;
    self.exp = nil;
    self.level = nil;
    self.hp = nil;
    self.attack = nil;
    self.defence = nil;
    
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
    WriteConWarning( "** msg_card_intensify:Process() called" );
    --dump_obj(self.user_cards);
    dlg_card_intensify_result.RefreshUI(self);
end
