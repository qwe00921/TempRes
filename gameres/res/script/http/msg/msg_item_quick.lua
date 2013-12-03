msg_item_quick = msg_base:new();
local p = msg_item_quick;
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
	self.idMsg = MSG_ITEM_QUICK;
end

function p:Init()
end

function p:Process()
	msg_cache.msg_item_quick = self;
    WriteConWarning( "** msg_item_quick:Process() called" );
	pack_box_mgr.UseItemCallBack(self)
	-- if self.result == true then 
	-- else
		-- WriteConWarning( "** msg_item_gift error" );
	-- end
end
