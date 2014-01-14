


msg_collect_materiallist = msg_base:new();
local p = msg_collect_materiallist;
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
	self.idMsg = MSG_COLLECT_MATERIALLIST;
end

function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_collect_materiallist:Process() called" );
	
	msg_cache.msg_material_list = self;
	
	if self.result then
		country_storage.RefreshUI( self );
		item_choose.RefreshUI();
	else
	
	end
end

