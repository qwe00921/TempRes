
msg_maininterface = msg_base:new();
local p = msg_maininterface;
local super = msg_base;

--������ʵ��
function p:new()
	o = {}
	setmetatable( o,self);
	self.__index = self;
	o:ctor();return o;
end

--���캯��
function p:ctor()
	super.ctor(self);
	self.idMsg = MSG_PLAYER_USERINFO;
	
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_maininterface = self;
	
	WriteConWarning( "** msg_maininterface:Process() called" );
	if self.result then
		dlg_userinfo.RefreshUI(self.user);
	else
		--û���������봴���������
		--dlg_createrole.ShowUI();
	end
end





