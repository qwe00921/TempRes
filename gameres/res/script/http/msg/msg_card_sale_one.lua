msg_card_sale_one = msg_base:new();
local p = msg_card_sale_one;
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
	self.idMsg = MSG_CARDBOX_USER_CARDS;
	
	--self.id = nil;
	--self.type = nil;
end

function p:Init()
end

function p:Process()
	WriteCon("msg_card_sale_one");
	msg_cache.msg_card_sale_one = self;
    WriteConWarning( "** MSG_CARDBOX_USER_CARDS:Process() called" );
	if self.result == true then 
		dlg_card_attr_base.SaleKO(self);
	else
		WriteConWarning( "** MSG_CARDBOX_USER_CARDS error" );
	end
end
