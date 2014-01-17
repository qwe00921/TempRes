w_battle_target_statemachine = {}  --受击者状态机, 只关心受击者的受击动作及之后是站立还是死亡
local p = w_battle_target_statemachine;
		  

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
	self.IsTurnEnd = true; 
	self.id = 0;	
	self.canRevive = false;
	self.tarFighter = nil;
end



function p:init(id,camp)
	self.id = id
	self.camp = camp;
	if self.camp == W_BATTLE_HERO then
		self.tarFighter = w_battle_mgr.heroCamp:FindFighter(id)
	else
		self.tarFighter = w_battle_mgr.enemyCamp:FindFighter(id)
	end;
end;



function p:setInHurt(atkFighter)
	self.atkFighter = atkFighter;
	local targerFighter = self.tarFighter;
	--WriteCon( " targetTurn start tarid="..tostring(targerFighter:GetId()));
	
	--已成为目标,未攻击
	--targerFighter:BeTarTimesDec(atkFighter:GetId()); 
    if (targerFighter.IsHurt == false) then --进入受击标识
		WriteCon( "targetTurn Start id="..tostring(targerFighter:GetId()));
		self.IsTurnEnd = false;
		targerFighter.IsHurt = true;  --标识受击中
		local batch = w_battle_mgr.GetBattleBatch();
		local seqTarget = batch:AddSerialSequence();
		local seqHurt = batch:AddSerialSequence();
		
		--受击动画播放一次
		local cmdHurt = createCommandPlayer():Hurt( 0, targerFighter:GetNode(), "" );
		seqTarget:AddCommand( cmdHurt );
		
		--local cmdHurt = battle_show.AddActionEffect_ToSequence( 0, targerFighter:GetPlayerNode(), "lancer.ishurt", self.seqTarget);
        local cmdHurt = createCommandEffect():AddActionEffect( 0.35, targerFighter:GetPlayerNode(), "lancer.ishurt" );
		seqTarget:AddCommand( cmdHurt );		
		
		local cmdIshurt = targerFighter:cmdLua( "tar_hurt",   self.id, tostring(self.camp), seqHurt );
		seqHurt:SetWaitEnd(cmdHurt); 
	else
		WriteCon( "targetTurn InHurt now atkid="..tostring(atkFighter:GetId()));
	end;

end;

function p:tar_hurt() 
	local atkFighter = self.atkFighter;
	local targerFighter = self.tarFighter;
	
	if targerFighter.IsHurt == true then
		local batch = w_battle_mgr.GetBattleBatch();
		local seqTarget = batch:AddSerialSequence();
		local seqHurt = batch:AddSerialSequence();
		
 		local cmdHurt = createCommandEffect():AddActionEffect( 0.35, targerFighter:GetPlayerNode(), "lancer.ishurt" );
		seqTarget:AddCommand( cmdHurt );
		
		local cmdIshurt = targerFighter:cmdLua( "tar_hurt",   self.id, tostring(self.camp), seqHurt );
		seqHurt:SetWaitEnd(cmdHurt); 
	else
		WriteCon( "targetTurn tar_hurt to end tarid="..tostring(targerFighter:GetId()));
        self:tar_hurtEnd();
	end
end;

--奖励
function p:reward()
	local targerFighter = self.tarFighter;	
	local tmpList = { {E_DROP_MONEY, 1, targerFighter.Position},
					  {E_DROP_BLUESOUL , 2, targerFighter.Position},
					  {E_DROP_HPBALL , 3, targerFighter.Position},
					  {E_DROP_SPBALL , 4, targerFighter.Position}
					}
	w_battle_pve.MonsterDrop(tmpList)
	
end;

