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


function p.init()
	--p.heroCamp = nil;			--玩家阵营
	p.enemyCamp = nil;			--敌对阵营
	--p.uiLayer = nil;			--战斗层
	--p.heroUIArray = nil;		--玩家阵营站位UITag表
	--p.enemyUIArray = nil;		--敌对阵营站位UITag表
	--p.enemyUILockArray = nil;   --敌对目标被的锁定标志
	
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
	
end;


function p.starFighter()
	p.init();
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
			p.PVEEnemyID = p.enemyCamp:GetFirstActiveFighterID(targerID); --选择下个nowHP > 0活的怪物目标
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
	
	
	lStateMachine = w_battle_machinemgr.getAtkStateMachine(atkID);
	lStateMachine.turnState = W_BATTLE_TURN;  --行动中		

	if (skillType == W_SKILL_TYPE_1)  then -- 主动伤害的
		if (targetType == W_SKILL_TARGET_TYPE_1) then --单体
			local damage,lIsJoinAtk = w_battle_atkDamage.SkillDamage(skillID,atkFighter, targetFighter);
			damageLst[1] = damage;
			lCritLst[1] = lIsCrit;
			lJoinAtkLst[1] = lIsJoinAtk;
			targetFighter:SubLife(damage); --扣掉生命,但表现不要扣
			targetFighter:BeTarTimesAdd(atkID); --成为目标,未攻击
		elseif( (targetType == W_SKILL_TARGET_TYPE_2) or (targetType == W_SKILL_TARGET_TYPE_3)	or (targetType == W_SKILL_TARGET_TYPE_4)) then
		--群体, 近战冲到屏幕中间, 远程站原地
			local damage,lIsJoinAtk = w_battle_atkDamage.SkillDamage(skillID,atkFighter, targetFighter);
			ltargetCamp:SubLife(damage); --所有已存活的人扣减生命
			ltargetCamp:BeTarTimesAdd(atkID) --所有已存活的人成为目标
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
				p.PVEEnemyID = ltargetCamp:GetFirstActiveFighterID(targerID); --选择下个nowHP > 0活的怪物目标
			end
		end;
	else --主动恢复 or 加BUFF or 复活,   复活只在物品中使用
		--主动恢复或加BUFF技能类技能,不论是否群体都 站原地
		local damage = 0;
		if skillType == 2 then  --恢复类的有加血
			damage = w_battle_atkDamage.SkillBuffDamage(skillID,atkFighter);
			
			for pos=1,6 do
				damageLst[pos] = damage
			end		
		end;
		
		if (targetType == W_SKILL_TARGET_TYPE_11) then --自己
			targetFighter = atkFighter;
		elseif (targetType == W_SKILL_TARGET_TYPE_12) then --已方群体
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
				
				w_battle_pve.SetHeroCardAttr(v:GetId(), v);
			end;		
		end;
	else
		local fighter = p.heroCamp:FindFighter(pHeroPos);
		if fighter~= nil then
			if fighter:UseItem(lid) == true then
				cmdBuff = createCommandEffect():AddFgEffect( 0.5, fighter:GetNode(), effect_skill );
				local seqTemp = batch:AddSerialSequence();
				seqTemp:AddCommand( cmdBuff );		
				w_battle_pve.SetHeroCardAttr(v:GetId(), v);
			end;
		end
	end
	w_battle_db_mgr.CalUseItem(pPos)
	w_battle_useitem.RefreshUI()  --物品使用完后,调用刷新UI, UI会内部调用p.GetItemCanUsePlayer
end;

--我方BUFF阶断
function p.HeroBuffStarTurn()
	WriteCon( "HeroBuffStarTurn");
	p.atkCampType = W_BATTLE_HERO;
	p.HeroBuffTurnEnd();  --直接判定我方BUFF结束
end;

--检查是否所有的BUFF都播放完毕
function p.CheckHeroBuffIsEnd()
  
end;

