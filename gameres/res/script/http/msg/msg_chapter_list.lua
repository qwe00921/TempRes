msg_chapter_list = msg_base:new();
local p = msg_chapter_list;
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
	self.idMsg = MSG_CHAPTER_LIST;
end

function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_chapter_list = self;
	
	WriteConWarning( "** msg_chapter_list:Process() called" );
	--quest_main.ShowUI(self.battles);
	--quest_main.ShowQuestList(self);
	stageMap_main.getChapterListCallBack(self);
end
