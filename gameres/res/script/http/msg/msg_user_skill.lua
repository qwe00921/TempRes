--------------------------------------------------------------
-- FileName: 	msg_user_skill.lua
-- author:		xyd, 2013/08/09
-- purpose:		���ܿ���
--------------------------------------------------------------

msg_user_skill = msg_base:new();
local p = msg_user_skill;
local super = msg_base;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_USER_SKILL; --��Ϣ��
end

--��ʼ��
function p:Init()
	
end

--������Ϣ
function p:Process()
	msg_cache.msg_user_skill = self;
	WriteConWarning( "** msg_user_skill:Process() called");
	user_skill_mgr.RefreshUI(self.user_skills);
end
