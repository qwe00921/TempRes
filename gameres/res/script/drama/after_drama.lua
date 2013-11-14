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

function p.DoAfterDrama()
--[[	if p.action == nil then
		x_battle_mgr.EnterBattle();
		return;
	end--]]
	
	local strParam = string.format("&target=%d",10002);
	SendReq( "Fight","StartPvP",10001,strParam );
	
	if p.action == BOSS_OUT then
		--boss_out.ShowUI( p.parameters[1], p.parameters[2], p.parameters[3]);
		x_battle_mgr.EnterBattle();
	elseif p.action == STAGE_CLEAR then
		--task_map.BattleRefresh( p.parameters )
		--x_battle_mgr.EnterBattle();
	end
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