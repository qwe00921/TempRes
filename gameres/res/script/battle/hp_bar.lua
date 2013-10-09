--------------------------------------------------------------
-- FileName: 	hp_bar.lua
-- author:		2013/05/23
-- purpose:		Ѫ���ࣨ��ʵ����
-- ע�⣺		�������ж��ʵ����ע���÷���
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

--���캯��
function p:ctor()
    self.node = nil;
    self.life = 0;
    self.lifeMax = 0;  
end

--����Exp�ڵ�
function p:CreateExpNode()
	local nodeExp = createNDUIExp();
	if nodeExp ~= nil then
		nodeExp:Init("","");
		self.node = nodeExp;
	end
end

--��ȡ�ڵ�
function p:GetNode()
	return self.node;
end

--���ýڵ�ȡ��Ĭ�Ͻڵ㣨��bossѪ����
function p:SetNode( in_node )
	if self.node ~= nil then
		self.node:RemoveFromParent(true);
		self.node = nil;
	end
	self.node = in_node;
end

--��ʼ��
function p:InitForBoss( parentNode, in_life, in_lifeMax )
	self.life = in_life;
	self.maxLife = in_lifeMax;
	
	--���óߴ�
	--self.node:SetFgTransform( 1, 1, 0, 0 );
	
	--������
	self.node:SetTextFontSize( FontSize(12));
	self.node:SetTextFontColor( ccc4(255,255,255,255));
	self.node:SetStart(0);
	self.node:SetTotal( in_lifeMax );
	self.node:SetProcess( in_life );
end

--��ʼ��
function p:Init( parentNode, in_life, in_lifeMax )
	--����ͼƬ
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
	
	--���óߴ�
	self.node:SetFrameRect( CCRectMake(x, y, w, h));
	self.node:SetFgTransform( 0.62, 0.13636, 43, 20 );
	
	--������
	self.node:SetTextFontSize( FontSize(6));
	self.node:SetTextFontColor( ccc4(255,255,255,255));
	self.node:SetStart(0);
	self.node:SetTextStyle(2);
	self.node:SetTotal( in_lifeMax );
	self.node:SetProcess( in_life );
end

--����Ѫ��
function p:SetLife( in_life )
	self.life = in_life;
	if self.node ~= nil then
		self.node:SetProcess( self.life );	
	end
end

--����Ѫ������
function p:SetLifeMax( in_lifeMax )
	self.lifeMax = in_lifeMax;
	if self.node ~= nil then
		self.node:SetTotal( self.lifeMax );	
	end
end