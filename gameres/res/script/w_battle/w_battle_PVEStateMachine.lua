w_battle_PVEAtkState = {}
local p = w_battle_PVEAtkState;

--PVE��һ��ս����״̬��


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
	self.IsEnd = false;
	self.IsAtkTurnEnd = false;	
	self.IsTarTurnEnd = false;
	
end

function p:init(id,atkFighter,atkCampType,tarFighter, atkCampType,damage,isCrit,isJoinAtk)
	
	self.atkId = atkFighter:GetId();
	self.id = atkId;	
	self.targerId = tarFighter:GetId();
	self.atkCampType = atkCampType;
	self.tarCampType = tarCampType;
	
	self.damage = damage;
	self.isCrit = isCrit;
	self.isJoinAtk = isJoinAtk;
	self.atkplayerNode = atkFighter:GetPlayerNode();
	self.IsRevive = false;
	
	local batch = battle_show.GetNewBatch(); 
	self.seqAtk    = batch:AddSerialSequence();
    self.seqTarget = batch:AddSerialSequence();	
	self.seqBullet = batch:AddSerialSequence();	
	
	p:start();
end;

function p:start()
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();

			
	if self.atkType == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
	
		
		local distance = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "distance" ) );
        local playerNode = self.atkplayerNode;
    
		--�����������λ��
		local originPos = playerNode:GetCenterPos();

		--�ܻ�Ŀ���λ��
		local enemyPos = targetFighter:GetFrontPos(playerNode);


		--��������
		local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
		self.seqAtk:AddCommand( cmdAtkBegin );
			
		local cmdSetPic = atkFighter:cmdLua( "SetFighterPic",  0, "", seqAtk );
		
       
		--�򹥻�Ŀ���ƶ�
		local cmd2 = JumpMoveTo(atkFighter, originPos, enemyPos, self.seqAtk, false);
		
		
		--�л�������״̬
		atkFighter:cmdLua( "atk_startAtk",  0, self.id, self.seqAtk );

		tarFighter:cmdLua("tar_hurt",       0, self.id, self.seqTarget);
		self.seqTarget:SetWaitEnd( cmd2 );
		
		
	elseif self.atkType == W_BATTLE_DISTANCE_Archer then  --Զ�̹���
	    local isBullet = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "is_bullet" ) );
		local bulletAni;
		if isBullet == N_BATTLE_BULLET_1 then --�е���
			local cmdAtk = createCommandPlayer():Atk( 0.3, playerNode, "" );
			seqAtk:AddCommand( cmdAtk ); --��������
			
			local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
			--�ܻ�����
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
			
			--�л�������״̬
			atkFighter:cmdLua( "atk_startAtk",  0, self.id, self.seqAtk );

			tarFighter:cmdLua("tar_hurt",       0, self.id, self.seqTarget);
			self.seqTarget:SetWaitEnd( cmdAtk );
			
		else  --û����
			local cmdAtk = createCommandPlayer():Atk( 0.3, playerNode, "" );
			seqAtk:AddCommand( cmdAtk ); --��������
			
			local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
			--�ܻ�����
			if atkSound ~= nil then
				local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
				self.seqAtk:AddCommand( cmdAtkMusic );
			end
			
			atkFighter:cmdLua( "atk_startAtk",  0, self.id, self.seqAtk );
			
			tarFighter:cmdLua("tar_hurt", 0, self.id, self.seqTarget);
			self.seqTarget:SetWaitEnd( cmdAtk );
		end

	end
	
end


function p:atk_startAtk()  --����
	local atkFighter = self:getAtkFighter();

	if self.atkType == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
		--�������˶���
		local cmdAtk = createCommandPlayer():Atk( 0.3, playerNode, "" );
		self.seqAtk:AddCommand( cmdAtk );	
		

		local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
		--�ܻ�����
		if atkSound ~= nil then
			local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
			self.seqAtk:AddCommand( cmdAtkMusic );
		end
		
	end;
	
	--�������������ܻ�����
	atkFighter:cmdLua( "atk_end",  0, self.id, self.seqAtk ); 
	
end

function p:atk_end()
	local atkFighter = self:getAtkFighter();
	local tarFighter = self:getTarFighter();


    --�ܻ����Ѫ,���õȵ�Ѫ�������
	local cmd11 = tarFighter:cmdLua( "fighter_damage",  0, self.id, seqTarget );	

    --��������	
	if self.atkType == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
		--����
		local cmdBackRset = createCommandEffect():AddActionEffect( 0, atkFighter:GetPlayerNode(), "lancer.target_hurt_back_reset" );
		self.seqAtk:AddCommand( cmdBackRset ); 
		
		--local cmdClearPic = atkFighter:cmdLua( "ClearAllFighterPic",  0, self.id, seqAtk );
	end;

	--��ʶ�������Ĺ��������
	atkFighter:cmdLua( "atk_standby",  atkFighter:GetId(), self.id, self.seqAtk ); 


	--�ܻ�������
	--�ܻ�������һ	
	targetFighter:BeHitDec(atkFighter:GetId()); 
	
	self:tar_hurtEnd();


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

