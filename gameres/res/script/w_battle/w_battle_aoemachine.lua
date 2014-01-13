w_battle_aoemachine = w_battle_PVEStateMachine:new()  --AOE伤害状态机
local p = w_battle_aoemachine;
		  
--PVE的一次战斗的状态机
local super = w_battle_PVEStateMachine;

function p:aoeinit(id,atkFighter,atkCampType,tarFighter, atkCampType,damage,isCrit,isJoinAtk,isSkill,skillID)
	if atkCampType == W_BATTLE_HERO then
		self.atkcamp = w_battle_mgr.heroCamp
		self.targercamp = w_battle_mgr.enemyCamp
	else
		self.atkcamp = w_battle_mgr.enemyCamp
		self.targercamp = w_battle_mgr.heroCamp
	end;
	
	
	self:init(id,atkFighter,atkCampType,tarFighter, atkCampType,damage,isCrit,isJoinAtk,isSkill,skillID);
	
end;


function p:start()
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();
    local playerNode = self.atkplayerNode;
	self.enemyPos = w_battle_mgr.GetScreenCenterPos()		
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --近战普攻, 冲到屏中间
        --先吟唱音乐及动作
    	local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( self.singSound );
        self.seqStar:AddCommand( cmdSingMusic );
    
	    local cmd1 = createCommandEffect():AddFgEffect( 0.01, hero:GetNode(), sing );
		self.seqStar:AddCommand( cmd1 );
		
		--攻击音乐
		--local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
		--self.seqStar:AddCommand( cmdAtkBegin );

		--向攻击目标移动
		local cmdMove = OnlyMoveTo(atkFighter, self.originPos, self.enemyPos, self.seqAtk);
		self.seqAtk:SetWaitEnd( cmd1 );
		
		local cmdHurt = tarFighter:cmdLua("tar_hurtBegin",        self.id,"", self.seqTarget);
		self.seqTarget:SetWaitEnd( cmdMove );
		
	elseif self.distanceRes == W_BATTLE_DISTANCE_Archer then  --远程攻击,全当作无弹道,都在原地放技能
    	local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( self.singSound );
        self.seqStar:AddCommand( cmdSingMusic );
    
	    local cmd1 = createCommandEffect():AddFgEffect( 0.01, hero:GetNode(), sing );
		self.seqStar:AddCommand( cmd1 );		

		self.targercamp:BeTarTimesDec(atkFighter:GetId());		
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, playerNode, "" );
		self.seqAtk:AddCommand( cmdAtk ); --攻击动作
		self.seqAtk:SetWaitEnd( cmd1 ); --攻击动作

		local atkSound = self.atkSound;
		--受击音乐
		if atkSound ~= nil then
			local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
			self.seqAtk:AddCommand( cmdAtkMusic );
		end;	
		tarFighter:cmdLua("tar_hurtBegin",  self.id, "", self.seqTarget);
		self.seqTarget:SetWaitEnd( cmdAtk );
	end
	
end


function p:atk_startAtk()  --攻击
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();
	
	--攻击队列增加
	tarFighter:BeHitAdd(atkFighter:GetId());  
	
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
		--攻击敌人动画
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, self.atkplayerNode, "" );
		self.seqAtk:AddCommand( cmdAtk );	

		local atkSound = self.atkSound;
		--受击音乐
		if atkSound ~= nil then
			local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
			self.seqAtk:AddCommand( cmdAtkMusic );
		end
		
	end;
	
	--攻击结束播放受击动作
	atkFighter:cmdLua( "atk_end",  self.id, "", self.seqAtk ); 
	
end

function p:atk_end()
	local atkFighter = self:getAtkFighter();
	--local tarFighter = self:getTarFighter();


    --受击后掉血,不用等掉血动画完成
	tarFighter:SubShowLife(self.damage); --掉血动画,及表示的血量减少
	local cmd4 = createCommandPlayer():Standby( 0.01, self.atkplayerNode, "" );
	self.seqAtk:AddCommand( cmd4 );
	
    --处理攻击方	
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
        --返回原来的位置
        local cmd5 = OnlyMoveTo(atkFighter, self.enemyPos, self.originPos, self.seqAtk);
	end;

	--标识攻击方的攻击完成了
	atkFighter:cmdLua( "atk_standby",  self.id, "", self.seqAtk ); 

	--受击方结算
	--受击次数减一	
	tarFighter:BeHitDec(atkFighter:GetId()); 
	
	if tarFighter:GetHitTimes() == 0 then --受击次数为0时
		tarFighter.IsHurt = false;
		WriteCon( "atkid:"..tostring(atkFighter:GetId()).." atk_end GetHitTimes == 0 ");
		if tarFighter.firstID ~= atkFighter:GetId() then 
			self:targerTurnEnd();  --受击方流程结束,此时可能还在 tar_hurt状态动画中
		end
	else
		WriteCon( "atkid:"..tostring(atkFighter:GetId()).." atk_end GetHitTimes > 0  ");
		self:targerTurnEnd();  --受击方流程结束,此时可能还在 tar_hurt状态动画中
	end;