--我方BUFF结束
function p.HeroBuffTurnEnd()
	WriteCon( "HeroBuffTurnEnd");	
	if p.heroCamp:isAllDead() == true then  --我方全死
	  p.FightLose();	
	else 	
	  --我方还有人活着
	  w_battle_pve.RoundStar();  --UI界面全亮起来
	  w_battle_machinemgr.InitAtkTurnEnd(); --标识玩家的回合
	  --我方使用物品阶断
	  --   当选中一个物品后,得到这个物品可使用的玩家列表,调用w_battle_useitem.RefreshUI()
	  --我方行动阶断,只要出现攻击就等于进入这个阶断
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
	w_battle_pve.PickStep(p.CheckEnemyAllDied);  --拾取掉落奖励,并回调检查敌方是否全死
end;

--敌方BUFF开始
function p.EnemyBuffStarTurn()
	WriteCon( "EnemyBuffStarTurn");	
   p.atkCampType = W_BATTLE_ENEMY;
   p.EnemyBuffTurnEnd();  --先暂时判定BUFF完成
end;

--检查敌方BUFF是否结束
function p.CheckEnemyBuffTurnIsEnd()
	
end;

--敌方BUFF结束
function p.EnemyBuffTurnEnd()
	WriteCon( "EnemyBuffTurnEnd");	
	p.atkCampType = W_BATTLE_ENEMY 
	w_battle_pve.PickStep(p.CheckEnemyAllDied);  --拾取掉落奖励,并回调检查敌方是否全死
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

--敌方回合开始
function p.EnemyStarTurn()  --怪物回合开始
	WriteCon( "EnemyStarTurn");	
	--p.EnemyTurnEnd() --暂时判定敌方回合结束
	
	for k,v in ipairs(p.enemyCamp.fighters) do 
		local latkFighter = v;
		local lTargetFighter = p.getEnemyTarget(v)
		if lTargetFighter == nil then
			break;
		end
		if lTargetFighter.nowlife >= 0 then
			if lTargetFighter.Skill == 0 then
				p.SetPVEAtkID(v:GetId(), true, lTargetFighter:GetId());	
				break;
			else
				if p.EnemyUseSkill() == true then
					p.SetPVESkillAtkID(v:GetId(), true, lTargetFighter:GetId());		
					break;
				else
					p.SetPVEAtkID(v:GetId(), true, lTargetFighter:GetId());		
					break;
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
		    p.EnemyStarTurn()
		end
	end
end;

--战斗胜利
function p.FightWin()  
	if w_battle_db_mgr.step < w_battle_db_mgr.maxStep then
		--w_battle_db_mgr.step = w_battle_db_mgr.step + 1;	
		w_battle_db_mgr.nextStep();  --数据进入下一波次
		--w_battle_mgr.enemyCamp:free();
		w_battle_pve.FighterOver(true); --过场动画之后,UI调用starFighter
	else
		w_battle_pve.MissionOver(p.SendResult);  --任务结束,任务奖励界面
		p.QuitBattle();
	end
end;

--战斗失败
function p.FightLose()  
	--没有续打,只有失败界面
end;
--[[
function p.StepOver(pIsPass)  --这一波次结束

    if pIsPass == false then  --被怪打死
		w_battle_pve.FighterOver(false); --提示复活
	else --把怪打死
		
	
	end;
    
end;
]]--
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

