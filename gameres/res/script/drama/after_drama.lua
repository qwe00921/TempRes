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
BATTLE_BEGIN = 3;

function p.DoAfterDrama(stageId)
	WriteCon("StageID fewafawefaw");
	n_battle_mgr.EnterBattle( N_BATTLE_PVE, stageId );
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