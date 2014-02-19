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
	if substep == 1 then
		--p.nextGuidSubStep(); 
	elseif substep == 2 then
		p.nextGuidSubStep();
	elseif substep == 3 then
		w_battle_mgr.SetPVEAtkID(2); --2号位跳到目标的位置 状态机停下再显示遮照 
	elseif substep == 4 then
		w_battle_mgr.SetPVEAtkID(1);  
		local lstateMachine = w_battle_machinemgr.getAtkStateMachine(2); 		--让2号位的状态机继续行动(攻击)
		if lstateMachine ~= nil then
			lstateMachine:atk_startAtk();
		end; 
		--等怪全死后下一引导
	elseif substep == 5 then
		--等波次切换后进行下一引导		
	elseif substep == 6 then
		w_battle_mgr.SetPVETargerID(6);
		p.nextGuidSubStep();
	elseif substep == 7 then
		w_battle_mgr.SetPVEAtkID(2);  --等下一轮我方回合时调用 rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 8 then
			 --等战斗胜利,1号位怪死掉时,掉HP球(心之水晶),然后进行下一引导
	elseif substep == 9 then
		local lstateMachine = w_battle_machinemgr.getTarStateMachine(W_BATTLE_ENEMY,1); 		--让1号位的状态机继续死亡动画后的流程
		if lstateMachine ~= nil then
			lstateMachine:tar_dieEnd();
		end;
	    --怪物进场后调用 进行下一引导
	elseif substep == 10 then
		p.nextGuidSubStep();
	elseif substep == 11 then
	   --选择物品
		w_battle_useitem.UseItem(1);
		p.nextGuidSubStep();
	elseif substep == 12 then
		--使用物品
		w_battle_mgr.UseItem(1,2);
		p.nextGuidSubStep();
	elseif substep == 13 then
		p.nextGuidSubStep();		
		--等战斗任务结束调用 进行下一步引导
	elseif substep == 14 then
		--引导结束后任务战斗结束
		p.IsGuid = false;
		w_battle_pve.MissionOver(w_battle_mgr.MissionWin);  --任务结束,任务奖励界面
	end
	
end

function p.fighterSecondGuid(substep)
	p.IsGuid = true;
	p.guidstep = 3;
	p.substep = substep;
	if substep == 1 then

	elseif substep == 2 then

	elseif substep == 3 then

	elseif substep == 4 then

	elseif substep == 5 then
		--收到战斗发起返回消息后 rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 6 then
		--双方人物进场后 rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 7 then
		p.nextGuidSubStep();
	elseif substep == 8 then
		p.nextGuidSubStep();
	elseif substep == 9 then
		p.SetPVETargerID(2);
		p.nextGuidSubStep();
	elseif substep == 10 then
		p.nextGuidSubStep();
	elseif substep == 11 then
		w_battle_mgr.SetPVEAtkID(3);
		p.nextGuidSubStep();
	elseif substep == 12 then
		p.nextGuidSubStep();
	elseif substep == 13 then
		p.nextGuidSubStep();
	elseif substep == 14 then
		--战斗胜利并加载下一波敌人后 rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 15 then
		p.nextGuidSubStep();
	elseif substep == 16 then
		p.nextGuidSubStep();
	elseif substep == 17 then
	    --攻击敌人后 SP球必掉, 需飞向指定目标
		--rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 18 then
		p.nextGuidSubStep();
	elseif substep == 19 then
		p.nextGuidSubStep();
	elseif substep == 20 then
		w_battle_mgr.SetPVESkillAtkID(2);
		--技能发动后 rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 21 then
	    --战斗失败后
		--rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 22 then
		p.IsGuid = false;
	end	
	
end

function p.nextGuidSubStep()
	rookie_mask.Show(p.guidstep, p.substep + 1);
end