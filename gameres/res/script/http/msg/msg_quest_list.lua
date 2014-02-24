msg_quest_list = msg_base:new();
local p = msg_quest_list;
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
	self.idMsg = MSG_QUEST_LIST;
end

function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_quest_list = self;
	
	WriteConWarning( "** msg_quest_list:Process() called" );
	--quest_main.ShowUI(self.battles);
	quest_main.ShowQuestList(self);
	
	if w_battle_guid.IsGuid == true then
		if w_battle_guid.guidstep == 5 then
			if w_battle_guid.substep == 5 then
				w_battle_guid.CanSubStep5 = true
			end
		end
	end
end
