w_battle_atk_statemachine = {}  --单体伤害状态机
local p = w_battle_atk_statemachine;
		  

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
	--self.IsAtkTurnEnd = false;	
	self.turnState = W_BATTLE_NOT_TURN;
	self.atkId = 0;
	self.id = 0;	
	--self.tarList = 0;
	self.targetLst = {};
	self.damageLst = {};
	--self.atkCampType = 0;
	--self.tarCampType = 0;
	--self.atkType = 0; 
	--self.damage = 0;
	self.critLst = {};
	self.joinAtkLst = {};
	self.atkplayerNode = 0;
	self.IsRevive = false;
	self.IsSkill  = false;

end



function p:init(id,atkFighter,atkCampType,tarFighter, tarCampType,damageLst,critLst,joinAtkLst,isSkill,skillID,isAoe,targetLst,HasBuffLst)
	self.atkId = atkFighter:GetId();
	--self.id = atkFighter:GetId();	
	self.targerId = tarFighter:GetId();
	self.atkFighter = atkFighter;
	self.targetFighter = tarFighter;
	self.atkCampType = atkCampType;
	self.tarCampType = tarCampType;
	
	self.damageLst = damageLst;	
	self.critLst = critLst;
	self.joinAtkLst = joinAtkLst;
	self.atkplayerNode = atkFighter:GetPlayerNode();
	self.IsSkill = isSkill; --是否属于技能
    self.isAoe = isAoe;
	self.skillID = skillID;
	if self.IsSkill == true then
		self.distanceRes = tonumber( SelectCell( T_SKILL_RES, skillID, "distance" ) );--远程与近战的判断;	
		self.targetType   = tonumber( SelectCell( T_SKILL, skillID, "Target_type" ) );
		self.skillType = tonumber( SelectCell( T_SKILL, skillID, "Skill_type" ) );
		self.singSound = SelectCell( T_SKILL_SOUND, skillID, "sing_sound" );
		self.hurtSound = SelectCell( T_SKILL_SOUND, skillID, "hurt_sound" );
		self.sing = SelectCell( T_SKILL_RES, skillID, "sing_effect" );
        self.hurt = SelectCell( T_SKILL_RES, skillID, "hurt_effect" );
		self.is_bullet = tonumber( SelectCell( T_SKILL_RES, skillID, "is_bullet" ) );
		self.HasBuffLst = HasBuffLst;
		--self.bufftype = tonumber(SelectCell( T_SKILL, skillID, "buff_type" ) );
	else
		self.distanceRes = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "distance" ) );
		self.atkSound =  SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
		self.is_bullet = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "is_bullet" ) );
	end


    --攻击者最初的位置
    self.originPos = self.atkplayerNode:GetCenterPos();
	if self.isAoe == true then
		if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --近战
			self.enemyPos = w_battle_mgr.GetScreenCenterPos();	
		else  --远程,在自己位置上,没有目标
			self.enemyPos = nil;
		end;
		self.targetLst = targetLst;
	else
	    self.enemyPos = tarFighter:GetFrontPos(self.atkplayerNode);	
		self.targetLst = {}
		self.targetLst[1] = tarFighter;
	end
    --攻击目标的位置
	if self.atkCampType == W_BATTLE_ENEMY then --攻击方是怪物,先出手延迟
		self:startDelay();
	else
		self:atk_startsing();
	end

	
	--self:start();

end;

function p:startDelay()
	local batch = w_battle_mgr.GetBattleBatch(); 
	local seqStar = batch:AddSerialSequence();
	local seqAtk = batch:AddSerialSequence();	
	local atkFighter = self.atkFighter
    	
	
	local cmdStandby = createCommandPlayer():Standby( atkFighter.delayTime, self.atkplayerNode, "" );
	seqStar:AddCommand( cmdStandby );	
	
	local cmdAtk = self.atkFighter:cmdLua("atk_startsing",  self.id,"", seqAtk);
	seqAtk:SetWaitEnd( cmdStandby );
end;

