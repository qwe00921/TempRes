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
	
	self.m_strNumberPath = "effect.num_level";
end

--根据数值位数设置偏移
function p:AdjustOffset( num )
	if num >= 100 then
		self:SetOffset( 0, 2 );
	elseif num >= 10 then
		self:SetOffset( 5, 2 );
	else
		self:SetOffset( 15, 2 );
	end
end

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
	
	--播放动画
	self.imageNode:SetVisible( true );
	self.imageNode:SetFramePosXY( self.offsetX, self.offsetY);
end

