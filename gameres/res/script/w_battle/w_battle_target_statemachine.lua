w_battle_target_statemachine = {}  --�ܻ���״̬��, ֻ�����ܻ��ߵ��ܻ�������֮����վ����������
local p = w_battle_target_statemachine;
		  

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	return o;
end

--���캯��
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
	self.IsTurnEnd = false;
	--�ѳ�ΪĿ��,δ����
	--targerFighter:BeTarTimesDec(atkFighter:GetId()); 
	
    	
	
    if (targerFighter.IsHurt == false) then --�����ܻ���ʶ
		WriteCon( "targetTurn Start id="..tostring(targerFighter:GetId()));
		targerFighter.IsHurt = true;  --��ʶ�ܻ���
		local batch = w_battle_mgr.GetBattleBatch();
		self.seqTarget = batch:AddSerialSequence();
		self.seqHurt = batch:AddSerialSequence();
		
		--�ܻ���������һ��
		local cmdHurt = createCommandPlayer():Hurt( 0, targerFighter:GetNode(), "" );
		self.seqTarget:AddCommand( cmdHurt );
		
		local cmdHurt = battle_show.AddActionEffect_ToSequence( 0, targerFighter:GetPlayerNode(), "lancer.ishurt", self.seqTarget);
		
		local cmdIshurt = atkFighter:cmdLua( "tar_hurt",   self.id, tostring(W_BATTLE_ENEMY), self.seqHurt );
		self.seqHurt:SetWaitEnd(cmdHurt); 
	end;

end;

function p:tar_hurt() 
	local atkFighter = self.atkFighter;
	local targerFighter = self.tarFighter;
	
	if targerFighter.IsHurt == true then
		local cmdHurt = battle_show.AddActionEffect_ToSequence( 0, targerFighter:GetPlayerNode(), "lancer.ishurt", self.seqTarget);
		
		local batch = w_battle_mgr.GetBattleBatch();
		self.seqHurt = batch:AddSerialSequence();
		
		local cmdIshurt = atkFighter:cmdLua( "tar_hurt",   self.id, tostring(W_BATTLE_ENEMY), self.seqHurt );
		self.seqHurt:SetWaitEnd(cmdHurt); 
	else
		self:tar_hurtEnd();
	end
end;

--����
function p:reward()
	local targerFighter = self.tarFighter;	
	local tmpList = { {E_DROP_MONEY, 1, targerFighter.Position},
					  {E_DROP_BLUESOUL , 2, targerFighter.Position},
					  {E_DROP_HPBALL , 3, targerFighter.Position},
					  {E_DROP_SPBALL , 4, targerFighter.Position}
					}
	w_battle_pve.MonsterDrop(tmpList)
	
end;

--ֻ�����˽���ʱ�ŵ���
function p:tar_hurtEnd()
	local targerFighter = self.tarFighter;	
	
	if (targerFighter.Hp > 0) or (targerFighter:GetTargerTimes() > 0 ) then  --������,���߳�ΪĿ��δ������������Ϊ0,��������վ��	
		targerFighter:standby();
		self:targerTurnEnd();  --�ܻ������̽���
	elseif targerFighter.Hp <= 0 then
		if self.canRevive == true then  --�ɸ���
			targerFighter.isDead = false;
			targerFighter.canRevive = false;
			
			targerFighter:standby();

			local cmdf = createCommandEffect():AddActionEffect( 0.01, targerFighter:GetNode(), "lancer_cmb.revive" );
			self.seqTarget:AddCommand( cmdf );
			local cmdC = createCommandEffect():AddActionEffect( 0.01, targerFighter.m_kShadow, "lancer_cmb.revive" );
			self.seqTarget:AddCommand( cmdC );		
			
			local batch = w_battle_mgr.GetBattleBatch(); 
			local seqDie = batch:AddSerialSequence();
			local cmdRevive = targerFighter:cmdLua("tar_ReviveEnd",  self.id, tostring(W_BATTLE_ENEMY), seqDie);
			self.seqRevive:SetWaitEnd( cmdC ); 
		else	--������
			--�ж��Ƿ�Ҫ�л�����Ŀ��
			targerFighter:Die();  --��ʶ����
			if(self.camp == W_BATTLE_ENEMY) then  --�ܻ����ǹ���
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
			else  --�ܻ��������,�ڹ���ʱ����ѡ����ȫ��Ŀ�����账��
				
			end;
			
			--self:reward(); --��ý���
			
			local cmdf = createCommandEffect():AddActionEffect( 0.01, targerFighter.m_kShadow, "lancer_cmb.die" );
			self.seqTarget:AddCommand( cmdf );
			local cmdC = createCommandEffect():AddActionEffect( 0.01, targerFighter:GetNode(), "lancer_cmb.die" );
			self.seqTarget:AddCommand( cmdC );				
			--local batch = battle_show.GetNewBatch(); 
			--local seqDie	= batch:AddParallelSequence();
			local batch = w_battle_mgr.GetBattleBatch(); 
			local seqDie = batch:AddSerialSequence();
			local cmdDieEnd = targerFighter:cmdLua("tar_dieEnd",  self.id, tostring(W_BATTLE_ENEMY), seqDie);
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
	self:targerTurnEnd();
end;

--�Լ��ĻغϽ���
function p:targerTurnEnd()
	self.IsTurnEnd = true;
	local tarFighter = self.tarFighter;	
	WriteCon( "targetTurnEnd id="..tostring(tarFighter:GetId()));
	w_battle_mgr.checkTurnEnd(); --����Ƿ�غϽ�������

end;

function p:IsEnd()
	return self.IsTurnEnd;
end;
