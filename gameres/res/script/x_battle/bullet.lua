--------------------------------------------------------------
-- FileName: 	bullet.lua
-- author:		zhangwq, 2013/05/22
-- purpose:		子弹类（多实例）
--------------------------------------------------------------

bullet = {}
local p = bullet;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
    self.node = nil;
	self.bulletConfig = nil;
end
	
function p:UseConfig( title )
	self.bulletConfig = GetBullet( title );
	if self.bulletConfig == nil then
		WriteConErr( string.format("use bullet config err: %s", title));
	else
		self:SetEffectAni(self.bulletConfig:GetAni());
	end
end

function p:GetConfig()
	return self.bulletConfig;
end

--获取距离扣除数
function p:GetSubDistance()
	if self.bulletConfig ~= nil then
		return self.bulletConfig:GetSubDistance();
	else
		return 0.0f;
	end
end

--获取起点偏移量
function p:GetStartOffset()
	if self.bulletConfig ~= nil then
		return self.bulletConfig:GetStartOffset();
	else
		return 0.0f;
	end
end
	
--创建node
function p:AddToBattleLayer()
	-- create node for bullet
	--node = createNDUINode();
	node = createNDBullet();
	if node == nil then
		WriteConErr( "create bullet failed" );
		return nil;
	end

	node:Initialization();
	node:SetFramePosXY( 0, 0 );
	node:SetVisible( false );
	
	if E_DEMO_VER == 2 then
	    x_battle_mgr.uiLayer:AddChildZTag( node, E_BATTLE_Z_BULLET, E_BATTLE_TAG_BULLET );
    elseif E_DEMO_VER == 1 then
        battle_mgr.uiLayer:AddChildZTag( node, E_BATTLE_Z_BULLET, E_BATTLE_TAG_BULLET );
    elseif E_DEMO_VER == 3 then
    	card_battle_mgr.uiLayer:AddChildZTag( node, E_BATTLE_Z_BULLET, E_BATTLE_TAG_BULLET );    
	end
	return node;
end

--设置子弹特效
function p:SetEffect( bulletType )
	if bulletType == 1 then
		node:AddFgEffect( "combo.bullet" );
	elseif bulletType == 2 then
		node:AddFgEffect( "lancer.hero_bullet" );
	elseif bulletType == 3 then
		node:AddFgEffect( "lancer.hero_bullet6" );--龙卷风	
	elseif bulletType == 4 then
		node:AddFgEffect( "x.tuc" );		
	end
end

--设置子弹特效_v2
function p:SetEffectAni( aniTitle )
	if nil == aniTitle then 
		return ;
	end
	node:AddFgEffect( aniTitle );
end

--设置子弹特效
function p:SetEffectEx( idx )
	if idx >= 1 and idx <= 5 then
		node:AddFgEffect( "lancer.hero_bullet"..idx );
	end
end

--获取node
function p:GetNode()
	return node;
end

--发射
function p:cmdShoot( atkFighter, targetFighter, seq, byJump )
	-- set bullet start pos
	local atkPos = atkFighter:GetNode():GetCenterPos();
	--node:SetVisible( true );
	node:SetFrameSize(1,1);
	node:SetFramePos( atkPos );

	-- distance
	local targetPos = targetFighter:GetNode():GetCenterPos();
	local x = targetPos.x - atkPos.x;
	local y = targetPos.y - atkPos.y;
	local distance = (x ^ 2 + y ^ 2) ^ 0.5;
	
	-- calc start offset
	local startOffset = self:GetStartOffset();
	local offsetX = x * startOffset / distance;
	local offsetY = y * startOffset / distance;
	node:SetFramePosXY( atkPos.x + offsetX, atkPos.y + offsetY );
	
	-- sub distance
	local percent = (distance - self:GetSubDistance()) / distance;
	distance = distance * percent;
	x = x * percent;
	y = y * percent;
	
	-- choose fx
	local fx = "";
	if byJump then
		fx = "lancer_cmb.bullet_shoot_jump";
	else
		fx = "lancer.bullet_shoot";
	end
	
	-- cmd with var
	local cmd = battle_show.AddActionEffect_ToSequence( 0, node, fx, seq );
	local varEnv = cmd:GetVarEnv();
	varEnv:SetFloat( "$1", x );
	varEnv:SetFloat( "$2", y );
	varEnv:SetFloat( "$3", distance * 0.4 );
	
	return cmd;
end


--隐藏子弹
function p:cmdSetVisible( isVisible, seq )
	local cmd = createCommandInstant_Misc():SetVisible( node, isVisible );
	if cmd ~= nil and seq ~= nil then
		seq:AddCommand( cmd );
	end	
	return cmd;
end