function p:tar_hurt()
	local batch = battle_show.GetNewBatch(); 
    local seqTarget = batch:AddSerialSequence();	
    local seqHurtEnd = batch:AddSerialSequence();   

	local atkFighter = self:getAtkFighter();
	local targetFighter = self:getTarFighter();


    if targerFighter.IsHurt = false then
		targerFighter.IsHurt = true;  --��ʶ�ܻ���
		--�ܻ���������һ��
		local cmdHurt = createCommandPlayer():Hurt( 0, targetFighter:GetNode(), "" );
		seqTarget:AddCommand( cmdHurd );

	    --�ܻ��������޲�
		local cmdHurtAll = createCommandPlayer():Hurt( 0, targetFighter:GetNode(), "" );
		seqTarget:AddCommand( cmdHurtAll );

        --�ܻ����
		--tarFighter:cmdLua("tar_hurtEnd", 0, self.id, seqHurtEnd);
		--seqHurtEnd:SetWaitEnd( cmdHurt );
	end;
	
end;


function p:tar_hurtEnd()
	local atkFighter = self:getAtkFighter();
	local targetFighter = self:getTarFighter();	
	
	if targetFighter.beHitTimes == 0 then --�ܻ�����Ϊ0ʱ
		targerFighter.IsHurt = false;
	    if targetFighter.showlife > 0 then  --������,��������վ��	
			targetFighter:standby();
			self:targerTurnEnd();  --�ܻ������̽���
		elseif targetFighter.showlife <= 0 then
            if self.CanRevive == true then  --�ɻֻ�
				local fighter = self:getTarFighter();
				fighter.isDead = false;
				fighter.canRevive = false;
				
				fighter:standby();

				local cmdf = createCommandEffect():AddActionEffect( 0.01, fighter:GetNode(), "lancer_cmb.revive" );
				self.seqTarget:AddCommand( cmdf );
				local cmdC = createCommandEffect():AddActionEffect( 0.01, fighter.m_kShadow, "lancer_cmb.revive" );
				self.seqTarget:AddCommand( cmdC );		
								
				local cmdRevive =targerFighter:cmdLua("tar_ReviveEnd", 0, self.id, seq);
				self.seqTarget:SetWaitEnd( cmdC ); 
			else	--������
				--�ж��Ƿ�Ҫ�л�����Ŀ��
				if p.LockEnemy == true then
					if(p.PVEEnemyID == lFighterID) then  --��ǰ�����Ĺ����Ѿ�����
						if p.enemyCamp:GetActiveFighterCount() > 0 then --��������
							p.PVEEnemyID = p.enemyCamp:GetActiveFighterID(lFighterID); --����ID��Ļ�Ĺ���Ŀ��
							--p.LockEnemy = false  --ֻҪѡ������һֱ��������������
						else  --û�л��ŵĹ����ѡ
						   p.isCanSelFighter = false;
						end
					end;
				else
					--�����������Ĺ���,��ѡ���ҷ���Աʱ������˹����ѡ��,���账��
				end;			
			
			
				local cmdf = createCommandEffect():AddActionEffect( 0.01, targetFighter.m_kShadow, "lancer_cmb.die" );
				self.seqTarget:AddCommand( cmdf );
				local cmdC = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer_cmb.die" );
				self.seqTarget:AddCommand( cmdC );				
				
				local cmdDieEnd =targerFighter:cmdLua("tar_dieEnd", 0, self.id, seq);
				seqDieEnd:SetWaitEnd( cmdDieEnd ); 
			end;
		end;
	else --�����������˴��,���ι�����������ܻ����̾ͽ�����
		self:targerTurnEnd();  --�ܻ������̽���
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
	end
end;


--[[
function p:atk_hurt()    	
	local batch = battle_show.GetNewBatch(); 
	local seqAtk    = batch:AddSerialSequence();
    local seqTarget = batch:AddSerialSequence();
		
	local atkFighter = self:getAtkFighter();	
	
	--show������ֵ����,ƮѪ
	atkFighter:atk_damage(self.damage);
    	

	
	--cmdAtk:SetDelay(0.2f); --���ù����ӳ�
     local playerNode = self.atkplayerNode;
    
	
    --	
	
    --���վ������
    local cmd4 = createCommandPlayer():Standby( 0.01, playerNode, "" );
    seqAtk:AddCommand( cmd4 );
    

    --����ԭ����λ��
    local cmd5 = JumpMoveTo(atkFighter, enemyPos, originPos, seqAtk, false);

    

    
    local cmdAtkEnd = createCommandInstant_Misc():SetZOrderAtTop( atkFighter:GetNode(), false );
    seqAtk:AddCommand( cmdAtkEnd );
    
	--��������������, ����˳�д�����1,��Ϊ0ʱ,�ж��Ƿ����վ����������.
	--��cmd����ִ��ѹ��seqAtk˳��ִ��
	atkFighter:cmdLua( "atk_hurt",  targetFighter:GetId(), "", seqAtk );

end
]]--
function p:getFighter(pId,pCampType)
	local lFighter = nil;
	if pCampType == W_BATTLE_HERO then
		lFigheter = w_battle_mgr.heroCamp:FindFighter(pId);
	else
		lFigheter = w_battle_mgr.enemyCamp:FindFighter(pId);
	end
	
end;

function p:getAtkFighter()
	return self:getFighter(self.atkId, atkCampType);
end;

function p:getTarFighter()
	return self:getFighter(self.targerId, tarCampType);
end;