--吟唱
function p:atk_startsing()
	if self.IsSkill == true then
		local batch = w_battle_mgr.GetBattleBatch(); 
		local seqStar = batch:AddSerialSequence();
		local seqAtk = batch:AddSerialSequence();
--		self.seqTarget = batch:AddSerialSequence(); 
	
    	local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( self.singSound );
        seqStar:AddCommand( cmdSingMusic );
    
	    local cmd1 = createCommandEffect():AddFgEffect( 0.5, self.atkFighter:GetNode(), self.sing );
		seqStar:AddCommand( cmd1 );
		
		if self.skillType == 1 then  --伤害类
			local cmdAtk = self.atkFighter:cmdLua("atk_start",  self.id,"", seqAtk);
			seqAtk:SetWaitEnd( cmd1 );
		else --恢复类,上BUFF类
			local cmdAtk = self.atkFighter:cmdLua("atk_startBuff",  self.id,"", seqAtk);
			seqAtk:SetWaitEnd( cmd1 );
		end;
	else
		self:atk_start();
    end;					
	
end;

--加恢复或BUFF
function p:atk_startBuff()
	local cmdBuff = nil;
	local batch = w_battle_mgr.GetBattleBatch(); 
		
	for k,v in pairs(self.targetLst) do
		tarFighter = v;
		--local pos = v:GetId();
		cmdBuff = createCommandEffect():AddFgEffect( 1, tarFighter:GetNode(), self.hurt );
		local seqTemp = batch:AddSerialSequence();
		seqTemp:AddCommand( cmdBuff );		
		
		if self.skillType == 2 then --加血类
			local ldamage = (self.damageLst)[k];
			tarFighter:AddShowLife(ldamage); --加血动画,及表示的血量减少				
			tarFighter:AddLife(ldamage);
		else
			tarFighter:AddSkillBuff(self.skillID);
		end;
	end	
	
	local seqBuff = batch:AddSerialSequence();
	local cmdBuffEnd = self.atkFighter:cmdLua("atk_BuffEnd",  self.id,"", seqBuff);
	seqBuff:SetWaitEnd( cmdBuff );
	
end;


function p:atk_BuffEnd()
	self:atkTurnEnd();
end;

--开始,近战的先移动
function p:atk_start()
	local atkFighter = self.atkFighter;
	local tarFighter = self.targetFighter;
	local batch = w_battle_mgr.GetBattleBatch(); 
	local seqStar = batch:AddSerialSequence();
	--local seqAtk = batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence(); 
		
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
		--向攻击目标移动
		local cmdMove = OnlyMoveTo(atkFighter, self.originPos, self.enemyPos, seqStar);
		
		local cmdAtk = atkFighter:cmdLua("atk_startAtk",  self.id,"", seqTarget);
		seqTarget:SetWaitEnd( cmdMove );
	elseif self.distanceRes == W_BATTLE_DISTANCE_Archer then  --远程攻击
		self:atk_startAtk();
	end;
end

