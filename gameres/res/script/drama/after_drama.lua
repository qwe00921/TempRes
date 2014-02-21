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
	local rewardT = dlg_drama.rewardData or {};
	if maininterface.m_bgImage then
		maininterface.m_bgImage:SetVisible(false);
	end
	if viewType == after_drama_data.FIGHT then
		WriteCon("viewType FIGHT ");
		dlg_drama.CloseUI()
		if E_DEMO_VER== 4 then
			n_battle_mgr.EnterBattle( N_BATTLE_PVE, nextView, nowTeam );--进入战斗PVE
		else
			w_battle_mgr.EnterBattle( W_BATTLE_PVE, nextView, nowTeam );--进入战斗PVE
		end
	elseif viewType == after_drama_data.CHAPTER then
		dlg_drama.CloseUI();
		drama_mgr.ClearData();
		stageMap_main.openChapter(openView);
		WriteCon("viewType CHAPTER ");
	elseif viewType == after_drama_data.STAGE then
		dlg_drama.CloseUI();
		drama_mgr.ClearData();
		quest_main.ShowUI(nextView);
		WriteCon("viewType STAGE ");
	elseif viewType == after_drama_data.ROOKIE then
		WriteCon("viewType ROOKIE dlg_drama.storyId == "..dlg_drama.storyId);
		dlg_drama.CloseUI();
		drama_mgr.ClearData();
 		rookie_main.dramaCallBack(dlg_drama.storyId)
	elseif viewType == after_drama_data.REWARD then
		dlg_drama.CloseUI();
		drama_mgr.ClearData();
		quest_result.ShowWinView(rewardT)		
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