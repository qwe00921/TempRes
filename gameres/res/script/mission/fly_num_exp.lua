--------------------------------------------------------------
-- FileName: 	fly_num_exp.lua
-- BaseClass:   fly_num
-- author:		zhangwq, 2013/07/30
-- purpose:		飘经验（任务地图）
--------------------------------------------------------------

fly_num_exp = fly_num:new();
local p = fly_num_exp;
local super = fly_num;


--创建新实例
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--构造函数
function p:ctor()
    super.ctor(self);
end
