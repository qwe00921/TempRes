--------------------------------------------------------------
-- FileName: 	hud.lua
-- author:		zhangwq, 2013/06/02
-- purpose:		hud辅助功能
--------------------------------------------------------------

hud = {}
local p = hud;

local imageMask = nil;
local hudNode = nil;

--淡入
function p.FadeIn()
	p.GetImageMask():AddActionEffect( "lancer.fadeout" ); --fadeout
end

--淡出
function p.FadeOut()
	p.GetImageMask():AddActionEffect( "lancer.fadein" ); --fadein	
end

--获取hud节点
function p.GetNode()
	if p.hudNode == nil then
		p.hudNode = GetHudLayer();
	end
	return p.hudNode;
end

--添加蒙版图片
function p.GetImageMask()
	if p.imageMask == nil then
		local imageMask = createNDUIImage();
		imageMask:Init();
		imageMask:SetFrameRectFull();
	
		local pic = GetPictureByAni("lancer.mask", 0); 
		imageMask:SetPicture( pic );
		p.GetNode():AddChildZ( imageMask, 1 );
		p.imageMask = imageMask;
	end
	return p.imageMask;
end

