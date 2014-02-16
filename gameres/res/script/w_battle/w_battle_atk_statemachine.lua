w_battle_atk_statemachine = {}  --�����˺�״̬��
local p = w_battle_atk_statemachine;
		  

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
	self.IsSkill = isSkill; --�Ƿ����ڼ���
    self.isAoe = isAoe;
	self.skillID = skillID;
	if self.IsSkill == true then
		self.distanceRes = tonumber( SelectCell( T_SKILL_RES, skillID, "distance" ) );--Զ�����ս���ж�;	
		self.targetType   = tonumber( SelectCell( T_SKILL, skillID, "target_type" ) );
		self.skillType = tonumber( SelectCell( T_SKILL, skillID, "skill_type" ) );
		self.singSound = SelectCell( T_SKILL_SOUND, skillID, "sing_sound" );
		self.hurtSound = SelectCell( T_SKILL_SOUND, skillID, "hurt_sound" );
		self.atkeffect = SelectCell( T_SKILL_RES, skillID, "attack_effect" );
		self.sing = SelectCell( T_SKILL_RES, skillID, "sing_effect" );
        self.hurt = SelectCell( T_SKILL_RES, skillID, "target_effect" );
		self.is_bullet = tonumber( SelectCell( T_SKILL_RES, skillID, "is_bullet" ) );
		self.bulleteffect = SelectCell( T_SKILL_RES, skillID, "bullet_effect" );
		self.HasBuffLst = HasBuffLst;
		--self.bufftype = tonumber(SelectCell( T_SKILL, skillID, "buff_type" ) );
	else
		self.distanceRes = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "distance" ) );
		self.atkSound =  SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
		if self.atkSound == nil then
			self.atkSound = "battle_paw.mp3"
		end
		self.target_sound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "target_sound" );	
		
		
		self.is_bullet = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "is_bullet" ) );
	end
	
    --�����������λ��
    self.originPos = self.atkplayerNode:GetCenterPos();
	if self.isAoe == true then
		if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս
			self.enemyPos = w_battle_mgr.GetScreenCenterPos();
		else  --Զ��,���Լ�λ����,û��Ŀ��
			self.enemyPos = nil;
		end;
		self.targetLst = targetLst;
	else
	    self.enemyPos = tarFighter:GetFrontPos(self.atkplayerNode);
		self.targetLst = {}
		self.targetLst[1] = tarFighter;
	end
	self.atkFighter:HideBuffNode();
    --����Ŀ���λ��
	if self.atkCampType == W_BATTLE_ENEMY then --�������ǹ���,�ȳ����ӳ�
		self:startDelay();
	else
		self:atk_startsing();
	end
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

--����
function p:atk_startsing()
	if self.IsSkill == true then
		local batch = w_battle_mgr.GetBattleBatch(); 
		local seqStar = batch:AddSerialSequence();
		local seqAtk = batch:AddSerialSequence();
--		self.seqTarget = batch:AddSerialSequence(); 
		if self.singSound ~= nil then
			local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( self.singSound );
			seqStar:AddCommand( cmdSingMusic );
		end;
    
	    local cmd1 = createCommandEffect():AddFgEffect( 0.5, self.atkFighter:GetNode(), self.sing );
		seqStar:AddCommand( cmd1 );
		
		if self.skillType == 1 then  --�˺���
			local cmdAtk = self.atkFighter:cmdLua("atk_start",  self.id,"", seqAtk);
			seqAtk:SetWaitEnd( cmd1 );
		else --�ָ���,��BUFF��
			local cmdAtk = self.atkFighter:cmdLua("atk_startBuff",  self.id,"", seqAtk);
			seqAtk:SetWaitEnd( cmd1 );
		end;
	else
		self:atk_start();
    end;					
	
end;

--�ӻָ���BUFF
function p:atk_startBuff()
	local cmdBuff = nil;
	local batch = w_battle_mgr.GetBattleBatch(); 
		
	for k,v in pairs(self.targetLst) do
		tarFighter = v;
		--local pos = v:GetId();
		cmdBuff = createCommandEffect():AddFgEffect( 1, tarFighter:GetNode(), self.hurt );
		local seqTemp = batch:AddSerialSequence();
		seqTemp:AddCommand( cmdBuff );		
		
		if self.skillType == 2 then --��Ѫ��
			local ldamage = (self.damageLst)[k];
			tarFighter:AddShowLife(ldamage); --��Ѫ����,����ʾ��Ѫ������				
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

