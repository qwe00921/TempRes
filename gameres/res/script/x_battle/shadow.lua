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
	
end