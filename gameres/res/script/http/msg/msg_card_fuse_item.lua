--------------------------------------------------------------
-- FileName: 	msg_card_fuse_item.lua
-- author:		Zjj, 2013/08/05
-- purpose:		�����ںϵ�����Ϣ��
--------------------------------------------------------------

msg_card_fuse_item = msg_base:new();
local p = msg_card_fuse_item;
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
    self.idMsg = MSG_CARD_FUSE_ITEM; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_card_fuse_item = self;
	WriteConWarning( "** msg_card_fuse_item:Process() called" );
	dlg_card_fuse.SaveItemData(self.mix_items);
end
