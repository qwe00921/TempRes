--------------------------------------------------------------
-- FileName: 	msg_err.lua
-- author:		zhangwq, 2013/09/02
-- purpose:		通用错误处理消息
--------------------------------------------------------------

msg_err = msg_base:new();
local p = msg_err;
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
    self.idMsg = MSG_MISC_ERR; --消息号
	self.command = "";
	self.action = "";
	self.errcode = 0;
	self.errmsg = ""; --完整错误信息，优先级高，忽略errkey字段！
	self.errkey = ""; --错误串，对应到strres.ini
end

--初始化
function p:Init()
	
end

--处理消息
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

--处理错误
function p:Process_Err1()
	--...
	--弹出提示框
end

--处理错误
function p:Process_Err2()
	--...
	--弹出提示框
end

--提取错误文本
function p:GetErrText()
	if self.errmsg ~= nil and #self.errmsg > 0 then
		return tostring(self.errmsg);
	elseif self.errkey ~= nil and #self.errkey > 0 then
		return GetStr(tostring(self.errkey));
	end
end

