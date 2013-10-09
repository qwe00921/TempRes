--------------------------------------------------------------
-- FileName: 	task_map_roll_state.lua
-- author:		zhangwq, 2013/09/06
-- purpose:		地图Roll点状态
--------------------------------------------------------------

task_map_roll_state = {}
local p = task_map_roll_state;


--------------------------------------------------------------------------
local STATE_DISABLED 	= 1; --禁止状态
local STATE_READY    	= 2; --就绪状态，可以扔骰子
local STATE_ROLLING  	= 3; --正在播放扔骰子特效
local STATE_CLICK_PATH	= 4; --等待点击寻路状态
local STATE_WALKING  	= 5; --角色正在地图上寻路

local cur_roll_state = p.STATE_READY;	--当前Roll点状态
local cur_roll_number = 0; 				--当前丢出来的骰子点数

local is_busy = false;				--当前是否忙？
local is_player_jump_done = false;	--角色是否跳跃完成
local is_roll_msg_recved = false;	--是否接收到服务端Roll点消息
--------------------------------------------------------------------------

--进入地图时的处理
function p.OnEnterMap()
	WriteCon( "[roll_state]: OnEnterMap()");
	p.Reset();
end

--关闭地图时的处理
function p.OnCloseMap()
	WriteCon( "[roll_state]: OnCloseMap()");
	p.Reset();
end

--重置
function p.Reset()
	WriteCon( "[roll_state]: Reset()");
	
	is_busy = false;
	is_player_jump_done = false;
	is_roll_msg_recved = false;
end

--角色跳跃完成
function p.OnPlayerJumpDone()
	WriteCon( "[roll_state]: OnPlayerJumpDone()");
	
	is_player_jump_done = true;
	p.UpdateRollState();
end

--发送Roll点请求给服务端了
function p.OnSendRollRequest()
	WriteCon( "[roll_state]: OnSendRollRequest()");
	
	is_busy = true;
	is_roll_msg_recved = false;
	p.UpdateRollState();	
end

--收到服务端消息了
function p.OnRecvRollMsg()
	WriteCon( "[roll_state]: OnRecvRollMsg()");
	
	is_roll_msg_recved = true;
	p.UpdateRollState();
end

--玩家点击地图寻路
function p.OnClickPath()
	WriteCon( "[roll_state]: OnClickPath()");
	
	is_busy = true;
	is_player_jump_done = false;
	
	p.SetRollState_Walking();
	p.UpdateRollState();
end

--更新Roll点状态
function p.UpdateRollState()

	--根据标志位更新Roll点状态
	if is_busy then
		if is_player_jump_done and is_roll_msg_recved then
			is_busy = false;
			p.SetRollState_Ready();
		end
	end
	
	--更新Roll点按钮状态
	local isEnabled = (not is_busy) and task_map.IsActionPointOK();
	task_map_mainui.SetRollBtnState( isEnabled );
end

--返回当前状态
function p.GetRollState()
	return cur_roll_state;
end

--返回当前Roll点数
function p.GetRollNumber()
	return cur_roll_number;
end

--设置当前Roll点数
function p.SetRollNumber( rollNum )
	cur_roll_number = rollNum;
end

--清空当前Roll点数
function p.ClearRollNumber()
	cur_roll_number = 0;
end

--设置为禁止状态
function p.SetRollState_Disabled()
	WriteCon( "[roll_state]: =>disabled state");
	
	cur_roll_state = STATE_DISABLED;
end

--设置为就绪状态
function p.SetRollState_Ready()
	WriteCon( "[roll_state]: =>ready state");
	
	cur_roll_state = STATE_READY;
	is_busy = false;
end

--设置为Rolling状态（播放摇骰子特效）
function p.SetRollState_Rolling()
	WriteCon( "[roll_state]: =>rolling state");
	
	cur_roll_state = STATE_ROLLING;
	is_busy = true;
end

--设置为等待点击寻路状态
function p.SetRollState_ClickPath()
	WriteCon( "[roll_state]: =>click map state");
	
	cur_roll_state = STATE_STATE_CLICK_PATH;
	is_busy = true;
end

--设置为Walking状态（角色在跳跳）
function p.SetRollState_Walking()
	WriteCon( "[roll_state]: =>walking state");
	
	cur_roll_state = STATE_WALKING;
	is_busy = true;
end

--是否禁止状态
function p.IsState_Disabled()
	return cur_roll_state == STATE_DISABLED;
end

--是否就绪状态
function p.IsState_Ready()
	return (cur_roll_state == STATE_READY) and (not is_busy);
end

--是否Rolling状态
function p.IsState_Rolling()
	return cur_roll_state == STATE_ROLLING;
end

--是否ClickPath状态
function p.IsState_ClickPath()
	return cur_roll_state == STATE_STATE_CLICK_PATH;
end

--是否Walking状态
function p.IsState_Walking()
	return cur_roll_state == STATE_WALKING;
end