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
	
	if w_battle_mgr.NeedQuit == true then --中途退出,直接结束
		self:targerTurnEnd();
	end
	--self.playNode = targerFighter:GetNode()
	--self.oldPos = self.playNode:GetCenterPos()
	--WriteCon( " targetTurn start tarid="..tostring(targerFighter:GetId()));
--	targerFighter:HideBuffNode()
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
--奖励
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
		WriteCon( "**********Wring! targetTurn GetHitTimes~=0 need die id="..tostring(targerFighter:GetId()));
		targerFighter:standby();
	elseif targerFighter.Hp <= 0 then
		if targerFighter.canRevive == true then --复活
			local cmdC = w_battle_mgr.setFighterRevive(targerFighter);
			local batch = w_battle_mgr.GetBattleBatch(); 
			local seqDie = batch:AddSerialSequence();
			local cmdDieEnd = targerFighter:cmdLua("tar_ReviveEnd",  self.id, tostring(self.camp), seqDie);
			seqDie:SetWaitEnd( cmdC ); 
			
		else  --死了
			local cmdC = w_battle_mgr.setFighterDie(targerFighter,self.camp);
			if cmdC ~= nil then	
				local batch = w_battle_mgr.GetBattleBatch(); 			
				local seqDie = batch:AddSerialSequence();
				if w_battle_guid.IsGuid == false then
					local cmdDieEnd = targerFighter:cmdLua("tar_dieEnd",  self.id, tostring(self.camp), seqDie);
					seqDie:SetWaitEnd( cmdC ); 
				else
					if (w_battle_guid.guidstep == 3) and (w_battle_guid.substep == 8) then  --动画做完,先引导,再做别的
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

--自己的回合结束
function p:targerTurnEnd()
	self.IsTurnEnd = true;
	local tarFighter = self.tarFighter;	
--	tarFighter:ShowBuffNode();
	WriteCon( "targetTurnEnd id="..tostring(tarFighter:GetId()));
	w_battle_mgr.checkTurnEnd(); --检查是否回合结束结束

end;

function p:IsEnd()
	return self.IsTurnEnd;
end;
