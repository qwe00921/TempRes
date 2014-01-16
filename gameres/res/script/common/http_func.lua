--------------------------------------------------------------
-- FileName: 	http_func.lua
-- author:		
-- purpose:		http��������
--------------------------------------------------------------

local http_busy = false;
local busy_fx = "lancer.busy";

local WaitForPostCallBack = nil;
local RequestCallBack = nil;

--����Http����
function SendReq( cmd, action, uid, param )
	if WaitForPostCallBack ~= nil then
		local flag = WaitForPostCallBack();--��Ҫ����ֵ���Ƿ��ѷ���post����
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

--���õȴ�post�Ľӿ�
function SetWaitForPost( pCall )
	WaitForPostCallBack = pCall;
end

--post�ɹ��ص�
function PostBack()
	--WaitForPostCallBack = nil;
	if RequestCallBack ~= nil and RequestCallBack.Cmd ~= nil and RequestCallBack.Action ~= nil and RequestCallBack.Uid ~= nil and RequestCallBack.Param ~= nil then
		SendReq(RequestCallBack.Cmd, RequestCallBack.Action, RequestCallBack.Uid, RequestCallBack.Param );
	end
end

