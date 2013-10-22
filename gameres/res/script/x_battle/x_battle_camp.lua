--------------------------------------------------------------
-- FileName: 	x_battle_camp.lua
-- BaseClass:   battle_camp
-- author:		zhangwq, 2013/06/20
-- purpose:		作战阵营（多实例）
--------------------------------------------------------------

x_battle_camp = battle_camp:new();
local p = x_battle_camp;
local super = battle_camp;

PET_FLY_DRAGON_TAG = 1;
PET_MINING_TAG  = 2;
PET_BLUE_DEVIL_TAG = 3;
BOSS_TAG = 4;

function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
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
			t[#t+1] = v;
		end
	end
	return t;
end

--添加战士

function p:AddBoss()
		local uiTag = 14;
		local node = GetPlayer( x_battle_mgr.uiLayer, uiTag );
		if node == nil then
			WriteCon( "get player node failed" );
			return;
		end
		
		local f = x_fighter:new();
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

function p:AddFighters( uiArray )
	for i=1,#uiArray do
		local uiTag = uiArray[i];
		local node = GetPlayer( x_battle_mgr.uiLayer, uiTag );
		if node == nil then
			WriteCon( "get player node failed" );
			return;
		end
		
		local f = x_fighter:new();
		self.fighters[#self.fighters + 1] = f;
		
		f:Init( uiTag, node, self.idCamp );
		self:SetFighterConfig( f, i );
		f:standby();
		
		if self:IsHeroCamp() then
			node:SetZOrder( E_BATTLE_Z_HERO_FIGHTER );
			f:SetLookAt( E_LOOKAT_RIGHT );
		else
			node:SetZOrder( E_BATTLE_Z_ENEMY_FIGHTER );
			f:SetLookAt( E_LOOKAT_LEFT );
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
	
	if idx==1 then
		f:UseConfig( "fly_dragon" );
		f.petTag = PET_BLUE_DEVIL_TAG;
	elseif idx==2 then
		f:UseConfig( "mining" );
		f.petTag = PET_MINING_TAG;
		
		--f:UseConfig( "blue_devil" );
		--f.petTag = PET_BLUE_DEVIL_TAG;
		
	elseif idx==3 then
		f:UseConfig( "fly_dragon" );
		f.petTag = PET_FLY_DRAGON_TAG;
	elseif idx==4 then
		f:UseConfig( "mining" );
		f.petTag = PET_MINING_TAG;
		
		--f:UseConfig( "blue_devil" );
		--f.petTag = PET_BLUE_DEVIL_TAG;
	elseif idx==5 then
		f:UseConfig( "fly_dragon" );
		f.petTag = PET_FLY_DRAGON_TAG;
		
	elseif idx==6 then
		f:UseConfig( "boss" );
		f.petTag = BOSS_TAG;
		
		--f:UseConfig( "blue_devil" );
		--f.petTag = PET_BLUE_DEVIL_TAG;
	end	
end
