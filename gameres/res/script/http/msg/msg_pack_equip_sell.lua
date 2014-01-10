msg_pack_equip_sell = msg_base:new();
local p = msg_pack_equip_sell;
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
	self.idMsg = MSG_PACK_EQUIP_SELL;
end

function p:Init()
end

function p:Process()
	msg_cache.msg_pack_equip_sell = self;
    WriteConWarning( "** msg_pack_equip_sell:Process() called" );
	pack_box_mgr.sellEquipCallBack(self);
	equip_sell.sellResult(self);
end
