--------------------------------------------------------------
-- FileName: 	resp_factory.lua
-- author:		zhangwq, 2013/07/05
-- purpose:		��Ӧ������������
--------------------------------------------------------------

resp_factory = {}
local p = resp_factory;

--������Ӧ�Ŵ�����Ӧ
function CreateResponse( command, action )
	WriteConWarning( string.format("CreateResponse(): command=%s, action=%s", command, action));
	
	--������Ϣ
	--if idResponse == 1 then return resp_test:new();
	return resp_test:new();
	--@todo...
	--return nil;
end
