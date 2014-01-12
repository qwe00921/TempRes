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
	self.tarList = 0;
	
	--self.atkCampType = 0;
	--self.tarCampType = 0;
	--self.atkType = 0; 
	self.damage = 0;
	self.isCrit = false;
	self.isJoinAtk = false;
	self.atkplayerNode = 0;
	self.IsRevive = false;
	self.IsSkill  = false;

end



function p:init(id,atkFighter,atkCampType,tarFighter, tarCampType,damage,isCrit,isJoinAtk,isSkill,skillID)
	self.atkId = atkFighter:GetId();
	self.id = atkFighter:GetId();	
	self.targerId = tarFighter:GetId();
	self.atkFighter = atkFighter;
	self.targetFighter = tarFighter;
	self.atkCampType = atkCampType;
	self.tarCampType = tarCampType;
	
	self.damage = damage;
	self.isCrit = isCrit;
	self.isJoinAtk = isJoinAtk;
	self.atkplayerNode = atkFighter:GetPlayerNode();
	self.IsSkill = isSkill; --�Ƿ����ڼ���

	if self.IsSkill == true then
		self.distanceRes = tonumber( SelectCell( T_SKILL_RES, skillID, "distance" ) );--Զ�����ս���ж�;	
		self.targetType   = tonumber( SelectCell( T_SKILL, skillID, "Target_type" ) );
		self.skillType = tonumber( SelectCell( T_SKILL, skillID, "Skill_type" ) );
		self.singSound = SelectCell( T_SKILL_SOUND, skillID, "sing_sound" );
		self.hurtSound = SelectCell( T_SKILL_SOUND, skillID, "hurt_sound" );
		self.isBullet = tonumber( SelectCell( T_SKILL_RES, SkillId, "is_bullet" ) );
	else
		self.distanceRes = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "distance" ) );
		self.atkSound =  SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );	
		self.is_bullet = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "is_bullet" ) );
	end


    --�����������λ��
    self.originPos = self.atkplayerNode:GetCenterPos();

    --����Ŀ���λ��
    self.enemyPos = tarFighter:GetFrontPos(self.atkplayerNode);	

	
	local batch = w_battle_mgr.GetBattleBatch(); 
	self.seqStar = batch:AddSerialSequence();
	self.seqAtk = batch:AddSerialSequence();
	self.seqTarget = batch:AddSerialSequence(); 
	
	
	self:start();

end;

function p:start()
	local atkFighter = self.atkFighter;
	local tarFighter = self.targetFighter;
    local playerNode = self.atkplayerNode;
			
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
	
		--�򹥻�Ŀ���ƶ�
		local cmdMove = OnlyMoveTo(atkFighter, self.originPos, self.enemyPos, self.seqStar);
		
		local cmdAtk = atkFighter:cmdLua("atk_startAtk",  self.id,"", self.seqTarget);
		self.seqTarget:SetWaitEnd( cmdMove );
	elseif self.distanceRes == W_BATTLE_DISTANCE_Archer then  --Զ�̹���
		self:atk_startAtk();
	end;
	    
end

function p:atk_startAtk()  
	local atkFighter = self.atkFighter;
	local tarFighter = self.targetFighter;
	--��ΪĿ��δ�����Ķ��м���
	tarFighter:BeTarTimesDec(atkFighter:GetId());
	
	--������������
	tarFighter:BeHitAdd(atkFighter:GetId());  

		
	local lfirstID = tarFighter.firstID;
	local latkID = atkFighter:GetId();
	if self.isJoinAtk == true then
		if(lfirstID ~= latkID) then
		--�ϻ��Ķ���
			WriteCon("JoinAtk flash");
		end;
	end;	
    
	

	--�ܻ�
	local  ltargetMachine = w_battle_machinemgr.getTarStateMachine(self.tarCampType, tarFighter:GetId());
	--ltargetMachine.init()
	ltargetMachine:setInHurt(self.atkFighter);	
	
	if self.distanceRes == W_BATTLE_DISTANCE_NoArcher then  --��ս�չ�
		--�������˶���
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, self.atkplayerNode, "" );
		self.seqAtk:AddCommand( cmdAtk );	
		--�������������ܻ�����
		self.atkFighter:cmdLua( "atk_end",  self.id, "", self.seqAtk ); 

    else
		local isBullet = self.is_bullet 
		local bulletAni;
		
		local cmdAtk = createCommandPlayer():Atk( W_BATTLE_ATKTIME, playerNode, "" );
		self.seqStar:AddCommand( cmdAtk ); --��������
		
		local atkSound = self.atkSound;
		--��������
		if atkSound ~= nil then
			local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
			self.seqAtk:AddCommand( cmdAtkMusic );
		end			

		if isBullet == N_BATTLE_BULLET_1 then --�е���
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
			
			atkFighter:cmdLua("atk_end",        self.id, "", self.seqTarget);
			self.seqTarget:SetWaitEnd( cmdAtk );
		else  --û����
			--��������
			self.atkFighter:cmdLua( "atk_end",  self.id, "", self.seqAtk ); 

		end
	end;

	
	
	
end

function p:atk_end()
	local atkFighter = self.atkFighter;
	local tarFighter = self.targetFighter;	
	
	--�ܻ����Ѫ,���õȵ�Ѫ�������
	tarFighter:SubShowLife(self.damage); --��Ѫ����,����ʾ��Ѫ������	
	
	local cmd4 = createCommandPlayer():Standby( 0.01, self.atkplayerNode, "" );
	self.seqAtk:AddCommand( cmd4 );
	atkFighter:standby();	

	--�ܻ�������һ	
	tarFighter:BeHitDec(atkFighter:GetId()); 
	
	if tarFighter:GetHitTimes() == 0 then --�ܻ�����Ϊ0ʱ
		tarFighter.IsHurt = false;
	end;
	
    --��������	
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


