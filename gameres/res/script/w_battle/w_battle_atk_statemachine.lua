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



function p:init(id,atkFighter,atkCampType,tarFighter, tarCampType,damageLst,critLst,joinAtkLst,isSkill,skillID,isAoe)
	self.atkId = atkFighter:GetId();
	self.id = atkFighter:GetId();	
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
		self.targetType   = tonumber( SelectCell( T_SKILL, skillID, "Target_type" ) );
		self.skillType = tonumber( SelectCell( T_SKILL, skillID, "Skill_type" ) );
		self.singSound = SelectCell( T_SKILL_SOUND, skillID, "sing_sound" );
		self.hurtSound = SelectCell( T_SKILL_SOUND, skillID, "hurt_sound" );
		self.sing = SelectCell( T_SKILL_RES, skillID, "sing_effect" );
        self.hurt = SelectCell( T_SKILL_RES, skillID, "hurt_effect" );
		self.is_bullet = tonumber( SelectCell( T_SKILL_RES, skillID, "is_bullet" ) );
		--self.bufftype = tonumber(SelectCell( T_SKILL, skillID, "buff_type" ) );
	else
		self.distanceRes = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "distance" ) );
		self.atkSound =  SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
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
		if w_battle_mgr.atkCampType == W_BATTLE_ENEMY then
			if self.skillType == 1 then --������
				self.targetLst = w_battle_mgr.heroCamp.fighters;
			else --�ָ�BUFF��
				self.targetLst = w_battle_mgr.enemyCamp.fighters;
			end;
		else
			if self.skillType == 1 then --������
				self.targetLst = w_battle_mgr.enemyCamp.fighters;
			else  --�ָ���
				self.targetLst = w_battle_mgr.heroCamp.fighters;
			end;
		end;
	else
	    self.enemyPos = tarFighter:GetFrontPos(self.atkplayerNode);	
		self.targetLst[1] = tarFighter;
	end
    --����Ŀ���λ��


	
	local batch = w_battle_mgr.GetBattleBatch(); 
	self.seqStar = batch:AddSerialSequence();
	self.seqAtk = batch:AddSerialSequence();
	self.seqTarget = batch:AddSerialSequence(); 
	
	self:startsing();
	--self:start();

end;

--����
function p:startsing()
	if self.IsSkill == true then
    	local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( self.singSound );
        self.seqStar:AddCommand( cmdSingMusic );
    
	    local cmd1 = createCommandEffect():AddFgEffect( 0.5, self.atkFighter:GetNode(), self.sing );
		self.seqStar:AddCommand( cmd1 );
		
		if self.skillType == 1 then  --�˺���
			local cmdAtk = self.atkFighter:cmdLua("atk_start",  self.id,"", self.seqAtk);
			self.seqAtk:SetWaitEnd( cmd1 );
		else --�ָ���,��BUFF��
			local cmdAtk = self.atkFighter:cmdLua("atk_startBuff",  self.id,"", self.seqAtk);
			self.seqAtk:SetWaitEnd( cmd1 );
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

	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
		--�򹥻�Ŀ���ƶ�
		local cmdMove = OnlyMoveTo(atkFighter, self.originPos, self.enemyPos, self.seqStar);
		
		local cmdAtk = atkFighter:cmdLua("atk_startAtk",  self.id,"", self.seqTarget);
		self.seqTarget:SetWaitEnd( cmdMove );
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
	
	for k,v in pairs(self.targetLst) do
		tarFighter = v;
		--��ΪĿ��δ�����Ķ��м���
		tarFighter:BeTarTimesDec(atkFighter:GetId());
		
		--������������
		tarFighter:BeHitAdd(atkFighter:GetId());  
		
		--�ܻ�
		local  ltargetMachine = w_battle_machinemgr.getTarStateMachine(self.tarCampType, tarFighter:GetId());
		ltargetMachine:setInHurt(self.atkFighter);	
	end

	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
		--�������˶���
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, self.atkplayerNode, "" );
		self.seqAtk:AddCommand( cmdAtk );	
	
		if self.IsSkill == true then	--�����ܻ���Ч
			for k,v in pairs(self.targetLst) do
				tarFighter = v;
				local cmd11 = createCommandEffect():AddFgEffect( 1, tarFighter:GetNode(), self.hurt );
				local batch = w_battle_mgr.GetBattleBatch(); 
				local seqTemp = batch:AddSerialSequence();
				seqTemp:AddCommand( cmd11 );					
			end;			
		end;		
		--�������������ܻ�����
		self.atkFighter:cmdLua( "atk_end",  self.id, "", self.seqAtk ); 
    else
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, self.atkplayerNode, "" );
		self.seqStar:AddCommand( cmdAtk ); --��������
		
		local atkSound = self.atkSound;
		--��������
		if atkSound ~= nil then
			local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
			self.seqAtk:AddCommand( cmdAtkMusic );
		end			

		if self.is_bullet == W_BATTLE_BULLET_1 then --�е���
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
			if self.IsSkill == true then  --�������ܻ���Ч
				local cmd11 = createCommandEffect():AddFgEffect( 1, tarFighter:GetNode(), self.hurt );			
				self.seqAtk:AddCommand(cmd11);
			end;
			
			atkFighter:cmdLua("atk_end",        self.id, "", self.seqTarget);
			self.seqTarget:SetWaitEnd( bulletend );
		else  --û����
			--��������
			if self.IsSkill == true then	--�����ܻ���Ч
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

			
			self.atkFighter:cmdLua( "atk_end",  self.id, "", self.seqTarget ); 
			self.seqTarget:SetWaitEnd( cmdAtk );
		end
	end;

