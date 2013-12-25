--[[
	File name : shadow.lua
	Class function: 所有移动物件的脚底阴影
	Author : 郭浩
	Date : 2013/10/31
--]]

w_shadow = {}
local p = w_shadow;

--创建新实例
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	return o;
end

function p:ctor()
	self.m_kPosition = nil;
	self.m_strFx = nil;
	self.m_kLocalPicture = nil;
	self.m_nX = nil;
	self.m_nY = nil;
	self.m_nWidth = nil;
	self.m_nHeight = nil;
	self.m_kTargetRoleNode = nil;
	self.m_kNode = nil;
end

function p:GetNode()
	return self.m_kNode;
end

function p:MoveTo( playerNodePos, targetPos)
	if self.m_kNode == nil then
		WriteCon( "fighter node nil" );
		return nil;
	end
	
	local duration = 0;
	local cmd = nil;
	--local fx = "x.hero_atk";
	local fx = "x_cmb.hero_atk";
	
	local nOX = playerNodePos.x;
	local nOY = playerNodePos.y;
	local nTX = targetPos.x;
	local nTY = targetPos.y;
	
	local x = nTX - nOX;
	local y = nTY - nOY;

	-- cmd with var
	cmd = battle_show.AddActionEffect_ToParallelSequence( 0.2, self.m_kNode, fx);
	local varEnv = cmd:GetVarEnv();
	varEnv:SetFloat( "$1", x );
	varEnv:SetFloat( "$2", y );
	
	return cmd;
end

function p:MoveToEx(targetVector)
	if self.m_kNode == nil then
		WriteCon( "fighter node nil" );
		return nil;
	end
	
	local duration = 0;
	local cmd = nil;
	--local fx = "x.hero_atk";
	local fx = "x_cmb.hero_atk";
	
	local nTX = targetVector.x;
	local nTY = targetVector.y;
	
	local x = nTX;
	local y = nTY;

	-- cmd with var
	cmd = battle_show.AddActionEffect_ToParallelSequence( 0, self.m_kNode, fx);
	local varEnv = cmd:GetVarEnv();
	varEnv:SetFloat( "$1", x );
	varEnv:SetFloat( "$2", y );
	
	return cmd;
end

function p:Init(strFx,kParentNode)
	local pic = GetPictureByAni(strFx, 0 );
	local pNode = createNDUIImage();
	pNode:Init();
	pNode:SetPicture(pic);
	
	m_kTargetRoleNode = kParentNode;
	
	local kParentPos = kParentNode:GetFramePos();
	local kParentSize = kParentNode:GetFrameSize();
	local kShadowPicSize = pic:GetSize();
	
	local w = kParentSize.w * 0.4;
	local h = kParentSize.h * 0.15;
	local x = kParentPos.x + (kParentSize.w - w) / 2 - 5;
	local y = kParentPos.y + kParentSize.h * 0.7;

	pNode:SetFramePosXY(x,y);
	pNode:SetFrameSize(w,h);

	pNode:SetIsShadow(true);
	
	self.m_kNode = pNode;
	self.m_kLocalPicture = pic;
	
	return pNode;
end