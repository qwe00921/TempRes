--------------------------------------------------------------
-- FileName: 	w_battle_mgr.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		ս������������ʵ����demo v2.0
--------------------------------------------------------------

w_battle_mgr = {}
local p = w_battle_mgr;

p.heroCamp = nil;			--�����Ӫ
p.enemyCamp = nil;			--�ж���Ӫ
p.uiLayer = nil;			--ս����
p.heroUIArray = nil;		--�����ӪվλUITag��
p.enemyUIArray = nil;		--�ж���ӪվλUITag��
p.enemyUILockArray = nil;   --�ж�Ŀ�걻��������־


p.petNode={};       --˫��������
p.petNameNode={};   --˫���������ƽ��

p.imageMask = nil			--�����ɰ���Ч
p.PVEEnemyID = nil;   --��ǰ�������ĵ���ID
--p.PVEHeroID  = nil;  --��ǰ��������Ӣ��ID
p.PVEShowEnemyID = nil;  --��ǰ��ʾѪ���ĵ���ID
p.LockEnemy = false; --�����Ƿ���������
p.LockFagID = nil;  --֮ǰ��������־

local isPVE = false;
local isActive = false;
local useParallelBatch = true; --�Ƿ�.ʹ�ò�������
p.isBattleEnd = false;
p.isCanSelFighter = false;  --�Ƿ��п�ѡ��Ĺ���,ս��UI�������ҷ���Աʱ,�����жϴ˱���,�ٴ�����

local BATTLE_PVE = 1;
local BATTLE_PVP = 2;
--p.seqStar = nil;

p.batchIsFinish = true;
p.battle_batch  = nil;
p.atkCampType = nil;
p.battleIsStart = false;
p.AtkTimes  = 0;
p.SkillTimes= 0;
p.CritTimes = 0;
p.JoinAtkTimes = 0;
p.MoreDamageTimes = 0;


function p.init()
	--p.heroCamp = nil;			--�����Ӫ
	p.enemyCamp = nil;			--�ж���Ӫ
	--p.uiLayer = nil;			--ս����
	--p.heroUIArray = nil;		--�����ӪվλUITag��
	--p.enemyUIArray = nil;		--�ж���ӪվλUITag��
	--p.enemyUILockArray = nil;   --�ж�Ŀ�걻��������־
	
	p.PVEEnemyID = nil;   --��ǰ�������ĵ���ID
	--p.PVEHeroID = nil;
	p.PVEShowEnemyID = nil;  --��ǰ��ʾѪ���ĵ���ID
	p.LockEnemy = false; --�����Ƿ���������
	p.LockFagID = nil;  --֮ǰ��������־
	
	p.batchIsFinish = true;
	p.battle_batch  = nil;
	p.atkCampType = nil;
	p.battleIsStart = true;

	p.AtkTimes  = 0;
	p.SkillTimes= 0;
	p.CritTimes = 0;
	p.JoinAtkTimes = 0;
	p.MoreDamageTimes = 0;	
	
end;


function p.starFighter()
	p.init();
--	w_battle_PVEStaMachMgr.init();
	p.InitLockAction();
	GetBattleShow():EnableTick( true );
	if w_battle_db_mgr.step == 1 then  --ֻ�е�һ������Ҫ��������
		p.createHeroCamp( w_battle_db_mgr.GetPlayerCardList() );
	end;
    p.createEnemyCamp( w_battle_db_mgr.GetTargetCardList() );
	--�����ŵĹ���,����Ŀ��
    p.PVEEnemyID = p.enemyCamp:GetFirstActiveFighterID(nil);
	--p.PVEHeroID = p.heroCamp:GetFirstActiveFighterPos(nil);
	p.PVEShowEnemyID = p.PVEEnemyID; 
	p.LockEnemy = false;
	p.isCanSelFighter = true;	
	p.atkCampType = W_BATTLE_HERO;
	w_battle_machinemgr.init();
	p.HeroBuffStarTurn();  --�ҷ�BUFF��ʼ�׶�
	
