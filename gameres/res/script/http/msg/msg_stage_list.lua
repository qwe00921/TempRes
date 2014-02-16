msg_stage_list = msg_base:new();
local p = msg_stage_list;
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
	self.idMsg = MSG_STAGE_LIST;
end

function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_stage_list = self;
	
	WriteConWarning( "** msg_stage_list:Process() called" );
	if stageMap_main.openMapId == 1 then
		stageMap_1.addAllStage(self);
	elseif stageMap_main.openMapId == 2 then
		stageMap_2.addAllStage(self);
	elseif stageMap_main.openMapId == 3 then
		stageMap_3.addAllStage(self);
	elseif stageMap_main.openMapId == 4 then
		stageMap_4.addAllStage(self);
	elseif stageMap_main.openMapId == 5 then
		stageMap_5.addAllStage(self);
	elseif stageMap_main.openMapId == 6 then
		stageMap_6.addAllStage(self);
	elseif stageMap_main.openMapId == 7 then
		stageMap_7.addAllStage(self);
	elseif stageMap_main.openMapId == 8 then
		stageMap_8.addAllStage(self);
	elseif stageMap_main.openMapId == 9 then
		stageMap_9.addAllStage(self);
	end
end
