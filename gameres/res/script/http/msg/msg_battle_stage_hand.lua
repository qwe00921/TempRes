--------------------------------------------------------------
-- FileName:    msg_battle_stage_hand.lua
-- author:      hst, 2013/09/3
-- purpose:     ս�������ֽ׶���Ϣ
--------------------------------------------------------------

msg_battle_stage_hand = msg_base:new();
local p = msg_battle_stage_hand;
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
    self.idMsg = MSG_BATTLE_HAND; --��Ϣ��
    
    if false then
        
        
    end
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
    WriteConWarning( "** msg_battle_fighters:Process() called" );
    card_battle_mgr.ReceiveBattle_Stage_HandRes( self );
end
