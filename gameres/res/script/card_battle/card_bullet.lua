--------------------------------------------------------------
-- FileName: 	card_bullet.lua
-- BaseClass:   bullet
-- author:		zhangwq, 2013/08/14
-- purpose:		卡牌战斗：子弹类（多实例）
--------------------------------------------------------------

card_bullet = bullet:new();
local p = card_bullet;
local super = bullet;


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