--近战: 攻击的同时受击
--远程有道弹: 道弹结束后受击
--远程无道:受击
--单体技能同上
--群体技能,攻后结束后,受击
function p:atk_startAtk()  
	local atkFighter = self.atkFighter;
	local tarFighter = self.targetFighter;
	local batch = w_battle_mgr.GetBattleBatch(); 
	local seqStar = batch:AddSerialSequence();
	local seqAtk = batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence(); 	
    local seqAtkEnd = batch:AddSerialSequence(); 	
	local seqMusic =  batch:AddSerialSequence(); 	
	
	WriteCon( "atkFighter atkid="..tostring(atkFighter:GetId()).." tarid="..tostring(tarFighter:GetId()) );
	for k,v in pairs(self.targetLst) do
		
		tarFighter = v;
		--成为目标未攻击的队列减少
		tarFighter:BeTarTimesDec(atkFighter:GetId());
		
		--攻击队列增加
		tarFighter:BeHitAdd(atkFighter:GetId());  
		if tarFighter.IsHurt == false then --未受击
			--受击
			local  ltargetMachine = w_battle_machinemgr.getTarStateMachine(self.tarCampType, tarFighter:GetId());
			--if ltargetMachine:IsEnd() == true then --处于待机状态
				WriteCon( "atkFighter atkid="..tostring(atkFighter:GetId()).." target inhurt tarid="..tostring(tarFighter:GetId()) );
				ltargetMachine:setInHurt(self.atkFighter);	
			--end;
		end;
	end

	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
		--攻击敌人动画
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, self.atkplayerNode, "" );
		seqAtk:AddCommand( cmdAtk );	
	
		local cmd11 = nil;
		if self.IsSkill == true then	--近战技能只有攻击,  受击特效
			--for k,v in pairs(self.targetLst) do
			--	tarFighter = v;
				local lPlayNode = atkFighter:GetAtkImageNode(self.atkplayerNode,self.hurt)
				--local lPlayNode = tarFighter:GetPlayerNode()
				cmd11 = createCommandEffect():AddFgEffect( 1, lPlayNode, self.hurt );
				local batch = w_battle_mgr.GetBattleBatch(); 
				local seqTemp = batch:AddSerialSequence();
				seqTemp:AddCommand( cmd11 );					
				
			--end;			
		end;		
		--攻击结束播放受击动作
		self.atkFighter:cmdLua( "atk_end",  self.id, "", seqAtkEnd ); 
		seqAtkEnd:SetWaitEnd(cmdAtk);
    else

		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, self.atkplayerNode, "" );
		seqStar:AddCommand( cmdAtk ); --攻击动作
		
		local atkSound = self.atkSound;
		--攻击音乐
		if atkSound ~= nil then
			local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
			seqMusic:AddCommand( cmdAtkMusic );
		end			

		if self.is_bullet == W_BATTLE_BULLET_1 then --有弹道
			local bulletAni = "w_bullet."..tostring( atkFighter.cardId );
			
			local deg = atkFighter:GetAngleByFighter( tarFighter );
			local bullet = w_bullet:new();
			bullet:AddToBattleLayer();
			bullet:SetEffectAni( bulletAni );
						
			bullet:GetNode():SetRotationDeg( deg );
			local bullet1 = bullet:cmdSetVisible( true, seqAtk );
			bulletend = bullet:cmdShoot( atkFighter, tarFighter, seqAtk, false );
			local bullet3 = bullet:cmdSetVisible( false, seqAtk );
			--seqBullet:SetWaitEnd( cmdAtk );
			if self.IsSkill == true then  --技能有受击光效
				local cmd11 = createCommandEffect():AddFgEffect( 1, tarFighter:GetNode(), self.hurt );			
				seqAtk:AddCommand(cmd11);
			end;
			
			atkFighter:cmdLua("atk_end",        self.id, "", seqTarget);
			seqTarget:SetWaitEnd( bulletend );
		else  --没弹道
			--攻击结束
			if self.IsSkill == true then	--技能受击特效
				--for pos=1,#self.targetLst do
				--	tarFighter = (self.targetLst)[pos];
				for k,v in pairs(self.targetLst) do
					tarFighter = v;
					local cmd11 = createCommandEffect():AddFgEffect( 1, tarFighter:GetNode(), self.hurt );
					local batch = w_battle_mgr.GetBattleBatch(); 
					local seqTemp = batch:AddSerialSequence();
					seqTemp:AddCommand( cmd11 );
				end;			
			end;			

			
			self.atkFighter:cmdLua( "atk_end",  self.id, "", seqTarget ); 
			seqTarget:SetWaitEnd( cmdAtk );
		end
	end;

end



function p:atk_end()
	local atkFighter = self.atkFighter;
	local tarFighter = nil;
	local batch = w_battle_mgr.GetBattleBatch(); 
--	local seqStar = batch:AddSerialSequence();
	local seqAtk = batch:AddSerialSequence();
