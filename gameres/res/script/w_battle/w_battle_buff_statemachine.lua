w_battle_buff_statemachine = {}  --buff״̬��
local p = w_battle_buff_statemachine;
		  

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
	self.IsTurnEnd = false;
    self.fighter = nil;
	self.buffShowIndex = 0;
	self.buff_time = 0;
	self.noTurnbufftype = nil; --�����ж���BUFF״̬
	self.hasTurn = true;
end

function p:init(pfighter,pCamp)
	self.id = pfighter:GetId();
	self.fighter = pfighter;
	self.camp = pCamp
end;


function p:start()
	if self.fighter.Hp > 0 then  --û������û��BUFFֱ�ӽ���
		if #self.fighter.SkillBuff > 0 then
			self:nextBuff();			
		else
			self:BuffEnd();
		end
    else
		self.hasTurn = false;
		self:BuffEnd();
	end	
	
end;

function p:nextBuff()
	local fighter = self.fighter;
	if fighter.Hp <= 0 then  --����
		if fighter.canRevive == true then --����
			local cmdC = w_battle_mgr.setFighterRevive(fighter);
			local batch = w_battle_mgr.GetBattleBatch(); 
			local seqDie = batch:AddSerialSequence();
			local cmdDieEnd = fighter:cmdLua("buff_ReviveEnd",  self.id, tostring(self.camp), seqDie);
			seqDie:SetWaitEnd( cmdC ); 
			
		else  --����
			local cmdC = w_battle_mgr.setFighterDie(fighter,self.camp);
			if cmdC ~= nil then	
				local batch = w_battle_mgr.GetBattleBatch(); 			
				local seqDie = batch:AddSerialSequence();
				local cmdDieEnd = fighter:cmdLua("buff_dieEnd",  self.id, tostring(self.camp), seqDie);
				seqDie:SetWaitEnd( cmdC ); 
			end;
		end;					
		--fighterDieLst[#fighterDieLst + 1] = fighter; --���������б�							
		return ;
	end	
	
	self.buffShowIndex = self.buffShowIndex +1;
	if self.buffShowIndex > #self.fighter.SkillBuff then
		self:BuffEnd();
	else
		self.fighter:HideBuffNode()
		local buffInfo = self.fighter.SkillBuff[self.buffShowIndex];
		if    (buffInfo.buff_type == W_BUFF_TYPE_1)    --�����ж���BUFF
			or  (buffInfo.buff_type == W_BUFF_TYPE_2)
			or  (buffInfo.buff_type == W_BUFF_TYPE_3)
			or  (buffInfo.buff_type == W_BUFF_TYPE_4) 
			or  (buffInfo.buff_type == W_BUFF_TYPE_5) then 
			
			if self.buff_time < buffInfo.buff_time then
				self.noTurnbufftype = buff_type;
			end;
			self.hasTurn = false;
			self:nextBuff();
		elseif buffInfo.buff_type == W_BUFF_TYPE_9 then  --��ѪBUFF
			local lhp = math.modf(fighter.maxHp * buffInfo.buff_param / 100 )
			fighter.AddLife(lhp);
			fighter.AddShowLife(lhp);
			self:ShowBuff(buffInfo.buff_type); --��ʾĳ��BUFF
		elseif (buffInfo.buff_type == W_BUFF_TYPE_6) 
			or  (buffInfo.buff_type == W_BUFF_TYPE_7)  
			or  (buffInfo.buff_type == W_BUFF_TYPE_8) then --��ѪBUFF
			local lhp = math.modf(fighter.maxHp * buffInfo.buff_param / 100 )
			fighter:SubShowLife(lhp);
			fighter:SubLife(lhp);
			self:ShowBuff(buffInfo.buff_type); --��ʾĳ��BUFF
		end;
	end
end;

function p:buff_dieEnd()
	self:BuffEnd();
end;

function p:buff_ReviveEnd() 
	self:BuffEnd();
end;

function p:ShowBuff(buff_type)
	local buffAni = "n_battle_buff.buff_type_act"..tostring(buff_type); 
	local cmdBuff = createCommandEffect():AddFgEffect( 2, self.fighter:GetNode(), buffAni );
				
	local batch = w_battle_mgr.GetBattleBatch(); 
	local seqBuff = batch:AddSerialSequence();
	seqBuff:AddCommand( cmdBuff );

	local cmd = createCommandLua():SetCmd( "nextBuff", self.id, 0, "");
	local seqNextbuff = batch:AddSerialSequence();
	seqNextbuff:AddCommand(cmd);
	seqNextbuff:SetWaitEnd(cmdBuff);
end

function p:BuffEnd()
	local machine = w_battle_machinemgr.getAtkStateMachine(self.id);
	 
	if self.hasTurn == true then
		if self.fighter.Hp > 0 then
			self.fighter.HasTurn = true;
			machine.turnState = W_BATTLE_NOT_TURN;
		else
			self.fighter.HasTurn = false;
			machine.turnState = W_BATTLE_TURNEND;
		end;
	else
		self.fighter.HasTurn = false;
		machine.turnState = W_BATTLE_TURNEND;
	end
	self.IsTurnEnd = true;
	self.fighter:ShowBuffNode()
	w_battle_mgr.checkBuffEnd();
end;

function p:IsEnd()
	return self.IsTurnEnd;
end