--[[
--处于攻击过程中的队列
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
--开始战斗表现:pve
function p.play_pve( targetId )
    WriteCon("-----------------Enter the pve mission id = "..targetId);
	isPVE = true;	
	w_battle_stage.Init();
    w_battle_stage.EnterBattle_Stage_Loading();
    p.SendStartPVEReq( targetId );
end

--开始战斗表现:pvp
function p.play_pvp( targetId )
    WriteCon("-----------------Enter the pvp Tuser id = "..targetId);
    isPVE = false;
    w_battle_stage.Init();
    w_battle_stage.EnterBattle_Stage_Loading();
    p.SendStartPVPReq( targetId );
end

--显示回合数
function p.ShowRoundNum()
    --local roundNum = w_battle_stage.GetRoundNum();
    --w_battle_mainui.ShowRoundNum( roundNum );
    w_battle_show.DoEffectShowTurnNum();
end

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
	--local param = string.format("&missionID=%d", targetId,teamid);
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
    dlg_menu.CloseUI();
    dlg_userinfo.CloseUI();
    w_battle_db_mgr.Init( msg );
	
	--enter PVP
	--w_battle_pvp.ShowUI( battleType, missionId );	
	--w_battle_mainui.ShowUI();
	w_battle_pve.ShowUI();
	
	--音乐
	PlayMusic_Battle();	
	--[[
   
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
	--按活着的怪物,给个目标
    p.PVEEnemyID = p.enemyCamp:GetFirstActiveFighterID(nil);
	p.PVEShowEnemyID = p.PVEEnemyID; 
	p.LockEnemy = false;
	p.isCanSelFighter = true;	
	    
    p.createPet( UPetList, E_CARD_CAMP_HERO );
    p.createPet( TPetList, E_CARD_CAMP_ENEMY );
    p.ReSetPetNodePos();
    
    w_battle_pvp.ReadyGo();
    p.ShowRoundNum(); ]]--
end

--战斗阶段PVE->加载->响应
function p.ReceiveStartPVERes( msg )
	p.ReceiveStartPVPRes( msg );
end

--战斗阶段->永久BUFF表现
function p.EnterBattle_Stage_Permanent_Buff()
	w_battle_mainui.OnBattleShowFinished();
end

--进入回合阶段->召唤兽表现
function p.EnterBattle_RoundStage_Pet()
    local rounds = w_battle_stage.GetRoundNum();
    local petData = w_battle_db_mgr.GetPetRoundDB( rounds );
    if petData ~= nil and #petData > 0 and rounds <= W_BATTLE_MAX_ROUND then
        w_battle_show.DoEffectPetSkill( petData );
    else
        w_battle_mainui.OnBattleShowFinished();    
    end
end

--进入回合阶段->BUFF表现
function p.EnterBattle_RoundStage_Buff()
    local rounds = w_battle_stage.GetRoundNum();
    local buffEffectData = w_battle_db_mgr.GetBuffEffectRoundDB( rounds );
    if buffEffectData ~= nil and #buffEffectData > 0 and rounds <= W_BATTLE_MAX_ROUND then
        w_battle_show.DoEffectBuff( buffEffectData );
    else
        w_battle_mainui.OnBattleShowFinished();   
    end
end

--更新战士身上的BUFF
function p.UpdateFighterBuff()
	local heroes = p.heroCamp:GetAliveFighters();
	p.DelFighterBuff( heroes );
	local enemies = p.enemyCamp:GetAliveFighters();
	p.DelFighterBuff( enemies );
end

--更新战士身上的BUFF
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

--进入回合阶段->互殴
function p.EnterBattle_RoundStage_Atk()
    local rounds = w_battle_stage.GetRoundNum();
    local atkData = w_battle_db_mgr.GetRoundDB( rounds );
    if atkData ~= nil and #atkData > 0 and rounds <= W_BATTLE_MAX_ROUND then
    	w_battle_show.DoEffectAtk( atkData );
    else
        w_battle_mainui.OnBattleShowFinished();	
    end
end

--进入回合阶段->清算
function p.EnterBattle_RoundStage_Clearing()
    if not p.CheckBattleWin() then
         p.CheckBattleLose();
    end
    --进入下一个回合
    w_battle_stage.NextRound();
    p.ShowRoundNum();
    p.UpdatePetRage();
    w_battle_mainui.OnBattleShowFinished();
end

--取战斗层
function p:GetBattleLayer()
	if not isPVE then
		return w_battle_pvp.battleLayer;
	end
	return nil;
end

--创建宠物
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

--更新宠物怒气
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

--获取宠物结点
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

--获取宠物名称结点
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

--设置宠物及名称结点位置
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

--添加蒙版图片
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

--显示蒙版
function p.ShowMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(true);
		p.imageMask:AddActionEffect("x.imageMask_fadein");
	end
end

--不显示蒙版
function p.HideMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(false);
		p.imageMask:AddActionEffect("x.imageMask_fadeout");
	end
end

--[[
--取boss
function p.GetBoss()
	return p.enemyCamp:GetFirstFighter();
end
--]]

--是否active
function p.IsActive()
    return isActive;
end

--取第一个hero
function p.GetFirstHero()
	return p.heroCamp:GetFirstFighter();
end

--取第一个enemy
function p.GetFirstEnemy()
	return p.enemyCamp:GetFirstFighter();
end

--创建玩家阵营
function p.createHeroCamp( fighters )
	p.heroCamp = w_battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray, fighters );
	--p.heroCamp:AddShadows( p.heroUIArray, fighters );
	p.heroCamp:AddAllRandomTimeJumpEffect(true);
end

--创建敌对阵营
function p.createEnemyCamp( fighters )
	p.enemyCamp = w_battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	p.enemyCamp:AddFighters( p.enemyUIArray, fighters );
	--p.enemyCamp:AddShadows( p.enemyUIArray, fighters );
	p.enemyCamp:AddAllRandomTimeJumpEffect(false);
end

--测试PVP
function p.TestPVP()

end

--测试随机打一次(PVP)
function p.JumpToPoint( pSeq,Pos )
	local batch = battle_show.GetNewBatch();
	local f1 = p.heroCamp:GetRandomFighter();
	local f2 = p.enemyCamp:GetRandomFighter();
	local f3,f4 = p.enemyCamp:GetRandomFighter_2();
	
--	f1:AtkSkillMul( f3, f4, batch );
--	do return end

end

--查找fighter
function p.FindFighter(id)
	local f = p.heroCamp:FindFighter(id);
	if f == nil then
		f = p.enemyCamp:FindFighter(id);
	end
	return f;
end

--战斗胜利
function p.OnBattleWin()
	--GetBattleShow():Stop();
	p.isBattleEnd = true;
	SetTimerOnce( p.OpenBattleWin, 1.0f );
end

--打开战斗胜利界面
function p.OpenBattleWin()
	PlayEffectSoundByName( "battle_win.mp3" );
	w_battle_ko.CloseUI();
	--dlg_battle_win.ShowUI();
	quest_reward.ShowUI( w_battle_db_mgr.GetRewardData() );
end

--战斗失败
function p.OnBattleLose()
	--GetBattleShow():Stop();
	p.isBattleEnd = true;
	SetTimerOnce( p.OpenBattleLose, 2.0f );
end

--打开战斗失败界面
function p.OpenBattleLose()
	--dlg_battle_lose.ShowUI();
	quest_reward.ShowUI( w_battle_db_mgr.GetRewardData() );
end

--检查是否战斗胜利
function p.CheckBattleWin()
	if p.enemyCamp:IsAllFighterDead() then
		p.OnBattleWin();
		return true;
	end
	return false;
end

--检查是否战斗失败
function p.CheckBattleLose()
	if p.heroCamp:IsAllFighterDead() then
		p.OnBattleLose();
		return true;
	end
	return false;
end


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
					   post_data = w_battle_db_mgr.GetBattleItem()
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
	--WriteCon( "w_battle_mgr.QuitBattle()" );

	--w_battle_pvp.CloseUI();
	--w_battle_mainui.CloseUI();

	--game_main.EnterWorldMap();
	--dlg_menu.ShowUI();
	--dlg_userinfo.ShowUI();
		
	--hud.FadeIn();
	
	--音乐
	PlayMusic_Task();
	
	isActive = false;
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
    w_battle_show.DestroyAll();
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
				w_battle_pve.PickStep(w_battle_mgr.FightWin); --捡东西
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

--捡到Hp,或是Sp
function p.PickItem(pos, itemtype)
	if p.HeroCamp ~= nil then
		local heroFighter = p.heroCamp:FindFighter(pos);
		if heroFighter ~= nil then
			if itemtype == E_DROP_HPBALL then
				heroFighter:UseHpBall();
				w_battle_pve.SetHeroCardAttr(heroFighter:GetId(),heroFighter);
			elseif itemtype == E_DROP_SPBALL then
				heroFigheter:UseSpBall();
				w_battle_pve.SetHeroCardAttr(heroFighter:GetId(),heroFighter);
			end
		end
	end;
	
end