--	local seqMusic = batch:AddSerialSequence();
--	local seqTarget = batch:AddSerialSequence(); 
		
	--for pos=1,#self.targetLst do
	--	tarFighter = (self.targetLst)[pos];
	for k,v in pairs(self.targetLst) do
		tarFighter = v;
		--受击后掉血,不用等掉血动画完成
		local ldamage = (self.damageLst)[k];
		if ldamage == nil then
			WriteCon(" position ="..tostring(tarFighter.Position).." k="..tostring(k));
		end;
		local lisMoredamage = false;  --超量击杀
		if tarFighter.Hp <= 0 then
			lisMoredamage = true;
		end;
		tarFighter:SubShowLife(ldamage); --掉血动画,及表示的血量减少	
		if self.atkCampType == W_BATTLE_HERO then
			if w_battle_mgr.LockEnemy ~= true then --未锁定,要更新血量
				w_battle_pve.SetHp(tarFighter); --更新血量	
			else
				if tarFighter:GetId() == w_battle_mgr.PVEEnemyID then
					w_battle_pve.SetHp(tarFighter); --更新血量	
				end
			end;	
		else
			w_battle_pve.SetHeroCardAttr(tarFighter:GetId(), tarFighter);
		end;
		
		local lIsJoinAtk = self.joinAtkLst[k]
		--tarFighter:ShowSpeak();
		if lIsJoinAtk== true then
			local lfirstID = tarFighter.firstID;
			local latkID = atkFighter:GetId();
			if(lfirstID ~= latkID) then
			--合击的动画
				tarFighter:ShowSpeak();
			else
				lIsJoinAtk = false;
			end;
		end;
		
		local lIsCrit = self.critLst[k];	--是否暴击
		--tarFighter:ShowCrit();
		if lIsCrit == true then
			tarFighter:ShowCrit();
		end;
		if self.atkCampType == W_BATTLE_HERO then
			--掉落物品的表现
			w_battle_atkDamage.getitem(tarFighter.Position ,self.IsSkill, lIsCrit,lIsJoinAtk,lisMoredamage); 
			
			--统计各项次数
			--w_battle_mgr.calAtkTimes(self.IsSkill,lIsCrit,lIsJoinAtk,lisMoredamage)
		end
		
        --中BUFF动画		
		if self.IsSkill == true then
			local lhasBuff = self.HasBuffLst[k]; --是否中BUFF
			if lhasBuff == true then
				local buffAni = w_battle_mgr.GetBuffAni(self.skillID);
				local cmdBuff = createCommandEffect():AddFgEffect( 1, tarFighter:GetNode(), buffAni );
				
				local batch = w_battle_mgr.GetBattleBatch(); 
				local seqBuff = batch:AddSerialSequence();
				seqBuff:AddCommand( cmdBuff );
				tarFighter:AddSkillBuff(self.skillID);
			end;
		end;
		
		--受击次数减一	
		tarFighter:BeHitDec(atkFighter:GetId()); 
		WriteCon("tarFighter BeHitDec id:"..tostring(atkFighter:GetId()));
		
		if tarFighter:GetHitTimes() == 0 then --受击次数为0时
			WriteCon("tarFighter isHurt = false targetId:"..tostring(tarFighter:GetId()));
			tarFighter.IsHurt = false;
		end;
		

	end;
	
  
	local cmd4 = createCommandPlayer():Standby( 0.01, self.atkplayerNode, "" );	
	seqAtk:AddCommand( cmd4 );
	atkFighter:standby();	

	
    --处理攻击方	
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --近战普攻
        --返回原来的位置
        local cmd5 = OnlyMoveTo(atkFighter, self.enemyPos, self.originPos, seqAtk);
		atkFighter:cmdLua( "atk_moveback",  self.id, "", seqAtk ); 
	else
		self:atkTurnEnd();
	end;


	
end

function p:atk_moveback() --回到攻击点
	self:atkTurnEnd();
end;

function p:atkTurnEnd()
	local atkFighter = self.atkFighter;
	local tarFighter = self.targetFighter;
	self.turnState = W_BATTLE_TURNEND
	
	--已行动的人结束行动了
	--w_battle_mgr.AtkDec(atkFighter:GetId());	
	--WriteCon( "atkTurnEnd atkid:"..tostring(atkFighter:GetId()));
	w_battle_mgr.checkTurnEnd();
end;


