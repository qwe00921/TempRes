--------------------------------------------------------------
-- FileName: 	msg_team_update.lua
-- author:		Zjj, 2013/07/31
-- purpose:		�����Ϣ
--------------------------------------------------------------

msg_team_replace = msg_base:new();
local p = msg_team_replace;
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
    self.idMsg = MSG_TEAM_MODIFY; --��Ϣ��
	
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	--msg_cache.msg_team_replace = self;
	WriteConWarning( "** msg_team_replace:Process() called" );
	if self.result then
		dlg_card_group_main.UpdateListData( self );
		
--		dlg_battlearray.UpdateListData( self );
	else
		dlg_msgbox.ShowOK( ToUtf8("��ʾ"), self.message, nil, dlg_card_group_main.layer );
	end
end
