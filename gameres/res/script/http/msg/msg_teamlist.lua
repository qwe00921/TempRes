--------------------------------------------------------------
-- FileName: 	msg_teamlist.lua
-- author:		Zjj, 2013/07/09
-- purpose:		玩家消息
--------------------------------------------------------------

msg_teamlist = msg_base:new();
local p = msg_teamlist;
local super = msg_base;

--创建新实例
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
    self.idMsg = MSG_TEAM_LIST; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_teamlist = self;
	WriteConWarning( "** msg_teamlist:Process() called" );
	dlg_card_group.ShowGruopList(self.teams);
end
