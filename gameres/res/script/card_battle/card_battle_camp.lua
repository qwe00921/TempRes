--------------------------------------------------------------
-- FileName: 	card_battle_camp.lua
-- BaseClass:   battle_camp
-- author:		zhangwq, 2013/08/14
-- purpose:		��ս��Ӫ����ʵ����
--------------------------------------------------------------

card_battle_camp = battle_camp:new();
local p = card_battle_camp;
local super = battle_camp;


function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
    super.ctor(self);
end

--��ȡ���fighters
function p:GetAliveFighters()
	local t = {}
	for k,v in ipairs(self.fighters) do
		if v ~= nil and (not v.isDead) and v:CheckTmpLife() then
			t[#t+1] = v;
		end
	end
	return t;
end

--���սʿ
function p:AddFighters( uiArray, fighters )
	--for i=1,#uiArray do
	for i=1,#fighters do
		local uiTag = uiArray[i];
		local fighter = fighters[i];
		if fighter.id ~= nil then
    		local node = GetPlayer( card_battle_mgr.uiLayer, uiTag );
            if node == nil then
                WriteCon( "get player node failed" );
                return;
            end
            
            local f = card_fighter:new();
            self.fighters[#self.fighters+1] = f;
            
            --սʿ���Գ�ʹ��
            f.idFighter = fighter.id
            f.camp = self.idCamp;
			
			--@cheat
			if f.camp == E_CARD_CAMP_HERO then
				f.life = 1000;
				f.lifeMax = 1000;			
			else
				f.life = fighter.hp;
				f.lifeMax = fighter.hp;
			end
            
            f:Init( uiTag, node, self.idCamp );
        
            self:SetFighterConfig( f, i );
            f:standby();
            f:GetPlayerNode():AddActionEffect( "card_battle_cmb.card_scale" );
            
            if self:IsHeroCamp() then
                node:SetZOrder( E_BATTLE_Z_HERO_FIGHTER );
                f:SetLookAt( E_LOOKAT_RIGHT );
            else
                node:SetZOrder( E_BATTLE_Z_ENEMY_FIGHTER );
                f:SetLookAt( E_LOOKAT_LEFT );
            end
            node:SetId( tonumber(f.idFighter));
            node:SetLuaDelegate( card_battle_mgr.OnClickFighter );      
		end
	end
end

--����fighter����
function p:SetFighterConfig( f, idx )
	if f == nil then return end;
	local t = {
	   10100301,30700702,10100303,10100304,10100402,
	   10100401,10100403,10100404,20400101,20400102,
	   20400103,20400104,30700701,10100302,30700703,
	   30700704,30700801,30700802,30700803,30700804
	   };
	f:UseConfig( string.format("%d", t[idx]) );
	f.UseConfig = t[idx];
	--[[
	--@override:������,���س�������
	if false then
		f:UseConfig( "fly_dragon" );
		f.petTag = PET_FLY_DRAGON_TAG;
		return;
	end
	
	if idx==1 then
		f:UseConfig( "blue_devil" );
		f.petTag = PET_BLUE_DEVIL_TAG;
	elseif idx==2 then
		f:UseConfig( "fly_dragon" );
		f.petTag = PET_FLY_DRAGON_TAG;
		
		--f:UseConfig( "blue_devil" );
		--f.petTag = PET_BLUE_DEVIL_TAG;
		
	elseif idx==3 then
		f:UseConfig( "blue_devil" );
		f.petTag = PET_BLUE_DEVIL_TAG;
	elseif idx==4 then
		f:UseConfig( "mining" );
		f.petTag = PET_MINING_TAG;
		
		--f:UseConfig( "blue_devil" );
		--f.petTag = PET_BLUE_DEVIL_TAG;
	elseif idx==5 then
		f:UseConfig( "fly_dragon" );
		f.petTag = PET_FLY_DRAGON_TAG;
		
		--f:UseConfig( "blue_devil" );
		--f.petTag = PET_BLUE_DEVIL_TAG;
	end	
	--]]
end
