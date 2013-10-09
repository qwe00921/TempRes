--------------------------------------------------------------
-- FileName:    card_skill_bar.lua
-- BaseClass:   hp_bar
-- author:      zhangwq, 2013/08/14
-- purpose:     卡牌战斗：技能条类（多实例）
--------------------------------------------------------------

card_skill_bar = hp_bar:new();
local p = card_skill_bar;
local super = hp_bar;

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

--初始化
function p:Init( parentNode, in_life, in_lifeMax )
    --设置图片
    local picBg = GetPictureByAni( "lancer.hpbar_v2", 0 );
    local picFg = GetPictureByAni( "lancer.hpbar_v2", 1 );

    self.node:SetPicture( picBg, picFg );
    self.life = in_life;
    self.maxLife = in_lifeMax;
    
    local parentSize = parentNode:GetFrameSize();
    local picBgSize = picBg:GetSize();
    
    local w = picBgSize.w;
    local h = picBgSize.h;
    local x = (parentSize.w - w)/2;
    local y = -h * 0.8;
    --local x = (1.0 - rate) * 0.5 * w;
    --local y = -h * 0.8;
    
    --设置尺寸
    self.node:SetFrameRect( CCRectMake(x, y, w, h));
    self.node:SetFgTransform( 1, 1, 0, 0 );
    
    local pos=self.node:GetFramePos();
    pos.y = pos.y - UIOffsetY(30);
    self.node:SetFramePosXY(pos.x, pos.y);
    
    --条属性
    self.node:SetTextFontSize( FontSize(6));
    self.node:SetTextFontColor( ccc4(255,255,255,255));
    self.node:SetStart(0);
    self.node:SetNoText(2);
    self.node:SetTotal( in_lifeMax );
    self.node:SetProcess( in_life );
end