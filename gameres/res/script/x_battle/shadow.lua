--[[
	File name : shadow.lua
	Class function: 所有移动物件的脚底阴影
	Author : 郭浩
	Date : 2013/10/31
--]]

shadow = {}
local p = shadow;

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

function p:Init(strFx,pParentNode)
	local pic = GetPictureByAni(strFx, 0 );
	local pNode = createNDUIImage();
	pNode:Init();
	pNode:SetPicture(pic);
	
	m_kTargetRoleNode = pParentNode;
	
	local parentSize = pParentNode:GetFrameSize();
	local kShadowPicSize = pic:GetSize();
	
	local w = parentSize.w * 0.4;
	local h = parentSize.h * 0.15;
	local x = (parentSize.w - w) / 2;
	local y = parentSize.h * 0.8;

	pNode:SetFramePosXY(x,y);
	pNode:SetFrameSize(w,h);
	
	self.m_kNode = pNode;
	self.m_kLocalPicture = pic;
	
	return true;
end