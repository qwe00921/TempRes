msg_count_data = msg_base:new();
local p = msg_count_data;
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
	self.idMsg = MSG_COUNT_DATA;
end

function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_count_data = self;
	
	WriteConWarning( "** msg_count_data:Process() called" );
	country_main.ShowCount(self);
end
