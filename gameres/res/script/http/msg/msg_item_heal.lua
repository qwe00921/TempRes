msg_item_heal = msg_base:new();
local p = msg_item_heal;
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
	self.idMsg = MSG_ITEM_HEAL;
	
	self.message = nil;
	self.result = nil;
end

function p:Init()
end

function p:Process()
	msg_cache.msg_item_heal = self;
    WriteConWarning( "** msg_item_heal:Process() called" );
	if self.result == true then 
		--pack_box_mgr.RefreshUI(self.user_items);
	else
		WriteConWarning( "** msg_item_heal error" );
	end
end
