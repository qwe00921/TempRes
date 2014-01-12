w_battle_aoemachine = w_battle_PVEStateMachine:new()  --AOE�˺�״̬��
local p = w_battle_aoemachine;
		  
--PVE��һ��ս����״̬��
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
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�, �嵽���м�
        --���������ּ�����
    	local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( self.singSound );
        self.seqStar:AddCommand( cmdSingMusic );
    
	    local cmd1 = createCommandEffect():AddFgEffect( 0.01, hero:GetNode(), sing );
		self.seqStar:AddCommand( cmd1 );
		
		--��������
		--local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
		--self.seqStar:AddCommand( cmdAtkBegin );

		--�򹥻�Ŀ���ƶ�
		local cmdMove = OnlyMoveTo(atkFighter, self.originPos, self.enemyPos, self.seqAtk);
		self.seqAtk:SetWaitEnd( cmd1 );
		
		local cmdHurt = tarFighter:cmdLua("tar_hurtBegin",        self.id,"", self.seqTarget);
		self.seqTarget:SetWaitEnd( cmdMove );
		
	elseif self.distanceRes == W_BATTLE_DISTANCE_Archer then  --Զ�̹���,ȫ�����޵���,����ԭ�طż���
    	local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( self.singSound );
        self.seqStar:AddCommand( cmdSingMusic );
    
	    local cmd1 = createCommandEffect():AddFgEffect( 0.01, hero:GetNode(), sing );
		self.seqStar:AddCommand( cmd1 );		

		self.targercamp:BeTarTimesDec(atkFighter:GetId());		
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, playerNode, "" );
		self.seqAtk:AddCommand( cmdAtk ); --��������
		self.seqAtk:SetWaitEnd( cmd1 ); --��������

		local atkSound = self.atkSound;
		--�ܻ�����
		if atkSound ~= nil then
			local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
			self.seqAtk:AddCommand( cmdAtkMusic );
		end;	
		tarFighter:cmdLua("tar_hurtBegin",  self.id, "", self.seqTarget);
		self.seqTarget:SetWaitEnd( cmdAtk );
	end
	
end


function p:atk_startAtk()  --����
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();
	
	--������������
	tarFighter:BeHitAdd(atkFighter:GetId());  
	
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
		--�������˶���
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, self.atkplayerNode, "" );
		self.seqAtk:AddCommand( cmdAtk );	

		local atkSound = self.atkSound;
		--�ܻ�����
		if atkSound ~= nil then
			local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
			self.seqAtk:AddCommand( cmdAtkMusic );
		end
		
	end;
	
	--�������������ܻ�����
	atkFighter:cmdLua( "atk_end",  self.id, "", self.seqAtk ); 
	
end

function p:atk_end()
	local atkFighter = self:getAtkFighter();
	--local tarFighter = self:getTarFighter();


    --�ܻ����Ѫ,���õȵ�Ѫ�������
	tarFighter:SubShowLife(self.damage); --��Ѫ����,����ʾ��Ѫ������
	local cmd4 = createCommandPlayer():Standby( 0.01, self.atkplayerNode, "" );
	self.seqAtk:AddCommand( cmd4 );
	
    --��������	
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
        --����ԭ����λ��
        local cmd5 = OnlyMoveTo(atkFighter, self.enemyPos, self.originPos, self.seqAtk);
	end;

	--��ʶ�������Ĺ��������
	atkFighter:cmdLua( "atk_standby",  self.id, "", self.seqAtk ); 

	--�ܻ�������
	--�ܻ�������һ	
	tarFighter:BeHitDec(atkFighter:GetId()); 
	
	if tarFighter:GetHitTimes() == 0 then --�ܻ�����Ϊ0ʱ
		tarFighter.IsHurt = false;
		WriteCon( "atkid:"..tostring(atkFighter:GetId()).." atk_end GetHitTimes == 0 ");
		if tarFighter.firstID ~= atkFighter:GetId() then 
			self:targerTurnEnd();  --�ܻ������̽���,��ʱ���ܻ��� tar_hurt״̬������
		end
	else
		WriteCon( "atkid:"..tostring(atkFighter:GetId()).." atk_end GetHitTimes > 0  ");
		self:targerTurnEnd();  --�ܻ������̽���,��ʱ���ܻ��� tar_hurt״̬������
	end;

end

function p:fighter_damage()
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();
	
end;


function p:atk_standby()
   	local atkFighter = self:getTarFighter();
	atkFighter:standby();
    --atkFighrer.turnRound = false;	--��ʶ��������;
	self:atkTurnEnd();
	
end;



