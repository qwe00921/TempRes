msg_beast_call = msg_base:new();
local p = msg_beast_call;
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
	self.idMsg = MSG_PET_CALLPET;
	
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	WriteConWarning( "** msg_beast_call:Process() called" );
	if self.result then
		beast_mgr.CallBeast( tonumber( self.type ) );
	else

	end
end