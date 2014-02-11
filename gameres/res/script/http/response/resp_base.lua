--------------------------------------------------------------
-- FileName: 	resp_base.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		响应基类
--------------------------------------------------------------

resp_base = {}
local p = resp_base;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
    self.cmd = ""; --功能大类
	self.action = ""; --功能子类
	self.result = 0; --成功标志
	self.errmsg = ""; --错误信息
	self.msgArray={}; --消息数组
end

--初始化
function p:Init()
end

--处理响应
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


--添加消息
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

--获取消息
function p:GetMsg( idmsg )
	local msg = self.msgArray[idmsg];
	if msg == nil then
		WriteConErr( string.format("GetMsg() failed, idmsg=%d", idmsg));
	end
	return msg;
end

--返回消息数量
function p:GetMsgCount()
	return #self.msgArray;
end