--只有受伤结束时才调用
function p:tar_hurtEnd()
	local targerFighter = self.tarFighter;	
	local batch = w_battle_mgr.GetBattleBatch();
	local seqTarget = batch:AddSerialSequence();
	local seqHurt = batch:AddSerialSequence();
    if self:IsEnd() then  --已结束
		return ;
	end;
	
	if targerFighter.IsHurt == true then  --又进入了受击状态
		return ;
	end;
	
			
	if (targerFighter.Hp > 0) or (targerFighter:GetTargerTimes() > 0 ) then  --还活着,或者成为目标未攻击的人数不为0,继续播放站立	
		targerFighter:standby();
		--if (targerFighter.Hp > 0) then
			WriteCon( "targetTurn standby id="..tostring(targerFighter:GetId()));
		--elseif targerFighter:GetTargerTimes() > 0 then
		--	WriteCon( "targetTurn Die but GetTargerTimes> 0 id="..tostring(targerFighter:GetId()));
		--end;
		self:targerTurnEnd();  --受击方流程结束
	elseif (targerFighter:GetHitTimes() ~= 0) then
		WriteCon( "**********Error! targetTurn GetHitTimes~=0 need die id="..tostring(targerFighter:GetId()));
	elseif targerFighter.Hp <= 0 then
		if self.canRevive == true then  --可复活
			targerFighter.isDead = false;
			targerFighter.canRevive = false;
			
			targerFighter:standby();

			local cmdf = createCommandEffect():AddActionEffect( 0.01, targerFighter:GetNode(), "lancer_cmb.revive" );
			seqTarget:AddCommand( cmdf );
			local cmdC = createCommandEffect():AddActionEffect( 0.01, targerFighter.m_kShadow, "lancer_cmb.revive" );
			seqTarget:AddCommand( cmdC );		
			
			--local batch = w_battle_mgr.GetBattleBatch(); 
			local seqDie = batch:AddSerialSequence();
			local cmdRevive = targerFighter:cmdLua("tar_ReviveEnd",  self.id, tostring(self.camp), seqDie);
			seqDie:SetWaitEnd( cmdC ); 
		else	--怪死了
			--判断是否要切换怪物目标
			if targerFighter.isDead == true then
				WriteCon( "*********************Error! tar_hurtEnd can not in die double  tarid="..tostring(targerFighter:GetId()) );	
				return ;
			end;
			targerFighter:Die();  --标识死亡
			WriteCon( "tar_hurtEnd tar_die tarid="..tostring(targerFighter:GetId()) );
			if(self.camp == W_BATTLE_ENEMY) then  --受击的是怪物
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
					local lcount = w_battle_mgr.enemyCamp:GetNotDeadFighterCount();
					if lcount == 1 then
						w_battle_mgr.PVEEnemyID = w_battle_mgr.enemyCamp:GetFirstNotDeadFighterID(targerFighter:GetId()); --除此ID外的活的怪物目标
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
			
			--[[
			if targerFighter.m_kShadow ~= nil then
				local cmdf = createCommandEffect():AddActionEffect( 0.01, targerFighter.m_kShadow, "lancer_cmb.die" );
				self.seqTarget:AddCommand( cmdf );
			end;
			]]--
			local cmdC = createCommandEffect():AddActionEffect( 3, targerFighter:GetNode(), "lancer_cmb.die" );
			seqTarget:AddCommand( cmdC );				
			local seqDie = batch:AddSerialSequence();
			local cmdDieEnd = targerFighter:cmdLua("tar_dieEnd",  self.id, tostring(self.camp), seqDie);
			seqDie:SetWaitEnd( cmdC ); 
		end;
	end;

	
end;

function p:tar_ReviveEnd() 
	fighter:GetNode():ClearAllAniEffect();
    fighter.buffList = {};		
	self:targerTurnEnd();	
end;

function p:tar_dieEnd() 
	local tarFighter = self.tarFighter;
	WriteCon( "tar_dieEnd tarid="..tostring(tarFighter:GetId()).." self.atkFighter id="..tostring(self.atkFighter:GetId()) );
	self:targerTurnEnd();
end;

--自己的回合结束
function p:targerTurnEnd()
	self.IsTurnEnd = true;
	local tarFighter = self.tarFighter;	
	WriteCon( "targetTurnEnd id="..tostring(tarFighter:GetId()));
	w_battle_mgr.checkTurnEnd(); --检查是否回合结束结束

end;

function p:IsEnd()
	return self.IsTurnEnd;
end;
