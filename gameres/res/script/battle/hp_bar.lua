--------------------------------------------------------------
-- FileName: 	hp_bar.lua
-- author:		2013/05/23
-- purpose:		血条类（多实例）
-- 注意：		这个类会有多个实例，注意用法！
--------------------------------------------------------------

hp_bar = {}
local p = hp_bar;

function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	
	o:ctor();
	--o:CreateExpNode();
	return o;
end

--构造函数
function p:ctor()
    self.node = nil;
    self.life = 0;
    self.lifeMax = 0;  
end

--创建Exp节点
function p:CreateExpNode()
	local nodeExp = createNDUIExp();
	if nodeExp ~= nil then
		nodeExp:Init("","");
		self.node = nodeExp;
	end
end

--获取节点
function p:GetNode()
	return self.node;
end

--设置节点取代默认节点（如boss血条）
function p:SetNode( in_node )
	if self.node ~= nil then
		self.node:RemoveFromParent(true);
		self.node = nil;
	end
	self.node = in_node;
end

--初始化
function p:InitForBoss( parentNode, in_life, in_lifeMax )
	self.life = in_life;
	self.maxLife = in_lifeMax;
	
	--设置尺寸
	--self.node:SetFgTransform( 1, 1, 0, 0 );
	
	--条属性
	self.node:SetTextFontSize( FontSize(12));
	self.node:SetTextFontColor( ccc4(255,255,255,255));
	self.node:SetStart(0);
	self.node:SetTotal( in_lifeMax );
	self.node:SetProcess( in_life );
end

--初始化
function p:Init( parentNode, in_life, in_lifeMax )
	--设置图片
	local picBg = GetPictureByAni( "lancer.hpbar", 0 );
	local picFg = GetPictureByAni( "lancer.hpbar", 1 );

	self.node:SetPicture( picBg, picFg );
	self.life = in_life;
	self.maxLife = in_lifeMax;
	
	local parentSize = parentNode:GetFrameSize();
	local picBgSize = picBg:GetSize();
	
	local w = picBgSize.w;
	local h = picBgSize.h;
	local x = 0;
	local y = -h * 0.8;
	--local x = (1.0 - rate) * 0.5 * w;
	--local y = -h * 0.8;
	
	--设置尺寸
	self.node:SetFrameRect( CCRectMake(x, y, w, h));
	self.node:SetFgTransform( 0.62, 0.13636, 43, 20 );
	
	--条属性
	self.node:SetTextFontSize( FontSize(6));
	self.node:SetTextFontColor( ccc4(255,255,255,255));
	self.node:SetStart(0);
	self.node:SetTextStyle(2);
	self.node:SetTotal( in_lifeMax );
	self.node:SetProcess( in_life );
end

--设置血量
function p:SetLife( in_life )
	self.life = in_life;
	if self.node ~= nil then
		self.node:SetProcess( self.life );	
	end
end

--设置血量上限
function p:SetLifeMax( in_lifeMax )
	self.lifeMax = in_lifeMax;
	if self.node ~= nil then
		self.node:SetTotal( self.lifeMax );	
	end
end