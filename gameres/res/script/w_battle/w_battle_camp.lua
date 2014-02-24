--------------------------------------------------------------
-- FileName: 	w_battle_camp.lua
-- BaseClass:   battle_camp
-- author:		zhangwq, 2013/06/20
-- purpose:		作战阵营（多实例）
--------------------------------------------------------------

w_battle_camp = battle_camp:new();
local p = w_battle_camp;
local super = battle_camp;
local g_Herofighters = nil;
local g_HeroIndex = 1;
local g_Enemyfighters = nil;
local g_EnemyIndex = 1;
local g_HeroShadows = nil;
local g_HeroShadowIndex = 1;
local g_EnemyShadows = nil;
local g_EnemyShadowsIndex = 1;

PET_FLY_DRAGON_TAG = 1;
PET_MINING_TAG  = 2;
PET_BLUE_DEVIL_TAG = 3;
BOSS_TAG = 4;

local tobjId = {"10392","10684","10706","10745","10774","10835","10836","10838","10884","10953","10999","11000","11007","11008","11024","11027"}

function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	p.jumpIndex = 1;
	return o;
end

--构造函数
function p:ctor()
    super.ctor(self);
end

--获取存活fighters
function p:GetAliveFighters()
	local t = {}
	for k,v in ipairs(self.fighters) do
		if v ~= nil and (not v.isDead) and v:CheckTmpLife() then
			t[#t + 1] = v;
		end
	end
	return t;
end

--获取存活fighters中哪些可成为目标
--id需与pFighterID不同
function p:GetFirstActiveFighterID(pFighterID) 
	local lminSelId=7;  --
	local lId= nil; --真实的ID
	for k,v in ipairs(self.fighters) do
		if ((v.nowlife > 0) and (v:GetId() ~= pFighterID))then
			if v.selIndex < lminSelId then
				lminSelId = v.selIndex ;
				lId = v:GetId();
				--break;
			end
		end;
	end;
	
	return lId;
end;	

--获取存活fighters中哪些可成为目标
--id需与pFighterID不同
--以pos从1-6排序
function p:GetFirstActiveFighterPos(pFighterID) 
	local lminSelId=7;  --
	local lId= nil; --真实的ID
	for k,v in ipairs(self.fighters) do
		if ((v.nowlife > 0) and (v:GetId() ~= pFighterID))then
			if v:GetId() < lminSelId then
				lminSelId = v.selIndex ;
				lId = v:GetId();
				--break;
			end
		end;
	end;
	
	return lId;
end;	

--传入攻击者,获得属性加成的玩家列表,给怪物攻击选择
function p:GetElementFighter(pAtkFighter)
	local lLst = {}
	for k,v in ipairs(self.fighters) do
		if (v.nowlife > 0) and (w_battle_atkDamage.IsElement(pAtkFighter,v) == true) then
			table.insert(lLst,v);
		end;
	end;
	return lLst;
end;

--传入受击者,获得哪些攻击有属性加成的位置,玩家界面显示相克
function p:GetElementAtkFighter(pTarFighter)
	local lLst = {}
	for k,v in ipairs(self.fighters) do
		if (v.Hp > 0) and (w_battle_atkDamage.IsElement(v,pTarFighter) == true) then
			table.insert(lLst,v:GetId());
		end;
	end;
	return lLst;

end;
--获得体力>0的玩家列表
function p:GetHeroFighter()
	local lLst = {}
	for k,v in ipairs(self.fighters) do
		if v.nowlife > 0 then
			table.insert(lLst,v);
		end;
	end;
	return lLst;
end;


--获得当前尸体未消失的怪物
function p:GetFirstNotDeadFighterID(pFighterID) 
	local lminSelId=7;  --
	local lId= nil; --真实的ID
	for k,v in ipairs(self.fighters) do
		if ((v.isDead == false) and (v:GetId() ~= pFighterID))then
			if v.selIndex < lminSelId then
				lminSelId = v.selIndex ;
				lId = v:GetId();
				--break;
			end
		end;
	end;
	
	return lId;
end;	

--获得预估还活着的怪物
function p:GetFirstHasHpFighterID(pFighterID)
	local lminSelId = 7;  --
	local lId= pFighterID; --真实的ID
	for k,v in ipairs(self.fighters) do
		if ((v.nowlife > 0) and (v:GetId() ~= pFighterID))then
			if v.selIndex < lminSelId then
				lminSelId = v.selIndex ;
				lId = v:GetId();
				--break;
			end
		end;
	end;
	
	return lId;	
end;

--获得当前尸体未消失的怪物
function p:GetNotDeadFighterCount()
	local lCount = 0;
	for k,v in ipairs(self.fighters) do
		if (v.isDead == false) then --尸体还在
			lCount = lCount + 1;
		end;
	end;
    return lCount;
end

function p:GetHasHpFighterCount()
	local lCount = 0;
	for k,v in ipairs(self.fighters) do
		if (v.nowlife > 0) then --尸体还在
			lCount = lCount + 1;
		end;
	end;
    return lCount;
	
end;

function p:HasTurn()
	local lHasTurn = false;
	for k,v in ipairs(self.fighters) do
		if (v.HasTurn == true) then --可以行动
			lHasTurn = true;
			break;
		end;
	end;
	
	return lHasTurn;
end;

--判断是否所有的全死了
function p:isAllDead()
	local lisAllDead = true;
	for k,v in ipairs(self.fighters) do
		if (v.isDead == false) then --尸体还在
			lisAllDead = false;
			break;
		end;
	end;
	
	return lisAllDead;
end;

--扣血
function p:SubLife(damage)
	for k,v in ipairs(self.fighters) do
		if (v.isDead == false) then --尸体还在
			v:SubLife(damage)
			break;
		end;
	end;
end;

function p:BeTarTimesAdd(atkID)
	for k,v in ipairs(self.fighters) do
		if (v.Hp > 0) then --未死
			v:BeTarTimesAdd(atkID)
			break;
		end;
	end;
end;

--受击数减一
function p:BeTarTimesDec(atkID)
	for k,v in pairs(self.fighters) do
		v:BeTarTimesDec(atkID);
	end;
end;
--[[
--查找位置对应的fighter
function p:FindFighter(pPos)
	local fighter = nil;
	for k,v in ipairs(self.fighters) do
		if (v.Position == pPos) then
			fighter = v;
			break;
		end
	end
	return fighter;
end;
]]--

--[[
--判定攻击方回合是否结束(含受击方动画完成)
function p:CheckAtkTurnEnd()
	local lresult = true;
	for k,v in ipairs(self.fighters) do
		if v.IsTurnEnd == false then
			lresult = false;
			break;
		end;
	end;
	
	return lresult;
	
end;

--初始化攻击方回合标识
function p:InitAtkTurnEnd()
	for k,v in ipairs(self.fighters) do
		 v.IsTurnEnd = false;
	end;

end;
]]--
--还有多少存活
function p:GetActiveFighterCount()
	local lCount = 0;
	for k,v in ipairs(self.fighters) do
		if v.nowlife > 0 then
			lCount = lCount + 1; 
		end;
	end;
end;


--添加战士

function p:AddBoss()
	local uiTag = 14;
	local node = GetPlayer( w_battle_mgr.uiLayer, uiTag );
	if node == nil then
		WriteCon( "get player node failed" );
		return;
	end
		
	local f = w_fighter:new();
	self.fighters[#self.fighters + 1] = f;
		
	f:Init( uiTag, node, self.idCamp );
	self:SetBossConfig( f);
	f:standby();
	f.idCamp = E_CARD_CAMP_ENEMY;
		
	if self:IsHeroCamp() then
		node:SetZOrder( 3 );
		f:SetLookAt( E_LOOKAT_RIGHT );
	else
		node:SetZOrder(3);
		f:SetLookAt( E_LOOKAT_LEFT );
	end
end

function p.AddHeroFightersJumpEffect()
	local pFighter = g_Herofighters[g_HeroIndex];

	if pFighter == nil then
		WriteConWarning(string.format("pFighter is nil,ID is %d\n",g_HeroIndex));
		return nil;
	end
	
	local node = pFighter:GetPlayerNode();
	if node == nil then
		WriteCon( "get player node failed" );
		return;
	end

	local pOldPos = node:GetCenterPos();

	local lwinWidth = GetWinSize().w;

	local fTemp = 0.0;
		
	if w_battle_mgr.platform == W_PLATFORM_WIN32 then
		fTemp = 320.0;
	else
		fTemp = 640.0;
	end	
	local fScale = GetUIScale();
	local loffset = (W_BATTLE_JUMPSTAR * (lwinWidth / fTemp) * fScale);

	--local lwinWidth = GetWinSize().w;	
	--update by csd
	--w_battle_mgr.platformScale in win32 is 1, in other is 2 
	--local loffset = W_BATTLE_JUMPSTAR * (lwinWidth / 320 * w_battle_mgr.platformScale);	
	--local lscale = GetUIScale();
	local x = pOldPos.x - loffset;
	local y = pOldPos.y;
	
	local pNewPos = CCPointMake(x,y);
	pFighter:SaveOldPos(pNewPos);
	
	local batch = battle_show.GetNewBatch();
	local cmd = pFighter:JumpToPosition(batch,pNewPos,true);
	
	g_HeroIndex = g_HeroIndex + 1;
end

function p.AddEnemyFightersJumpEffect()
	local pFighter = g_Enemyfighters[g_EnemyIndex];

	if pFighter == nil then
		return nil;
	end
	
	local node = pFighter:GetPlayerNode();
	if node == nil then
		WriteCon( "get player node failed" );
		return;
	end
		
	local pOldPos = node:GetCenterPos();
	
	local lwinWidth = GetWinSize().w;	
	local fTemp = 0.0;
		
	if w_battle_mgr.platform == W_PLATFORM_WIN32 then
		fTemp = 320.0;
	else
		fTemp = 640.0;
	end
	
	local fScale = GetUIScale();
	
	local loffset = (W_BATTLE_JUMPSTAR * (lwinWidth / fTemp) * fScale);
	--local lwinWidth = GetWinSize().w;
	--update by csd	
	--w_battle_mgr.platformScale in win32 is 1, in other is 2
	--local loffset = W_BATTLE_JUMPSTAR * (lwinWidth / 320 * w_battle_mgr.platformScale);		
	--local lscale = GetUIScale();
	local x = pOldPos.x + loffset;
	local y = pOldPos.y;

	local pNewPos = CCPointMake(x,y);	
	pFighter:SaveOldPos(pNewPos);
	
	local batch = battle_show.GetNewBatch();
	--node:AddActionEffect("lancer.fadein0");
	local cmd = pFighter:JumpToPosition(batch,pNewPos,true);
	
	local lSceneSeq = batch:AddSerialSequence();
	local lcmdSceneEnd = createCommandLua():SetCmd( "intoSceneEnd", pFighter.Position, 0, "");
	lSceneSeq:AddCommand(lcmdSceneEnd);	
	lSceneSeq:SetWaitEnd(cmd);
	
	g_EnemyIndex = g_EnemyIndex + 1;
end

function p:AddAllRandomTimeJumpEffect(bHero)

	if self.fighters == nil then
		WriteConWarning("self.fighters is nil");
	end
	
	if bHero == true then
		WriteCon("Add hero Jump");
		g_Herofighters = self.fighters;
		g_HeroIndex = 1;
		for k,v in ipairs(self.fighters) do
			local fTime = k / 10.0f + 0.3f;
			local str = string.format("Hero jump time is %8.6f",fTime);
			WriteCon(str);
			SetTimerOnce( p.AddHeroFightersJumpEffect, fTime );
		end
	else
		g_Enemyfighters = self.fighters;
		g_EnemyIndex = 1;
		for k,v in ipairs(self.fighters) do
			local fTime = k / 10.0f + 0.3f;

			SetTimerOnce( p.AddEnemyFightersJumpEffect, fTime );
		end
	end
end

function p:AddShadows(uiArray, fighters)
	for i = 1,#self.fighters do
	    local fighterInfo = self.fighters[i];
        local uiTag = uiArray[tonumber( fighterInfo.Position )];
--		local node = GetPlayer( w_battle_mgr.uiLayer, uiTag );
--		local nodeUI = GetUiNode( w_battle_mgr.uiLayer, uiTag );
	    local node = w_battle_mgr.GetPlayerNode(uiTag );
		if node == nil then
			WriteCon( "get player node failed" );
			return;
		end
		
		local kShadow = w_shadow:new();
		local nIndex = #self.shadows + 1;
		self.shadows[nIndex] = kShadow;
		--[[
		local pOldPos = node:GetCenterPos();

		if self.idCamp == E_CARD_CAMP_HERO then
			pOldPos.x = pOldPos.x;
		elseif self.idCamp == E_CARD_CAMP_ENEMY then
			pOldPos.x = pOldPos.x;
		end
		
		node:SetCenterPos(pOldPos);
		]]--
		local kShadowNode = kShadow:Init("w_battle_res.shadow",node);
		self.fighters[nIndex]:SetShadow(kShadow.m_kNode);
		w_battle_mgr.uiLayer:AddChildZ(kShadowNode,0);
		--self:SetFighterConfig( kShadow, i );
		--kShadow:standby();
		
		if self:IsHeroCamp() then
			--node:SetZOrder( E_BATTLE_Z_HERO_FIGHTER );
			--kShadow:SetLookAt( E_LOOKAT_RIGHT );
		else
			--node:SetZOrder( E_BATTLE_Z_ENEMY_FIGHTER );
			--kShadow:SetLookAt( E_LOOKAT_LEFT );
		end
	end
end

function p:AddFighters( uiArray, fighters )
	for i = 1,#fighters do
	    local fighterInfo = fighters[i];
		local uiTag = uiArray[tonumber( fighterInfo.Position )];
		--local node = GetPlayer( w_battle_mgr.uiLayer, uiTag );
		local nodeUI = GetUiNode( w_battle_mgr.uiLayer, uiTag );
		local node = w_battle_mgr.GetPlayerNode(uiTag );
		if (node == nil) or (nodeUI == nil) then
			WriteCon( "get player node failed" );
			return;
		end
		
		local f = w_fighter:new();
		self.fighters[#self.fighters + 1] = f;
		--self.fighters[tonumber(fighterInfo.Position)] = f;%
		
		local pOldPos = nodeUI:GetCenterPos();
		
		local lwinWidth = GetWinSize().w;

		local fTemp = 0.0;
		
		if w_battle_mgr.platform == W_PLATFORM_WIN32 then
			fTemp = 320.0;
		else
			fTemp = 640.0;
		end
		
		local lscale = GetUIScale();
		local loffset = (W_BATTLE_JUMPSTAR * (lwinWidth / fTemp) * lscale);
		
		--if w_battle_mgr.platform == W_PLATFORM_WIN32 then
			--有跳入动作
			if self.idCamp == E_CARD_CAMP_HERO then
			--	pOldPos.x = pOldPos.x + loffset
			elseif self.idCamp == E_CARD_CAMP_ENEMY then
			--	pOldPos.x = pOldPos.x - loffset
			end
			
			node:SetCenterPos(pOldPos);
		--end;
		--战士属性
        f.life = tonumber( fighterInfo.Hp );
        --f.lifeMax = tonumber( fighterInfo.Hp );
        f.level = tonumber( fighterInfo.Level );
        f.uniqueId = tonumber( fighterInfo.UniqueId );
        f.cardId = tonumber( fighterInfo.CardID );
		f.Attack = tonumber( fighterInfo.Attack);
		f.Defence = tonumber( fighterInfo.Defence);
--		f.atkType = tonumber ( fighterInfo.Damage_type);
		f.Position = tonumber (fighterInfo.Position);
		f.Crit	   = tonumber (fighterInfo.Crit);
		f.Skill	   = tonumber (fighterInfo.Skill);
		f.element  = tonumber (fighterInfo.element);
		f.CardID   = tonumber (fighterInfo.CardID);
		f.Sp = tonumber(fighterInfo.Sp);
		f.maxSp = tonumber(fighterInfo.maxSp);
		f.Level = tonumber(fighterInfo.Level);
		f.canRevive = fighterInfo.canRevive;
		f.dropLst = fighterInfo.dropLst; --掉落的物品列表
        f.buffList = {};

		local x = pOldPos.x;
		local y = pOldPos.y;
		
		local pNewPos = CCPointMake(x,y);
		f:SaveOldPos(pNewPos);
		
		if w_battle_db_mgr.IsDebug == true then
			if self.idCamp == E_CARD_CAMP_HERO then
				f.Attack = 1000;
				--f.Defence = 1;
				--
				--if f.Position == 2 then
				--	f.Sp = 100;
				--end
				
				--f.Defence = f.Defence + 200;
			--[[	f.Sp = 100;
				if f.Position == 2 then
					f.Skill = 102;
				elseif f.Position == 3 then
					f.Skill = 2;
				elseif f.Position == 4 then
					f.Skill = 1001;
				elseif f.Position == 5 then
					f.Skill = 1008;
				end;]]--
			elseif self.idCamp == E_CARD_CAMP_ENEMY then
				f.Attack = 1;
				f.Defence = 100;
				f.Skill = 0;
				if f.Position == 5 then
					f.Skill = 1001;
				end
			--[[	if f.Position == 1  then
					f.Skill = 1005;
				elseif f.Position == 3 then
					f.Skill = 2;
				elseif f.Position == 4 then
					f.Skill = 1001;
				elseif f.Position == 5 then
					f.Skill = 1008;
				else
					f.Skill = 1;
				end;]]--
			end
		end;		
		
		
		--f:Init( uiTag, node, self.idCamp );
		f:Init( fighterInfo.Position, node, self.idCamp );
		f.nowlife = f.Hp;
		
		if w_battle_db_mgr.IsDebug == true then
			if self.idCamp == E_CARD_CAMP_HERO then
				w_battle_pve.SetHeroCardAttr(f.Position, f);
			end;
		end
		
		WriteCon("cardId="..tostring(f.cardId))
		self:SetFighterConfig( f, f.cardId ); 
		f:standby();
		
		local lscale = GetUIScale();
		
		if self:IsHeroCamp() then
			node:SetZOrder( E_BATTLE_Z_HERO_FIGHTER + f.Position);
			f:SetLookAt( E_LOOKAT_LEFT );
		else
			node:SetZOrder( E_BATTLE_Z_ENEMY_FIGHTER + f.Position );
			f:SetLookAt( E_LOOKAT_RIGHT );
		end
		node:SetId(f.idFighter);
		
		local batch = battle_show.GetNewBatch();
		node:AddActionEffect("lancer.fadein0");
		local pRolePos = node:GetFramePos();
		local kRealSize = node:GetCurAnimRealSize();
		local btn = GetButton(w_battle_pve.battleLayer,210 + f.Position);
		if nil ~= btn then
			btn:SetCenterPos(pRolePos);
			btn:SetFrameSize(kRealSize.w / 2,kRealSize.h / 2);
		end
	end
end

--设置fighter配置

function p:SetBossConfig( f )
	if f == nil then return end;

	f:UseConfig( "boss" );
	f.petTag = BOSS_TAG;
		
		--f:UseConfig( "blue_devil" );
		--f.petTag = PET_BLUE_DEVIL_TAG;
end

function p:SetFighterConfig( f, idx )
	if f == nil then return end;

	--@override:测试用,重载宠物类型
	if false then
		f:UseConfig( "fly_dragon" );
		f.petTag = PET_FLY_DRAGON_TAG;
		return;
	end
	f:UseConfig( string.format( "%s", idx ));
	--f:UseConfig( string.format("test%s", tobjId[self.idCamp == E_CARD_CAMP_HERO and idx or idx + 8]) );
	--f.petTag = idx % 2 == 0 and PET_FLY_DRAGON_TAG or PET_BLUE_DEVIL_TAG;
end

function p:ClearFighterBuff()
	for k,v in ipairs(self.fighters) do
		v:initBuff();
	end
end

function p:SetFightersZOrder(pZorder)
	for k,v in ipairs(self.fighters) do
		v.node:SetZOrder(pZorder + v.Position);
	end
end

function p:CheckAllIntoScene()
	local lres = true;
	for k,v in ipairs(self.fighters) do
		if v.isIntoScene == false then
			lres = false;
			break;
		end
	end
	
	return lres;
end