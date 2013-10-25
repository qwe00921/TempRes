--------------------------------------------------------------
-- FileName:    after_drama.lua
-- author:      hst 2013-10-18
-- purpose:     ���鲥����ɽ���ȥҪ��������
--------------------------------------------------------------

after_drama = {}
local p = after_drama;
p.action = nil; --��Ҫִ�еĶ���
p.parameters = {};

BOSS_OUT = 1;       --BOSS����
STAGE_CLEAR = 2;    --ͨ��    


function p.DoAfterDrama()
	if p.action == nil then
		return;
	end
	
	if p.action == BOSS_OUT then
		boss_out.ShowUI( p.parameters[1], p.parameters[2], p.parameters[3]);
	
	elseif p.action == STAGE_CLEAR then
		task_map.BattleRefresh( p.parameters )
		
	end
	p.Clear();
end

function p.AddAction( action, parameters )
	p.action = action;
	p.parameters = parameters;
end

function p.Clear()
	p.action = nil; --��Ҫִ�еĶ���
    p.parameters = {};
end