end;
--[[
--���﹥��
function p.SetPVEMonsterAtk(atkID)
   WriteCon( "SetPVEMonsterAtk ID:"..tonumber(atkID));
   if p.battleIsStart ~= true then
		WriteCon( "Warning! Battle not Start");
		return false;
   end;

   local atkFighter = w_battle_mgr.enemyCamp:FindFighter( tonumber( atkID ) );

   local targerID = w_battle_mgr.PVEHeroID;
   if targerID == nil then
      WriteCon( "Error! SetPVEAtkID targerID is nil");
	  return false;
   end; 

   if atkFighter == nil then
      WriteCon( "Error! SetPVEAtkID atkFighter is nil! id:"..tostring(atkID));
	  return false;
   end;

   local targetFighter = w_battle_mgr.heroCamp:FindFighter( tonumber( targerID ) );
   if targetFighter == nil then
      WriteCon( "Error! SetPVEAtkID targetFighter is nil! id:"..tostring(targerID));
	  return false;
   end;


   --��ѡĿ���,�ȼ����˺�
   local damage,lIsJoinAtk,lIsCrit = w_battle_atkDamage.SimpleDamage(atkFighter, targetFighter);
   targetFighter:SubLife(damage); --�۵�����,�����ֲ�Ҫ��
   

   --Ĭ��ѡ���Ŀ��,�ж����ｫ��
	if targetFighter.nowlife <= 0 then
		p.PVEHeroID = p.heroCamp:GetFirstActiveFighterPos(targerID); --ѡ���¸�nowHP > 0��Ĺ���Ŀ��
	end;
	
	
	--��ΪĿ��,δ����
	targetFighter:BeTarTimesAdd(atkID);

	local lStateMachine = w_battle_machinemgr.getAtkStateMachine(atkID);
	local damageLst = {};
	damageLst[1] = damage;
	lStateMachine.turnState = W_BATTLE_TURN;  --�ж���
	lStateMachine:init(atkID,atkFighter,W_BATTLE_ENEMY,targetFighter, W_BATTLE_HERO,damageLst,lIsCrit,lIsJoinAtk);
	
	--return true;	
	
end;

]]--
--���������Լ�,�ܻ���ID֮ǰ��ѡ���Զ�ѡ��,��ս�����������
function p.SetPVEAtkID(atkID,IsMonster,targetID)
    WriteCon( "SetPVEAtkID:"..tonumber(atkID));
    if p.battleIsStart ~= true then
		WriteCon( "Warning! Battle not Start");
		return false;
    end;

	local atkFighter = nil;
	if IsMonster == true then
		atkFighter = w_battle_mgr.enemyCamp:FindFighter( tonumber( atkID ) );
    else
		atkFighter = w_battle_mgr.heroCamp:FindFighter( tonumber( atkID ) );
	end;
   
    local atkCampType = nil;
	local targetCampType = nil;
    --local targerID = nil;
    if IsMonster == true then
		--targerID = w_battle_mgr.PVEHeroID;
		atkCampType = W_BATTLE_ENEMY;
		targetCampType = W_BATTLE_HERO;
    else
		targerID = w_battle_mgr.PVEEnemyID;
		atkCampType = W_BATTLE_HERO;
		targetCampType = W_BATTLE_ENEMY;
    end;

   if targerID == nil then
      WriteCon( "Error! SetPVEAtkID targerID is nil");
	  return false;
   end; 

   if atkFighter == nil then
      WriteCon( "Error! SetPVEAtkID atkFighter is nil! id:"..tostring(atkID));
	  return false;
   end;

	local targetFighter = nil;
	if IsMonster == true then
		targetFighter = w_battle_mgr.heroCamp:FindFighter( tonumber( targerID ) );	
	else
		targetFighter = w_battle_mgr.enemyCamp:FindFighter( tonumber( targerID ) );	
	end

   if targetFighter == nil then
      WriteCon( "Error! SetPVEAtkID targetFighter is nil! id:"..tostring(targerID));
	  return false;
   end;

	if IsMonster ~= true then
	   if w_battle_mgr.isCanSelFighter == false then  --û�д���Ŀ���ѡ
		  WriteCon( "Warning! All targetFighter is Dead!");
		  return false;  
	   end;
    end;

   --��ѡĿ���,�ȼ����˺�
   local damage,lIsJoinAtk,lIsCrit = w_battle_atkDamage.SimpleDamage(atkFighter, targetFighter,IsMonster);
   targetFighter:SubLife(damage); --�۵�����,�����ֲ�Ҫ��
   
    if IsMonster ~= true then
	   --Ĭ��ѡ���Ŀ��,�ж����ｫ��
		if (targetFighter.nowlife <= 0) and (p.LockEnemy == false) then
			p.PVEEnemyID = p.enemyCamp:GetFirstActiveFighterID(targerID); --ѡ���¸�nowHP > 0��Ĺ���Ŀ��
		end
	end;
	
	--��ΪĿ��,δ����
	targetFighter:BeTarTimesAdd(atkID);

	local lStateMachine = w_battle_machinemgr.getAtkStateMachine(atkID);
	local damageLst = {};
	damageLst[1] = damage;
	local lCritLst = {}
	lCritLst[1] = lIsCrit;
	local lJoinAtkLst = {}
	lJoinAtkLst[1] = lIsJoinAtk;
	
	lStateMachine.turnState = W_BATTLE_TURN;  --�ж���
	lStateMachine:init(atkID,atkFighter,atkCampType,targetFighter, targetCampType,damageLst,lCritLst,lJoinAtkLst,false);
	
	return true;
end;					



