--------------------------------------------------------------
-- FileName: 	bullet.lua
-- BaseClass:   bullet
-- author:		zhangwq, 2013/06/20
-- purpose:		�ӵ��ࣨ��ʵ����
--------------------------------------------------------------

x_bullet = bullet:new();
local p = x_bullet;
local super = bullet;


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
