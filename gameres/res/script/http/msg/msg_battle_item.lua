
msg_battle_item = msg_base:new();
local p = msg_battle_item;
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
    self.idMsg = MSG_BATTLE_ITEM; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_battle_item:Process() called" );
	
	if self.result then
		item_choose.RefreshUI( self.battle_items );
	end
end