--���������Լ�,�ܻ���ID֮ǰ��ѡ���Զ�ѡ��,��ս�����������
function p.SetPVESkillAtkID(atkID, IsMonster,targetID)
   WriteCon( "SetPVESkillAtkID:"..tonumber(atkID));
	local atkFighter = nil;
	if IsMonster == true then
		atkFighter = w_battle_mgr.enemyCamp:FindFighter( tonumber( atkID ) );
	else
		atkFighter = w_battle_mgr.heroCamp:FindFighter( tonumber( atkID ) );
	end;

    local atkCampType = nil;
	local targetCampType = nil;	
    
    if IsMonster == true then
		atkCampType = W_BATTLE_ENEMY;
		targetCampType = W_BATTLE_HERO;
    else
		targerID = w_battle_mgr.PVEEnemyID;
		atkCampType = W_BATTLE_HERO;
		targetCampType = W_BATTLE_ENEMY;
    end;
	
    if targerID == nil then
      WriteCon( "Error! SetPVEAtkID targerID is nil");
	  return false;
    end; 

    if atkFighter == nil then
      WriteCon( "Error! SetPVEAtkID atkFighter is nil! id:"..tostring(atkID));
	  return false;
    end;

    local targetFighter = nil;
    if IsMonster == true then
       targetFighter = w_battle_mgr.heroCamp:FindFighter( tonumber( targerID ) );
    else
	   targetFighter = w_battle_mgr.enemyCamp:FindFighter( tonumber( targerID ) );
    end;
    if targetFighter == nil then
       WriteCon( "Error! SetPVEAtkID targetFighter is nil! id:"..tostring(targerID));
	   return false;
    end;

    if IsMonster ~= true then
	   if w_battle_mgr.isCanSelFighter == false then  --û�д���Ŀ���ѡ
		  WriteCon( "Warning! All targetFighter is Dead!");
		  return false;  
	   end;
    end;

   local skillID = atkFighter.Skill;

   local distanceRes = tonumber( SelectCell( T_SKILL_RES, skillID, "distance" ) );--Զ�����ս���ж�;	
   local targetType   = tonumber( SelectCell( T_SKILL, skillID, "Target_type" ) );
   local skillType = tonumber( SelectCell( T_SKILL, skillID, "Skill_type" ) );

    if (distanceRes == nil) then
		WriteCon( "Error! Skil distance Config is Error! skill="..tostring(skillID));
		return false;
    end;

    if (targetType == nil) then
		WriteCon( "Error! Skil Target_type Config is Error! skill="..tostring(skillID));
		return false;
    end;
   
    if (skillType == nil) then
		WriteCon( "Error! Skil Skill_type Config is Error! skill="..tostring(skillID));
		return false;
	end;

	--�ѿ�ʼ����,������δ��ʼ
	--p.AtkAdd(atkID);
	    
	local latkCap = nil;
	local ltargetCamp = nil;
	if IsMonster == true then
		latkCap = p.enemyCamp;
		ltargetCamp = p.heroCamp;
	else
		latkCap = p.heroCamp;
		ltargetCamp = p.enemyCamp;
	end;
	
	local lStateMachine = nil;
	local isAoe = false;
	local damageLst = {};
	local lCritLst = {}
	local lJoinAtkLst = {}
	
	
	lStateMachine = w_battle_machinemgr.getAtkStateMachine(atkID);
	lStateMachine.turnState = W_BATTLE_TURN;  --�ж���		

	if (skillType == W_SKILL_TYPE_1)  then -- �����˺���
		if (targetType == W_SKILL_TARGET_TYPE_1) then --����
			local damage,lIsJoinAtk = w_battle_atkDamage.SkillDamage(skillID,atkFighter, targetFighter);
			damageLst[1] = damage;
			lCritLst[1] = lIsCrit;
			lJoinAtkLst[1] = lIsJoinAtk;
			targetFighter:SubLife(damage); --�۵�����,�����ֲ�Ҫ��
			targetFighter:BeTarTimesAdd(atkID); --��ΪĿ��,δ����
		elseif( (targetType == W_SKILL_TARGET_TYPE_2) or (targetType == W_SKILL_TARGET_TYPE_3)	or (targetType == W_SKILL_TARGET_TYPE_4)) then
		--Ⱥ��, ��ս�嵽��Ļ�м�, Զ��վԭ��
			local damage,lIsJoinAtk = w_battle_atkDamage.SkillDamage(skillID,atkFighter, targetFighter);
			ltargetCamp:SubLife(damage); --�����Ѵ����˿ۼ�����
			ltargetCamp:BeTarTimesAdd(atkID) --�����Ѵ����˳�ΪĿ��
			for pos=1,6 do
				damageLst[pos] = damage
				lCritLst[pos] = false;
				lJoinAtkLst[pos] = false;
			end
			isAoe = true;
		else
			WriteCon( "Error! Skil Config is Error! skilltype and targettype is not right! skill="..tostring(skillID));
			return false;
		end

		if IsMonster ~= true then
			if (targetFighter.nowlife <= 0) and (p.LockEnemy == false) then
				p.PVEEnemyID = ltargetCamp:GetFirstActiveFighterID(targerID); --ѡ���¸�nowHP > 0��Ĺ���Ŀ��
			end
		end;
	else --�����ָ� or ��BUFF or ����,   ����ֻ����Ʒ��ʹ��
		--�����ָ����BUFF�����༼��,�����Ƿ�Ⱥ�嶼 վԭ��
		local damage = 0;
		if skillType == 2 then  --�ָ�����м�Ѫ
			damage = w_battle_atkDamage.SkillBuffDamage(skillID,atkFighter);
			
			for pos=1,6 do
				damageLst[pos] = damage
			end		
		end;
		
		if (targetType == W_SKILL_TARGET_TYPE_11) then --�Լ�
			targetFighter = atkFighter;
		elseif (targetType == W_SKILL_TARGET_TYPE_12) then --�ѷ�Ⱥ��
			isAoe = true;
		else
			WriteCon( "Error! Skil Config is Error! skilltype and targettype is not right! skill="..tostring(skillID));
			return false;
		end
	end;
	
	
--	local id = w_battle_PVEStaMachMgr.addStateMachine(lStateMachine);
	--lStateMachine:init(id,atkFighter,atkCampType,targetFighter, W_BATTLE_HERO,damage,lIsCrit,lIsJoinAtk,true,skillID);
	lStateMachine:init(atkID,atkFighter,atkCampType,targetFighter, targetCampType,damageLst,lCritLst ,lJoinAtkLst,true,skillID,isAoe);	
	
	return true;
end;					



function p.GetBattleBatch()
	if p.batchIsFinish == true then
		p.batchIsFinish = false;			
		p.battle_batch = p.newBatch();
	end
	
	return p.battle_batch;
end;

function p.newBatch()
	local battleShow = GetBattleShow();
	if battleShow == nil then
		WriteCon( "w_battle getBattleShow() failed");
		return nil;
	end
	
   	RegCallBack_BattleShowFinished(p.BatchCallBack);
	
	local seqBatch = battleShow:AddSequenceBatch();
	return seqBatch;
end;

function p.BatchCallBack()
	p.batchIsFinish = true;
end;


