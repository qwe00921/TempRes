--------------------------------------------------------------
-- FileName: 	fly_num.lua
-- author:		zhangwq, 2013/06/03
-- purpose:		���������ࣨ��������ƮѪ��ħ������ֵ�ȣ�
-- ע�⣺		�������ж��ʵ����ע���÷���
--------------------------------------------------------------

fly_num = {}
local p = fly_num;


--������ʵ��
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	
	o:ctor();
	o.picNum = {}
	return o;
end

--���캯��
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
--��ʼ��
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

--��ȡ�ڵ�
function p:GetNode()
	return self.imageNode;
end

--���ýڵ�
function p:SetOwnerNode( ownerNode )
    self.ownerNode = ownerNode;
end

--�������ͼƬ
function p:CreateComboPicture()
	self.comboPicture = createNDPictureCombo();	
	self.comboPicture:SetDelFlag( false );
end

--����ͼ��ڵ�
function p:CreateImageNode()
	if self.imageNode == nil then
		self.imageNode = createNDUIImage();
		self.imageNode:Init();
		self.imageNode:SetFramePosXY(0,0);
		self.imageNode:SetFrameSize(10,10);
		self.imageNode:SetVisible( false );
	end
end

--��ʼ������ͼƬ
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

--������ֵ��ȡͼƬ(num=[0,9])
function p:GetPicByNum( num )
	if num >= 0 and num <= 9 then
		return self.picNum[""..num];
	else
		return nil;
	end
end

--������ֵλ������ƫ��
function p:AdjustOffset( num )
	if num >= 100 then
		self:SetOffset( -10, -50 );
	elseif num >= 10 then
		self:SetOffset( 5, -50 );
	else
		self:SetOffset( 15, -50 );
	end
end

--����λ��ƫ��
function p:SetOffset( x, y )
	self.offsetX = UIOffsetX(x);
	self.offsetY = UIOffsetY(y);
end

--����push����ͼƬ
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

--Ʈ����ֵ
function p:PlayNum( num )
	local nIntNumber = math.floor(num)
	
	if not self.isInited then return end
	if self.ownerNode == nil then return end
	
	--push����ͼƬ
	self:PushNum( nIntNumber );
	self:AdjustOffset( nIntNumber );
	
	--����ͼƬ
	self.imageNode:SetScale(1.0f);
	self.imageNode:SetPicture( self.comboPicture );
	self.imageNode:ResizeToFitPicture();
	self.imageNode:SetScale(0.7f);
	
	--���Ŷ���
	self.imageNode:SetVisible( true );
	self.imageNode:SetOpacity( 0 );
	self.imageNode:SetFramePosXY( self.offsetX, self.offsetY + UIOffsetY(20));
	self:AddAction();
end

--��actionЧ��
function p:AddAction()
	--self.imageNode:AddActionEffect( "lancer_cmb.flynum" );
	----self.imageNode:AddActionEffect( "lancer.flynum" );
	self.imageNode:AddActionEffect( "lancer_cmb.flynum_v2" );
end