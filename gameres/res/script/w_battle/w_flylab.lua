

--------------------------------------------------------------
-- FileName: 	w_flyLab.lua
-- BaseClass:   fly_num
-- author:		csd, 2013/06/20
-- purpose:		���ַɳ�
--------------------------------------------------------------

w_flyLab = {};
local p = w_flyLab;



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
    self.ownerNode = nil;
    self.imageNode = nil;
    self.offsetX = 0;
    self.offsetY = 0;

end

function p:Init()
	self:CreateImageNode();
	self.offsetX = 0;
	self.offsetY = -20;
	self.isInited = true;
end;

function p:GetNode()
	return self.imageNode;
end;

function p:CreateImageNode()
	if self.imageNode == nil then
		self.imageNode = createNDUIImage();
		self.imageNode:Init();
		--self.imageNode:SetFramePosXY(0,0);
		--self.imageNode:SetFrameSize(50,50);
		self.imageNode:SetVisible( false );
	end
end

--���ýڵ�
function p:SetOwnerNode( ownerNode )
    self.ownerNode = ownerNode;
end

--����λ��ƫ��
function p:SetOffset( x, y )
	self.offsetX = UIOffsetX(x);
	self.offsetY = UIOffsetY(y);
end

--Ʈ����ֵ
function p:PlayLab( ltype )
  
    --����ͼƬ
	local lPicture = nil;
	if ltype == 1 then
		lPicture = GetPictureByAni("w_battle_res.crite",0);
	else
		lPicture = GetPictureByAni("w_battle_res.speak",0);
	end
    --self.imageNode:SetScale(1.0f);
    self.imageNode:SetPicture( lPicture );
    self.imageNode:ResizeToFitPicture();
    self.imageNode:SetScale(5.0f);
    
    --���Ŷ���
    self.imageNode:SetVisible( true );
    self.imageNode:SetOpacity( 0 );
    self.imageNode:SetFramePosXY( self.offsetX, self.offsetY + UIOffsetY(60));
    self:AddAction();
end

--��actionЧ��
function p:AddAction()
    --self.imageNode:AddActionEffect( "lancer_cmb.flynum" );
    ----self.imageNode:AddActionEffect( "lancer.flynum" );
    self.imageNode:AddActionEffect( "lancer_cmb.flynum_v2" );
end

