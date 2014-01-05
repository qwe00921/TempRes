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

	local batch = battle_show.GetNewBatch(); 
	self.seqStar = batch:AddParallelSequence(); --战斗开始的并行动画;
	self.seqAtk = batch:AddSerialSequence();
    self.seqTarget = batch:AddSerialSequence(); 
	--self.seqBullet = batch:AddSerialSequence();	
	
end



function p:init(seqStar,id,atkFighter,atkCampType,tarFighter, atkCampType,damage,isCrit,isJoinAtk)
	self.seqStar = seqStar;
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

	
	self:start();

end;

function p:start()
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();
    local latkType = self.atkType;
			
	if latkType == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
	
		local distance = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "distance" ) );
        local playerNode = self.atkplayerNode;
    
		--攻击者最初的位置
		local originPos = playerNode:GetCenterPos();

		--受击目标的位置
		local enemyPos = tarFighter:GetFrontPos(playerNode);

		
		--攻击音乐
		--local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
		--self.seqStar:AddCommand( cmdAtkBegin );

		--向攻击目标移动
		local cmdMove = OnlyMoveTo(atkFighter, originPos, enemyPos, self.seqAtk);
		
		--切换到攻击状态
		local cmdAtk = atkFighter:cmdLua( "atk_startAtk",   self.id,"", self.seqAtk );
		--self.seqAtk:SetWaitEnd(cmdMove);
		
		--self.seqTarget = batch:AddSerialSequence();	
		local cmdHurt = tarFighter:cmdLua("tar_hurt",        self.id,"", self.seqTarget);
		self.seqTarget:SetWaitEnd( cmdMove );
		
		
	elseif self.atkType == W_BATTLE_DISTANCE_Archer then  --远程攻击
	    local isBullet = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "is_bullet" ) );
		local bulletAni;
		if isBullet == N_BATTLE_BULLET_1 then --有弹道
			local cmdAtk = createCommandPlayer():Atk( 0.3, playerNode, "" );
			self.seqAtk:AddCommand( cmdAtk ); --攻击动作
			
			local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
			--受击音乐
			if atkSound ~= nil then
				local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
				self.seqAtk:AddCommand( cmdAtkMusic );
			end			
			
			local bulletAni = "n_bullet."..tostring( atkFighter.cardId );
			
			local deg = atkFighter:GetAngleByFighter( tarFighter );
			local bullet = w_bullet:new();
			bullet:AddToBattleLayer();
			bullet:SetEffectAni( bulletAni );
						
			bullet:GetNode():SetRotationDeg( deg );
			local bullet1 = bullet:cmdSetVisible( true, self.seqAtk );
			bulletend = bullet:cmdShoot( atkFighter, tarFighter, self.seqAtk, false );
			local bullet3 = bullet:cmdSetVisible( false, self.seqAtk );
			--seqBullet:SetWaitEnd( cmdAtk );
			
			--切换到攻击状态
			atkFighter:cmdLua( "atk_startAtk",  self.id,  "", self.seqAtk );

			tarFighter:cmdLua("tar_hurt",        self.id, "", self.seqTarget);
			self.seqTarget:SetWaitEnd( cmdAtk );
			
		else  --没弹道
			local cmdAtk = createCommandPlayer():Atk( 0.3, playerNode, "" );
			self.seqAtk:AddCommand( cmdAtk ); --攻击动作
			
			local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
			--受击音乐
			if atkSound ~= nil then
				local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
				self.seqAtk:AddCommand( cmdAtkMusic );
			end
			
			atkFighter:cmdLua( "atk_startAtk",   self.id,"", self.seqAtk );
			
			tarFighter:cmdLua("tar_hurt",  self.id, "", self.seqTarget);
			self.seqTarget:SetWaitEnd( cmdAtk );
		end

	end
	
end


function p:atk_startAtk()  --攻击
	local atkFighter = self:getAtkFighter();

	if self.atkType == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
		--攻击敌人动画
		local cmdAtk = createCommandPlayer():Atk( 0.3, self.atkplayerNode, "" );
		self.seqAtk:AddCommand( cmdAtk );	
		

		local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
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
	local tarFighter = self:getTarFighter();


    --受击后掉血,不用等掉血动画完成
	--local cmd11 = tarFighter:cmdLua( "fighter_damage",   self.id,"", self.seqTarget );	
	tarFighter:SubShowLife(self.damage); --掉血动画,及表示的血量减少

    --处理攻击方	
	if self.atkType == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
		
		    --最初站立动画
		local cmd4 = createCommandPlayer():Standby( 0.01, self.atkplayerNode, "" );
		self.seqAtk:AddCommand( cmd4 );
        --返回原来的位置
        local cmd5 = OnlyMoveTo(atkFighter, self.enemyPos, self.originPos, self.seqAtk);
    
