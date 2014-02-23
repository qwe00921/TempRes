--------------------------------------------------------------
-- FileName: 	effect_num.lua
-- BaseClass:   effect_num
-- author:		
-- purpose:		特效经验字体
--------------------------------------------------------------

effect_num = fly_num:new();
local p = effect_num;
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
	
	self.m_size = CCSizeMake(10,10);
	self.m_strNumberPath = "effect.num_level";
	self.m_scale = 1.0f;
	self.m_fBestScale = 12.0 / 18.0;
	self.m_strOptPath = nil;
	self.m_nNumCount = 0;
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

function p:SetSize(kSize)
	self.m_size = kSize;
end

--设置图片路径
function p:SetNumFont()
	self.m_strNumberPath = "effect.num_font";
	self.m_strOptPath = "effect.opt_effect";
end

--根据数值位数设置偏移
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

function p:SetHeight(h)
	self.m_size = CCSizeMake(self.m_fBestScale * h,h);
end

function p:PushNum( num )
	local numStr = tostring(num);
	local len = string.len(numStr);
	self.m_nNumCount = len;
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
	
	--push数字图片
	self:PushNum( num );
	self:AdjustOffset( num );
	
	--设置图片
	local pCenter = CCPointMake(self.ownerNode:GetFrameSize().w / 2.0,self.ownerNode:GetFrameSize().h / 2.0);
	self.imageNode:SetScale(self.m_scale);
	self.imageNode:SetFrameSize(self.m_size.w * self.m_nNumCount,self.m_size.h);
	self.imageNode:SetCenterPos(pCenter);
	self.imageNode:SetPicture( self.comboPicture );
	
	--self.imageNode:ResizeToFitPicture();
	
	--播放动画
	self.imageNode:SetVisible( true );
	--self.imageNode:SetFramePosXY( self.offsetX, self.offsetY);
end

