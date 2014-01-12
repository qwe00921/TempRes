--------------------------------------------------------------
-- FileName: 	http_func.lua
-- author:		
-- purpose:		http辅助函数
--------------------------------------------------------------

local http_busy = false;
local busy_fx = "lancer.busy";

--发送Http请求
function SendReq( cmd, action, uid, param )
	SendRequest( cmd, action, uid, param );
	
	SetTimerOnce( OnTimerCheckBusy, 1.0f );
	http_busy = true;
end

function SendPost(cmd)
	PostRequest(cmd);
	
	SetTimerOnce( OnTimerCheckBusy, 1.0f );
	http_busy = true;
end

--检查是否忙
function OnTimerCheckBusy()
	if http_busy then
		if not FindHudEffect(busy_fx) then
			AddHudEffect( busy_fx );
		end
	end
end

function HttpOK()
	http_busy = false;
	DelHudEffect( busy_fx );
end