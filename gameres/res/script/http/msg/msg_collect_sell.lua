
msg_collect_sell = msg_base:new();
local p = msg_collect_sell;
local super = msg_base;

function p:new()
	o = {}
	setmetatable(o, self);
	self.__index = self;
	o:ctor();
	return o;
end

function p:ctor()
	super.ctor(self);
	self.idMsg = MSG_COLLECT_SELL;
end

function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** MSG_COLLECT_SELL:Process() called" );
	
	if self.result then
		country_storage_sell.SellCallBack();
	else
		dlg_msgbox.ShowOK( ToUtf8("提示") , self.message , nil, country_storage_sell.layer );
	end
end



