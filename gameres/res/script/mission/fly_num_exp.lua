--------------------------------------------------------------
-- FileName: 	fly_num_exp.lua
-- BaseClass:   fly_num
-- author:		zhangwq, 2013/07/30
-- purpose:		Ʈ���飨�����ͼ��
--------------------------------------------------------------

fly_num_exp = fly_num:new();
local p = fly_num_exp;
local super = fly_num;


--������ʵ��
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor(); return o;
end

--���캯��
function p:ctor()
    super.ctor(self);
end
