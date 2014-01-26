--------------------------------------------------------------
-- FileName: 	w_battle_mgr.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		战斗管理器（单实例）demo v2.0
--------------------------------------------------------------

w_battle_mgr = {}
local p = w_battle_mgr;

p.heroCamp = nil;			--玩家阵营
p.enemyCamp = nil;			--敌对阵营
p.uiLayer = nil;			--战斗层
p.heroUIArray = nil;		--玩家阵营站位UITag表
p.enemyUIArray = nil;		--敌对阵营站位UITag表
p.enemyUILockArray = nil;   --敌对目标被的锁定标志


p.petNode={};       --双方宠物结点
p.petNameNode={};   --双方宠物名称结点

p.imageMask = nil			--增加蒙版特效
p.PVEEnemyID = nil;   --当前被攻击的敌人ID
--p.PVEHeroID  = nil;  --当前被攻击的英雄ID
p.PVEShowEnemyID = nil;  --当前显示血量的敌人ID
p.LockEnemy = false; --敌人是否被锁定攻击
p.LockFagID = nil;  --之前的锁定标志

local isPVE = false;
local isActive = false;
local useParallelBatch = true; --是否.使用并行批次
p.isBattleEnd = false;
p.isCanSelFighter = false;  --是否还有可选择的怪物,战斗UI界面点击我方人员时,需先判断此变理,再处理点击

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
p.missionID = nil;
p.EnemyBuffDie = false;
p.hpballval = 0;  --hp球恢复
p.spballval = 0;  --sp球恢复
p.MissionDropTab = {};
p.buffTimerID = nil;

p.HpBallNum = 0;
p.SpBallNum = 0;
p.IsPickEnd = false;
p.PickEndEvent = nil;

p.dropHpBall = 0;
p.dropSpBall = 0;
p.platform = 1;
p.isClose = false;

function p.init()
	p.platform = GetFlatform();
	p.isClose = false;	
	--p.heroCamp = nil;			--玩家阵营
	p.enemyCamp = nil;			--敌对阵营
	--p.uiLayer = nil;			--战斗层
	--p.heroUIArray = nil;		--玩家阵营站位UITag表
	--p.enemyUIArray = nil;		--敌对阵营站位UITag表
	--p.enem	yUILockArray = nil;   --敌对目标被的锁定标志
	
	p.PVEEnemyID = nil;   --当前被攻击的敌人ID
	--p.PVEHeroID = nil;
	p.PVEShowEnemyID = nil;  --当前显示血量的敌人ID
	p.LockEnemy = false; --敌人是否被锁定攻击
	p.LockFagID = nil;  --之前的锁定标志
	
	p.batchIsFinish = true;
	p.battle_batch  = nil;
	p.atkCampType = nil;
	p.battleIsStart = true;

	p.AtkTimes  = 0;
	p.SkillTimes= 0;
	p.CritTimes = 0;
	p.JoinAtkTimes = 0;
	p.MoreDamageTimes = 0;	
	p.hpballval = tonumber(SelectRowInner(T_DROP_VAL,"drop_type",1,"value") );
	p.spballval = tonumber(SelectRowInner(T_DROP_VAL,"drop_type",2,"value") );
	
	p.HpBallNum = 0;
	p.SpBallNum = 0;
	p.IsPickEnd = false;
	p.PickEndEvent = nil;
end;


function p.starFighter()
	p.init();
	w_battle_pve.SetBg(p.missionID);
--	w_battle_PVEStaMachMgr.init();
	p.InitLockAction();
	GetBattleShow():EnableTick( true );
	if w_battle_db_mgr.step == 1 then  --只有第一波才需要进场动画
		p.createHeroCamp( w_battle_db_mgr.GetPlayerCardList() );
	end;
    p.createEnemyCamp( w_battle_db_mgr.GetTargetCardList() );
	--按活着的怪物,给个目标
    p.PVEEnemyID = p.enemyCamp:GetFirstActiveFighterID(nil);
	local lEnemyFighter = p.enemyCamp:FindFighter(p.PVEEnemyID);
	w_battle_pve.SetHp(lEnemyFighter);
	--p.PVEHeroID = p.heroCamp:GetFirstActiveFighterPos(nil);
	p.PVEShowEnemyID = p.PVEEnemyID; 
	p.LockEnemy = false;
	p.isCanSelFighter = true;	
	p.atkCampType = W_BATTLE_HERO;
	w_battle_machinemgr.init();
	
	p.buffTimerID = SetTimer(p.UpdateBuff, W_SHOWBUFF_STATE );  --设置显示BUFF的时间
	p.HeroBuffStarTurn();  --我方BUFF开始阶断
	
