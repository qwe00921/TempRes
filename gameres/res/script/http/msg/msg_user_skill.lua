--------------------------------------------------------------
-- FileName: 	msg_user_skill.lua
-- author:		xyd, 2013/08/09
-- purpose:		技能卡包
--------------------------------------------------------------

msg_user_skill = msg_base:new();
local p = msg_user_skill;
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
    self.idMsg = MSG_USER_SKILL; --消息号
end

--初始化
function p:Init()
	
end

--处理消息
function p:Process()
	msg_cache.msg_user_skill = self;
	WriteConWarning( "** msg_user_skill:Process() called");
	user_skill_mgr.RefreshUI(self.user_skills);
end