function p:tar_hurtBegin()


	local atkFighter = self:getAtkFighter();
	--local targerFighter = self:getTarFighter();

    --��ΪĿ��δ�������б��һ
	self.targercamp:BeTarTimesDec(atkFighter:GetId());	
	local targerFighter = nil;
	local cmdHurt = nil;
	for k,v in pairs(self.targercamp.fighters) do
		targerFighter = v;
		if (targerFighter.IsHurt == false) then
			targerFighter.IsHurt = true;  --��ʶ�ܻ���
			--�ܻ���������һ��
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
			--�ϻ��Ķ���
				WriteCon("JoinAtk flash");
			end;
		end;	
	
	end;
    
	if cmdHurt ~= nil then --���һ���ܻ������ı�ʶ������,���е��ܻ�����,ʱ�䶼һ��
		local batch = w_battle_mgr.GetBattleBatch();
		self.seqHurt = batch:AddSerialSequence();
		local cmdIshurt = atkFighter:cmdLua( "tar_hurt",   self.id,"", self.seqHurt );
		self.seqHurt:SetWaitEnd(cmdHurt); 
    end;				
	--��������
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

--����
function p:reward()
	local targerFighter = self:getTarFighter();	
	local tmpList = { {E_DROP_MONEY, 1, targerFighter.Position},
					  {E_DROP_BLUESOUL , 2, targerFighter.Position},
					  {E_DROP_HPBALL , 3, targerFighter.Position},
					  {E_DROP_SPBALL , 4, targerFighter.Position}
					}
	w_battle_pve.MonsterDrop(tmpList)
	
end;

--ֻ�����˽���ʱ�ŵ���
function p:tar_hurtEnd()
	local atkFighter = self:getAtkFighter();
	local targerFighter = self:getTarFighter();	
	
	--if targerFighter:GetHitTimes() == 0 then --�ܻ�����Ϊ0ʱ
	--	targerFighter.IsHurt = false;
	    if (targerFighter.showlife > 0) or (targerFighter:GetTargerTimes() > 0 ) then  --������,���߳�ΪĿ��δ������������Ϊ0,��������վ��	
			targerFighter:standby();
			self:targerTurnEnd();  --�ܻ������̽���
		elseif targerFighter.showlife <= 0 then
            if self.CanRevive == true then  --�ɸ���
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
			else	--������
				--�ж��Ƿ�Ҫ�л�����Ŀ��
				targerFighter:Die();  --��ʶ����
				if w_battle_mgr.LockEnemy == true then
					if(w_battle_mgr.PVEEnemyID == targerFighter:GetId()) then  --��ǰ�����Ĺ��������ڱ������Ĺ���
						if w_battle_mgr.enemyCamp:GetNotDeadFighterCount() > 0 then --�ɻ�������
							w_battle_mgr.PVEEnemyID = w_battle_mgr.enemyCamp:GetFirstNotDeadFighterID(targerFighter:GetId()); --����ID��Ļ�Ĺ���Ŀ��
							w_battle_mgr.SetLockAction(w_battle_mgr.PVEEnemyID);
							--p.LockEnemy = false  --ֻҪѡ������һֱ��������������
						else  --û�л��ŵĹ����ѡ
						   w_battle_mgr.isCanSelFighter = false;
						end
					end;
				else
					if w_battle_mgr.enemyCamp:GetNotDeadFighterCount() == 1 then
						w_battle_mgr.PVEEnemyID = w_battle_mgr.enemyCamp:GetFirstNotDeadFighterID(targerFighter:GetId()); --����ID��Ļ�Ĺ���Ŀ��
						w_battle_mgr.SetPVETargerID(w_battle_mgr.PVEEnemyID);
					end
					--�����������Ĺ���,��ѡ���ҷ���Աʱ������˹����ѡ��,���账��
				end;			
				self:reward(); --��ý���
				
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
	--else --�����������˴��,���ι�����������ܻ����̾ͽ�����
	--	self:targerTurnEnd();  --�ܻ������̽���
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
	
	if (self.IsAtkTurnEnd == true) and (self.IsTarTurnEnd == true) then --�ܻ� �ʹ������
		local atkFighter = self:getAtkFighter();	
		WriteCon( "atkid:"..tostring(atkFighter:GetId()).." PVEStateMachine is End ");
		
		self.IsEnd = true;
		w_battle_mgr.AtkDec(atkFighter:GetId());	

		w_battle_PVEStaMachMgr:delStateMachine(self.id);
		local atkFighter = self:getAtkFighter();
		atkFighter.IsTurnEnd = true;
		
		if self.atkCampType == W_BATTLE_HERO then	
			if w_battle_mgr.enemyCamp:isAllDead() == false then --����ʬ�����
				w_battle_mgr.CheckHeroTurnIsEnd();	
			else  --û��ʬ����
				--w_battle_mgr.FightWin();
				if w_battle_mgr.CheckAtkListIsNull() == true then --�������ж�����,�Ѿ��ж�������
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

