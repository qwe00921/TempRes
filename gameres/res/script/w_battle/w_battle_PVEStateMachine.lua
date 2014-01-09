w_battle_PVEStateMachine = {}
local p = w_battle_PVEStateMachine;
		  
--PVE的一次战斗的状态机


--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	return o;
end

--构造函数
function p:ctor()
	self.IsEnd = false;
	self.IsAtkTurnEnd = false;	
	self.IsTarTurnEnd = false;
	
	self.atkId = 0;
	self.id = 0;	
	self.targerId = 0;
	self.atkCampType = 0;
	self.tarCampType = 0;
	self.atkType = 0; 
	self.damage = 0;
	self.isCrit = false;
	self.isJoinAtk = false;
	self.atkplayerNode = 0;
	self.IsRevive = false;
	
--[[
	local batch = battle_show.GetNewBatch(); 
	--self.seqStar = batch:AddParallelSequence(); --战斗开始的并行动画;
	self.seqStar = battle_show.GetDefaultParallelSequence();
	self.seqAtk = batch:AddParallelSequence();
    self.seqTarget = batch:AddParallelSequence(); 
	--self.seqBullet = batch:AddSerialSequence();	
	]]--
end



function p:init(id,atkFighter,atkCampType,tarFighter, atkCampType,damage,isCrit,isJoinAtk)
	--self.seqStar = seqStar;
	self.atkId = atkFighter:GetId();
	self.id = id;	
	self.targerId = tarFighter:GetId();
	self.atkCampType = atkCampType;
	self.tarCampType = tarCampType;
	self.atkType = atkFighter:GetAtkType(); 
	self.damage = damage;
	self.isCrit = isCrit;
	self.isJoinAtk = isJoinAtk;
	self.atkplayerNode = atkFighter:GetPlayerNode();
	

    --攻击者最初的位置
    self.originPos = self.atkplayerNode:GetCenterPos();

    --攻击目标的位置
    self.enemyPos = tarFighter:GetFrontPos(self.atkplayerNode);	

	
	local batch = w_battle_mgr.GetBattleBatch(); 
	self.seqStar = batch:AddSerialSequence();
	self.seqAtk = batch:AddSerialSequence();
	self.seqTarget = batch:AddSerialSequence(); 
	
	
	self:start();

end;

function p:start()
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();
    local latkType = self.atkType;
    local playerNode = self.atkplayerNode;
			
	if latkType == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
	
		local distance = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "distance" ) );
       
    
		--攻击者最初的位置
		local originPos = playerNode:GetCenterPos();

		--受击目标的位置
		local enemyPos = tarFighter:GetFrontPos(playerNode);

		
		--攻击音乐
		--local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
		--self.seqStar:AddCommand( cmdAtkBegin );

		--WriteCon("atk move! id="..tostring(atkFighter:GetId()));
		--向攻击目标移动
		local cmdMove = OnlyMoveTo(atkFighter, originPos, enemyPos, self.seqStar);
		
		--self.seqAtk = batch:AddParallelSequence();
		--切换到攻击状态
		
		--local cmdAtk = atkFighter:cmdLua( "atk_startAtk",   self.id,"", self.seqAtk );
		--self.seqAtk:SetWaitEnd(cmdMove);
		
		
		local cmdHurt = tarFighter:cmdLua("tar_hurtBegin",        self.id,"", self.seqTarget);
		self.seqTarget:SetWaitEnd( cmdMove );
		
		
	elseif self.atkType == W_BATTLE_DISTANCE_Archer then  --远程攻击
	    local isBullet = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "is_bullet" ) );
		local bulletAni;
		if isBullet == N_BATTLE_BULLET_1 then --有弹道
			local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, playerNode, "" );
			self.seqStar:AddCommand( cmdAtk ); --攻击动作
			
			
			local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
			--受击音乐
			if atkSound ~= nil then
				local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
				self.seqAtk:AddCommand( cmdAtkMusic );
			end			
			self.seqAtk:SetWaitEnd(cmdAtk);
			local bulletAni = "w_bullet."..tostring( atkFighter.cardId );
			
			local deg = atkFighter:GetAngleByFighter( tarFighter );
			local bullet = w_bullet:new();
			bullet:AddToBattleLayer();
			bullet:SetEffectAni( bulletAni );
						
			bullet:GetNode():SetRotationDeg( deg );
			local bullet1 = bullet:cmdSetVisible( true, self.seqAtk );
			bulletend = bullet:cmdShoot( atkFighter, tarFighter, self.seqAtk, false );
			local bullet3 = bullet:cmdSetVisible( false, self.seqAtk );
			--seqBullet:SetWaitEnd( cmdAtk );
			
			tarFighter:cmdLua("tar_hurtBegin",        self.id, "", self.seqTarget);
			self.seqTarget:SetWaitEnd( cmdAtk );

			--切换到攻击状态
			--atkFighter:cmdLua( "atk_startAtk",  self.id,  "", self.seqAtk );
			--self.seqAtk:SetWaitEnd(cmdAtk);
			
		else  --没弹道
			local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, playerNode, "" );
			self.seqStar:AddCommand( cmdAtk ); --攻击动作
			
			local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
			--受击音乐
			if atkSound ~= nil then
				--local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
				--self.seqAtk:AddCommand( cmdAtkMusic );
			end;	

			tarFighter:cmdLua("tar_hurtBegin",  self.id, "", self.seqTarget);
			self.seqTarget:SetWaitEnd( cmdAtk );
			
			--atkFighter:cmdLua( "atk_startAtk",   self.id,"", self.seqAtk );
			--self.seqAtk:SetWaitEnd(cmdAtk);
			
			

		end

	end
	
