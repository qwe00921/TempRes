msg_card_sell = msg_base:new();
local p = msg_card_sell;
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
	self.idMsg = MSG_CARD_SELL;
end

function p:Init()
end

function p:Process()
	msg_cache.msg_card_sell = self;
    WriteConWarning( "** msg_card_sell:Process() called" );
	card_bag_mgr.DelCallBack(self)
	if self.result == true then 
		WriteConWarning( "** msg_card_sell OK" );
		dlg_card_attr_base.SaleKO(self);
	else
		WriteConErr( "** msg_card_sell error" );
	end
end


