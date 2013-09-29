--------------------------------------------------------------
-- FileName: 	msg_err.lua
-- author:		zhangwq, 2013/09/02
-- purpose:		ͨ�ô�������Ϣ
--------------------------------------------------------------

msg_err = msg_base:new();
local p = msg_err;
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
    self.idMsg = MSG_MISC_ERR; --��Ϣ��
	self.command = "";
	self.action = "";
	self.errcode = 0;
	self.errmsg = ""; --����������Ϣ�����ȼ��ߣ�����errkey�ֶΣ�
	self.errkey = ""; --���󴮣���Ӧ��strres.ini
end

--��ʼ��
function p:Init()
	
end

--������Ϣ
function p:Process()
	msg_cache.msg_err = self;
	WriteConWarning( "** msg_err:Process() called" );
	
	if self.command == "cmd1" then
		p:Process_Err1();
	elseif self.command == "cmd2" then
		p:Process_Err2();
	elseif self.command == "User" then
		dlg_create_player.CreatePlayerFaild(self);
	end
end

--�������
function p:Process_Err1()
	--...
	--������ʾ��
end

--�������
function p:Process_Err2()
	--...
	--������ʾ��
end

--��ȡ�����ı�
function p:GetErrText()
	if self.errmsg ~= nil and #self.errmsg > 0 then
		return tostring(self.errmsg);
	elseif self.errkey ~= nil and #self.errkey > 0 then
		return GetStr(tostring(self.errkey));
	end
end