--��ʼ,��ս�����ƶ�
function p:atk_start()
	local atkFighter = self.atkFighter;
	local tarFighter = self.targetFighter;
	local batch = w_battle_mgr.GetBattleBatch(); 
	local seqStar = batch:AddSerialSequence();
	--local seqAtk = batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence(); 
		
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
		--�򹥻�Ŀ���ƶ�
		local cmdMove = nil;
		local fX = GetWinSize().w / 2.0;
		local fY = GetWinSize().h / 2.0;
		--self.enemyPos = CCPointMake(fX,fY);
		
		--WriteCon(string.format("X:%d,Y:%d",fX,fY));
		--if w_battle_mgr.platform == W_PLATFORM_WIN32 then
			cmdMove = JumpMoveTo(atkFighter, self.originPos, self.enemyPos, seqStar);		
		--else
			--cmdMove = OnlyMoveTo(atkFighter, self.originPos, self.enemyPos, seqStar);
	--	end
		
		if w_battle_mgr.IsGuid == false then  --����ս��
			local cmdAtk = atkFighter:cmdLua("atk_startAtk",  self.id,"", seqTarget);
			seqTarget:SetWaitEnd( cmdMove );
		else  --����ս��
			if (w_battle_mgr.step == 3) and (w_battle_mgr.substep == 3) then
				local cmdAtk = atkFighter:cmdLua("atk_guidstep3_3",  self.id,"", seqTarget);
				seqTarget:SetWaitEnd( cmdMove );
			else
				local cmdAtk = atkFighter:cmdLua("atk_startAtk",  self.id,"", seqTarget);
				seqTarget:SetWaitEnd( cmdMove );
			end
		end;
	elseif self.distanceRes == W_BATTLE_DISTANCE_Archer then  --Զ�̹���
		self:atk_startAtk();
	end;
end

