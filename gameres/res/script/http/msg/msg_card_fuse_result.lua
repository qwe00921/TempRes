--------------------------------------------------------------
-- FileName: 	msg_card_fuse_result.lua
-- author:		Zjj, 2013/08/05
-- purpose:		�����ںϽ����Ϣ��
--------------------------------------------------------------

msg_card_fuse_result = msg_base:new();
local p = msg_card_fuse_result;
local super = msg_base;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	
	o:ctor();
	return o;
end

--���캯��
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_TEAM_UPDATE; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_card_fuse_result = self;
	WriteConWarning( "** msg_card_fuse_result:Process() called" );
	dlg_card_fuse_result.ShowUI(self.user_card);

end