end

function p:fighter_damage()
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();
	
end;


function p:atk_standby()
   	local atkFighter = self:getTarFighter();
	atkFighter:standby();
    --atkFighrer.turnRound = false;	--标识攻击结束;
	self:atkTurnEnd();
	
end;



function p:tar_hurtBegin()


	local atkFighter = self:getAtkFighter();
	--local targerFighter = self:getTarFighter();

    --成为目标未攻击的列表减一
	self.targercamp:BeTarTimesDec(atkFighter:GetId());	
	local targerFighter = nil;
	local cmdHurt = nil;
	for k,v in pairs(self.targercamp.fighters) do
		targerFighter = v;
		if (targerFighter.IsHurt == false) then
			targerFighter.IsHurt = true;  --标识受击中
			--受击动画播放一次
			cmdHurt = createCommandPlayer():Hurt( 0, targerFighter:GetNode(), "" );
			self.seqTarget:AddCommand( cmdHurt );
			
			cmdHurt = createCommandEffect():AddActionEffect( 0, targerFighter:GetPlayerNode(), "lancer.ishurt" );
			self.seqTarget:AddCommand(cmdHurt)
			--cmdHurt = battle_show.AddActionEffect_ToSequence( 0, targerFighter:GetPlayerNode(), "lancer.ishurt", self.seqTarget);
		end;
		
		local lfirstID = targerFighter.firstID;
		local latkID = atkFighter:GetId();
		if self.isJoinAtk == true then
			if(lfirstID ~= latkID) then
			--合击的动画
				WriteCon("JoinAtk flash");
			end;
		end;	
	
	end;
    
	if cmdHurt ~= nil then --最后一个受击动画的标识就行了,所有的受击动画,时间都一样
		local batch = w_battle_mgr.GetBattleBatch();
		self.seqHurt = batch:AddSerialSequence();
		local cmdIshurt = atkFighter:cmdLua( "tar_hurt",   self.id,"", self.seqHurt );
		self.seqHurt:SetWaitEnd(cmdHurt); 
    end;				
	--攻击动画
	self:atk_startAtk();
	
end;

function p:tar_hurt()
	local atkFighter = self:getAtkFighter();
	for k,v in pairs(self.targercamp.fighters) do
	    local targerFighter = self:getTarFighter();
		targerFighter = v;
		if targerFighter.IsHurt == true then
			local cmdHurt = battle_show.AddActionEffect_ToSequence( 0, targerFighter:GetPlayerNode(), "lancer.ishurt", self.seqTarget);
			
			local batch = w_battle_mgr.GetBattleBatch();
			self.seqHurt = batch:AddSerialSequence();
			
			local cmdIshurt = atkFighter:cmdLua( "tar_hurt",   self.id,"", self.seqHurt );
			self.seqHurt:SetWaitEnd(cmdHurt); 
		else
			self:tar_hurtEnd();
		end
	end;
end;

--奖励
function p:reward()
	local targerFighter = self:getTarFighter();	
	local tmpList = { {E_DROP_MONEY, 1, targerFighter.Position},
					  {E_DROP_BLUESOUL , 2, targerFighter.Position},
					  {E_DROP_HPBALL , 3, targerFighter.Position},
					  {E_DROP_SPBALL , 4, targerFighter.Position}
					}
	w_battle_pve.MonsterDrop(tmpList)
	
end;

