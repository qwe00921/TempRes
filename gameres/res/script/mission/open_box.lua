--------------------------------------------------------------
-- FileName: 	open_box.lua
-- author:		hst, 2013/05/29
-- purpose:		open box
--------------------------------------------------------------

open_box = {}
local p = open_box;

p.layer = nil;

--显示UI
function p.ShowUI()	
	local pMainLayer = createNDUILayer();
    if pMainLayer == nil then
        return false;
    end
	
	local pBottomLayer = createNDUILayer();
    if pBottomLayer == nil then
        return false;
    end
	
	local pTopLayer = createNDUILayer();
    if pTopLayer == nil then
        return false;
    end
	
	pTopLayer:Init();
	pTopLayer:SetSwallowTouch(false);
	pTopLayer:SetFrameRectFull();
	
	pBottomLayer:Init();
	pBottomLayer:SetSwallowTouch(false);
	pBottomLayer:SetFrameRectFull();
	
	pMainLayer:Init();
	pMainLayer:SetSwallowTouch(false);
	pMainLayer:SetFrameRectFull();
	
	pMainLayer:AddChildZTag(pTopLayer,0,1);
	pMainLayer:AddChildZTag(pBottomLayer,0,2);
	
	GetUIRoot():AddChildZTag(pMainLayer,0xff,10);
	
    LoadUI("open_box_info.xui", pBottomLayer, nil);
	
    LoadUI("open_box.xui", pTopLayer, nil);
	
	p.layer = pMainLayer;
	
	p.DoEffect(pTopLayer, pBottomLayer);
	
	-- 宝箱关闭按钮，点击屏幕触发
	local closeBtn = createNDUIButton();
	closeBtn:Init();
	closeBtn:SetFrameRectFull();
	pMainLayer:AddChildZ(closeBtn,5);
	closeBtn:SetLuaDelegate(p.OnUIEventBtn);
	
	PlayEffectSoundByName( "sk_openbox.mp3" );--音效
end

function p.DoEffect(pTopLayer, pBottomLayer)	
	--底部信息上移效果
	local openBoxInfoNode = GetImage( pBottomLayer,ui_open_box_info.ID_CTRL_PICTURE_1 );
	if nil == openBoxInfoNode then
        return false;
    end
	local node_x = openBoxInfoNode:GetFramePos().x + UIOffsetX(70);
	pBottomLayer:SetFramePosXY(0,node_x);
	pBottomLayer:AddActionEffect("test.open_box_info_up");
	
	--获得字样的印章效果
	local stampNode = GetImage( pBottomLayer,ui_open_box_info.ID_CTRL_PICTURE_9 );
	local stampNode_xy=stampNode:GetFramePos();
	stampNode:SetFramePosXY(stampNode_xy.x + UIOffsetX(30), stampNode_xy.y + UIOffsetY(30));
	stampNode:AddFgEffect("lancer_cmb.stamp_fx");
	
	--印章模糊效果
    stampNode:AddActionEffect("lancer.openbox_stamp");
    
    --背景图片缩放效果
    openBoxInfoNode:AddActionEffect("lancer.open_box_scale");
	
	--箱子下落效果
	pTopLayer:SetFramePosXY(0, UIOffsetY(-500));
	pTopLayer:AddActionEffect("test.open_box_down");
	
	--开箱子动画
	local boxNode = GetImage( pTopLayer,ui_open_box.ID_CTRL_PICTURE_6 );
	boxNode:AddFgEffect("lancer.open_box_fx_n1");
	boxNode:AddActionEffect("test_cmb.open-box");
	boxNode:AddFgEffect("lancer_cmb.open_box_fx_new");
	
	--卡牌出箱子效果
	local cardNode = GetImage( pTopLayer,ui_open_box.ID_CTRL_PICTURE_10 );
	local cardNode_xy=cardNode:GetFramePos();
	
	--获得卡牌
	--cardNode:SetFramePosXY(cardNode_xy.x,cardNode_xy.y-100);
	--cardNode:AddBgEffect("lancer_cmb.open_box_card_fx");
	
	--获得宝石
	cardNode:SetFramePosXY(cardNode_xy.x,cardNode_xy.y - UIOffsetY(50));
	cardNode:AddBgEffect("lancer_cmb.open_box_emerald");
	
	--删除卡牌从箱子上升效果改为淡入
	--cardNode:AddActionEffect("test.open_box_card_up");
	cardNode:AddActionEffect("test.card_fadein");
		
	--开箱子光效
	local boxGlowFX = GetImage( pTopLayer,ui_open_box.ID_CTRL_PICTURE_3 );
	boxGlowFX:AddFgEffect("lancer_cmb.open_box_star_fx");
end

function p.OnUIEventBtn(uiNode, uiEventType, param)	
    if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end


