--------------------------------------------------------------
-- FileName: 	card_bullet.lua
-- BaseClass:   bullet
-- author:		zhangwq, 2013/08/14
-- purpose:		����ս�����ӵ��ࣨ��ʵ����
--------------------------------------------------------------

card_bullet = bullet:new();
local p = card_bullet;
local super = bullet;


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
