--------------------------------------------------------------
-- FileName: 	msg_teamlist.lua
-- author:		Zjj, 2013/07/09
-- purpose:		�����Ϣ
--------------------------------------------------------------

msg_teamlist = msg_base:new();
local p = msg_teamlist;
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
    self.idMsg = MSG_TEAM_LIST; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_teamlist = self;
	WriteConWarning( "** msg_teamlist:Process() called" );
	dlg_card_group.ShowGruopList(self.teams);
end
