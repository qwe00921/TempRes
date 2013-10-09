--------------------------------------------------------------
-- FileName: 	msg_card_fuse_result.lua
-- author:		Zjj, 2013/08/05
-- purpose:		卡牌融合结果消息类
--------------------------------------------------------------

msg_card_fuse_result = msg_base:new();
local p = msg_card_fuse_result;
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
	msg_cache.msg_card_fuse_result = self;
	WriteConWarning( "** msg_card_fuse_result:Process() called" );
	dlg_card_fuse_result.ShowUI(self.user_card);

end
