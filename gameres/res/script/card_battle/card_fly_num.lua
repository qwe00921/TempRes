--------------------------------------------------------------
-- FileName: 	card_fly_num.lua
-- BaseClass:   fly_num
-- author:		zhangwq, 2013/08/14
-- purpose:		����ս���ࣺ���������ࣨ��������ƮѪ��ħ������ֵ�ȣ�
--------------------------------------------------------------

card_fly_num = fly_num:new();
local p = card_fly_num;
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
