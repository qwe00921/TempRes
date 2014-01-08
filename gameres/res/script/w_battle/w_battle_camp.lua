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
		node:SetZOrder( 3 );
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
	
	local x = pOldPos.x - 220;
	local y = pOldPos.y;

	local pNewPos = CCPointMake(x,y);	
	
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
	
	local x = pOldPos.x + 220;
	local y = pOldPos.y;

	local pNewPos = CCPointMake(x,y);	
	
	local batch = battle_show.GetNewBatch();
	node:AddActionEffect("lancer.fadein0");
	local cmd = pFighter:JumpToPosition(batch,pNewPos,true);
	
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
			local str = string.format("Enemy jump time is %8.6f",fTime);
			WriteCon(str);
			SetTimerOnce( p.AddEnemyFightersJumpEffect, fTime );
		end
	end
end

function p:AddShadows(uiArray, fighters)
	for i = 1,#self.fighters do
	    local fighterInfo = self.fighters[i];
        local uiTag = uiArray[tonumber( fighterInfo.Position )];
		local node = GetPlayer( w_battle_mgr.uiLayer, uiTag );
		if node == nil then
			WriteCon( "get player node failed" );
			return;
		end
		
		local kShadow = w_shadow:new();
		local nIndex = #self.shadows + 1;
		self.shadows[nIndex] = kShadow;
		local pOldPos = node:GetCenterPos();

		if self.idCamp == E_CARD_CAMP_HERO then
			pOldPos.x = pOldPos.x;
		elseif self.idCamp == E_CARD_CAMP_ENEMY then
			pOldPos.x = pOldPos.x;
		end
		
		node:SetCenterPos(pOldPos);
		
		local kShadowNode = kShadow:Init("lancer.shadow",node);
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
		local node = GetPlayer( w_battle_mgr.uiLayer, uiTag );
		if node == nil then
			WriteCon( "get player node failed" );
			return;
		end
		
		local f = w_fighter:new();
		self.fighters[#self.fighters + 1] = f;
		--self.fighters[tonumber(fighterInfo.Position)] = f;
		
		local pOldPos = node:GetCenterPos();

		if self.idCamp == E_CARD_CAMP_HERO then
			pOldPos.x = pOldPos.x + 220;
		elseif self.idCamp == E_CARD_CAMP_ENEMY then
			pOldPos.x = pOldPos.x - 220;
		end
		node:SetCenterPos(pOldPos);
		
		--战士属性
        f.life = tonumber( fighterInfo.Hp );
        f.lifeMax = tonumber( fighterInfo.Hp );
        f.level = tonumber( fighterInfo.Level );
        f.uniqueId = tonumber( fighterInfo.UniqueId );
        f.cardId = tonumber( fighterInfo.CardID );
		f.Attack = tonumber( fighterInfo.Attack);
		f.Defence = tonumber( fighterInfo.Defence);
		f.atkType = tonumber ( fighterInfo.Damage_type);
		f.Position = tonumber (fighterInfo.Position);
		f.Crit	   = tonumber (fighterInfo.Crit);
		
        f.buffList = {};
         
		--临时攻击力调整
		f.Attack = 100;
		f.Defence = 0;
		f.life = 200;
				
		--f:Init( uiTag, node, self.idCamp );
		f:Init( fighterInfo.Position, node, self.idCamp );
		self:SetFighterConfig( f, f.cardId ); 
		f:standby();
		
        --f.idFighter = tonumber( fighterInfo.Position );
        --if self.idCamp == E_CARD_CAMP_ENEMY then
        --    f.idFighter = f.idFighter + W_BATTLE_CAMP_CARD_NUM;  --ID待商定
        --end
		
		if self:IsHeroCamp() then
			node:SetZOrder( E_BATTLE_Z_HERO_FIGHTER );
			f:SetLookAt( E_LOOKAT_LEFT );
		else
			node:SetZOrder( E_BATTLE_Z_ENEMY_FIGHTER );
			f:SetLookAt( E_LOOKAT_RIGHT );
		end
		node:SetId(f.idFighter);
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
