--------------------------------------------------------------
-- FileName: 	fly_num.lua
-- BaseClass:   fly_num
-- author:		zhangwq, 2013/06/20
-- purpose:		���������ࣨ��������ƮѪ��ħ������ֵ�ȣ�
--------------------------------------------------------------

n_fly_num = fly_num:new();
local p = n_fly_num;
local super = fly_num;


--������ʵ��
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	return o;
end

--���캯��
function p:ctor()
    super.ctor(self);
end
