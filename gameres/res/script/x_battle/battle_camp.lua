--------------------------------------------------------------
-- FileName: 	battle_camp.lua
-- author:		zhangwq, 2013/05/22
-- purpose:		��ս��Ӫ����ʵ����
--------------------------------------------------------------

battle_camp = {}
local p = battle_camp;

function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	
	o:ctor();
	o.idCamp = 0;
	o.fighters = {}
	return o;
end

--���캯��
function p:ctor()
    self.idCamp = 0;
    self.fighters = {}
end

--�Ƿ�hero��Ӫ
function p:IsHeroCamp()
	return self.idCamp == E_CARD_CAMP_HERO;
end

function p:AddFithersJumpEffect()
end

--ȡfighter����
function p:GetFighterCount()
	return #self.fighters;
end

--ȡ��N��fighter����1��ʼ��
function p:GetFighterAt( idx )
	return self.fighters[idx];
end

--ȡ��һ��fighter
function p:GetFirstFighter()
	return self.fighters[1];
end

--���սʿ
function p:AddFighters( uiArray )
	for i=1,#uiArray do
		local uiTag = uiArray[i];
		local node = GetImage( battle_mgr.uiLayer, uiTag );
		
		local f = fighter:new();
		f:Init( uiTag, node, self.idCamp );
		f:SetFighterPic();
		
		self.fighters[#self.fighters + 1] = f;
		
		if self.idCamp == E_CARD_CAMP_HERO then
			node:SetZOrder( E_BATTLE_Z_HERO_FIGHTER );
		else
			node:SetZOrder( E_BATTLE_Z_ENEMY_FIGHTER );
		end
	end
end

--��ȡ���սʿ
function p:GetRandomFighter()
	local f = self.fighters[ math.random(1,5) ];
	if f == nil then
		WriteCon( "get random fighter err" );
	end
	return f;
end

--��ȡ���սʿ2��
function p:GetRandomFighter_2()
	local f1 = self.fighters[ math.random(1,2) ];
	local f2 = self.fighters[ math.random(3,4) ];
	
	if f1 == nil or f2 == nil then
		WriteCon( "get random fighter err" );
	end
	return f1,f2;
end

--����fighter
function p:FindFighter(id)
	local count = self:GetFighterCount();
	for i = 1, count do
		local fighter = self:GetFighterAt(i);
		if fighter ~= nil and fighter:GetId() == id then
			return fighter;
		end
	end
	return nil;
end

--�Ƿ�����fighter������
function p:IsAllFighterDead()
	local count = self:GetFighterCount();
	for i = 1, count do
		local fighter = self:GetFighterAt(i);
		if fighter ~= nil and fighter:IsAlive() then
			return false;
		end
	end
	return true;
end

function p.AddAllRandomTimeJumpEffect()
end

function p:GetAliveFighters()
	local t = {}
	for k,v in ipairs(self.fighters) do
		if not v.isDead then
			t[#t+1] = v;
		end
	end
	return t;
end