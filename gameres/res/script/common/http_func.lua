--------------------------------------------------------------
-- FileName: 	http_func.lua
-- author:		
-- purpose:		http辅助函数
--------------------------------------------------------------

local http_busy = false;
local busy_fx = "lancer.busy";

local WaitForPostCallBack = nil;
local RequestCallBack = nil;
local pLayer = nil;

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
	
	if nil == pLayer then
		local layer = createNDUILayer();
		layer:Init();
		layer:SetFrameRectFull();
		layer:SetZOrder( 999999 );
		pLayer = layer;
	else
		pLayer:RemoveFromParent( false );
	end
	
	GetUIRoot():AddChild(pLayer);
	
	pLayer:SetSwallowTouch( true );

	SendRequest( cmd, action, uid, param );
	
	SetTimerOnce( OnTimerCheckBusy, 0.1f );
	http_busy = true;
	
	rookie_mask.onCallFlag = true;
end

function SendPost(cmd, action, uid, param,data)
	PostRequest(cmd, action, uid, param,data);
	
	SetTimerOnce( OnTimerCheckBusy, 0.1f );
	http_busy = true;
end

--检查是否忙
function OnTimerCheckBusy()
	if http_busy then
		--if not FindHudEffect(busy_fx) then
		WriteCon("mang");			
		if pLayer ~= nil and not pLayer:HasAniEffect( busy_fx ) then
			pLayer:AddFgEffect( busy_fx );
		end		
			--AddHudEffect(busy_fx);
		--end
	end
end

function HttpOK()
	http_busy = false;
	rookie_mask.onCallFlag = false;
	--DelHudEffect( busy_fx );
	if pLayer ~= nil then
		pLayer:SetSwallowTouch( false );
		if pLayer:HasAniEffect( busy_fx ) then
			pLayer:DelAniEffect( busy_fx );
		end
	end
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