--��ս: ������ͬʱ�ܻ�
--Զ���е���: �����������ܻ�
--Զ���޵�:�ܻ�
--���弼��ͬ��
--Ⱥ�弼��,���������,�ܻ�
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
		--��ΪĿ��δ�����Ķ��м���
		tarFighter:BeTarTimesDec(atkFighter:GetId());
		
		--������������
		tarFighter:BeHitAdd(atkFighter:GetId());  
		if tarFighter.IsHurt == false then --δ�ܻ�
			--�ܻ�
			local  ltargetMachine = w_battle_machinemgr.getTarStateMachine(self.tarCampType, tarFighter:GetId());
			--if ltargetMachine:IsEnd() == true then --���ڴ���״̬
				WriteCon( "atkFighter atkid="..tostring(atkFighter:GetId()).." target inhurt tarid="..tostring(tarFighter:GetId()) );
				ltargetMachine:setInHurt(self.atkFighter);	
			--end;
		end;
	end

	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
		--�������˶���
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, self.atkplayerNode, "" );
		seqAtk:AddCommand( cmdAtk );	
	
		local cmd11 = nil;
		if self.IsSkill == true then	--��ս���ܹ���
			if self.atkeffect ~= "" then
				local lPlayNode = atkFighter:GetAtkImageNode(self.atkplayerNode)
				cmd11 = createCommandEffect():AddFgEffect( 1, lPlayNode, self.atkeffect );
				local batch = w_battle_mgr.GetBattleBatch(); 
				local seqTemp = batch:AddSerialSequence();
				seqTemp:AddCommand( cmd11 );
			end;					

			--����,��Ҫ�����ܻ���Ч
			if self.hurt ~= nil then
				for k,v in pairs(self.targetLst) do
					local cmdhurt = createCommandEffect():AddFgEffect( 1, v:GetNode(), self.hurt );			
					local seqHurt = batch:AddSerialSequence(); 
					seqHurt:AddCommand(cmdhurt);
					if self.isAoe == true then
						seqHurt:SetWaitEnd(cmd11)
					end;
				end
			end;
		end;	
		
		if self.IsSkill == false then
			local seqMusic = batch:AddSerialSequence();
			if self.atkSound ~= nil then
				local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( self.atkplayerNode, true );
				seqMusic:AddCommand( cmdAtkBegin );

				local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( self.atkSound  );
				seqMusic:AddCommand( cmdAtkMusic );
			end		
		end;
		--�������������ܻ�����
		self.atkFighter:cmdLua( "atk_end",  self.id, "", seqAtkEnd ); 
		seqAtkEnd:SetWaitEnd(cmdAtk);
    else

		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, self.atkplayerNode, "" );
		seqStar:AddCommand( cmdAtk ); --��������
		
		if self.IsSkill == true then
			if self.atkeffect ~= "" then
				local lPlayNode = atkFighter:GetAtkImageNode(self.atkplayerNode)
				cmd11 = createCommandEffect():AddFgEffect( 1, lPlayNode, self.atkeffect );
				local batch = w_battle_mgr.GetBattleBatch(); 
				local seqTemp = batch:AddSerialSequence();
				seqTemp:AddCommand( cmd11 );
			end;		
		end;
		
		if self.is_bullet == W_BATTLE_BULLET_1 then --�е���
			
			local bulletAni = "n_bullet."..tostring( atkFighter.cardId );
			if self.IsSkill == true then
				bulletAni = self.bulleteffect;
			end;
			
			local deg;
			
			local lbulletnode = nil; 
			local ltargetPos;
			if self.isAoe == true then
				lbulletnode = w_battle_mgr.bulletCenterNode()
				ltargetPos = lbulletnode:GetCenterPos();
				local halfWidthSum = lbulletnode:GetCurAnimRealSize().w/2
				if atkFighter.camp == E_CARD_CAMP_HERO then
					ltargetPos.x = ltargetPos.x + halfWidthSum;
				else
					ltargetPos.x = ltargetPos.x - halfWidthSum;
				end
			else
				lbulletnode	= tarFighter:GetNode()
				ltargetPos = tarFighter:GetNode():GetCenterPos();
			end;
			
			--if self.iaAoe == true then
				
			deg = atkFighter:GetAngleByPos( ltargetPos );
			--else
			--	deg = atkFighter:GetAngleByFighter( tarFighter );
			--end;
			local bullet = w_bullet:new();
			bullet:AddToBattleLayer();
			bullet:SetEffectAni( bulletAni );
						
			bullet:GetNode():SetRotationDeg( deg );
			local bullet1 = bullet:cmdSetVisible( true, seqAtk );
			
			bulletend = bullet:cmdShootPos( atkFighter, ltargetPos, seqAtk, false );
			local bullet3 = bullet:cmdSetVisible( false, seqAtk );
			--seqBullet:SetWaitEnd( cmdAtk );
			--[[if self.IsSkill == true then  --�������ܻ���Ч
				local cmd11 = createCommandEffect():AddFgEffect( 1, tarFighter:GetNode(), self.hurt );			
				seqAtk:AddCommand(cmd11);
			end;
			]]--
			--local seqMusic = batch:AddSerialSequence();
			if self.IsSkill == false then
				if self.atkSound ~= nil then
					local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( self.atkplayerNode, true );
					seqAtk:AddCommand( cmdAtkBegin );

					local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( self.atkSound  );
					seqAtk:AddCommand( cmdAtkMusic );
				end		
			else --���ܹ���
				if self.hurt ~= "" then
					for k,v in pairs(self.targetLst) do
						local cmdhurt = createCommandEffect():AddFgEffect( 1, v:GetNode(), self.hurt );
						local batch = w_battle_mgr.GetBattleBatch(); 
						local seqTemp = batch:AddSerialSequence();
						seqTemp:AddCommand( cmdhurt );
						seqTemp:SetWaitEnd(bulletend);
					end;
				end;	
			end;
			atkFighter:cmdLua("atk_end",        self.id, "", seqTarget);
			seqTarget:SetWaitEnd( bulletend );
		else  --û����
			--��������
			if self.IsSkill == false then
				local seqMusic = batch:AddSerialSequence();
				if self.atkSound ~= nil then
					local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( self.atkplayerNode, true );
					seqMusic:AddCommand( cmdAtkBegin );

					local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( self.atkSound  );
					seqMusic:AddCommand( cmdAtkMusic );
				end							
			end;
			
			if self.hurt ~= "" then
				if self.IsSkill == true then	--�����ܻ���Ч
					for k,v in pairs(self.targetLst) do
						tarFighter = v;
						local cmd11 = createCommandEffect():AddFgEffect( 1, tarFighter:GetNode(), self.hurt );
						local batch = w_battle_mgr.GetBattleBatch(); 
						local seqTemp = batch:AddSerialSequence();
						seqTemp:AddCommand( cmd11 );
					end;			
				end;
			end;			

			
			self.atkFighter:cmdLua( "atk_end",  self.id, "", seqTarget ); 
			seqTarget:SetWaitEnd( cmdAtk );
		end
	end;

end



function p:atk_guidstep3_3()
	rookie_mask.ShowUI(p.step,p.substep + 1)
end;

function p:atk_end()
	local atkFighter = self.atkFighter;
	local tarFighter = nil;
	local batch = w_battle_mgr.GetBattleBatch(); 
