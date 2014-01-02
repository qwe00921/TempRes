--------------------------------------------------------------
-- FileName:    after_drama.lua
-- author:      hst 2013-10-18
-- purpose:     剧情播放完成接下去要做的事情
--------------------------------------------------------------

after_drama = {}
local p = after_drama;
p.action = nil; --需要执行的动作
p.parameters = {};

BOSS_OUT = 1;       --BOSS出现
STAGE_CLEAR = 2;    --通关    
BATTLE_BEGIN = 3;

function p.DoAfterDrama(stageId)
	WriteCon("StageID fewafawefaw");
	maininterface.m_bgImage:SetVisible(false);
	if E_DEMO_VER == 4 then
		n_battle_mgr.EnterBattle( N_BATTLE_PVE, stageId );
	elseif E_DEMO_VER == 5 then
		w_battle_mgr.EnterBattle( N_BATTLE_PVE, stageId );
	end;
	p.Clear();
end

function p.AddAction( action, parameters )
	p.action = action;
	p.parameters = parameters;
end

function p.Clear()
	p.action = nil; --需要执行的动作
    p.parameters = {};
end