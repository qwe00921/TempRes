--------------------------------------------------------------
-- FileName: 	json2lua_helper.lua
-- author:		zhangwq, 2013/07/10
-- purpose:		json转lua帮助函数（全局）
--------------------------------------------------------------

--将消息对象加入到响应对象
function j2l_resp_add_msg( idmsg )
	--var: resp, msg (defined in c++ side)
	if resp ~= nil and msg ~= nil then
		WriteConWarning( string.format("j2l_resp_add_msg() ok, idmsg=%d", idmsg ));
		resp:AddMsg( idmsg, msg );
	else
		WriteConErr( string.format("j2l_resp_add_msg() failed: idmsg=%d", idmsg));
	end
end

--处理响应 
function j2l_resp_process()
	WriteConWarning( "j2l_resp_process()");
	
	if resp ~= nil then
		--WriteConWarning( "j2l_resp_process() ok");
		resp:Process();
		resp = nil;
	end
end
