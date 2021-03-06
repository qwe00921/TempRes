--------------------------------------------------------------
-- FileName: 	msg_team_update.lua
-- author:		Zjj, 2013/07/31
-- purpose:		玩家消息
--------------------------------------------------------------

msg_team_update = msg_base:new();
local p = msg_team_update;
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
    self.idMsg = MSG_TEAM_UPDATE; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_team_update = self;
	WriteConWarning( "** msg_team_update:Process() called" );
	if self.result then
		dlg_card_group_main.RefreshBattleBtn( self );
	else
		dlg_msgbox.ShowOK( ToUtf8("提示"), self.message, nil, dlg_card_group_main.layer );
	end
end
