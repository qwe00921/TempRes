--------------------------------------------------------------
-- FileName: 	task_map_roll_state.lua
-- author:		zhangwq, 2013/09/06
-- purpose:		��ͼRoll��״̬
--------------------------------------------------------------

task_map_roll_state = {}
local p = task_map_roll_state;


--------------------------------------------------------------------------
local STATE_DISABLED 	= 1; --��ֹ״̬
local STATE_READY    	= 2; --����״̬������������
local STATE_ROLLING  	= 3; --���ڲ�����������Ч
local STATE_CLICK_PATH	= 4; --�ȴ����Ѱ·״̬
local STATE_WALKING  	= 5; --��ɫ���ڵ�ͼ��Ѱ·

local cur_roll_state = p.STATE_READY;	--��ǰRoll��״̬
local cur_roll_number = 0; 				--��ǰ�����������ӵ���

local is_busy = false;				--��ǰ�Ƿ�æ��
local is_player_jump_done = false;	--��ɫ�Ƿ���Ծ���
local is_roll_msg_recved = false;	--�Ƿ���յ������Roll����Ϣ
--------------------------------------------------------------------------

--�����ͼʱ�Ĵ���
function p.OnEnterMap()
	WriteCon( "[roll_state]: OnEnterMap()");
	p.Reset();
end

--�رյ�ͼʱ�Ĵ���
function p.OnCloseMap()
	WriteCon( "[roll_state]: OnCloseMap()");
	p.Reset();
end

--����
function p.Reset()
	WriteCon( "[roll_state]: Reset()");
	
	is_busy = false;
	is_player_jump_done = false;
	is_roll_msg_recved = false;
end

--��ɫ��Ծ���
function p.OnPlayerJumpDone()
	WriteCon( "[roll_state]: OnPlayerJumpDone()");
	
	is_player_jump_done = true;
	p.UpdateRollState();
end

--����Roll��������������
function p.OnSendRollRequest()
	WriteCon( "[roll_state]: OnSendRollRequest()");
	
	is_busy = true;
	is_roll_msg_recved = false;
	p.UpdateRollState();	
end

--�յ��������Ϣ��
function p.OnRecvRollMsg()
	WriteCon( "[roll_state]: OnRecvRollMsg()");
	
	is_roll_msg_recved = true;
	p.UpdateRollState();
end

--��ҵ����ͼѰ·
function p.OnClickPath()
	WriteCon( "[roll_state]: OnClickPath()");
	
	is_busy = true;
	is_player_jump_done = false;
	
	p.SetRollState_Walking();
	p.UpdateRollState();
end

--����Roll��״̬
function p.UpdateRollState()

	--���ݱ�־λ����Roll��״̬
	if is_busy then
		if is_player_jump_done and is_roll_msg_recved then
			is_busy = false;
			p.SetRollState_Ready();
		end
	end
	
	--����Roll�㰴ť״̬
	local isEnabled = (not is_busy) and task_map.IsActionPointOK();
	task_map_mainui.SetRollBtnState( isEnabled );
end

--���ص�ǰ״̬
function p.GetRollState()
	return cur_roll_state;
end

--���ص�ǰRoll����
function p.GetRollNumber()
	return cur_roll_number;
end

--���õ�ǰRoll����
function p.SetRollNumber( rollNum )
	cur_roll_number = rollNum;
end

--��յ�ǰRoll����
function p.ClearRollNumber()
	cur_roll_number = 0;
end

--����Ϊ��ֹ״̬
function p.SetRollState_Disabled()
	WriteCon( "[roll_state]: =>disabled state");
	
	cur_roll_state = STATE_DISABLED;
end

--����Ϊ����״̬
function p.SetRollState_Ready()
	WriteCon( "[roll_state]: =>ready state");
	
	cur_roll_state = STATE_READY;
	is_busy = false;
end

--����ΪRolling״̬������ҡ������Ч��
function p.SetRollState_Rolling()
	WriteCon( "[roll_state]: =>rolling state");
	
	cur_roll_state = STATE_ROLLING;
	is_busy = true;
end

--����Ϊ�ȴ����Ѱ·״̬
function p.SetRollState_ClickPath()
	WriteCon( "[roll_state]: =>click map state");
	
	cur_roll_state = STATE_STATE_CLICK_PATH;
	is_busy = true;
end

--����ΪWalking״̬����ɫ��������
function p.SetRollState_Walking()
	WriteCon( "[roll_state]: =>walking state");
	
	cur_roll_state = STATE_WALKING;
	is_busy = true;
end

--�Ƿ��ֹ״̬
function p.IsState_Disabled()
	return cur_roll_state == STATE_DISABLED;
end

--�Ƿ����״̬
function p.IsState_Ready()
	return (cur_roll_state == STATE_READY) and (not is_busy);
end

--�Ƿ�Rolling״̬
function p.IsState_Rolling()
	return cur_roll_state == STATE_ROLLING;
end

--�Ƿ�ClickPath״̬
function p.IsState_ClickPath()
	return cur_roll_state == STATE_STATE_CLICK_PATH;
end

--�Ƿ�Walking״̬
function p.IsState_Walking()
	return cur_roll_state == STATE_WALKING;
end