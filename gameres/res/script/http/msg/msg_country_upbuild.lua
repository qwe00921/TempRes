msg_country_upbuild = msg_base:new();
local p = msg_country_upbuild;
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
	self.idMsg = MSG_COUNTRY_UPBUILD;
end

function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_country_upbuild = self;
	
	WriteConWarning( "** msg_country_upbuild:Process() called" );
	country_building.uiBuildCallBack(self);
end
