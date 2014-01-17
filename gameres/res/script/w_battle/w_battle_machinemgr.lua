w_battle_machinemgr = {}
local p = w_battle_machinemgr;

p.targetHeroMachineLst = {}; --受击者状态机列表
p.targetEnemyMachineLst = {}; --受击者状态机列表

p.atkMachineLst = {}; 
p.atkEnemyMachineLst = {};



p.id = 0;


--受击者状态机管理,每个受击者状态机以受击开始,以死亡,或复活站立结束
function p.init()
	p.targetHeroMachineLst = {}; 
	p.targetEnemyMachineLst = {};
	p.atkMachineLst = {}; 
    p.atkEnemyMachineLst = {};
    --受击者状态机,默认的状态都是结束,所以不用判断是否存在
	for pos=1,6 do
		local lTargetHeroMachine = w_battle_target_statemachine:new();
		lTargetHeroMachine:init(pos,W_BATTLE_HERO);
		p.targetHeroMachineLst[pos] = lTargetHeroMachine;
		
		local lTargetEnemyMachine = w_battle_target_statemachine:new();
		lTargetEnemyMachine:init(pos,W_BATTLE_ENEMY);
		p.targetEnemyMachineLst[pos] = lTargetEnemyMachine;
		
	end;
--[[
	local camp = nil;
	if w_battle_mgr.atkCampType == W_BATTLE_HERO then
		camp = w_battle_mgr.heroCamp;
	else
		camp = w_battle_mgr.enemyCamp;
	end
	]]
	for k,v in ipairs(w_battle_mgr.heroCamp.fighters) do
		local lAtkMachine = w_battle_atk_statemachine:new();
		p.atkMachineLst[v:GetId()] = lAtkMachine;
	end;
	
	for k,v in ipairs(w_battle_mgr.enemyCamp.fighters) do
		local lAtkMachine = w_battle_atk_statemachine:new();
		p.atkEnemyMachineLst[v:GetId()] = lAtkMachine;
	end;
	
end;

--[[
function p.setInHurt(camp,pos)
	local lTargetMachine = nil;
	if camp == W_BATTLE_HERO then
		lTargetMachine = p.targetHeroMachineLst[pos] 
	else
		lTargetMachine = p.targetEnemyMachineLst[pos] 
	end
	
	lTargetMachine:setInHurt();  --设为受伤,状态机内部自动解除受伤,并处理后续
end;
]]--

--获得受击者状态机
function p.getTarStateMachine(camp,pos)
	if tonumber(camp) == W_BATTLE_HERO then
		return p.targetHeroMachineLst[pos]	
	else
		return p.targetEnemyMachineLst[pos]
	end
end

--获得攻击者状态机
function p.getAtkStateMachine(pos)
	local latkMachineLst =	{};
	if w_battle_mgr.atkCampType == W_BATTLE_HERO then
		latkMachineLst = p.atkMachineLst;
	else
		latkMachineLst = p.atkEnemyMachineLst;
	end;
	return latkMachineLst[pos];
end;


--判断所有受击的状态机是否都结束了
function p.checkAllTargetMachineEnd()  
	local lres = true;
	for pos=1,6 do
		local lTargetMachine = p.targetHeroMachineLst[pos];
		if lTargetMachine:IsEnd() == false then
			local lFighter = lTargetMachine.tarFighter;
			if lFighter ~= nil then
				if(lFighter:GetTargerTimes() == 0) then
					lres = false;
					break;
				end;
			end;
		end
	end
	
	for pos=1,6 do
		local lTargetMachine = p.targetEnemyMachineLst[pos];
		if lTargetMachine:IsEnd() == false then
			local lFighter = lTargetMachine.tarFighter;
			if lFighter ~= nil then
				if(lFighter:GetTargerTimes() == 0) then
					lres = false;
					break;
				end;
			end;
		end
	end	
	return lres;
end;

--判断所有攻击状态机处于行动中,若有行动中的,返回true
function p.checkAllAtkMachineHasTurn()	
	local lres = false;
	for pos=1,#(p.atkMachineLst) do
		local lMachine = p.atkMachineLst[pos];
		if lMachine.turnState == W_BATTLE_TURN  then --行动中
			lres = true;
			break;
		end
	end
	

	return lres;
end

--判断所有攻击状态机是否有未行动的,有未行动的返回true
function p.checkAllAtkMachineHasNotTurn()
	local lres = false;
	for pos=1,#(p.atkMachineLst) do
		local lMachine = p.atkMachineLst[pos];
		local lheroFighter = w_battle_mgr.heroCamp:FindFighter(pos);
		if (lheroFighter ~= nil) and (lheroFighter.nowlife > 0) then
			if lMachine.turnState == W_BATTLE_NOT_TURN  then --未行动
				lres = true;
				break;
			end
		end;
	end
	
	return lres;
end

--判断所有攻击状态机是否都已未行动的,若都行动了,返回true
function p.checkAllAtkMachineIsTurnEnd()
	local lres = true;
	for pos=1,#(p.atkMachineLst) do
		local lMachine = p.atkMachineLst[pos];
		if lMachine.turnState == W_BATTLE_TURNEND  then --未行动
			lres = false;
			break;
		end
	end
	
	return lres;
end

function p.InitAtkTurnEnd()
	for pos=1,#(p.atkMachineLst) do
		local lMachine = p.atkMachineLst[pos];
		lMachine.turnState = W_BATTLE_NOT_TURN;   --未行动
	end
end