--------------------------------------------------------------
-- FileName: 	msg_team_update.lua
-- author:		Zjj, 2013/07/31
-- purpose:		�����Ϣ
--------------------------------------------------------------

msg_team_update = msg_base:new();
local p = msg_team_update;
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
	msg_cache.msg_team_update = self;
	WriteConWarning( "** msg_team_update:Process() called" );
	if self.result then
		dlg_card_group_main.RefreshBattleBtn( self );
	else
		dlg_msgbox.ShowOK( ToUtf8("��ʾ"), self.message, nil, dlg_card_group_main.layer );
	end
end
