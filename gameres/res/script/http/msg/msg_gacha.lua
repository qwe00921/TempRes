--------------------------------------------------------------
-- FileName: 	msg_gacha.lua
-- author:		Zjj, 2013/08/13
-- purpose:		Ť����Ϣ
--------------------------------------------------------------

msg_gacha = msg_base:new();
local p = msg_gacha;
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
    self.idMsg = MSG_GACHA; --��Ϣ��
end

--��ʼ��
function p:Init()
end

--������Ϣ
function p:Process()
	msg_cache.msg_gacha = self;
	WriteConWarning( "** msg_gacha:Process() called" );
	
	if self.result then
		dlg_gacha.ShowGachaData( self );
	end
	--dlg_gacha.ShowGachaData( self );
end
