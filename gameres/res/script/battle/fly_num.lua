--------------------------------------------------------------
-- FileName: 	fly_num.lua
-- author:		zhangwq, 2013/06/03
-- purpose:		飞行数字类（可用诸如飘血、魔、经验值等）
-- 注意：		这个类会有多个实例，注意用法！
--------------------------------------------------------------

fly_num = {}
local p = fly_num;


--创建新实例
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	
	o:ctor();
	o.picNum = {}
	return o;
end

--构造函数
function p:ctor()
    self.ownerNode = nil;
    self.imageNode = nil;
    self.comboPicture = nil;
	self.m_nType = 0;
    
    self.picNum = {};
    self.isInited = false;
    self.offsetX = 0;
    self.offsetY = 0;
	self.m_strNumberPath = "effect.num";
end

function p:GetType()
	return self.m_nType;
end
--初始化
function p:Init(nType)
	if 1 == nType then
		self.m_nType = nType
		self.m_strNumberPath = "effect.num_stike";
	elseif 2 == nType then
		self.m_strNumberPath = "effect.num_buff";
		self.m_nType = nType;
	end
	
	if not self.isInited then
		self:InitPicNum();
		self:CreateComboPicture();
		self:CreateImageNode();
	end
	
	self.offsetX = 0;
	self.offsetY = -20;
	self.isInited = true;
end

--获取节点
function p:GetNode()
	return self.imageNode;
end

--设置节点
function p:SetOwnerNode( ownerNode )
    self.ownerNode = ownerNode;
end

--创建组合图片
function p:CreateComboPicture()
	self.comboPicture = createNDPictureCombo();	
	self.comboPicture:SetDelFlag( false );
end

--创建图像节点
function p:CreateImageNode()
	if self.imageNode == nil then
		self.imageNode = createNDUIImage();
		self.imageNode:Init();
		self.imageNode:SetFramePosXY(0,0);
		self.imageNode:SetFrameSize(10,10);
		self.imageNode:SetVisible( false );
	end
end

--初始化数字图片
function p:InitPicNum()
	self.picNum["0"] = GetPictureByAni(self.m_strNumberPath, 0);
	self.picNum["1"] = GetPictureByAni(self.m_strNumberPath, 1);
	self.picNum["2"] = GetPictureByAni(self.m_strNumberPath, 2);
	self.picNum["3"] = GetPictureByAni(self.m_strNumberPath, 3);
	self.picNum["4"] = GetPictureByAni(self.m_strNumberPath, 4);
	self.picNum["5"] = GetPictureByAni(self.m_strNumberPath, 5);
	self.picNum["6"] = GetPictureByAni(self.m_strNumberPath, 6);
	self.picNum["7"] = GetPictureByAni(self.m_strNumberPath, 7);
	self.picNum["8"] = GetPictureByAni(self.m_strNumberPath, 8);
	self.picNum["9"] = GetPictureByAni(self.m_strNumberPath, 9);	
end

--根据数值获取图片(num=[0,9])
function p:GetPicByNum( num )
	if num >= 0 and num <= 9 then
		return self.picNum[""..num];
	else
		return nil;
	end
end

--根据数值位数设置偏移
function p:AdjustOffset( num )
	if num >= 100 then
		self:SetOffset( -10, -50 );
	elseif num >= 10 then
		self:SetOffset( 5, -50 );
	else
		self:SetOffset( 15, -50 );
	end
end

--设置位置偏移
function p:SetOffset( x, y )
	self.offsetX = UIOffsetX(x);
	self.offsetY = UIOffsetY(y);
end

--重新push数字图片
function p:PushNum( num )
	if num > 0 and num < 10000 then
		local n1 = math.floor( num / 1000 );
		num = num - n1 * 1000;
		
		local n2 = math.floor( num / 100 );
		num = num - n2 * 100;
		
		local n3 = math.floor( num / 10 );
		num = num - n3 * 10;

		local n4 = num;

		self.comboPicture:ClearPicture( false );
		if n1 > 0 						then self.comboPicture:PushPicture( self:GetPicByNum(n1)) end
		if n2 > 0 or n1 ~= 0 			then self.comboPicture:PushPicture( self:GetPicByNum(n2)) end
		if n3 > 0 or n1 + n2 ~= 0 		then self.comboPicture:PushPicture( self:GetPicByNum(n3)) end
		if n4 > 0 or n1 + n2 + n3 ~= 0 	then self.comboPicture:PushPicture( self:GetPicByNum(n4)) end
	end
end

--飘个数值
function p:PlayNum( num )
	local nIntNumber = math.floor(num)
	
	if not self.isInited then return end
	if self.ownerNode == nil then return end
	
	--push数字图片
	self:PushNum( nIntNumber );
	self:AdjustOffset( nIntNumber );
	
	--设置图片
	self.imageNode:SetScale(1.0f);
	self.imageNode:SetPicture( self.comboPicture );
	self.imageNode:ResizeToFitPicture();
	self.imageNode:SetScale(0.7f);
	
	--播放动画
	self.imageNode:SetVisible( true );
	self.imageNode:SetOpacity( 0 );
	self.imageNode:SetFramePosXY( self.offsetX, self.offsetY + UIOffsetY(20));
	self:AddAction();
end

--加action效果
function p:AddAction()
	--self.imageNode:AddActionEffect( "lancer_cmb.flynum" );
	----self.imageNode:AddActionEffect( "lancer.flynum" );
	self.imageNode:AddActionEffect( "lancer_cmb.flynum_v2" );
end