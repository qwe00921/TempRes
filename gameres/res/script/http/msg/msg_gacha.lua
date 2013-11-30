--------------------------------------------------------------
-- FileName: 	msg_gacha.lua
-- author:		Zjj, 2013/08/13
-- purpose:		扭蛋消息
--------------------------------------------------------------

msg_gacha = msg_base:new();
local p = msg_gacha;
local super = msg_base;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
	super.ctor(self);
    self.idMsg = MSG_GACHA; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_gacha = self;
	WriteConWarning( "** msg_gacha:Process() called" );
	
	if self.result then
		dlg_gacha.ShowGachaData( self );
	end
	--dlg_gacha.ShowGachaData( self );
end
