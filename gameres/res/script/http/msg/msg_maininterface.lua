
msg_maininterface = msg_base:new();
local p = msg_maininterface;
local super = msg_base;

--创建新实例
function p:new()
	o = {}
	setmetatable( o,self);
	self.__index = self;
	o:ctor();return o;
end

--构造函数
function p:ctor()
	super.ctor(self);
	self.idMsg = MSG_PLAYER_USERINFO;
	
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	msg_cache.msg_maininterface = self;
	
	WriteConWarning( "** msg_maininterface:Process() called" );
	if self.result then
		dlg_userinfo.RefreshUI(self.user);
	else
		--没有人物，则进入创建人物界面
		--dlg_createrole.ShowUI();
	end
end





