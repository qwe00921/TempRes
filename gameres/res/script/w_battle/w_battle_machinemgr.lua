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
	
	lTargetMachine:setInHurt();  --��Ϊ����,״̬���ڲ��Զ��������,���������
end;
]]--

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
	return latkMachineLst[pos];
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
	return lres;
end;

--�ж����й���״̬�������ж���,�����ж��е�,����true
function p.checkAllAtkMachineHasTurn()	
	local lres = false;
	for pos=1,#(p.atkMachineLst) do
		local lMachine = p.atkMachineLst[pos];
		if lMachine.turnState == W_BATTLE_TURN  then --�ж���
			lres = true;
			break;
		end
	end
	

	return lres;
end

--�ж����й���״̬���Ƿ���δ�ж���,��δ�ж��ķ���true
function p.checkAllAtkMachineHasNotTurn()
	local lres = false;
	for pos=1,#(p.atkMachineLst) do
		local lMachine = p.atkMachineLst[pos];
		local lheroFighter = w_battle_mgr.heroCamp:FindFighter(pos);
		if (lheroFighter ~= nil) and (lheroFighter.nowlife > 0) then
			if lMachine.turnState == W_BATTLE_NOT_TURN  then --δ�ж�
				lres = true;
				break;
			end
		end;
	end
	
	return lres;
end

--�ж����й���״̬���Ƿ���δ�ж���,�����ж���,����true
function p.checkAllAtkMachineIsTurnEnd()
	local lres = true;
	for pos=1,#(p.atkMachineLst) do
		local lMachine = p.atkMachineLst[pos];
		if lMachine.turnState == W_BATTLE_TURNEND  then --δ�ж�
			lres = false;
			break;
		end
	end
	
	return lres;
end

function p.InitAtkTurnEnd()
	for pos=1,#(p.atkMachineLst) do
		local lMachine = p.atkMachineLst[pos];
		lMachine.turnState = W_BATTLE_NOT_TURN;   --δ�ж�
	end
end