--���ĳ����Ʒ��ʹ�õ�����б�
function p.GetItemCanUsePlayer(pItemPos)
	local lPlayer = {};

    local lid = w_battle_db_mgr.GetItemid(pItemPos)
	local ltype = tonumber(SelectCell( T_MATERIAL, lid, "type" ));
	if ltype ~= W_MATERIAL_TARGET1 then --����ҩˮ����
		return nil;
	end
	
	local subtype = tonumber(SelectCell( T_MATERIAL, lid, "subtype" ));
	local effect_type = tonumber(SelectCell( T_MATERIAL, lid, "effect_type" ));
	local effect_value = tonumber(SelectCell( T_MATERIAL, lid, "effect_value" ));
	local effect_targer = tonumber(SelectCell( T_MATERIAL, lid, "effect_targer" ));
	if effect_targer == W_MATERIAL_TARGET2 then  --Ⱥ���
		for k,v in ipairs(p.heroCamp.fighters) do
			lPlayer[#lPlayer + 1 ] = v.Position;
		end
	elseif effect_targer == W_MATERIAL_TARGET1 then --�����
		if subtype == W_MATERIAL_SUBTYPE1 then  --HP>0��
				for k,v in ipairs(p.heroCamp.fighters) do
					if (v.nowlife > 0) and (v.nowlife < v.maxHp) then
						lPlayer[#lPlayer + 1 ] = v.Position;
					end
				end
			
		elseif subtype == W_MATERIAL_SUBTYPE2 then --����Ӧ״̬�Ĳſ���
			for k,v in ipairs(p.heroCamp.fighters) do
				if effect_type == W_BATTLE_REVIVAL then --������Ʒ
					if(v.nowlife == 0) then
						lPlayer[#lPlayer + 1 ] = v.Position;	
					end
				else  --��״̬��BUFF
					if v:HasBuff(effect_type) == true then
						lPlayer[#lPlayer + 1 ] = v.Position;	
					end
				end;
			end
		
		elseif subtype == W_MATERIAL_SUBTYPE3 then --����δ������,������
			for k,v in ipairs(p.heroCamp.fighters) do
				if v.nowlife > 0  then
					lPlayer[#lPlayer + 1 ] = v.Position;
				end
			end
		end
	
	end
	
	return lPlayer;
end;

--ʹ��ĳ����Ʒ
function p.UseItem(pItemPos, pHeroPos)
	local lid = w_battle_db_mgr.GetItemid(pItemPos)
	local effect_skill = SelectCell( T_MATERIAL_RES, lid, "effect" );  --���ܹ�Ч
	local batch = w_battle_mgr.GetBattleBatch(); 
	
	local effect_targer = tonumber(SelectCell( T_MATERIAL, lid, "effect_targer" ));
	if effect_targer == W_MATERIAL_TARGET2 then  --Ⱥ���
		for k,v in ipairs(p.heroCamp.fighters) do
			if v:UseItem(lid) == true then
				cmdBuff = createCommandEffect():AddFgEffect( 0.5, v:GetNode(), effect_skill );
				local seqTemp = batch:AddSerialSequence();
				seqTemp:AddCommand( cmdBuff );
			end;		
		end;
	else
		local fighter = p.heroCamp:FindFighter(pHeroPos);
		if fighter~= nil then
			if fighter:UseItem(lid) == true then
				cmdBuff = createCommandEffect():AddFgEffect( 0.5, fighter:GetNode(), effect_skill );
				local seqTemp = batch:AddSerialSequence();
				seqTemp:AddCommand( cmdBuff );		
			end;
		end
	end
	
	w_battle_useitem.RefreshUI()  --��Ʒʹ�����,����ˢ��UI, UI���ڲ�����p.GetItemCanUsePlayer
end;

--�ҷ�BUFF�׶�
function p.HeroBuffStarTurn()
	WriteCon( "HeroBuffStarTurn");
	p.atkCampType = W_BATTLE_HERO;
	p.HeroBuffTurnEnd();  --ֱ���ж��ҷ�BUFF����
end;

--����Ƿ����е�BUFF���������
function p.CheckHeroBuffIsEnd()
  
end;

--�ҷ�BUFF����
function p.HeroBuffTurnEnd()
	WriteCon( "HeroBuffTurnEnd");	
	if p.heroCamp:isAllDead() == true then  --�ҷ�ȫ��
	  p.FightLose();	
	else 	
	  --�ҷ������˻���
	  w_battle_pve.RoundStar();  --UI����ȫ������
	  w_battle_machinemgr.InitAtkTurnEnd(); --��ʶ��ҵĻغ�
	  --�ҷ�ʹ����Ʒ�׶�
	  --   ��ѡ��һ����Ʒ��,�õ������Ʒ��ʹ�õ�����б�,����w_battle_useitem.RefreshUI()
	  --�ҷ��ж��׶�,ֻҪ���ֹ����͵��ڽ�������׶�
	end
end;

--����ҷ��ж��Ƿ����
function p.CheckHeroTurnIsEnd()
	--if p.heroCamp:CheckAtkTurnEnd() == true then --Ӣ�۵ĻغϽ���
		p.HeroTurnEnd()
	--end
	
end;

--�ҷ��ж�����
function p.HeroTurnEnd()
	WriteCon( "HeroTurnEnd");	
	w_battle_pve.PickStep(p.CheckEnemyAllDied);  --ʰȡ���佱��,���ص����з��Ƿ�ȫ��
end;

--�з�BUFF��ʼ
function p.EnemyBuffStarTurn()
	WriteCon( "EnemyBuffStarTurn");	
   p.atkCampType = W_BATTLE_ENEMY;
   p.EnemyBuffTurnEnd();  --����ʱ�ж�BUFF���
end;

--���з�BUFF�Ƿ����
function p.CheckEnemyBuffTurnIsEnd()
	
end;

--�з�BUFF����
function p.EnemyBuffTurnEnd()
	WriteCon( "EnemyBuffTurnEnd");	
	p.atkCampType = W_BATTLE_ENEMY 
	w_battle_pve.PickStep(p.CheckEnemyAllDied);  --ʰȡ���佱��,���ص����з��Ƿ�ȫ��
	--p.EnemyStarTurn()
end;



function p.EnemyUseSkill()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
	local lnum = math.random(1,100);	
	if lnum > 30 then
		return false
	else
		return true;
	end
	
end;

--�з��غϿ�ʼ
function p.EnemyStarTurn()  --����غϿ�ʼ
	WriteCon( "EnemyStarTurn");	
	
	for k,v in ipairs(p.enemyCamp.fighters) do 
		local latkFighter = v;
		local lTargetFighter = p.getEnemyTarget(v)
		if lTargetFighter == nil then
			break;
		end
		
		if lTargetFighter.Skill == 0 then
			p.SetPVEAtkID(v:GetId(), true, lTargetFighter:GetId());	
		else
			--if p.EnemyUseSkill() == true then
			--	p.SetPVESkillAtkID(v:GetId(), true, lTargetFighter:GetId());		
			--	break;
			--else
				p.SetPVEAtkID(v:GetId(), true, lTargetFighter:GetId());		
				break;
			--end
		end
	end;
	--p.EnemyTurnEnd() --��ʱ�ж��з��غϽ���
end;

--���з��غ��Ƿ����
function p.CheckEnemyTurnIsEnd() 
	p.EnemyTurnEnd();
end;

--�з��غϽ���
function p.EnemyTurnEnd()
	WriteCon( "EnemyTurnEnd");	
	p.HeroBuffStarTurn();
end;

--�з��Ƿ�ȫ��
function p.CheckEnemyAllDied()
	if p.enemyCamp:isAllDead() == true then 	--����������, ���ν��� or ս������
		p.FightWin();
	else	
		if p.atkCampType == W_BATTLE_HERO then --��ǰ���ҷ��ж��ս������ʰȡ
			p.EnemyBuffStarTurn() 
		elseif p.atkCampType == W_BATTLE_ENEMY then --��ǰ�ǵз�BUFF�������ʰȡ
		    p.EnemyStarTurn()
		end
	end
end;

--ս��ʤ��
function p.FightWin()  
	if w_battle_db_mgr.step < w_battle_db_mgr.maxStep then
		w_battle_db_mgr.step = w_battle_db_mgr.step + 1;	
		w_battle_db_mgr.nextStep();  --���ݽ�����һ����
		--w_battle_mgr.enemyCamp:free();
		w_battle_pve.FighterOver(true); --��������֮��,UI����starFighter
	else
		w_battle_pve.MissionOver();  --�������,����������
		p.QuitBattle();
	end
end;

--ս��ʧ��
function p.FightLose()  
	--û������,ֻ��ʧ�ܽ���
end;
--[[
function p.StepOver(pIsPass)  --��һ���ν���

    if pIsPass == false then  --���ִ���
		w_battle_pve.FighterOver(false); --��ʾ����
	else --�ѹִ���
		
	
	end;
    
end;
]]--
--ս������ѡ�����Ŀ��,ѡ������ͱ�����
function p.SetPVETargerID(position)
	if position > 6 or position < 0 then
	    WriteCon("SetPVEEnemyID id error! id = "..tostring(targetId));	
		return ;
	end
	
	local lfighter = p.enemyCamp:FindFighter(position); --����ʬ�嶼û��
	if lfighter == nil then
		return ;
	end;


--	if p.isCanSelFighter == false then 
--		return ;
--	end;
	
	if lfighter:IsDead() == false then  --����δ����������������,����ΪĿ��
		p.PVEEnemyID = position;
		p.PVEShowEnemyID = p.PVEEnemyID;
		--��ʾ����Ѫ��
		p.LockEnemy = true;
		p.SetLockAction(position);	
	end;
end;	

function p.InitLockAction()
	for i=1, #p.enemyUILockArray do
    	local ltag = p.enemyUILockArray[i];
		local lLockPic = GetImage(p.uiLayer, ltag);	    
		lLockPic:SetVisible(false);
	end
end;

function p.SetLockAction(position)

   if p.LockFagID ~= position then
		--ȡ��������־
	   p.InitLockAction()
	   local ltag = p.enemyUILockArray[position];
	   local lLockPic = GetImage(p.uiLayer, ltag);	    
	   --local lLockPic = p.GetLockImage();		
	   lLockPic:SetVisible(true);
   end;

end;

--[[
--���ڹ��������еĶ���
function p.AtkAdd(pAtkId)
	p.AtkList[#p.AtkList + 1] = pAtkId;	
end;

function p.AtkDec(pAtkId)
	for k,v in pairs(p.AtkList) do
		if v == pAtkId then
			table.remove(p.AtkList,k);
			break;
		end;
	end;
end;

function p.CheckAtkListIsNull()
	local lres = false;
	if (p.AtkList == nil) or (#p.AtkList == 0)  then
		lres = true;
	end;
	return lres;
end;
]]--
--��ʼս������:pve
function p.play_pve( targetId )
    WriteCon("-----------------Enter the pve mission id = "..targetId);
	isPVE = true;	
	w_battle_stage.Init();
    w_battle_stage.EnterBattle_Stage_Loading();
    p.SendStartPVEReq( targetId );
end

--��ʼս������:pvp
function p.play_pvp( targetId )
    WriteCon("-----------------Enter the pvp Tuser id = "..targetId);
    isPVE = false;
    w_battle_stage.Init();
    w_battle_stage.EnterBattle_Stage_Loading();
    p.SendStartPVPReq( targetId );
end

--��ʾ�غ���
function p.ShowRoundNum()
    --local roundNum = w_battle_stage.GetRoundNum();
    --w_battle_mainui.ShowRoundNum( roundNum );
    w_battle_show.DoEffectShowTurnNum();
end

--ս���׶�->����->����
function p.SendStartPVPReq( targetId )
    local UID = GetUID();
    if UID == 0 or UID == nil then
        return ;
    end;
    local param = string.format("&target=%d", targetId);
    SendReq("Fight","StartPvP",UID,param);
end

--ս���׶�->����->����
function p.SendStartPVEReq( targetId )
    --local TID = 101011;
    local UID = GetUID();
    if UID == 0 or UID == nil then
        return ;
    end;
    local param = string.format("&missionID=%d", targetId);
    SendReq("Fight","StartPvC",UID,param);
end

--ս���׶�PVP->����->��Ӧ
function p.ReceiveStartPVPRes( msg )
    w_battle_db_mgr.Init( msg );
    local UCardList = w_battle_db_mgr.GetPlayerCardList();
    local TCardList = w_battle_db_mgr.GetTargetCardList();
    local TPetList = w_battle_db_mgr.GetTargetPetList();
    local UPetList = w_battle_db_mgr.GetPlayerPetList();
    if UCardList == nil or TCardList == nil or #UCardList == 0 or #TCardList == 0 then
    	WriteConErr(" battle data err! ");
    	return false;
    end
    p.createHeroCamp( UCardList );
    p.createEnemyCamp( TCardList );
	--�����ŵĹ���,����Ŀ��
    p.PVEEnemyID = p.enemyCamp:GetFirstActiveFighterID(nil);
	p.PVEShowEnemyID = p.PVEEnemyID; 
	p.LockEnemy = false;
	p.isCanSelFighter = true;	
	    
    p.createPet( UPetList, E_CARD_CAMP_HERO );
    p.createPet( TPetList, E_CARD_CAMP_ENEMY );
    p.ReSetPetNodePos();
    
    w_battle_pvp.ReadyGo();
    p.ShowRoundNum();
end

--ս���׶�PVE->����->��Ӧ
function p.ReceiveStartPVERes( msg )
	p.ReceiveStartPVPRes( msg );
end

--ս���׶�->����BUFF����
function p.EnterBattle_Stage_Permanent_Buff()
	w_battle_mainui.OnBattleShowFinished();
end

--����غϽ׶�->�ٻ��ޱ���
function p.EnterBattle_RoundStage_Pet()
    local rounds = w_battle_stage.GetRoundNum();
    local petData = w_battle_db_mgr.GetPetRoundDB( rounds );
    if petData ~= nil and #petData > 0 and rounds <= W_BATTLE_MAX_ROUND then
        w_battle_show.DoEffectPetSkill( petData );
    else
        w_battle_mainui.OnBattleShowFinished();    
    end
end

--����غϽ׶�->BUFF����
function p.EnterBattle_RoundStage_Buff()
    local rounds = w_battle_stage.GetRoundNum();
    local buffEffectData = w_battle_db_mgr.GetBuffEffectRoundDB( rounds );
    if buffEffectData ~= nil and #buffEffectData > 0 and rounds <= W_BATTLE_MAX_ROUND then
        w_battle_show.DoEffectBuff( buffEffectData );
    else
        w_battle_mainui.OnBattleShowFinished();   
    end
end

--����սʿ���ϵ�BUFF
function p.UpdateFighterBuff()
	local heroes = p.heroCamp:GetAliveFighters();
	p.DelFighterBuff( heroes );
	local enemies = p.enemyCamp:GetAliveFighters();
	p.DelFighterBuff( enemies );
end

--����սʿ���ϵ�BUFF
function p.DelFighterBuff( fighters )
	if fighters ~= nil and #fighters >0 then
        for key, fighter in ipairs(fighters) do
            local fighterBuff = fighter.buffList;
            for k, v in ipairs(fighterBuff) do
                local buffType = v.buttType;
                local buffAni = v.buffAni;
                if not v.isDel and not HasBuffType( fighter, buffType ) then
                    fighter:GetNode():DelAniEffect( buffAni );
                    v.isDel = true;
                end
            end
        end
    end
end

--����غϽ׶�->��Ź
function p.EnterBattle_RoundStage_Atk()
    local rounds = w_battle_stage.GetRoundNum();
    local atkData = w_battle_db_mgr.GetRoundDB( rounds );
    if atkData ~= nil and #atkData > 0 and rounds <= W_BATTLE_MAX_ROUND then
    	w_battle_show.DoEffectAtk( atkData );
    else
        w_battle_mainui.OnBattleShowFinished();	
    end
end

--����غϽ׶�->����
function p.EnterBattle_RoundStage_Clearing()
    if not p.CheckBattleWin() then
         p.CheckBattleLose();
    end
    --������һ���غ�
    w_battle_stage.NextRound();
    p.ShowRoundNum();
    p.UpdatePetRage();
    w_battle_mainui.OnBattleShowFinished();
end

--ȡս����
function p:GetBattleLayer()
	if not isPVE then
		return w_battle_pvp.battleLayer;
	end
	return nil;
end

--��������
function p.createPet( petList, camp )
	if petList == nil or #petList < 0 then
        return false;
    end
    for key, var in ipairs(petList) do
        local petId = tonumber( var.Pet_id );
        local skillId = tonumber( var.Skill_id );
        local Position = tonumber( var.Position );
        
        if camp == E_CARD_CAMP_ENEMY then
        	Position = Position + W_BATTLE_CAMP_CARD_NUM ;
        end
        
        local petPic = createNDUINode();
        petPic:Init();
        if camp == E_CARD_CAMP_ENEMY then
        	petPic:AddFgReverseEffect( SelectCell( T_PET_RES, petId, "total_pic" ) );
        else
            petPic:AddFgEffect( SelectCell( T_PET_RES, petId, "total_pic" ) );
        end
        p.uiLayer:AddChildZ( petPic,101);
        petPic:SetId( Position );
        p.petNode[ #p.petNode+1 ] = petPic;
        
        local petName = createNDUINode();
        petName:Init();
        petName:AddFgEffect( SelectCell( T_SKILL_RES, skillId, "name_effect" ) );
        p.uiLayer:AddChildZ( petName,101);
        p.petNameNode[ #p.petNameNode+1 ] = petName;
        petName:SetId( Position );
        
        local petLV = tonumber( var.Level );
        local petName = SelectCell( T_PET, petId, "name" );
        local petIconAni = SelectCell( T_PET_RES, petId, "face_pic" );
        local petSkillIconAni = SelectCell( T_SKILL_RES, skillId, "icon" );
        
        w_battle_pvp.InitPetUI( Position, petName, petLV, petIconAni, petSkillIconAni );
        w_battle_pvp.InitPetRage( Position, 0 );
    end
end

--���³���ŭ��
function p.UpdatePetRage()
    local UPetList = w_battle_db_mgr.GetPlayerPetList();
    local TPetList = w_battle_db_mgr.GetTargetPetList();
    if UPetList ~= nil then
    	for key, var in ipairs(UPetList) do
            local pos = tonumber( var.Position );
            local sp = tonumber( var.Sp );
            w_battle_pvp.UpdatePetRage( pos, sp );
        end
    end
    if TPetList ~= nil then
        for key, var in ipairs(UPetList) do
            local pos = tonumber( var.Position ) + W_BATTLE_CAMP_CARD_NUM;
            local sp = tonumber( var.Sp );
            w_battle_pvp.UpdatePetRage( pos, sp );
        end
    end
    
end

--��ȡ������
function p.GetPetNode( posId, camp )
	if posId == nil or camp == nil then
		return false;
	end
	local ln = #p.petNode;
	local posId = tonumber( posId )
	if camp == E_CARD_CAMP_ENEMY then
		posId = posId + W_BATTLE_CAMP_CARD_NUM;
	end
	for i=1, ln do
		local pNode = p.petNode[i];
		if pNode ~= nil and pNode:GetId() == posId then
			return pNode;
		end
	end
end 

--��ȡ�������ƽ��
function p.GetPetNameNode( posId, camp )
    if posId == nil or camp == nil then
        return false;
    end
    local ln = #p.petNameNode;
    local posId = tonumber( posId )
    if camp == E_CARD_CAMP_ENEMY then
        posId = posId + W_BATTLE_CAMP_CARD_NUM;
    end
    for i=1, ln do
        local pNode = p.petNameNode[i];
        if pNode ~= nil and pNode:GetId() == posId then
            return pNode;
        end
    end
end

--���ó��Ｐ���ƽ��λ��
function p.ReSetPetNodePos()
	local ln = #p.petNode;
	local ln2 = #p.petNameNode;
    for i=1, ln do
        local petNode = p.petNode[i];
        local id = petNode:GetId();
        if id > W_BATTLE_CAMP_CARD_NUM then
            petNode:SetFramePosXY( 768, GetScreenHeight()/2 - 128 );
        else
            petNode:SetFramePosXY( -256, GetScreenHeight()/2 ); 
        end
    end
    for j=1, ln2 do
        local pNode = p.petNameNode[j];
        local pId = pNode:GetId();
        if pId > W_BATTLE_CAMP_CARD_NUM then
            pNode:SetFramePosXY( -256, GetScreenHeight()/2 - 128 );
        else
            pNode:SetFramePosXY( 768, GetScreenHeight()/2 ); 
        end
    end
end

--����ɰ�ͼƬ
function p.AddMaskImage()
	if p.imageMask == nil then
		p.imageMask = createNDUIImage();
		p.imageMask:Init();
		p.imageMask:SetFrameRectFull();
		
		local pic = GetPictureByAni("lancer.mask", 0); 
		p.imageMask:SetPicture( pic );
		p.uiLayer:AddChildZ( p.imageMask,100);
		p.imageMask:AddActionEffect("x.imageMask_fadein");
	else
		p.ShowMaskImage();
	end
end

--��ʾ�ɰ�
function p.ShowMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(true);
		p.imageMask:AddActionEffect("x.imageMask_fadein");
	end
end

--����ʾ�ɰ�
function p.HideMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(false);
		p.imageMask:AddActionEffect("x.imageMask_fadeout");
	end
end

--[[
--ȡboss
function p.GetBoss()
	return p.enemyCamp:GetFirstFighter();
end
--]]

--�Ƿ�active
function p.IsActive()
    return isActive;
end

--ȡ��һ��hero
function p.GetFirstHero()
	return p.heroCamp:GetFirstFighter();
end

--ȡ��һ��enemy
function p.GetFirstEnemy()
	return p.enemyCamp:GetFirstFighter();
end

--���������Ӫ
function p.createHeroCamp( fighters )
	p.heroCamp = w_battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray, fighters );
	p.heroCamp:AddShadows( p.heroUIArray, fighters );
	p.heroCamp:AddAllRandomTimeJumpEffect(true);
end

--�����ж���Ӫ
function p.createEnemyCamp( fighters )
	p.enemyCamp = w_battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	p.enemyCamp:AddFighters( p.enemyUIArray, fighters );
	p.enemyCamp:AddShadows( p.enemyUIArray, fighters );
	p.enemyCamp:AddAllRandomTimeJumpEffect(false);
end

--����PVP
function p.TestPVP()

end

--���������һ��(PVP)
function p.JumpToPoint( pSeq,Pos )
	local batch = battle_show.GetNewBatch();
	local f1 = p.heroCamp:GetRandomFighter();
	local f2 = p.enemyCamp:GetRandomFighter();
	local f3,f4 = p.enemyCamp:GetRandomFighter_2();
	
--	f1:AtkSkillMul( f3, f4, batch );
--	do return end

end

--����fighter
function p.FindFighter(id)
	local f = p.heroCamp:FindFighter(id);
	if f == nil then
		f = p.enemyCamp:FindFighter(id);
	end
	return f;
end

--ս��ʤ��
function p.OnBattleWin()
	--GetBattleShow():Stop();
	p.isBattleEnd = true;
	SetTimerOnce( p.OpenBattleWin, 1.0f );
end

--��ս��ʤ������
function p.OpenBattleWin()
	PlayEffectSoundByName( "battle_win.mp3" );
	w_battle_ko.CloseUI();
	--dlg_battle_win.ShowUI();
	quest_reward.ShowUI( w_battle_db_mgr.GetRewardData() );
end

--ս��ʧ��
function p.OnBattleLose()
	--GetBattleShow():Stop();
	p.isBattleEnd = true;
	SetTimerOnce( p.OpenBattleLose, 2.0f );
end

--��ս��ʧ�ܽ���
function p.OpenBattleLose()
	--dlg_battle_lose.ShowUI();
	quest_reward.ShowUI( w_battle_db_mgr.GetRewardData() );
end

--����Ƿ�ս��ʤ��
function p.CheckBattleWin()
	if p.enemyCamp:IsAllFighterDead() then
		p.OnBattleWin();
		return true;
	end
	return false;
end

--����Ƿ�ս��ʧ��
function p.CheckBattleLose()
	if p.heroCamp:IsAllFighterDead() then
		p.OnBattleLose();
		return true;
	end
	return false;
end

function p.GetBattleUseItem()
	local post_data= { 
	                    {id="101001", num=1},
	                    {id="101002", num=2},
	                  };
	return post_data;
end;

function p.SendResult(missionID,result)
	local uid = GetUID();
	--uid = 10002;
	if uid ~= nil and uid > 0 then
		--ģ��  Action idm = ���Ͽ���unique_ID (1000125,10000123) 
		--local param = string.format("&missionID=%d&result=%d&money=0&soul=0", tonumber(missionID), tonumber(result));
		local param = {missionID = tonumber(missionID),
		               result = tonumber(result),
		               money  = 0,
					   soul   = 0,
					   post_data = p.GetBattleUseItem()
					   }
					
		SendPost("Fight","PvEReward",uid,"",FormatTableToJson(param));
		--card_intensify_succeed.ShowUI(p.baseCardInfo);
		--p.ClearData();
	end
end;

function p.GetReuslt()
	return p.battle_result;
end;

--����ս��
function p.EnterBattle( battleType, missionId )
	WriteCon( "w_battle_mgr.EnterBattle()" );

	math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
	p.battle_result = math.random(0,1);
	p.battle_result = 1;
	p.SendResult(missionId, p.battle_result);

	--���ذ�ť
--[[
    dlg_menu.CloseUI();
    dlg_userinfo.CloseUI();
    
	
	--enter PVP
	w_battle_pvp.ShowUI( battleType, missionId );	
	w_battle_mainui.ShowUI();
	
	--����
	PlayMusic_Battle();
	
	isActive = true;
	]]--
end

--�˳�ս��
function p.QuitBattle()
	--WriteCon( "w_battle_mgr.QuitBattle()" );

	--w_battle_pvp.CloseUI();
	--w_battle_mainui.CloseUI();

	--game_main.EnterWorldMap();
	--dlg_menu.ShowUI();
	--dlg_userinfo.ShowUI();
		
	--hud.FadeIn();
	
	--����
	PlayMusic_Task();
	
	isActive = false;
	p.clearDate();
end

--���ս������
function p.IsBattleEnd()
	if p.heroCamp:IsAllFighterDead() then
		return true;
	end
	
	if p.enemyCamp:IsAllFighterDead() then
		return true;
	end

	return false;
end

function p.clearDate()
	p.heroCamp = nil;
    p.enemyCamp = nil;          
    p.uiLayer = nil;           
    p.heroUIArray = nil;        
    p.enemyUIArray = nil;       
    p.petNode={};     
    p.petNameNode={};   
    p.imageMask = nil          
    p.isBattleEnd = false;
	p.battleIsStart = false;
    w_battle_show.DestroyAll();
end

function p.GetScreenCenterPos()
	local cNode = GetImage( p.uiLayer, ui_n_battle_pve.ID_CTRL_PICTURE_CENTER );
	return cNode:GetCenterPos();
end

function p.checkTurnEnd()
	--�ܻ�״̬��ȫ�ж��������δ���ж���, ����״̬��û�д����ж��е�
	if (w_battle_machinemgr.checkAllTargetMachineEnd() == true) and (w_battle_machinemgr.checkAllAtkMachineHasTurn() == false) then
		if p.atkCampType == W_BATTLE_HERO then	
			if p.enemyCamp:isAllDead() == false then --���л��ŵĵ���
				if w_battle_machinemgr.checkAllAtkMachineHasNotTurn() == false then  --������δ�ж�����
					p.HeroTurnEnd();  --����Ӣ�۾����ж�  
				end;
			else  --���е���ȫ����
				w_battle_pve.PickStep(w_battle_mgr.FightWin); --����
			end
		else
			if p.heroCamp:isAllDead() == false then
				p.EnemyTurnEnd();
			else
				p.FightLose();
			end		
		end;	
	end;
	
end

function p.getEnemyTarget(atkFighter)
	local lTargetFighter = nil;
	
	--ȡ������˵�
	local lFighterLst =  p.heroCamp:GetElementFighter(atkFighter); --����ܿ��Ƶ�����б�
	if #lFighterLst == 0 then
		lFighterLst = p.heroCamp:GetHeroFighter()
	end
	
	if #lFighterLst == 0 then
		return nil;
	end;

    --ȡѪ�����ٵ�	
	lTargetFighter = lFighterLst[1];
	lTargetFightetLst = {}
	for k,v in ipairs(lFighterLst) do 
		if v.nowlife <= lTargetFighter.nowlife then
     		 if v.nowlife < lTargetFighter.nowlife then
				lTargetFightetLst = {}	
				lTargetFighter = v; 
			 end;
	    	 table.insert(lTargetFightetLst,v)
		end
	end
	
	--ȡλ����С��
	--local lPos = 7;
	lTargetFighter = lFighterLst[1];
    if #lTargetFightetLst > 0 then
		for k,v in ipairs(lTargetFightetLst) do 
			if lTargetFighter:GetId() > v:GetId() then
				lTargetFighter = v;
			end
		end
	end

    return lTargetFighter;
end

function p.calAtkTimes(IsSkill,lIsCrit,lIsJoinAtk,lisMoredamage)
	if IsSkill == false then
		p.AtkTimes = p.AtkTimes + 1;
    else
		p.SkillTimes = p.SkillTimes + 1;
	end; 

	if lIsCrit == true then
		p.CritTimes = p.CritTimes + 1;
	end;
	
	if lIsJoinAtk == true then
		p.JoinAtkTimes = p.JoinAtkTimes + 1; 
	end;
	
	if lisMoredamage == true then
		p.MoreDamageTimes = p.MoreDamageTimes + 1;
	end

end

