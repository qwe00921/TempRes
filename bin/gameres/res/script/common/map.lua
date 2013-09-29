--------------------------------------------------------------
-- FileName: 	map.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		容器--哈希表（多实例）
--------------------------------------------------------------

map = {}
local p = map;

--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
end
