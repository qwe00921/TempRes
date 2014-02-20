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
	
	if w_battle_mgr.NeedQuit == true then --��;�˳�,ֱ�ӽ���
		self:targerTurnEnd();
	end
	--self.playNode = targerFighter:GetNode()
	--self.oldPos = self.playNode:GetCenterPos()
	--WriteCon( " targetTurn start tarid="..tostring(targerFighter:GetId()));
--	targerFighter:HideBuffNode()
	--�ѳ�ΪĿ��,δ����
	--targerFighter:BeTarTimesDec(atkFighter:GetId()); 
    if (targerFighter.IsHurt == false) then --�����ܻ���ʶ
		WriteCon( "targetTurn Start id="..tostring(targerFighter:GetId()));
		self.IsTurnEnd = false;
		targerFighter.IsHurt = true;  --��ʶ�ܻ���
		local batch = w_battle_mgr.GetBattleBatch();
		local seqTarget = batch:AddSerialSequence();
		local seqHurt = batch:AddSerialSequence();
		
		--�ܻ���������һ��
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
	local batch = w_battle_mgr.GetBattleBatch();
	local seqTarget = batch:AddSerialSequence();
	local seqHurt = batch:AddSerialSequence();	
	if targerFighter.IsHurt == true then
 		local cmdHurt = createCommandEffect():AddActionEffect( 0.35, targerFighter:GetPlayerNode(), "lancer.ishurt" );
		seqTarget:AddCommand( cmdHurt );
		
		local cmdIshurt = targerFighter:cmdLua( "tar_hurt",   self.id, tostring(self.camp), seqHurt );
		seqHurt:SetWaitEnd(cmdHurt); 
	else
		WriteCon( "targetTurn tar_hurt to end tarid="..tostring(targerFighter:GetId()));
		--if w_battle_mgr.platform == W_PLATFORM_WIN32 then
			local lPlayerNode = targerFighter:GetPlayerNode();
			local moveback = OnlyMoveTo(targerFighter, lPlayerNode:GetCenterPos(), targerFighter.oldPos, seqTarget,true);
			
			local cmdIshurt = targerFighter:cmdLua( "tar_hurtEnd",   self.id, tostring(self.camp), seqHurt );
			seqHurt:SetWaitEnd(moveback); 
		--else
		--	self:tar_hurtEnd();
		--end;
	end
end;
--[[
--����
function p:reward()
	local targerFighter = self.tarFighter;	
	local tmpList = {}
	if targerFighter.dropLst ~= nil then
		for k,v in ipairs(targerFighter.dropLst) do
			tmpList[#tmpList + 1] = {v.dropType, 1, targerFighter.Position, v.id};
		end
	end;
	w_battle_pve.MonsterDrop(tmpList)
end;
]]--
--ֻ�����˽���ʱ�ŵ���
function p:tar_hurtEnd()
	local targerFighter = self.tarFighter;	
	local batch = w_battle_mgr.GetBattleBatch();
	local seqTarget = batch:AddSerialSequence();
	local seqHurt = batch:AddSerialSequence();
    if self:IsEnd() then  --�ѽ���
		return ;
	end;
	
	if targerFighter.IsHurt == true then  --�ֽ������ܻ�״̬
		return ;
	end;
	
			
	if (targerFighter.Hp > 0) or (targerFighter:GetTargerTimes() > 0 ) then  --������,���߳�ΪĿ��δ������������Ϊ0,��������վ��	
		targerFighter:standby();
		--if (targerFighter.Hp > 0) then
			WriteCon( "targetTurn standby id="..tostring(targerFighter:GetId()));
		--elseif targerFighter:GetTargerTimes() > 0 then
		--	WriteCon( "targetTurn Die but GetTargerTimes> 0 id="..tostring(targerFighter:GetId()));
		--end;
		self:targerTurnEnd();  --�ܻ������̽���
	elseif (targerFighter:GetHitTimes() ~= 0) then
		WriteCon( "**********Wring! targetTurn GetHitTimes~=0 need die id="..tostring(targerFighter:GetId()));
		targerFighter:standby();
	elseif targerFighter.Hp <= 0 then
		if targerFighter.canRevive == true then --����
			local cmdC = w_battle_mgr.setFighterRevive(targerFighter);
			local batch = w_battle_mgr.GetBattleBatch(); 
			local seqDie = batch:AddSerialSequence();
			local cmdDieEnd = targerFighter:cmdLua("tar_ReviveEnd",  self.id, tostring(self.camp), seqDie);
			seqDie:SetWaitEnd( cmdC ); 
			
		else  --����
			local cmdC = w_battle_mgr.setFighterDie(targerFighter,self.camp);
			if cmdC ~= nil then	
				local batch = w_battle_mgr.GetBattleBatch(); 			
				local seqDie = batch:AddSerialSequence();
				if w_battle_guid.IsGuid == false then
					local cmdDieEnd = targerFighter:cmdLua("tar_dieEnd",  self.id, tostring(self.camp), seqDie);
					seqDie:SetWaitEnd( cmdC ); 
				else
					if (w_battle_guid.guidstep == 3) and (w_battle_guid.substep == 8) then  --��������,������,�������
						local cmdDieEnd = targerFighter:cmdLua("tar_guidstep3_8",  self.id, tostring(self.camp), seqDie);
						seqDie:SetWaitEnd( cmdC ); 
					else	
						local cmdDieEnd = targerFighter:cmdLua("tar_dieEnd",  self.id, tostring(self.camp), seqDie);
						seqDie:SetWaitEnd( cmdC ); 
					end
				end;
			end;
		end;		
	end;

	
end;

function p:tar_guidstep3_8()
	w_battle_mgr.nextGuidSubStep();
end;

function p:tar_ReviveEnd() 
	self:targerTurnEnd();	
end;

function p:tar_dieEnd() 
	local tarFighter = self.tarFighter;
	WriteCon( "tar_dieEnd tarid="..tostring(tarFighter:GetId()).." self.atkFighter id="..tostring(self.atkFighter:GetId()) );
	self:targerTurnEnd();
end;

--�Լ��ĻغϽ���
function p:targerTurnEnd()
	self.IsTurnEnd = true;
	local tarFighter = self.tarFighter;	
--	tarFighter:ShowBuffNode();
	WriteCon( "targetTurnEnd id="..tostring(tarFighter:GetId()));
	w_battle_mgr.checkTurnEnd(); --����Ƿ�غϽ�������

end;

function p:IsEnd()
	return self.IsTurnEnd;
end;
