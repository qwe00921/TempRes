

msg_player_update = msg_base:new();
local p = msg_player_update;
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
	self.idMsg = MSG_PLAYER_UPDATE;
end

function p:Init()
end

--处理消息
function p:Process()
	WriteConWarning( "** msg_player_update:Process() called" );
	
	msg_cache.msg_player = msg_cache.msg_player or {};
	
	if self.result then
		for key, value in pairs( self.user ) do
			msg_cache.msg_player[key] = value;
		end
		
		dlg_userinfo.RefreshUI( msg_cache.msg_player );
	end
end



