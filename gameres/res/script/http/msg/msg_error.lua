
msg_error = msg_base:new();
local p = msg_error;
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
	super.ctor( self );
    self.idMsg = MSG_GENERAL_ERROR; --消息号
end

--初始化
function p:Init()
end

--处理消息
function p:Process()
	local level = tonumber(self.msglevel);
	if level ~= nil and level == 1 then
		dlg_msgbox.ShowOK( ToUtf8( "提示" ), self.message, p.Process_Err1, GetUIRoot() );
	else
		dlg_msgbox.ShowOK( ToUtf8( "错误" ), self.message, p.Process_Err2, GetUIRoot() );
	end
end

--处理提示，一般是直接关闭
function p:Process_Err1()
	--p:Process_Err2();
end

--处理错误，退出到主界面
function p:Process_Err2()
--[[
	maininterface.HideUI();
	dlg_battlearray.HideUI();
	dlg_userinfo.HideUI();
	dlg_menu.HideUI();
--]]
	--game_main.main();
end