--		local cmdBackRset = createCommandEffect():AddActionEffect( 0, tarFighter:GetPlayerNode(), "lancer.target_hurt_back_reset" );
--		self.seqAtk:AddCommand( cmdBackRset ); 
		
		--local cmdClearPic = atkFighter:cmdLua( "ClearAllFighterPic",  0, self.id, seqAtk );
	end;

	--标识攻击方的攻击完成了
	atkFighter:cmdLua( "atk_standby",  self.id, "", self.seqAtk ); 


	--受击方结算
	--受击次数减一	
	tarFighter:BeHitDec(atkFighter:GetId()); 
	
	self:tar_hurtEnd();


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

function p:tar_hurt()


	local atkFighter = self:getAtkFighter();
	local targerFighter = self:getTarFighter();


    if targerFighter.IsHurt == false then
		targerFighter.IsHurt = true;  --标识受击中
		--受击动画播放一次
		local cmdHurt = createCommandPlayer():Hurt( 0, targerFighter:GetNode(), "" );
		self.seqTarget:AddCommand( cmdHurd );

	    --受击动画无限播
		--local cmdHurtAll = createCommandPlayer():Hurt( 0, targerFighter:GetNode(), "" );
		--self.seqTarget:AddCommand( cmdHurtAll );

        
	end;
	
end;


function p:tar_hurtEnd()
	local atkFighter = self:getAtkFighter();
	local targerFighter = self:getTarFighter();	
	
	if targerFighter:GetHitTimes() == 0 then --受击次数为0时
		targerFighter.IsHurt = false;
	    if targerFighter.showlife > 0 then  --还活着,继续播放站立	
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
								
				local cmdRevive =targerFighter:cmdLua("tar_ReviveEnd",  self.id, "", seq);
				self.seqTarget:SetWaitEnd( cmdC ); 
			else	--怪死了
				--判断是否要切换怪物目标
				if p.LockEnemy == true then
					if(p.PVEEnemyID == lFighterID) then  --当前锁定的怪物已经挂了
						if p.enemyCamp:GetActiveFighterCount() > 0 then --换个怪物
							p.PVEEnemyID = p.enemyCamp:GetActiveFighterID(lFighterID); --除此ID外的活的怪物目标
							--p.LockEnemy = false  --只要选过怪物一直都是属于锁定的
						else  --没有活着的怪物可选
						   p.isCanSelFighter = false;
						end
					end;
				else
					--非锁定攻击的怪物,在选择我方人员时就完成了怪物的选择,无需处理
				end;			
			
			
				local cmdf = createCommandEffect():AddActionEffect( 0.01, targerFighter.m_kShadow, "lancer_cmb.die" );
				self.seqTarget:AddCommand( cmdf );
				local cmdC = createCommandEffect():AddActionEffect( 0.01, targerFighter:GetNode(), "lancer_cmb.die" );
				self.seqTarget:AddCommand( cmdC );				
				
				local cmdDieEnd = targerFighter:cmdLua("tar_dieEnd",  self.id,"", self.seqTarget);
				--seqDieEnd:SetWaitEnd( cmdDieEnd ); 
			end;
		end;
	else --还在受其它人打击,本次攻击方发起的受击流程就结束了
		self:targerTurnEnd();  --受击方流程结束
	end;

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
	if (self.atkEnd == true) and (self.targerEnd == true) then
		self.IsEnd = true;
		w_battle_atkState:delStateMachine(self.id);
		self = nil;
	end
end;


--[[
function p:atk_hurt()    	
	local batch = battle_show.GetNewBatch(); 
	local seqAtk    = batch:AddSerialSequence();
    local seqTarget = batch:AddSerialSequence();
		
	local atkFighter = self:getAtkFighter();	
	
	--show的体力值减少,飘血
	atkFighter:atk_damage(self.damage);
    	

	
	--cmdAtk:SetDelay(0.2f); --设置攻击延迟
     local playerNode = self.atkplayerNode;
    
	
    --	
	
    --最初站立动画
    local cmd4 = createCommandPlayer():Standby( 0.01, playerNode, "" );
    seqAtk:AddCommand( cmd4 );
    

    --返回原来的位置
    local cmd5 = JumpMoveTo(atkFighter, enemyPos, originPos, seqAtk, false);

    

    
    local cmdAtkEnd = createCommandInstant_Misc():SetZOrderAtTop( atkFighter:GetNode(), false );
    seqAtk:AddCommand( cmdAtkEnd );
    
	--攻击方动画播完, 攻击顺列次数减1,减为0时,判断是否继续站立还是阵亡.
	--将cmd命的执行压入seqAtk顺序执行
	atkFighter:cmdLua( "atk_hurt",  targetFighter:GetId(), "", seqAtk );

end
]]--
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

