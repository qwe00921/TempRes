--------------------------------------------------------------
-- FileName: 	http_func.lua
-- author:		
-- purpose:		http辅助函数
--------------------------------------------------------------

local http_busy = false;
local busy_fx = "lancer.busy";

local WaitForPostCallBack = nil;
local RequestCallBack = nil;

--发送Http请求
function SendReq( cmd, action, uid, param )
	if WaitForPostCallBack ~= nil then
		local flag = WaitForPostCallBack();--需要返回值，是否已发送post请求
		if flag then
			WaitForPostCallBack = nil;
			RequestCallBack = { Cmd = cmd, Action = action, Uid = uid, Param = param };
			return;
		end
	end

	SendRequest( cmd, action, uid, param );
	
	SetTimerOnce( OnTimerCheckBusy, 1.0f );
	http_busy = true;
end

function SendPost(cmd, action, uid, param,data)
	PostRequest(cmd, action, uid, param,data);
	
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

--设置等待post的接口
function SetWaitForPost( pCall )
	WaitForPostCallBack = pCall;
end

--post成功回调
function PostBack()
	--WaitForPostCallBack = nil;
	if RequestCallBack ~= nil and RequestCallBack.Cmd ~= nil and RequestCallBack.Action ~= nil and RequestCallBack.Uid ~= nil and RequestCallBack.Param ~= nil then
		SendReq(RequestCallBack.Cmd, RequestCallBack.Action, RequestCallBack.Uid, RequestCallBack.Param );
	end
end

