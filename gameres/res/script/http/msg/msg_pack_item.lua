msg_pack_item = msg_base:new();
local p = msg_pack_item;
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
	self.idMsg = MSG_PACK_ITEM;
	
	--self.id = nil;
	--self.type = nil;
end

function p:Init()
end

function p:Process()
	msg_cache.msg_pack_item = self;
    WriteConWarning( "** msg_pack_box:Process() called" );
	dlg_gacha.ShowBagData(self);
end
