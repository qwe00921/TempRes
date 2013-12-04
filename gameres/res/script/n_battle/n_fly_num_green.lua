--------------------------------------------------------------
-- FileName:    n_fly_num_green.lua
-- BaseClass:   fly_num
-- author:      hst, 2013/09/27
-- purpose:     卡牌战斗类：飞行数字类（可用增益状态）
--------------------------------------------------------------

n_fly_num_green = fly_num:new();
local p = n_fly_num_green;
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

--初始化数字图片
function p:InitPicNum()
    self.picNum["0"] = GetPictureByAni("effect.num_green", 0);
    self.picNum["1"] = GetPictureByAni("effect.num_green", 1);
    self.picNum["2"] = GetPictureByAni("effect.num_green", 2);
    self.picNum["3"] = GetPictureByAni("effect.num_green", 3);
    self.picNum["4"] = GetPictureByAni("effect.num_green", 4);
    
    self.picNum["5"] = GetPictureByAni("effect.num_green", 5);
    self.picNum["6"] = GetPictureByAni("effect.num_green", 6);
    self.picNum["7"] = GetPictureByAni("effect.num_green", 7);
    self.picNum["8"] = GetPictureByAni("effect.num_green", 8);
    self.picNum["9"] = GetPictureByAni("effect.num_green", 9);  
end