--只有受伤结束时才调用
function p:tar_hurtEnd()
	local atkFighter = self:getAtkFighter();
	local targerFighter = self:getTarFighter();	
	
	--if targerFighter:GetHitTimes() == 0 then --受击次数为0时
	--	targerFighter.IsHurt = false;
	    if (targerFighter.showlife > 0) or (targerFighter:GetTargerTimes() > 0 ) then  --还活着,或者成为目标未攻击的人数不为0,继续播放站立	
			targerFighter:standby();
			self:targerTurnEnd();  --受击方流程结束
		elseif targerFighter.showlife <= 0 then
            if self.CanRevive == true then  --可复活
				targerFighter.isDead = false;
				targerFighter.canRevive = false;
				
				targerFighter:standby();

				local cmdf = createCommandEffect():AddActionEffect( 0.01, targerFighter:GetNode(), "lancer_cmb.revive" );
				self.seqTarget:AddCommand( cmdf );
				local cmdC = createCommandEffect():AddActionEffect( 0.01, targerFighter.m_kShadow, "lancer_cmb.revive" );
				self.seqTarget:AddCommand( cmdC );		
				
				--local batch = battle_show.GetNewBatch();
				--local seqDie	= batch:AddParallelSequence();
				local batch = w_battle_mgr.GetBattleBatch(); 
				local seqDie = batch:AddSerialSequence();
				local cmdRevive = targerFighter:cmdLua("tar_ReviveEnd",  self.id, "", seqDie);
				self.seqRevive:SetWaitEnd( cmdC ); 
			else	--怪死了
				--判断是否要切换怪物目标
				targerFighter:Die();  --标识死亡
				if w_battle_mgr.LockEnemy == true then
					if(w_battle_mgr.PVEEnemyID == targerFighter:GetId()) then  --当前死掉的怪物是正在被锁定的怪物
						if w_battle_mgr.enemyCamp:GetNotDeadFighterCount() > 0 then --可换个怪物
							w_battle_mgr.PVEEnemyID = w_battle_mgr.enemyCamp:GetFirstNotDeadFighterID(targerFighter:GetId()); --除此ID外的活的怪物目标
							w_battle_mgr.SetLockAction(w_battle_mgr.PVEEnemyID);
							--p.LockEnemy = false  --只要选过怪物一直都是属于锁定的
						else  --没有活着的怪物可选
						   w_battle_mgr.isCanSelFighter = false;
						end
					end;
				else
					if w_battle_mgr.enemyCamp:GetNotDeadFighterCount() == 1 then
						w_battle_mgr.PVEEnemyID = w_battle_mgr.enemyCamp:GetFirstNotDeadFighterID(targerFighter:GetId()); --除此ID外的活的怪物目标
						w_battle_mgr.SetPVETargerID(w_battle_mgr.PVEEnemyID);
					end
					--非锁定攻击的怪物,在选择我方人员时就完成了怪物的选择,无需处理
				end;			
				self:reward(); --获得奖励
				
				local cmdf = createCommandEffect():AddActionEffect( 0.01, targerFighter.m_kShadow, "lancer_cmb.die" );
				self.seqTarget:AddCommand( cmdf );
				local cmdC = createCommandEffect():AddActionEffect( 0.01, targerFighter:GetNode(), "lancer_cmb.die" );
				self.seqTarget:AddCommand( cmdC );				
				--local batch = battle_show.GetNewBatch(); 
				--local seqDie	= batch:AddParallelSequence();
				local batch = w_battle_mgr.GetBattleBatch(); 
				local seqDie = batch:AddSerialSequence();
				local cmdDieEnd = targerFighter:cmdLua("tar_dieEnd",  self.id,"", seqDie);
				seqDie:SetWaitEnd( cmdC ); 
			end;
		end;
	--else --还在受其它人打击,本次攻击方发起的受击流程就结束了
	--	self:targerTurnEnd();  --受击方流程结束
	--end;
	
end;

function p:tar_ReviveEnd()
	fighter:GetNode():ClearAllAniEffect();
    fighter.buffList = {};		
	self:targerTurnEnd();	
end;

function p:tar_dieEnd()
	self:targerTurnEnd();
end;

function p:atkTurnEnd()
	self.IsAtkTurnEnd = true;
	local atkFighter = self:getAtkFighter();	
	WriteCon( "atkid:"..tostring(atkFighter:GetId()).." atkTurnEnd ");
	self:CheckEnd();
end;

function p:targerTurnEnd()
	self.IsTarTurnEnd = true;
	local atkFighter = self:getAtkFighter();		
	local tarFighter = self:getTarFighter();
	WriteCon( "atkid:"..tostring(atkFighter:GetId().." targerTurnEnd tarid="..tostring(tarFighter:GetId())));
	self:CheckEnd();
end;

function p:CheckEnd()
	
	if (self.IsAtkTurnEnd == true) and (self.IsTarTurnEnd == true) then --受击 和打击变了
		local atkFighter = self:getAtkFighter();	
		WriteCon( "atkid:"..tostring(atkFighter:GetId()).." PVEStateMachine is End ");
		
		self.IsEnd = true;
		w_battle_mgr.AtkDec(atkFighter:GetId());	

		w_battle_PVEStaMachMgr:delStateMachine(self.id);
		local atkFighter = self:getAtkFighter();
		atkFighter.IsTurnEnd = true;
		
		if self.atkCampType == W_BATTLE_HERO then	
			if w_battle_mgr.enemyCamp:isAllDead() == false then --还有尸体存在
				w_battle_mgr.CheckHeroTurnIsEnd();	
			else  --没有尸体了
				--w_battle_mgr.FightWin();
				if w_battle_mgr.CheckAtkListIsNull() == true then --所有已行动的人,已经行动结束了
					w_battle_pve.PickStep(w_battle_mgr.FightWin); 
				end;
			end
			
		else
			if w_battle_mgr.heroCamp:isAllDead() == false then
				w_battle_mgr.CheckEnemyTurnEnd();
			else
				w_battle_mgr.FightLose();
			end		
		end;
		
		self = nil;		
	end
end;


function p:getFighter(pId,pCampType)
	local lFighter = nil;
	if pCampType == W_BATTLE_HERO then
		lFighter = w_battle_mgr.heroCamp:FindFighter(pId);
	else
		lFighter = w_battle_mgr.enemyCamp:FindFighter(pId);
	end
	return lFighter;
end;

function p:getAtkFighter()
	return self:getFighter(self.atkId, self.atkCampType);
end;

function p:getTarFighter()
	return self:getFighter(self.targerId, self.tarCampType);
end;

