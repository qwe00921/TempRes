--------------------------------------------------------------
-- FileName: 	msg_user_skill_intensify.lua
-- author:		xyd, 2013/08/13
-- purpose:		技能卡牌强化
--------------------------------------------------------------

msg_user_skill_intensify = msg_base:new();
local p = msg_user_skill_intensify;
local super = msg_base;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_USER_SKILL_INTENSIFY; --消息号
	self.ErrorMsg = "";
end

--初始化
function p:Init()
	
end

--处理消息
function p:Process()
	msg_cache.msg_user_skill_intensify = self;
	WriteConWarning( "** msg_user_skill_intensify:Process() called" );
	dlg_user_skill_intensify_result.RefreshUI(self);
end
