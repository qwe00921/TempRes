w_battle_machinemgr = {}
local p = w_battle_machinemgr;

p.targetHeroMachineLst = {}; --�ܻ���״̬���б�
p.targetEnemyMachineLst = {}; --�ܻ���״̬���б�

p.atkMachineLst = {}; 
p.atkEnemyMachineLst = {};



p.id = 0;


--�ܻ���״̬������,ÿ���ܻ���״̬�����ܻ���ʼ,������,�򸴻�վ������
function p.init()
	p.targetHeroMachineLst = {}; 
	p.targetEnemyMachineLst = {};
	p.atkMachineLst = {}; 
    p.atkEnemyMachineLst = {};
    --�ܻ���״̬��,Ĭ�ϵ�״̬���ǽ���,���Բ����ж��Ƿ����
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
		lAtkMachine.id = v.Position;
		p.atkMachineLst[#p.atkMachineLst + 1] = lAtkMachine;
	end;
	
	for k,v in ipairs(w_battle_mgr.enemyCamp.fighters) do
		local lAtkMachine = w_battle_atk_statemachine:new();
		lAtkMachine.id = v.Position;
		p.atkEnemyMachineLst[#p.atkEnemyMachineLst + 1] = lAtkMachine;
	end;
	
end;

--����ܻ���״̬��
function p.getTarStateMachine(camp,pos)
	if tonumber(camp) == W_BATTLE_HERO then
		return p.targetHeroMachineLst[pos]	
	else
		return p.targetEnemyMachineLst[pos]
	end
end

--��ù�����״̬��
function p.getAtkStateMachine(pos)
	local latkMachineLst =	{};
	if w_battle_mgr.atkCampType == W_BATTLE_HERO then
		latkMachineLst = p.atkMachineLst;
	else
		latkMachineLst = p.atkEnemyMachineLst;
	end;

	local latkMachine = nil;
	for k,v in ipairs(latkMachineLst) do
		if v.id == pos then
			latkMachine = v;
		end;
	end;
	return latkMachine;
end;


--�ж������ܻ���״̬���Ƿ񶼽�����
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
	if lres == true then
		WriteCon("all targetMachine finish");
	end
	return lres;
end;

--�ж����й���״̬�������ж���,�����ж��е�,����true
function p.checkAllAtkMachineHasTurn()	
	local lres = false;
	local latkMachineLst = nil;
	if w_battle_mgr.atkCampType == W_BATTLE_HERO then
		latkMachineLst = p.atkMachineLst;
	else
		latkMachineLst = p.atkEnemyMachineLst;
	end;
	
	for k,v in ipairs(latkMachineLst) do
		local lMachine = v
		if lMachine.turnState == W_BATTLE_TURN  then --�ж���
			lres = true;
			break;
		end
	end
	

	return lres;
end

--�ж����й���״̬���Ƿ���δ�ж���,��δ�ж��ķ���true,ֻ���ҷ���Ա����Ҫ���ж�
function p.checkAllAtkMachineHasNotTurn()
	local lres = false;
	local latkMachineLst = nil;
	local camp = nil;
	if w_battle_mgr.atkCampType == W_BATTLE_HERO then
		latkMachineLst = p.atkMachineLst;
		camp = w_battle_mgr.heroCamp; 
	else
		latkMachineLst = p.atkEnemyMachineLst;
		camp = w_battle_mgr.EnemyCamp;
	end;
	
	for k,v in ipairs(latkMachineLst) do
		local lMachine = v
		local lheroFighter = w_battle_mgr.heroCamp:FindFighter(v.id);
		if (lheroFighter ~= nil) and (lheroFighter.nowlife > 0) then
			if lMachine.turnState == W_BATTLE_NOT_TURN  then --δ�ж�
				lres = true;
				break;
			end
		end;
	end
	
	if lres == true then
		WriteCon("atk has not turn")
	else
		WriteCon("atk all is turn end")
	end
	
	return lres;
end
--[[
--�ж����й���״̬���Ƿ���δ�ж���,�����ж���,����true
function p.checkAllAtkMachineIsTurnEnd()
	local lres = true;
	for k,v in ipairs(p.atkMachineLst) do
		local lMachine = v
		if lMachine.turnState == W_BATTLE_TURNEND  then --���ж�
			lres = false;
			break;
		end
	end
	
	return lres;
end
]]--
function p.InitAtkTurnEnd(fightcamp)
	--for pos=1,#(p.atkMachineLst) do
	
	if fightcamp == W_BATTLE_HERO then
		camp = w_battle_mgr.heroCamp;
		latkMachineLst = p.atkMachineLst;
	else
		camp = w_battle_mgr.enemyCamp;
		latkMachineLst = p.atkEnemyMachineLst;
	end;
		
	for k,v in ipairs(latkMachineLst) do		
		local lMachine = v
		lMachine.turnState = W_BATTLE_NOT_TURN;   --δ�ж�
		
		local lFighter = camp:FindFighter(v.id);
		if (lFighter ~= nil) then
			if lFighter.nowlife > 0 then
				if lFighter.HasTurn == false then
					lMachine.turnState = W_BATTLE_TURNEND;
				end;
				
				if lFighter.nowlife ~= lFighter.Hp then
					local str = string.format("id=%d, Hp=%d nowLife=%d",lFighter:GetId(), lFighter.Hp,lFighter.nowlife)
					WriteCon(str);
				end;
			end;
		end;
	end
end