--	local seqStar = batch:AddSerialSequence();
	local seqAtk = batch:AddSerialSequence();
	local seqMusic = batch:AddSerialSequence();
--	local seqTarget = batch:AddSerialSequence(); 

	--��������
	if self.IsSkill == true then
		if self.hurtSound ~= nil then
			local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( self.atkplayerNode, true );
			seqMusic:AddCommand( cmdAtkBegin );

			local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( self.hurtSound  );
			seqMusic:AddCommand( cmdAtkMusic );
		end
	end;
		
	--for pos=1,#self.targetLst do
	--	tarFighter = (self.targetLst)[pos];
	for k,v in pairs(self.targetLst) do
		tarFighter = v;
		--�ܻ����Ѫ,���õȵ�Ѫ�������
		local ldamage = (self.damageLst)[k];
		if ldamage == nil then
			WriteCon(" position ="..tostring(tarFighter.Position).." k="..tostring(k));
		end;
		local lisMoredamage = false;  --������ɱ
		if tarFighter.Hp <= 0 then
			lisMoredamage = true;
		end;
		tarFighter:SubShowLife(ldamage); --��Ѫ����,����ʾ��Ѫ������	
		
		local lIsJoinAtk = self.joinAtkLst[k]
		--tarFighter:ShowSpeak();
		if lIsJoinAtk== true then
			local lfirstID = tarFighter.firstID;
			local latkID = atkFighter:GetId();
			if(lfirstID ~= latkID) then
			--�ϻ��Ķ���
				tarFighter:ShowSpeak();
			else
				lIsJoinAtk = false;
			end;
		end;
		
		local lIsCrit = self.critLst[k];	--�Ƿ񱩻�
		--tarFighter:ShowCrit();
		if lIsCrit == true then
			tarFighter:ShowCrit();
		end;
		if self.atkCampType == W_BATTLE_HERO then
			--������Ʒ�ı���
			w_battle_atkDamage.getitem(tarFighter.Position ,self.IsSkill, lIsCrit,lIsJoinAtk,lisMoredamage); 
			
			--ͳ�Ƹ������
			--w_battle_mgr.calAtkTimes(self.IsSkill,lIsCrit,lIsJoinAtk,lisMoredamage)
		end
		
        --��BUFF����		
		if self.IsSkill == true then
			local lhasBuff = self.HasBuffLst[k]; --�Ƿ���BUFF
			if lhasBuff == true then --��BUFF��Ч��ʱû��
				--[[
				local buffAni = w_battle_mgr.GetBuffAni(self.skillID);
				local cmdBuff = createCommandEffect():AddFgEffect( 1, tarFighter:GetNode(), buffAni );
				
				local batch = w_battle_mgr.GetBattleBatch(); 
				local seqBuff = batch:AddSerialSequence();
				seqBuff:AddCommand( cmdBuff );
				]]--
				tarFighter:AddSkillBuff(self.skillID);
			end;
		end;
		
		--�ܻ�������һ	
		tarFighter:BeHitDec(atkFighter:GetId()); 
		WriteCon("tarFighter BeHitDec id:"..tostring(atkFighter:GetId()));
		
		if tarFighter:GetHitTimes() == 0 then --�ܻ�����Ϊ0ʱ
			WriteCon("tarFighter isHurt = false targetId:"..tostring(tarFighter:GetId()));
			tarFighter.IsHurt = false;
		end;
		

	end;
	
  
	local cmd4 = createCommandPlayer():Standby( 0.01, self.atkplayerNode, "" );	
	seqAtk:AddCommand( cmd4 );
	atkFighter:standby();	

	
    --��������	
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
        --����ԭ����λ��
		local cmd5 = nil;
		cmd5 = JumpMoveTo(atkFighter, self.enemyPos, self.originPos, seqAtk);	

		atkFighter:cmdLua( "atk_moveback",  self.id, "", seqAtk ); 
	else
		self:atkTurnEnd();
	end;


	
end

function p:atk_moveback() --�ص�������
	self:atkTurnEnd();
end;

function p:atkTurnEnd()
	local atkFighter = self.atkFighter;
	local tarFighter = self.targetFighter;
	self.turnState = W_BATTLE_TURNEND
	self.atkFighter:ShowBuffNode();
	--���ж����˽����ж���
	--w_battle_mgr.AtkDec(atkFighter:GetId());	
	--WriteCon( "atkTurnEnd atkid:"..tostring(atkFighter:GetId()));
	w_battle_mgr.checkTurnEnd();
end;


