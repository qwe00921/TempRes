--------------------------------------------------------------
-- FileName: 	msg_mainui.lua
-- author:		xyd, 2013/09/05
-- purpose:		���״̬��Ϣ
--------------------------------------------------------------

msg_createrole = msg_base:new();
local p = msg_createrole;
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
    self.idMsg = MSG_PLAYER_CREATEROLE;					--��Ϣ��
  
  	--[[
    self.user_status.user_name =nil;					--�û���
    self.user_status.level = nil;						--�ȼ�
    self.user_status.mission_point = nil;				--����
    self.user_status.mission_point_max = nil;			--��������
    self.user_status.arena_point = nil;					--����
    self.user_status.arena_point_max = nil;				--��������
    self.card_num = nil;								--��Ƭ����
    self.card_max = nil;								--��Ƭ����
    self.gold_num = nil;								--�������
    self.rmb_num = nil;									--��������
    ]]
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_player = self.user;
	WriteConWarning( "** msg_createrole:Process() called" );
	
	if self.result then
		dlg_createrole.CloseUI();
		maininterface.ShowUI(self.user);
	else
		dlg_msgbox.ShowOK( ToUtf8("��ʾ"), self.message, nil, dlg_createrole.layer );
		--WriteConWarning("��������ʧ��");
	end
end
