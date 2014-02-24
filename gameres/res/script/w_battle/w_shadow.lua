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
end

function p:MoveToEx(targetVector)
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

	pNode:SetIsShadow(true);
	
	self.m_kNode = pNode;
	self.m_kLocalPicture = pic;
	
	return pNode;
end