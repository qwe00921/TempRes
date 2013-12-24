--------------------------------------------------------------
-- FileName: 	fly_num.lua
-- BaseClass:   fly_num
-- author:		zhangwq, 2013/06/20
-- purpose:		���������ࣨ��������ƮѪ��ħ������ֵ�ȣ�
--------------------------------------------------------------

n_fly_num = fly_num:new();
local p = n_fly_num;
local super = fly_num;


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

--��ʼ������ͼƬ
function p:InitPicNum()
    self.picNum["0"] = GetPictureByAni("effect.num_damage", 0);
    self.picNum["1"] = GetPictureByAni("effect.num_damage", 1);
    self.picNum["2"] = GetPictureByAni("effect.num_damage", 2);
    self.picNum["3"] = GetPictureByAni("effect.num_damage", 3);
    self.picNum["4"] = GetPictureByAni("effect.num_damage", 4);
    self.picNum["5"] = GetPictureByAni("effect.num_damage", 5);
    self.picNum["6"] = GetPictureByAni("effect.num_damage", 6);
    self.picNum["7"] = GetPictureByAni("effect.num_damage", 7);
    self.picNum["8"] = GetPictureByAni("effect.num_damage", 8);
    self.picNum["9"] = GetPictureByAni("effect.num_damage", 9);    
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
    self.imageNode:SetFramePosXY( self.offsetX, self.offsetY + UIOffsetY(60));
    self:AddAction();
end

--��actionЧ��
function p:AddAction()
    --self.imageNode:AddActionEffect( "lancer_cmb.flynum" );
    ----self.imageNode:AddActionEffect( "lancer.flynum" );
    self.imageNode:AddActionEffect( "lancer_cmb.flynum_v2" );
end

