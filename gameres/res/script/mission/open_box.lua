--------------------------------------------------------------
-- FileName: 	open_box.lua
-- author:		hst, 2013/05/29
-- purpose:		open box
--------------------------------------------------------------

open_box = {}
local p = open_box;

p.layer = nil;

--��ʾUI
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
	
	-- ����رհ�ť�������Ļ����
	local closeBtn = createNDUIButton();
	closeBtn:Init();
	closeBtn:SetFrameRectFull();
	pMainLayer:AddChildZ(closeBtn,5);
	closeBtn:SetLuaDelegate(p.OnUIEventBtn);
	
	PlayEffectSoundByName( "sk_openbox.mp3" );--��Ч
end

function p.DoEffect(pTopLayer, pBottomLayer)	
	--�ײ���Ϣ����Ч��
	local openBoxInfoNode = GetImage( pBottomLayer,ui_open_box_info.ID_CTRL_PICTURE_1 );
	if nil == openBoxInfoNode then
        return false;
    end
	local node_x = openBoxInfoNode:GetFramePos().x + UIOffsetX(70);
	pBottomLayer:SetFramePosXY(0,node_x);
	pBottomLayer:AddActionEffect("test.open_box_info_up");
	
	--���������ӡ��Ч��
	local stampNode = GetImage( pBottomLayer,ui_open_box_info.ID_CTRL_PICTURE_9 );
	local stampNode_xy=stampNode:GetFramePos();
	stampNode:SetFramePosXY(stampNode_xy.x + UIOffsetX(30), stampNode_xy.y + UIOffsetY(30));
	stampNode:AddFgEffect("lancer_cmb.stamp_fx");
	
	--ӡ��ģ��Ч��
    stampNode:AddActionEffect("lancer.openbox_stamp");
    
    --����ͼƬ����Ч��
    openBoxInfoNode:AddActionEffect("lancer.open_box_scale");
	
	--��������Ч��
	pTopLayer:SetFramePosXY(0, UIOffsetY(-500));
	pTopLayer:AddActionEffect("test.open_box_down");
	
	--�����Ӷ���
	local boxNode = GetImage( pTopLayer,ui_open_box.ID_CTRL_PICTURE_6 );
	boxNode:AddFgEffect("lancer.open_box_fx_n1");
	boxNode:AddActionEffect("test_cmb.open-box");
	boxNode:AddFgEffect("lancer_cmb.open_box_fx_new");
	
	--���Ƴ�����Ч��
	local cardNode = GetImage( pTopLayer,ui_open_box.ID_CTRL_PICTURE_10 );
	local cardNode_xy=cardNode:GetFramePos();
	
	--��ÿ���
	--cardNode:SetFramePosXY(cardNode_xy.x,cardNode_xy.y-100);
	--cardNode:AddBgEffect("lancer_cmb.open_box_card_fx");
	
	--��ñ�ʯ
	cardNode:SetFramePosXY(cardNode_xy.x,cardNode_xy.y - UIOffsetY(50));
	cardNode:AddBgEffect("lancer_cmb.open_box_emerald");
	
	--ɾ�����ƴ���������Ч����Ϊ����
	--cardNode:AddActionEffect("test.open_box_card_up");
	cardNode:AddActionEffect("test.card_fadein");
		
	--�����ӹ�Ч
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


