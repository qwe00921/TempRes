--------------------------------------------------------------
-- FileName: 	msg_user_skill_intensify.lua
-- author:		xyd, 2013/08/13
-- purpose:		���ܿ���ǿ��
--------------------------------------------------------------

msg_user_skill_intensify = msg_base:new();
local p = msg_user_skill_intensify;
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
    self.idMsg = MSG_USER_SKILL_INTENSIFY; --��Ϣ��
	self.ErrorMsg = "";
end

--��ʼ��
function p:Init()
	
end

--������Ϣ
function p:Process()
	msg_cache.msg_user_skill_intensify = self;
	WriteConWarning( "** msg_user_skill_intensify:Process() called" );
	dlg_user_skill_intensify_result.RefreshUI(self);
end
