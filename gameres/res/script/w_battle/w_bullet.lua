--------------------------------------------------------------
-- FileName: 	bullet.lua
-- BaseClass:   bullet
-- author:		zhangwq, 2013/06/20
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