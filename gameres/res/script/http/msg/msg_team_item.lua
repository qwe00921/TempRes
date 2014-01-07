msg_team_item = msg_base:new();
local p = msg_team_item;
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
	self.idMsg = MSG_TEAM_ITEM;
end

function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_team_item = self;
	
	WriteConWarning( "** msg_team_item:Process() called" );
	--quest_main.ShowUI(self.battles);
	quest_team_item.showTeamItem(self);
end
