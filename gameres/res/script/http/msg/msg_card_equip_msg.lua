--------------------------------------------------------------
-- FileName: 	msg_mail_send_msg.lua
-- author:		wjl, 2013/11/27
-- purpose:		�����ʼ�
--------------------------------------------------------------

msg_card_equip_msg = msg_base:new();
local p = msg_card_equip_msg;
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
    self.idMsg = MSG_CARD_EQUIPMENT_DETAIL; --��Ϣ��
end

--��ʼ��
function p:Init()
end

function p:SetIdMsg(id)
	self.idMsg = id;
end

--������Ϣ
function p:Process()
	--msg_cache.msg_card_box = self.user_cards;
	WriteCon( "** msg_card_equip_msg:Process() called" );
	--dump_obj(self.user_cards);
	
	if self.idMsg == MSG_CARD_EQUIPMENT_DETAIL then --����װ����ϸ
		
	elseif self.idMsg == MSG_CARD_EQUIPMENT_INSTALL then --����װ����װ
		
	elseif self.idMsg == MSG_CARD_EQUIPMENT_UNINSTALL then --����װ��ж��
		
	elseif self.idMsg == MSG_CARD_EQUIPMENT_CHANGE then --����װ������
		
	end
end
