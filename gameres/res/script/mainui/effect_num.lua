--------------------------------------------------------------
-- FileName: 	effect_num.lua
-- BaseClass:   effect_num
-- author:		
-- purpose:		��Ч��������
--------------------------------------------------------------

effect_num = fly_num:new();
local p = effect_num;
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
	
	self.m_strNumberPath = "effect.num_level";
	self.m_scale = 1.0f;
	self.m_strOptPath = nil;
end

function p:Init()
	super.Init(self);
	
	self.offsetX = 0;
	self.offsetY = 0;
	
	if self.m_strOptPath then
		self.picNum["div"] = GetPictureByAni(self.m_strOptPath, 0);	
		self.picNum["add"] = GetPictureByAni(self.m_strOptPath, 1);	
		self.picNum["sub"] = GetPictureByAni(self.m_strOptPath, 2);
	end
end

function p:SetScale( nScale )
	self.m_scale = nScale;
end

--����ͼƬ·��
function p:SetNumFont()
	self.m_strNumberPath = "effect.num_font";
	self.m_strOptPath = "effect.opt_effect";
end

--������ֵλ������ƫ��
function p:AdjustOffset( num )
	--[[
	if num >= 100 then
		self:SetOffset( 0, 2 );
	elseif num >= 10 then
		self:SetOffset( 5, 2 );
	else
		self:SetOffset( 15, 2 );
	end
	--]]
end

function p:GetPicByNum( num )
	if num == "/" then
		num = "div";
	elseif num == "+" then
		num = "add";
	elseif num == "-" then
		num = "sub";
	end
	return self.picNum[tostring(num)];
end

function p:PushNum( num )
	local numStr = tostring(num);
	local len = string.len(numStr);
	if len > 0 then
		self.comboPicture:ClearPicture( false );
		for i = 1, len do
			local n = string.sub(numStr, i, i );
			self.comboPicture:PushPicture( self:GetPicByNum( n ) );
		end
	end
end

function p:PlayNum( num )
	--local nIntNumber = math.floor(num)
	
	if not self.isInited then return end
	if self.ownerNode == nil then return end
	
	--push����ͼƬ
	self:PushNum( num );
	self:AdjustOffset( num );
	
	--����ͼƬ
	self.imageNode:SetScale(self.m_scale);
	self.imageNode:SetPicture( self.comboPicture );
	self.imageNode:ResizeToFitPicture();
	
	--���Ŷ���
	self.imageNode:SetVisible( true );
	self.imageNode:SetFramePosXY( self.offsetX, self.offsetY);
end