end;
--[[
--怪物攻击
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


   --点选目标后,先计算伤害
   local damage,lIsJoinAtk,lIsCrit = w_battle_atkDamage.SimpleDamage(atkFighter, targetFighter);
   targetFighter:SubLife(damage); --扣掉生命,但表现不要扣
   

   --默认选择的目标,判定怪物将死
	if targetFighter.nowlife <= 0 then
		p.PVEHeroID = p.heroCamp:GetFirstActiveFighterPos(targerID); --选择下个nowHP > 0活的怪物目标
	end;
	
	
	--成为目标,未攻击
	targetFighter:BeTarTimesAdd(atkID);

	local lStateMachine = w_battle_machinemgr.getAtkStateMachine(atkID);
	local damageLst = {};
	damageLst[1] = damage;
	lStateMachine.turnState = W_BATTLE_TURN;  --行动中
	lStateMachine:init(atkID,atkFighter,W_BATTLE_ENEMY,targetFighter, W_BATTLE_HERO,damageLst,lIsCrit,lIsJoinAtk);
	
	--return true;	
	
end;

]]--
--攻击方是自己,受击方ID之前已选或自动选择,给战斗主界面调用
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
		targetID = w_battle_mgr.PVEEnemyID;
		atkCampType = W_BATTLE_HERO;
		targetCampType = W_BATTLE_ENEMY;
    end;

   if targetID == nil then
      WriteConErr( "Error! SetPVEAtkID targerID is nil");
	  return false;
   end; 

   if atkFighter == nil then
      WriteConErr( "Error! SetPVEAtkID atkFighter is nil! id:"..tostring(atkID));
	  return false;
   end;

	if (atkFighter.Sp == 100) and (atkFighter.Skill ~= 0) then
		if IsMonster ~= true then
			local distanceRes = tonumber( SelectCell( T_SKILL_RES, atkFighter.Skill, "distance" ) );--远程与近战的判断;	
			local targetType   = tonumber( SelectCell( T_SKILL, atkFighter.Skill, "Target_type" ) );
			local skillType = tonumber( SelectCell( T_SKILL, atkFighter.Skill, "Skill_type" ) );
			if (distanceRes ~= nil) and (targetType ~= nil) and (skillType ~= nil) then
				return p.SetPVESkillAtkID(atkID);
			end;
		end;
	end;

	local targetFighter = nil;
	if IsMonster == true then
		targetFighter = w_battle_mgr.heroCamp:FindFighter( tonumber( targetID ) );	
	else
		targetFighter = w_battle_mgr.enemyCamp:FindFighter( tonumber( targetID ) );	
	end

   if targetFighter == nil then
      WriteCon( "Error! SetPVEAtkID targetFighter is nil! id:"..tostring(targetID));
	  return false;
   end;

	if IsMonster ~= true then
	   if w_battle_mgr.isCanSelFighter == false then  --没有存活的目标可选
		  WriteCon( "Warning! All targetFighter is Dead!");
		  return false;  
	   end;
    end;

   --点选目标后,先计算伤害
   local damage,lIsJoinAtk,lIsCrit = w_battle_atkDamage.SimpleDamage(atkFighter, targetFighter,IsMonster);
   targetFighter:SubLife(damage); --扣掉生命,但表现不要扣

    if IsMonster ~= true then
	   --默认选择的目标,判定怪物将死
		if (targetFighter.nowlife <= 0) and (p.LockEnemy == false) then
			p.PVEEnemyID = p.enemyCamp:GetFirstHasHpFighterID(targerID); --选择下个nowHP > 0活的怪物目标
		end
	end;
				 
	--成为目标,未攻击
	targetFighter:BeTarTimesAdd(atkID);

	local lStateMachine = w_battle_machinemgr.getAtkStateMachine(atkID);
	local damageLst = {};
	damageLst[1] = damage;
	local lCritLst = {}
	lCritLst[1] = lIsCrit;
	local lJoinAtkLst = {}
	lJoinAtkLst[1] = lIsJoinAtk;
	
	lStateMachine.turnState = W_BATTLE_TURN;  --行动中
	lStateMachine:init(atkID,atkFighter,atkCampType,targetFighter, targetCampType,damageLst,lCritLst,lJoinAtkLst,false);
	
	return true;
end;					



