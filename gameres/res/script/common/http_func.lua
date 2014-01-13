--------------------------------------------------------------
-- FileName: 	http_func.lua
-- author:		
-- purpose:		http��������
--------------------------------------------------------------

local http_busy = false;
local busy_fx = "lancer.busy";

--����Http����
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

--����Ƿ�æ
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