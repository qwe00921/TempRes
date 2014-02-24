w_battle_guid = {}
local p = w_battle_guid;

--战斗引导的控制

p.IsGuid = false;
p.guidstep = nil;
p.substep = nil;

--第一轮的新手引导,点击完的事件
function p.fighterGuid(substep)
	p.IsGuid = true;
	p.guidstep = 3;
	p.substep = substep;
	if p.substep == 1 then
		maininterface.ShowUI(rookie_main.userData);
		maininterface.HideUI();
		dlg_userinfo.HideUI();
		dlg_drama.ShowUI( 1, after_drama_data.ROOKIE, 0, 0);
	elseif p.substep == 2 then
		w_battle_mgr.EnterBattle(1,100011,1);
		--rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 3 then
		rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 4 then
		w_battle_pve.setBtnClick(2);
		--w_battle_mgr.SetPVEAtkID(2); --2号位跳到目标的位置 状态机停下再显示遮照 
	elseif p.substep == 5 then
		w_battle_pve.setBtnClick(1);
		--w_battle_mgr.SetPVEAtkID(1);  
		local lstateMachine = w_battle_machinemgr.getAtkStateMachine(2); 		--让2号位的状态机继续行动(攻击)
		if lstateMachine ~= nil then
			lstateMachine:atk_startAtk();
		end; 
		--等怪全死后下一引导
	elseif p.substep == 6 then
		w_battle_mgr.FightWin();
		--等波次切换后进行下一引导		
	elseif p.substep == 7 then
		--w_battle_pve.setBtnClick(6);
		w_battle_mgr.SetPVETargerID(3);
		rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 8 then
		w_battle_pve.setBtnClick(2);  --等下一轮我方回合时调用 rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif p.substep == 9 then
		--w_battle_mgr.HeroTurnEnd();
		--等战斗胜利,1号位怪受击时,掉HP球(心之水晶),然后进行下一引导
		--暴水晶
		rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 10 then
	   --w_battle_mgr.FightWin(); 
	--[[	local lstateMachine = w_battle_machinemgr.getTarStateMachine(W_BATTLE_ENEMY,1); 		--让1号位的状态机继续死亡动画后的流程
		if lstateMachine ~= nil then
			lstateMachine:tar_dieEnd();
		end;
		]]--
	    --BOSS怪物进场后,我方的下一回合调用 进行下一引导
	elseif p.substep == 11 then
		
	elseif p.substep == 12 then
	   --选择物品
		w_battle_pve.GuidUseItem1();
		rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 13 then
		--使用物品
		w_battle_useitem.UseItem(2);
		rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 14 then
		--等战斗任务结束 进行结算
		--quest_reward.CloseUI();
		--dlg_drama.ShowUI(2, after_drama_data.ROOKIE, 0, 0);
	elseif p.substep == 15 then
		p.IsGuid = false;
		quest_reward.CloseUI();
		dlg_drama.ShowUI(2, after_drama_data.ROOKIE, 0, 0);
		--引导结束后任务战斗结束
		--w_battle_mgr.MissionWin();  --任务结束,任务奖励界面
	end
	
end

function p.fighterSecondGuid(substep)
	p.IsGuid = true;
	p.guidstep = 5;
	p.substep = substep;
	if substep == 1 then  --剧情
		dlg_drama.ShowUI( 4, after_drama_data.ROOKIE,0,0)
	elseif substep == 2 then 
		maininterface.ShowUI(rookie_main.userData);
		country_main.ShowUI();
		rookie_mask.ShowUI(p.guidstep,substep);
	elseif substep == 3 then  --转到主页
		dlg_menu.HomeClick();
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 4 then --开启任务主界面
		stageMap_main.OpenWorldMap();
		PlayMusic_Task(1);
		maininterface.HideUI();
		
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 5 then --显示第一章
		stageMap_1.ChapterClick();
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 6 then --选择第一个任务
		quest_main.FightMissionClick();
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 7 then --剧情结束后发起战斗	
		dlg_drama.ShowUI( 5, after_drama_data.ROOKIE,0,0)
	elseif substep == 8 then
		--此时人物均已进场
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 9 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 10 then
		rookie_mask.ShowUI(p.guidstep, substep);
		--p.nextGuidSubStep();
	elseif substep == 11 then  --选择了一个敌人
		w_battle_mgr.SetPVETargerID(3);  
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 12 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 13 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 14 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 15 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 16 then
		w_battle_pve.setBtnClick(3);--我方三号位点击
	    --可以放开,至到战斗胜利
		--第一波战斗胜利并加载下一波敌人进场后 rookie_mask.ShowUI()
	elseif substep == 17 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 18 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 19 then
		--我方2号位的SP直接补满
		local lfighter = w_battle_mgr.heroCamp:FindFighter(2);
		lfighter.Sp = 100;
		w_battle_pve.SetHeroCardAttr(2, lfighter);
	    rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 20 then
		rookie_mask.ShowUI(p.guidstep, substep); --触发条件 增加为滑动
	elseif substep == 21 then
		--发动技能时,先卡住,加载引导
		rookie_mask.ShowUI(p.guidstep, substep); --触发条件 增加为滑动
	elseif substep == 22 then
		rookie_mask.ShowUI(p.guidstep, substep); 
	elseif substep == 23 then
		w_battle_pve.setBtnSkillClick(2);
	    --放开,自由战斗,等第三波战败,战败后,进入下一引导
		--rookie_mask.ShowUI(p.step,p.substep + 1)
		--rookie_mask.ShowUI(p.guidstep, substep); 
	elseif substep == 24 then		
		p.IsGuid = false;
		quest_reward.CloseUI();
		rookie_main.SendUpdateStep(5);
	end	
	
end

function p.nextGuidSubStep()
	rookie_mask.ShowUI(p.guidstep, p.substep);
end