--攻击方是自己,受击方ID之前已选或自动选择,给战斗主界面调用
function p.SetPVESkillAtkID(atkID, IsMonster,targetID)
   WriteCon( "SetPVESkillAtkID:"..tonumber(atkID));
	local atkFighter = nil;
	if IsMonster == true then
		atkFighter = w_battle_mgr.enemyCamp:FindFighter( tonumber( atkID ) );
	else
		atkFighter = w_battle_mgr.heroCamp:FindFighter( tonumber( atkID ) );
		if atkFighter.Sp < 100 then
			WriteConErr( "Sp<100");
			return false;
		end
	end;

    local atkCampType = nil;
	local targetCampType = nil;	
    
    if IsMonster == true then
		atkCampType = W_BATTLE_ENEMY;
		targetCampType = W_BATTLE_HERO;
    else
		targetID = w_battle_mgr.PVEEnemyID;
		atkCampType = W_BATTLE_HERO;
		targetCampType = W_BATTLE_ENEMY;
    end;
	
    if targetID == nil then
      WriteConErr( "Error! SetPVESkillAtkID targerID is nil");
	  return false;
    end; 

    if atkFighter == nil then
      WriteConErr( "Error! SetPVESkillAtkID atkFighter is nil! id:"..tostring(atkID));
	  return false;
    end;

    local targetFighter = nil;
    if IsMonster == true then
       targetFighter = w_battle_mgr.heroCamp:FindFighter( tonumber( targetID ) );
    else
	   targetFighter = w_battle_mgr.enemyCamp:FindFighter( tonumber( targetID ) );
    end;
    if targetFighter == nil then
       WriteConErr( "Error! SetPVESkillAtkID targetFighter is nil! id:"..tostring(targetID));
	   return false;
    end;

    if IsMonster ~= true then
	   if w_battle_mgr.isCanSelFighter == false then  --没有存活的目标可选
		  WriteCon( "Warning! All targetFighter is Dead!");
		  return false;  
	   end;
    end;

   local skillID = atkFighter.Skill;

   local distanceRes = tonumber( SelectCell( T_SKILL_RES, skillID, "distance" ) );--远程与近战的判断;	
   local targetType   = tonumber( SelectCell( T_SKILL, skillID, "Target_type" ) );
   local skillType = tonumber( SelectCell( T_SKILL, skillID, "Skill_type" ) );

    if (distanceRes == nil) then
		WriteConErr( "Error! Skil distance Config is Error! skill="..tostring(skillID));
		if p.platform == W_PLATFORM_WIN32 then
			return p.SetPVEAtkID(atkID, IsMonster,targetID);
		else
			return false;
		end;
    end;

    if (targetType == nil) then
		WriteConErr( "Error! Skil Target_type Config is Error! skill="..tostring(skillID));
		if p.platform == W_PLATFORM_WIN32 then
			return p.SetPVEAtkID(atkID, IsMonster,targetID);
		else
			return false;
		end;
    end;
   
    if (skillType == nil) then
		WriteConErr( "Error! Skil Skill_type Config is Error! skill="..tostring(skillID));
		if p.platform == W_PLATFORM_WIN32 then
			return p.SetPVEAtkID(atkID, IsMonster,targetID);
		else
			return false;
		end;
	end;

	--已开始攻击,但攻击未开始
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
	local ltargetLst = {}
	local lHasBufLst = {}
	lStateMachine = w_battle_machinemgr.getAtkStateMachine(atkID);
	lStateMachine.turnState = W_BATTLE_TURN;  --行动中		
	--计算BUFF的机率
	local lbuffProbability = tonumber( SelectCell( T_SKILL, skillID, "buff_probability" ) );
	--远程与近战的判断;	
	if (skillType == W_SKILL_TYPE_1)  then -- 主动伤害的
		if (targetType == W_SKILL_TARGET_TYPE_1) then --单体
			local damage,lIsJoinAtk = w_battle_atkDamage.SkillDamage(skillID,atkFighter, targetFighter);
			targetFighter:SubLife(damage); --扣掉生命,但表现不要扣
			targetFighter:BeTarTimesAdd(atkID); --成为目标,未攻击
			local lnum = w_battle_atkDamage.getRandom(1,100);
			if lnum <= lbuffProbability then
				lHasBufLst[1] = true
			else
				lHasBufLst[1] = false;
			end;
			
			damageLst[1] = damage;
			lCritLst[1] = lIsCrit;
			lJoinAtkLst[1] = lIsJoinAtk;
			ltargetLst[1] = targetFighter;

		elseif( (targetType == W_SKILL_TARGET_TYPE_2) or (targetType == W_SKILL_TARGET_TYPE_3)	or (targetType == W_SKILL_TARGET_TYPE_4)) then
		--群体, 近战冲到屏幕中间, 远程站原地
		    for k,v in ipairs(ltargetCamp.fighters) do
				targetFighter = v;
				if targetFighter.Hp > 0 then
					local damage,lIsJoinAtk = w_battle_atkDamage.SkillDamage(skillID,atkFighter, targetFighter);
					targetFighter:SubLife(damage); --扣掉生命,但表现不要扣
					targetFighter:BeTarTimesAdd(atkID); --成为目标,未攻击

					local lnum = w_battle_atkDamage.getRandom(k,100);
					if lnum <= lbuffProbability then
						lHasBufLst[#ltargetLst + 1] = true
					else
						lHasBufLst[#ltargetLst + 1] = false;
					end;
										
					damageLst[#ltargetLst + 1] = damage
					lCritLst[#ltargetLst + 1] = false;
					lJoinAtkLst[#ltargetLst + 1] = lIsJoinAtk;
					ltargetLst[#ltargetLst + 1] = targetFighter
					
				end;
			end;
			isAoe = true;
		else
			WriteCon( "Error! Skil Config is Error! skilltype and targettype is not right! skill="..tostring(skillID));
			return false;
		end

		if IsMonster ~= true then
			if (targetFighter.nowlife <= 0) and (p.LockEnemy == false) then
				p.PVEEnemyID = ltargetCamp:GetFirstActiveFighterID(targerID); --选择下个nowHP > 0活的怪物目标
			end
		end;
	else --主动恢复 or 加BUFF or 复活,   复活只在物品中使用
		--主动恢复或加BUFF技能类技能,不论是否群体都 站原地
		local damage = 0;
		if skillType == 2 then  --恢复类的有加血
			damage = w_battle_atkDamage.SkillBuffDamage(skillID,atkFighter);
			for k,v in ipairs(latkCap.fighters) do
				targetFighter = v;
				if targetFighter.Hp > 0 then
					damageLst[#ltargetLst + 1] = damage
					ltargetLst[#ltargetLst + 1] = targetFighter
				end;
			end;
		end;
		
		if (targetType == W_SKILL_TARGET_TYPE_11) then --自己
			targetFighter = atkFighter;
			ltargetLst[1] = targetFighter;
		elseif (targetType == W_SKILL_TARGET_TYPE_12) then --已方群体
			for k,v in ipairs(latkCap.fighters) do
				targetFighter = v;
				if targetFighter.Hp > 0 then
					--damageLst[#ltargetLst + 1] = damage
					ltargetLst[#ltargetLst + 1] = targetFighter
				end;
			end;				
			isAoe = true;
		else
			WriteCon( "Error! Skil Config is Error! skilltype and targettype is not right! skill="..tostring(skillID));
			return false;
		end
	end;
	
	atkFighter.Sp = 0 ;
	if IsMonster ~= true then
		w_battle_pve.SetHeroCardAttr(atkID, atkFighter);
	end;
--	local id = w_battle_PVEStaMachMgr.addStateMachine(lStateMachine);
	--lStateMachine:init(id,atkFighter,atkCampType,targetFighter, W_BATTLE_HERO,damage,lIsCrit,lIsJoinAtk,true,skillID);
	lStateMachine:init(atkID,atkFighter,atkCampType,targetFighter, targetCampType,damageLst,lCritLst ,lJoinAtkLst,true,skillID,isAoe,ltargetLst,lHasBufLst);	
	
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


--获得某个物品可使用的玩家列表
function p.GetItemCanUsePlayer(pItemPos)
	local lPlayer = {};

    local lid = w_battle_db_mgr.GetItemid(pItemPos)
	local ltype = tonumber(SelectCell( T_MATERIAL, lid, "type" ));
	if ltype ~= W_MATERIAL_TARGET1 then --不是药水类型
		return nil;
	end
	
	local subtype = tonumber(SelectCell( T_MATERIAL, lid, "sub_type" ));
	local effect_type = tonumber(SelectCell( T_MATERIAL, lid, "effect_type" ));
	local effect_value = tonumber(SelectCell( T_MATERIAL, lid, "effect_value" ));
	local effect_targer = tonumber(SelectCell( T_MATERIAL, lid, "effect_target" ));
	if effect_targer == W_MATERIAL_TARGET2 then  --群体的
		for k,v in ipairs(p.heroCamp.fighters) do
			lPlayer[#lPlayer + 1 ] = v.Position;
		end
	elseif effect_targer == W_MATERIAL_TARGET1 then --单体的
		if subtype == W_MATERIAL_SUBTYPE1 then  --HP>0的
				for k,v in ipairs(p.heroCamp.fighters) do
					if (v.nowlife > 0) and (v.nowlife < v.maxHp) then
						lPlayer[#lPlayer + 1 ] = v.Position;
					end
				end
			
		elseif subtype == W_MATERIAL_SUBTYPE2 then --中相应状态的才可用
			for k,v in ipairs(p.heroCamp.fighters) do
				if effect_type == W_BATTLE_REVIVAL then --复活物品
					if(v.nowlife == 0) then
						lPlayer[#lPlayer + 1 ] = v.Position;	
					end
				else  --解状态的BUFF
					if v:HasBuff(effect_type) == true then
						lPlayer[#lPlayer + 1 ] = v.Position;	
					end
				end;
			end
		
		elseif subtype == W_MATERIAL_SUBTYPE3 then --所有未死亡的,均可用
			for k,v in ipairs(p.heroCamp.fighters) do
				if v.nowlife > 0  then
					lPlayer[#lPlayer + 1 ] = v.Position;
				end
			end
		end
	
	end
	
	return lPlayer;
end;

--使用某个物品
function p.UseItem(pItemPos, pHeroPos)
	local leffectflag = true;
	local lid = w_battle_db_mgr.GetItemid(pItemPos)
	local effect_skill = SelectCell( T_MATERIAL_RES, lid, "effect" );  --技能光效
	local batch = w_battle_mgr.GetBattleBatch(); 
	if (effect_skill == nil) or (effect_skill == {}) then
		effect_skill = "skill_effect.hurt_add_hp";
		WriteCon( "material_res.ini config failed id="..tostring(lid));
	end;
	
	local effect_targer = tonumber(SelectCell( T_MATERIAL, lid, "effect_target" ));
	if effect_targer == W_MATERIAL_TARGET2 then  --群体的
		for k,v in ipairs(p.heroCamp.fighters) do
			if v:UseItem(lid) == true then
				cmdBuff = createCommandEffect():AddFgEffect( 0.5, v:GetNode(), effect_skill );
				local seqTemp = batch:AddSerialSequence();
				seqTemp:AddCommand( cmdBuff );
				
				--w_battle_pve.SetHeroCardAttr(v:GetId(), v);
			end;		
		end;
	else
		local fighter = p.heroCamp:FindFighter(pHeroPos);
		if fighter~= nil then
			if fighter:UseItem(lid) == true then
				cmdBuff = createCommandEffect():AddFgEffect( 0.5, fighter:GetNode(), effect_skill );
				local seqTemp = batch:AddSerialSequence();
				seqTemp:AddCommand( cmdBuff );		
				--w_battle_pve.SetHeroCardAttr(fighter:GetId(), fighter);
			end;
		end
	end
	w_battle_db_mgr.CalUseItem(pItemPos)
	w_battle_useitem.RefreshUI()  --物品使用完后,调用刷新UI, UI会内部调用p.GetItemCanUsePlayer
end;

--我方BUFF阶断
function p.HeroBuffStarTurn()
	WriteCon( "HeroBuffStarTurn");
	p.atkCampType = W_BATTLE_HERO;
	p.SetCampZorder();
	calBuff(W_BATTLE_HERO);
	--p.HeroBuffTurnEnd();  --直接判定我方BUFF结束
end;

--检查是否所有的BUFF都播放完毕
function p.CheckHeroBuffIsEnd()
  
end;

--我方BUFF结束
function p.HeroBuffTurnEnd()
	WriteCon( "HeroBuffTurnEnd");	
	if p.heroCamp:isAllDead() == true then  --我方全死
        p.FightLose();	
	elseif p.heroCamp:HasTurn() == true then -- 有可以行动的
		 w_battle_pve.RoundStar();  --UI界面全亮起来
		 w_battle_machinemgr.InitAtkTurnEnd(W_BATTLE_HERO); --标识玩家的回合
		--我方使用物品阶断
		--   当选中一个物品后,得到这个物品可使用的玩家列表,调用w_battle_useitem.RefreshUI()
        --我方行动阶断,只要出现攻击就等于进入这个阶断
 	else  --无人可行动
		p.HeroTurnEnd();
	end
end;

--检查我方行动是否结束
function p.CheckHeroTurnIsEnd()
	--if p.heroCamp:CheckAtkTurnEnd() == true then --英雄的回合结束
		p.HeroTurnEnd()
	--end
	
end;

--我方行动结束
function p.HeroTurnEnd()
	WriteCon( "HeroTurnEnd");	
	p.PickEndEvent = p.CheckEnemyAllDied;
	p.IsPickEnd = false;
	p.dropHpBall = 0;
	p.dropSpBall = 0;
	w_battle_pve.PickStep(p.CanPickEnd);  --拾取掉落奖励,并回调检查敌方是否全死
end;

--敌方BUFF开始
function p.EnemyBuffStarTurn()
	WriteCon( "EnemyBuffStarTurn");	
   p.atkCampType = W_BATTLE_ENEMY;
   p.EnemyBuffDie = false;
   p.SetCampZorder();
   w_battle_machinemgr.InitAtkTurnEnd(W_BATTLE_ENEMY); 
   calBuff(W_BATTLE_ENEMY);
   --p.EnemyBuffTurnEnd();  --先暂时判定BUFF完成
end;

function calBuff(campType)
	local fighterLst;
	if campType == W_BATTLE_HERO then
		fighterLst = p.heroCamp.fighters;
	else
		fighterLst = p.enemyCamp.fighters;
	end;
	local fighterDieLst = {}
	for k,v in ipairs(fighterLst) do
		local fighter = v;
		if (fighter.Hp > 0) then
			for i=#fighter.SkillBuff,1,-1 do --BUFF时间到了
				local buffInfo = fighter.SkillBuff[i];
				if buffInfo.buff_time == 0 then
					if buffInfo.buff_type == W_BUFF_TYPE_301 then
						fighter.canRevive = false;
					end
					table.remove(fighter.SkillBuff,i);
				else
					buffInfo.buff_time = buffInfo.buff_time - 1;
				end
			end;
			fighter:calBuff();
			fighter.Buff = 1;
			fighter.HasTurn = true; --先设置可以行动
		end;
	end;	

	w_battle_machinemgr.starBuffStateMachine();

end;	

function p.checkBuffEnd()
	if w_battle_machinemgr.allBuffEnd() == true then
		if p.atkCampType == W_BATTLE_HERO then
			p.HeroBuffTurnEnd();
		else
			p.EnemyBuffTurnEnd();
		end	
	end;
end;



--检查敌方BUFF是否结束
function p.CheckEnemyBuffTurnIsEnd()
	
end;

--敌方BUFF结束
function p.EnemyBuffTurnEnd()
	WriteCon( "EnemyBuffTurnEnd");	
	p.atkCampType = W_BATTLE_ENEMY 
	if p.EnemyBuffDie == true then --有死亡发生
		p.PickEndEvent = p.CheckEnemyAllDied;
		p.IsPickEnd = false;
		p.dropHpBall = 0;
		p.dropSpBall = 0;
		w_battle_pve.PickStep(p.CanPickEnd);  --拾取掉落奖励,并回调检查敌方是否全死
	else
	   p.CheckEnemyAllDied();
	end;
	--p.EnemyStarTurn()
end;



function p.EnemyUseSkill(lseed)
	if w_battle_db_mgr.IsDebug == true then
		return true;
	end;
	
	local lnum = w_battle_atkDamage.getRandom(lseed,100);
	--WriteCon( "Monster Skill Random num:"..tostring(lnum));		
	if lnum > 30 then
		return false
	else
		return true;
	end
	
end;

--敌方回合开始
function p.EnemyStarTurn()  --怪物回合开始
	WriteCon( "EnemyStarTurn");	
	--p.EnemyTurnEnd() --暂时判定敌方回合结束
	lcount = 0;
	for k,v in ipairs(p.enemyCamp.fighters) do 
		local latkFighter = v;
		if (latkFighter.nowlife > 0) and (latkFighter.HasTurn == true) then --可以行动且活着
			local lTargetFighter = p.getEnemyTarget(v)
			if lTargetFighter == nil then
				break;
			end
			local ltargetID = lTargetFighter:GetId();
			lcount = lcount + 1;
			latkFighter.delayTime = W_BATTLE_DELAYTIME * lcount;
			if latkFighter.Skill == 0 then
				p.SetPVEAtkID(latkFighter:GetId(), true, ltargetID);	
				--break;
			else
				if p.EnemyUseSkill(k) == true then
					p.SetPVESkillAtkID(latkFighter:GetId(), true, ltargetID);		
					--break;
				else
					p.SetPVEAtkID(latkFighter:GetId(), true, ltargetID);		
					--break;
				end
			end
		end;
	end;
	
	--p.EnemyTurnEnd() --暂时判定敌方回合结束
end;

--检查敌方回合是否结束
function p.CheckEnemyTurnIsEnd() 
	p.EnemyTurnEnd();
end;

--敌方回合结束
function p.EnemyTurnEnd()
	WriteCon( "EnemyTurnEnd");	
	p.HeroBuffStarTurn();
end;

--敌方是否全挂
function p.CheckEnemyAllDied()
	if p.enemyCamp:isAllDead() == true then 	--怪物死光了, 波次结束 or 战斗结束
		p.FightWin();
	else	
		if p.atkCampType == W_BATTLE_HERO then --当前是我方行动刚结束后的拾取
			p.EnemyBuffStarTurn() 
		elseif p.atkCampType == W_BATTLE_ENEMY then --当前是敌方BUFF结束后的拾取
			if p.enemyCamp:HasTurn() then  --有行动回合
				p.EnemyStarTurn()
			else
				p.EnemyTurnEnd();
			end;
		end
	end
end;

--战斗胜利
function p.FightWin()  
	KillTimer(p.buffTimerID);
	p.heroCamp:ClearFighterBuff();
	if w_battle_db_mgr.step < w_battle_db_mgr.maxStep then
		w_battle_db_mgr.nextStep();  --数据进入下一波次
		--w_battle_mgr.enemyCamp:free();
		w_battle_pve.FighterOver(true); --过场动画之后,UI调用starFighter
	else
		w_battle_pve.MissionOver(p.MissionWin);  --任务结束,任务奖励界面
	end
end;

--战斗失败
function p.FightLose()  
	KillTimer(p.buffTimerID);
	--没有续打,只有失败界面
	w_battle_pve.MissionOver(p.MissionLose);
end;

function p.MissionLose()
	p.QuitBattle()
	p.SendResult(0);	
end;

--战斗界面选择怪物目标,选择后怪物就被锁定
function p.SetPVETargerID(position)
	if position > 6 or position < 0 then
	    WriteCon("SetPVEEnemyID id error! id = "..tostring(targetId));	
		return ;
	end
	
	local lfighter = p.enemyCamp:FindFighter(position); --怪连尸体都没了
	if lfighter == nil then
		return ;
	end;

	
--	if p.isCanSelFighter == false then 
--		return ;
--	end;
	
	if lfighter:IsDead() == false then  --怪物未进入了死亡动画中,可作为目标
		p.PVEEnemyID = position;
		p.PVEShowEnemyID = p.PVEEnemyID;
		--显示怪物血量
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
		--取消锁定标志
	   p.InitLockAction()
	   local ltag = p.enemyUILockArray[position];
	   local lLockPic = GetImage(p.uiLayer, ltag);	    
	   --local lLockPic = p.GetLockImage();		
	   lLockPic:SetVisible(true);
	   local targetFighter = p.enemyCamp:FindFighter(position);
	   w_battle_pve.SetHp(targetFighter); --更新血量
	   local lElementLst = p.heroCamp:GetElementAtkFighter(targetFighter);
	   w_battle_pve.UpdateDamageBufftype(lElementLst);
   end;

end;


--战斗阶段->加载->请求
function p.SendStartPVPReq( targetId )
    local UID = GetUID();
    if UID == 0 or UID == nil then
        return ;
    end;
    local param = string.format("&target=%d", targetId);
    SendReq("Fight","StartPvP",UID,param);
end

--战斗阶段->加载->请求
function p.SendStartPVEReq( targetId, teamid )
    --local TID = 101011;
    local UID = GetUID();
    if UID == 0 or UID == nil then
        return ;
    end;
    local param = string.format("&missionID=%d&teamID=%d", targetId,teamid);
    SendReq("Fight","StartPvC",UID,param);
end

--进入战斗
function p.EnterBattle( battleType, missionId,teamid )
	WriteCon( "w_battle_mgr.EnterBattle()" );
	p.missionID = missionId;

	p.SendStartPVEReq( missionId,teamid);
--[[	math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
	p.battle_result = math.random(0,1);
	p.battle_result = 1;
	p.SendResult(missionId, p.battle_result);
	]]--
end


--战斗阶段PVP->加载->响应
function p.ReceiveStartPVPRes( msg )
   -- p.SendResult(1)	;
	
    dlg_menu.HideUI();
    dlg_userinfo.HideUI();
	p.MissionDropTab = SelectRowList(T_MONSTER_DROP,"mission_id",p.missionID);
    w_battle_db_mgr.Init( msg );
	
		
	
	w_battle_pve.ShowUI();
	
	--音乐
	PlayMusic_Battle();	

end

--战斗阶段PVE->加载->响应
function p.ReceiveStartPVERes( msg )
	p.ReceiveStartPVPRes( msg );
end



--创建玩家阵营
function p.createHeroCamp( fighters )
	p.heroCamp = w_battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray, fighters );
	p.heroCamp:AddShadows( p.heroUIArray, fighters );
	p.heroCamp:AddAllRandomTimeJumpEffect(true);
end

--创建敌对阵营
function p.createEnemyCamp( fighters )
	p.enemyCamp = w_battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	p.enemyCamp:AddFighters( p.enemyUIArray, fighters );
	p.enemyCamp:AddShadows( p.enemyUIArray, fighters );
	p.enemyCamp:AddAllRandomTimeJumpEffect(false);
end


--查找fighter
function p.FindFighter(id)
	local f = p.heroCamp:FindFighter(id);
	if f == nil then
		f = p.enemyCamp:FindFighter(id);
	end
	return f;
end

function p.MissionWin()
	p.QuitBattle();
	p.SendResult(1);		
end;


function p.SendResult(result)
	local uid = GetUID();
	--uid = 10002;
	if uid ~= nil and uid > 0 then
		--模块  Action idm = 饲料卡牌unique_ID (1000125,10000123) 
		--local param = string.format("&missionID=%d&result=%d&money=0&soul=0", tonumber(missionID), tonumber(result));
		local param = {missionID = tonumber(p.missionID),
		               result = tonumber(result),
		               money  = 0,
					   soul   = 0,
					   post_data = w_battle_db_mgr.GetBattleEndItem()
					   }
		local lstr = FormatTableToJson(param);		
		SendPost("Fight","PvEReward",uid,"",lstr);
		--card_intensify_succeed.ShowUI(p.baseCardInfo);
		--p.ClearData();
	end
end;

function p.GetReuslt()
	return p.battle_result;
end;


--退出战斗
function p.QuitBattle()
	
	--hud.FadeIn();
	p.isClose = true;
	--音乐
	PlayMusic_Task();
	
	p.clearDate();
end

--检查战斗结束
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
    --w_battle_show.DestroyAll();
end

function p.GetScreenCenterPos()
	local cNode = GetImage( p.uiLayer, ui_n_battle_pve.ID_CTRL_PICTURE_CENTER );
	return cNode:GetCenterPos();
end

function p.checkTurnEnd()
	--受击状态机全行动完成了且未在行动中, 攻击状态机没有处于行动中的
	if (w_battle_machinemgr.checkAllTargetMachineEnd() == true) and (w_battle_machinemgr.checkAllAtkMachineHasTurn() == false) then
		if p.atkCampType == W_BATTLE_HERO then	
			if p.enemyCamp:isAllDead() == false then --还有活着的敌人
				if w_battle_machinemgr.checkAllAtkMachineHasNotTurn() == false then  --不存在未行动的人
					p.HeroTurnEnd();  --所有英雄均已行动  
				end;
			else  --所有敌人全死了
				p.PickEndEvent = p.FightWin;
				p.IsPickEnd = false;
				p.dropHpBall = 0;
				p.dropSpBall = 0;
				w_battle_pve.PickStep(p.CanPickEnd); --捡东西
			end
		else
			--WriteCon( "**********Error ! Enemy checkTurnEnd************ ");
			if p.heroCamp:isAllDead() == false then
				  --需检查怪物有未行动的
				p.EnemyTurnEnd();
			else
				p.FightLose();
			end		
		end;	
	end;
	
end

function p.getEnemyTarget(atkFighter)
	local lTargetFighter = nil;
	
	--取属性相克的
	local lFighterLst =  p.heroCamp:GetElementFighter(atkFighter); --获得能克制的玩家列表
	if #lFighterLst == 0 then
		lFighterLst = p.heroCamp:GetHeroFighter()
	end
	
	if #lFighterLst == 0 then
		return nil;
	end;

    --取血量最少的	
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
	
	--取位置最小的
	--local lPos = 7;
    if #lTargetFightetLst > 0 then
		lTargetFighter = lTargetFightetLst[1];
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

--捡到Hp,或是Sp
function p.PickItem(pos, itemtype)
	if p.heroCamp ~= nil then
		local heroFighter = p.heroCamp:FindFighter(pos);
		if heroFighter ~= nil then
			if itemtype == E_DROP_HPBALL then
				heroFighter:UseHpBall(p.hpballval);
		--		w_battle_pve.SetHeroCardAttr(heroFighter:GetId(),heroFighter);
			elseif itemtype == E_DROP_SPBALL then
				heroFighter:UseSpBall(p.spballval);
		--		w_battle_pve.SetHeroCardAttr(heroFighter:GetId(),heroFighter);
			end
		end
	end;
	
end

function p.getHeroFighterLst()
	return p.heroCamp.fighters;
	
end

function p.GetBuffAni(skillID)
	local lBuffAni = nil;
	local buff_type = tonumber(SelectCell(T_SKILL,skillID,"buff_type"));
	lBuffAni = "n_battle_buff.buff_type_act"..tostring(buff_type); 
	return lBuffAni;
	
end

function p.setFighterRevive(targetFighter)
	local batch = w_battle_mgr.GetBattleBatch();
	local seqTarget = batch:AddSerialSequence();
	local seqHurt = batch:AddSerialSequence();	
	
	targetFighter.isDead = false;
	targetFighter.canRevive = false;
			
	targetFighter:Revive();
	--targetFighter:RemoveBuff(W_BUFF_TYPE_301)

	targetFighter:ClearAllBuff();
	targetFighter:standby();

	local cmdf = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer_cmb.revive" );
	seqTarget:AddCommand( cmdf );
	--[[
	local cmdC = createCommandEffect():AddActionEffect( 0.01, targerFighter.m_kShadow, "lancer_cmb.revive" );
	seqTarget:AddCommand( cmdC );		
]]--
	return cmdc
end;

function p.reward(targerFighter)
	local tmpList = {}
	if targerFighter.dropLst ~= nil then
		for k,v in ipairs(targerFighter.dropLst) do
			tmpList[#tmpList + 1] = {v.dropType, 1, targerFighter.Position, v.id};
		end
	end;
	if #tmpList > 0 then
		w_battle_pve.MonsterDrop(tmpList)	
	end;
end;

function p.setFighterDie(targerFighter,camp)
	--判断是否要切换怪物目标
	if targerFighter.isDead == true then
		WriteCon( "*********************Wring! tar_hurtEnd can not in die double  tarid="..tostring(targerFighter:GetId()) );	
		return ;
	end;

	local batch = w_battle_mgr.GetBattleBatch();
	local seqTarget = batch:AddSerialSequence();
	local seqHurt = batch:AddSerialSequence();	

	targerFighter:Die();  --标识死亡
	WriteCon( "tar_hurtEnd tar_die tarid="..tostring(targerFighter:GetId()) );
	if(camp == W_BATTLE_ENEMY) then  --受击的是怪物
		p.reward(targerFighter); --怪物死亡掉装备
		if w_battle_mgr.LockEnemy == true then  --锁定目标
			if(w_battle_mgr.PVEEnemyID == targerFighter:GetId()) then  --当前死掉的怪物是正在被锁定的怪物
				if w_battle_mgr.enemyCamp:GetNotDeadFighterCount() > 0 then --可换个怪物
					w_battle_mgr.PVEEnemyID = w_battle_mgr.enemyCamp:GetFirstNotDeadFighterID(targerFighter:GetId()); --除此ID外的活的怪物目标
					w_battle_mgr.SetLockAction(w_battle_mgr.PVEEnemyID);
					--p.LockEnemy = false  --只要选过怪物一直都是属于锁定的
				else  --没有活着的怪物可选
				   w_battle_mgr.isCanSelFighter = false;
				end
			end;
		else --未锁定目标
		--	local lcount = w_battle_mgr.enemyCamp:GetNotDeadFighterCount();
			local lcount = w_battle_mgr.enemyCamp:GetHasHpFighterCount();
			if lcount == 1 then
				w_battle_mgr.PVEEnemyID = w_battle_mgr.enemyCamp:GetFirstHasHpFighterID(targerFighter:GetId()); --除此ID外的活的怪物目标,如果都没有就返回此ID
				w_battle_mgr.SetPVETargerID(w_battle_mgr.PVEEnemyID);
			elseif lcount > 1 then						
				local lFighter = w_battle_mgr.enemyCamp:FindFighter(w_battle_mgr.PVEEnemyID);
				if lFighter ~= nil then
					w_battle_pve.SetHp(lFighter);
				end;
			end
			--非锁定攻击的怪物,在选择我方人员时就完成了怪物的选择,无需处理
		end;		
	else  --受击的是玩家,在攻击时就已选择了全部目标无需处理
		
	end;
	
	
	if targerFighter.m_kShadow ~= nil then
		local cmdf = createCommandEffect():AddActionEffect( 0.01, targerFighter.m_kShadow, "lancer_cmb.die" );
		seqTarget:AddCommand( cmdf );
	end;
	
	local cmdC = createCommandEffect():AddActionEffect( 1, targerFighter:GetNode(), "lancer_cmb.die" );
	seqTarget:AddCommand( cmdC );	
	return cmdC			
end

function updateCampBuff(camp)
	if camp ~=nil then
		for k,v in ipairs(camp.fighters) do
			if v~= nil then
				if(v.Hp > 0) then
					if v.showBuff == true then
						if #v.SkillBuff > 0 then
							if v.BuffIndex > #v.SkillBuff then
								v.BuffIndex = 1;
							end
							local buffInfo = v.SkillBuff[v.BuffIndex]  --设置一个BUFF
							v:SetBuffNode(buffInfo.buff_type); --设置BUFF图片
							v.BuffIndex = v.BuffIndex + 1;
						end
					end;
				end;
			end;
		end
	end;
end

function p.UpdateBuff()
	if p.isClose == false then
		updateCampBuff(p.enemyCamp);
		updateCampBuff(p.heroCamp);
	end;
end

function p.AddBall(ltype,num)
	if ltype == E_DROP_HPBALL then
		p.HpBallNum = p.HpBallNum + num;
		local lst = string.format("HpBallNumAdd=%d HpBallNum=%d", num,p.HpBallNum)
		WriteCon(lst);
	elseif ltype == E_DROP_SPBALL then
		p.SpBallNum = p.SpBallNum + num
		local lst = string.format("SpBallNumAdd=%d SpBallNum=%d", num,p.SpBallNum)
		WriteCon(lst);
	end;
end;

function p.CanPickEnd()
	p.IsPickEnd	= true;
	p.checkPickEnd()
end;

function p.checkPickEnd()
	local lresult = false;
	if (p.IsPickEnd == true) and (p.HpBallNum <= 0) and (p.SpBallNum <= 0) then
		lresult = true
	end
    if lresult == true then
		if p.PickEndEvent ~= nil then
			p.PickEndEvent();
		end;
	end;
	
end

function p.SetCampZorder()
	if p.atkCampType == W_BATTLE_HERO then
		p.heroCamp:SetFightersZOrder(E_BATTLE_Z_HERO_FIGHTER)
		p.enemyCamp:SetFightersZOrder(E_BATTLE_Z_ENEMY_FIGHTER)
	else
		p.heroCamp:SetFightersZOrder(E_BATTLE_Z_ENEMY_FIGHTER)
		p.enemyCamp:SetFightersZOrder(E_BATTLE_Z_HERO_FIGHTER)
	end

	
end