end



function p:atk_end()
	local atkFighter = self.atkFighter;
	local tarFighter = nil;
   
		
	--for pos=1,#self.targetLst do
	--	tarFighter = (self.targetLst)[pos];
	for k,v in pairs(self.targetLst) do
		tarFighter = v;
		--�ܻ����Ѫ,���õȵ�Ѫ�������
		local ldamage = (self.damageLst)[k];
		local lisMoredamage = false;  --������ɱ
		if tarFighter.Hp <= 0 then
			lisMoredamage = true;
		end;
		tarFighter:SubShowLife(ldamage); --��Ѫ����,����ʾ��Ѫ������	
		
		local lIsJoinAtk = self.joinAtkLst[k]
		if lIsJoinAtk== true then
			local lfirstID = tarFighter.firstID;
			local latkID = atkFighter:GetId();
			if(lfirstID ~= latkID) then
			--�ϻ��Ķ���
				WriteCon("JoinAtk flash");
			else
				lIsJoinAtk = false;
			end;
		end;
		
		local lIsCrit = self.critLst[k];	--�Ƿ񱩻�
		if self.atkCampType == W_BATTLE_HERO then
			--������Ʒ�ı���
			w_battle_atkDamage.getitem(tarFighter.Position ,self.IsSkill, lIsCrit,lIsJoinAtk,lisMoredamage); 
			
			--ͳ�Ƹ������
			w_battle_mgr.calAtkTimes(self.IsSkill,lIsCrit,lIsJoinAtk,lisMoredamage)
		end
		
		--�ܻ�������һ	
		tarFighter:BeHitDec(atkFighter:GetId()); 
		
		if tarFighter:GetHitTimes() == 0 then --�ܻ�����Ϊ0ʱ
			tarFighter.IsHurt = false;
		end;
		

	end;

	local cmd4 = createCommandPlayer():Standby( 0.01, self.atkplayerNode, "" );	
	self.seqAtk:AddCommand( cmd4 );
	atkFighter:standby();	

	
    --����������	
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
        --����ԭ����λ��
        local cmd5 = OnlyMoveTo(atkFighter, self.enemyPos, self.originPos, self.seqAtk);
		atkFighter:cmdLua( "atk_moveback",  self.id, "", self.seqAtk ); 
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
	
	--���ж����˽����ж���
	--w_battle_mgr.AtkDec(atkFighter:GetId());	
	
	WriteCon( "atkTurnEnd atkid:"..tostring(atkFighter:GetId()));
	w_battle_mgr.checkTurnEnd();
end;

