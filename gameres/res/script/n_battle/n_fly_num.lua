--------------------------------------------------------------
-- FileName: 	fly_num.lua
-- BaseClass:   fly_num
-- author:		zhangwq, 2013/06/20
-- purpose:		飞行数字类（可用诸如飘血、魔、经验值等）
--------------------------------------------------------------

n_fly_num = fly_num:new();
local p = n_fly_num;
local super = fly_num;


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
