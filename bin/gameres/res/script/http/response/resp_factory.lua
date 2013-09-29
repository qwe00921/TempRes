--------------------------------------------------------------
-- FileName: 	resp_factory.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		响应工厂（单例）
--------------------------------------------------------------

resp_factory = {}
local p = resp_factory;

--根据响应号创建响应
function CreateResponse( command, action )
	WriteConWarning( string.format("CreateResponse(): command=%s, action=%s", command, action));
	
	--测试消息
	--if idResponse == 1 then return resp_test:new();
	return resp_test:new();
	--@todo...
	--return nil;
end