end


function p:atk_startAtk()  --攻击
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();

	
	if self.atkType == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
		--local batch = battle_show.GetNewBatch(); 
		--self.seqAtk = batch:AddParallelSequence();
		--self.seqAtk = batch:AddSerialSequence();
		--攻击敌人动画
		
		
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, self.atkplayerNode, "" );
		self.seqAtk:AddCommand( cmdAtk );	
		
--[[
		local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
		--受击音乐
		if atkSound ~= nil then
			local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
			self.seqAtk:AddCommand( cmdAtkMusic );
		end
	]]--	
	end;
	
	--攻击结束播放受击动作
	atkFighter:cmdLua( "atk_end",  self.id, "", self.seqAtk ); 
	
end

function p:atk_end()
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();


    --受击后掉血,不用等掉血动画完成
	tarFighter:SubShowLife(self.damage); --掉血动画,及表示的血量减少
	local cmd4 = createCommandPlayer():Standby( 0.01, self.atkplayerNode, "" );
	self.seqAtk:AddCommand( cmd4 );
	
    --处理攻击方	
	if self.atkType == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
		
		    --最初站立动画

        --返回原来的位置
        local cmd5 = OnlyMoveTo(atkFighter, self.enemyPos, self.originPos, self.seqAtk);
    
--		local cmdBackRset = createCommandEffect():AddActionEffect( 0, tarFighter:GetPlayerNode(), "lancer.target_hurt_back_reset" );
--		self.seqAtk:AddCommand( cmdBackRset ); 
	end;

	--标识攻击方的攻击完成了
	atkFighter:cmdLua( "atk_standby",  self.id, "", self.seqAtk ); 


	--受击方结算
	--受击次数减一	
	tarFighter:BeHitDec(atkFighter:GetId()); 
	
	if tarFighter:GetHitTimes() == 0 then --受击次数为0时
		tarFighter.IsHurt = false;
	else
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
	local targerFighter = self:getTarFighter();


    if (targerFighter.IsHurt == false) then
		targerFighter.IsHurt = true;  --标识受击中
		--受击动画播放一次
		local cmdHurt = createCommandPlayer():Hurt( 0, targerFighter:GetNode(), "" );
		self.seqTarget:AddCommand( cmdHurt );
		
		local cmdHurt = battle_show.AddActionEffect_ToSequence( 0, targerFighter:GetPlayerNode(), "lancer.ishurt", self.seqTarget);
		
		local batch = w_battle_mgr.GetBattleBatch();
		self.seqHurt = batch:AddSerialSequence();
		
		local cmdIshurt = atkFighter:cmdLua( "tar_hurt",   self.id,"", self.seqHurt );
		self.seqHurt:SetWaitEnd(cmdHurt); 
	end;
	
	local lfirstID = targerFighter.firstID;
	local latkID = atkFighter:GetId();
	if self.isJoinAtk == true then
		if(lfirstID ~= latkID) then
		--合击的动画
			WriteCon("JoinAtk flash");
		end;
	end;
	
	self:atk_startAtk();
	
end;

function p:tar_hurt()
	local atkFighter = self:getAtkFighter();
	local targerFighter = self:getTarFighter();
	
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
	    if targerFighter.showlife > 0 then  --还活着,继续播放站立	
			targerFighter:standby();
			
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
	self:targerTurnEnd();  --受击方流程结束
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
	self:CheckEnd();
end;

function p:targerTurnEnd()
	self.IsTarTurnEnd = true;
	self:CheckEnd();
end;

function p:CheckEnd()
	if (self.IsAtkTurnEnd == true) and (self.IsTarTurnEnd == true) then --受击 和打击变了
		self.IsEnd = true;
		w_battle_PVEStaMachMgr:delStateMachine(self.id);
		local atkFighter = self:getAtkFighter();
		atkFighter.IsTurnEnd = true;
		
		if self.atkCampType == W_BATTLE_HERO then	
			if w_battle_mgr.enemyCamp:isAllDead() == false then --还有尸体存在
				w_battle_mgr.CheckHeroTurnIsEnd();	
			else  --没有尸体了
				--w_battle_mgr.FightWin();
				w_battle_pve.PickStep(w_battle_mgr.FightWin); 
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

