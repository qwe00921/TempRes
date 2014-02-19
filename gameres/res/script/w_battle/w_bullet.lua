--------------------------------------------------------------
-- FileName: 	bullet.lua
-- BaseClass:   bullet
-- author:		csd, 2013/12/30
-- purpose:		子弹类（多实例）
--------------------------------------------------------------

w_bullet = bullet:new();
local p = w_bullet;
local super = bullet;

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
    super.ctor(self);
end

--发射     
function p:cmdShootPos( atkFighter, targetPos, seq, byJump )
	-- set bullet start pos
	local atkPos = atkFighter:GetNode():GetCenterPos();
	--node:SetVisible( true );
	node:SetFrameSize(1,1);
	node:SetFramePos( atkPos );

	-- distance
	--local targetPos = targetNode:GetCenterPos();
	--local targetPos = targetFighter:GetNode():GetCenterPos();
	local x = targetPos.x - atkPos.x;
	local y = targetPos.y - atkPos.y;
	local distance = (x ^ 2 + y ^ 2) ^ 0.5;
	
	-- calc start offset
	local startOffset = self:GetStartOffset();
	local offsetX = x * startOffset/distance;
	local offsetY = y * startOffset/distance;
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