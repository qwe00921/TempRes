--------------------------------------------------------------
-- FileName: 	resp_base.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		��Ӧ����
--------------------------------------------------------------

resp_base = {}
local p = resp_base;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
    self.cmd = ""; --���ܴ���
	self.action = ""; --��������
	self.result = 0; --�ɹ���־
	self.errmsg = ""; --������Ϣ
	self.msgArray={}; --��Ϣ����
end

--��ʼ��
function p:Init()
end

--������Ӧ
function p:Process()
    WriteConWarning( "** resp_base:Process() called" );
    
	HttpOK();
    
	local status, err = pcall( function()
									for _,v in pairs(self.msgArray) do
										v:Process();
									end 
								end )
	if not status then
		WriteConErr( tostring(err));
	end
end


--�����Ϣ
function p:AddMsg( idmsg, objmsg )
	if objmsg ~= nil then
		--WriteConWarning( string.format("AddMsg() ok, idmsg=%d", idmsg));
		self.msgArray[idmsg] = objmsg;
		return true;
	else
		--WriteConErr( string.format("AddMsg() failed, idmsg=%d", idmsg));
		return false;
	end
end

--��ȡ��Ϣ
function p:GetMsg( idmsg )
	local msg = self.msgArray[idmsg];
	if msg == nil then
		WriteConErr( string.format("GetMsg() failed, idmsg=%d", idmsg));
	end
	return msg;
end

--������Ϣ����
function p:GetMsgCount()
	return #self.msgArray;
end
