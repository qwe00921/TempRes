--------------------------------------------------------------
-- FileName: 	hud.lua
-- author:		zhangwq, 2013/06/02
-- purpose:		hud��������
--------------------------------------------------------------

hud = {}
local p = hud;

local imageMask = nil;
local hudNode = nil;

--����
function p.FadeIn()
	p.GetImageMask():AddActionEffect( "lancer.fadeout" ); --fadeout
end

--����
function p.FadeOut()
	p.GetImageMask():AddActionEffect( "lancer.fadein" ); --fadein	
end

--��ȡhud�ڵ�
function p.GetNode()
	if p.hudNode == nil then
		p.hudNode = GetHudLayer();
	end
	return p.hudNode;
end

--����ɰ�ͼƬ
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

