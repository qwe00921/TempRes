--[[
	File name : shadow.lua
	Class function: �����ƶ�����Ľŵ���Ӱ
	Author : ����
	Date : 2013/10/31
--]]

shadow = {}
local p = shadow;

--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	return o;
end

function p:ctor()
	
end