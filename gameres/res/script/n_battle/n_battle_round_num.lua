--------------------------------------------------------------
-- FileName:    n_battle_round_num.lua
-- BaseClass:   fly_num
-- author:      hst, 2013/12/6
-- purpose:     ����ս���ࣺ�غ�����
--------------------------------------------------------------

n_battle_round_num = fly_num:new();
local p = n_battle_round_num;
local super = fly_num;


--������ʵ��
function p:new()
    o = {}
    setmetatable( o, self );
    self.__index = self;
    o:ctor(); return o;
end

--���캯��
function p:ctor()
    super.ctor(self);
end

--��ʹ��imageNode
function p:InitWithImageNode( node )
    if not self.isInited then
        self:CreateComboPicture();
        self:InitPicNum();
        self.isInited = true;
    end
    self.imageNode = node;
end

--��ʼ������ͼƬ
function p:InitPicNum()
    self.picNum["0"] = GetPictureByAni("n.turn_num", 0);
    self.picNum["1"] = GetPictureByAni("n.turn_num", 1);
    self.picNum["2"] = GetPictureByAni("n.turn_num", 2);
    self.picNum["3"] = GetPictureByAni("n.turn_num", 3);
    self.picNum["4"] = GetPictureByAni("n.turn_num", 4);
    
    self.picNum["5"] = GetPictureByAni("n.turn_num", 5);
    self.picNum["6"] = GetPictureByAni("n.turn_num", 6);
    self.picNum["7"] = GetPictureByAni("n.turn_num", 7);
    self.picNum["8"] = GetPictureByAni("n.turn_num", 8);
    self.picNum["9"] = GetPictureByAni("n.turn_num", 9);  
end

--Ʈ����ֵ
function p:PlayNum( num )
    if not self.isInited then return end
    
    --push����ͼƬ
    self:PushNum( num );
    
    --����ͼƬ
    self.imageNode:SetPicture( self.comboPicture );
    self.imageNode:ResizeToFitPicture();
    
    --���Ŷ���
    self:AddAction();
    
end

--��actionЧ��
function p:AddAction()
    self.imageNode:AddActionEffect("n.blow_up");
end