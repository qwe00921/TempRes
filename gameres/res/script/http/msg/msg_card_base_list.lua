msg_card_base_list = msg_base:new();
local p = msg_card_base_list;
local super = msg_base;

--创新实例
function p:new()
	
	o = {}
	setmetatable( o, self );
    self.__index = self;
    o:ctor();
	return o;
end

--构造函数
function p:ctor()
	super.ctor(self);
	self.idMsg = MSG_CARDBOX_START;
	
	--self.id = nil;
	--self.type = nil;
end

function p:Init()
end

function p:Process()
	msg_cache.msg_card_base_list = self;
    WriteConWarning( "** MSG_CARDBOX_START:Process() called" );
	if self.result == true then 
		--dlg_card_attr_base.RefreshUI(self);
		--card_intensify.ShowCardList(self.cardList);
	else
		WriteConWarning( "** MSG_CARDBOX_START error" );
	end
end
