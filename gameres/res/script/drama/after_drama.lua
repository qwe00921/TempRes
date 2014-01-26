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
	local viewType = dlg_drama.openViewType
	WriteCon("viewType = "..viewType);
	local openView = dlg_drama.viewId
	WriteCon("openView = "..openView);
	local nextView = dlg_drama.viewId
	WriteCon("nextView = "..nextView);
	local nowTeam = dlg_drama.teamId
	WriteCon("nowTeam = "..nowTeam);
	maininterface.m_bgImage:SetVisible(false);
	
	if viewType == after_drama_data.FIGHT then
		WriteCon("viewType FIGHT ");
		if E_DEMO_VER== 4 then
			n_battle_mgr.EnterBattle( N_BATTLE_PVE, nextView, nowTeam );--进入战斗PVE
		else
			w_battle_mgr.EnterBattle( W_BATTLE_PVE, nextView, nowTeam );--进入战斗PVE
		end
	elseif viewType == after_drama_data.CHAPTER then
		stageMap_main.openChapter();
		WriteCon("viewType CHAPTER ");
	elseif viewType == after_drama_data.STAGE then
		quest_main.ShowUI(nextView);
		WriteCon("viewType STAGE ");
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