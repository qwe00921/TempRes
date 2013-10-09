--------------------------------------------------------------
-- FileName: 	get_card.lua
-- author:		guohao, 2013/05/27
-- purpose:		��ÿ�Ƭ����
--------------------------------------------------------------

get_card = {}
local p = get_card;
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
	
    LoadUI("get_card_info.xui", pBottomLayer, nil);

	LoadUI("get_card.xui", pTopLayer, nil);
	
	p.DoEffect(pTopLayer, pBottomLayer);
	
	--p.Init();
	--p.SetDelegate(layer);
	p.layer = pMainLayer;
	
	-- ��ȡ��Ƭ�رհ�ť�������Ļ����
	local closeBtn = createNDUIButton();
	closeBtn:Init();
	closeBtn:SetFrameRectFull();
	pMainLayer:AddChildZ(closeBtn,5);
	closeBtn:SetLuaDelegate(p.OnUIEventBtn);
	
	PlayEffectSoundByName( "sk_card.mp3" );--��Ч
end

function p.DoEffect(pTopLayer, pBottomLayer)	
	--�ײ���Ϣ����Ч��
	local getCardInfoNode = GetImage( pBottomLayer,ui_get_card_info.ID_CTRL_PICTURE_1 );
	if nil == getCardInfoNode then
        return false;
    end
	local node_y = getCardInfoNode:GetFramePos().y - UIOffsetY(70);
	pBottomLayer:SetFramePosXY(0,node_y);
	pBottomLayer:AddActionEffect("test.get_card_info_up");
	
	--���������ӡ��Ч��
	local stampNode = GetImage( pBottomLayer,ui_get_card_info.ID_CTRL_PICTURE_29 );
	local stampNode_xy=stampNode:GetFramePos();
	stampNode:SetFramePosXY(stampNode_xy.x - UIOffsetX(-50),stampNode_xy.y + UIOffsetY(50));
	stampNode:AddFgEffect("lancer_cmb.BGJ_stamp_fx");
	
	--ӡ��ģ��Ч��
	stampNode:AddActionEffect("lancer.cardget_stamp");

    --����ͼƬ����Ч��
	getCardInfoNode:AddActionEffect("lancer.card_info_scale");
	
	--��������
	local cardImage = GetImage(pTopLayer,ui_get_card.ID_CTRL_PICTURE_30);
	if (nil == cardImage) then
		WriteCon("cardImage == nil");
		return false;
	end
	cardImage:AddFgEffect("lancer_cmb.BGJ_card_fx");
	pTopLayer:SetFramePosXY(0,UIOffsetY(-500));
	pTopLayer:AddActionEffect("test.get_card_down");
	
	--��������
	--scene:AddActionEffect( "lancer_cmb.shake" );
	--pBottomLayer:AddActionEffect( "lancer_cmb.shake" );
end

function p.OnUIEventBtn(uiNode, uiEventType, param)	
	p.layer:LazyClose();
	p.layer = nil;
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end