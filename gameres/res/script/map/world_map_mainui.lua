--------------------------------------------------------------
-- FileName: 	world_map_mainui.lua
-- author:		xyd, 2013/09/05
-- purpose:		�����ͼ������
--------------------------------------------------------------

world_map_mainui = {}
local p = world_map_mainui;

p.layer = nil;
local ui = ui_world_map_mainui;

--��ʾUI
function p.ShowUI()
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
    
	GetUIRoot():AddChild(layer);
    LoadUI("world_map_mainui.xui", layer, nil);
    
	p.Init();
	p.SetDelegate(layer);
	p.layer = layer;
end

function p.Init()	
end

--���ð�ť
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
end

--�����¼�����
function p.SetDelegate(layer)
    --�
	local back = GetButton(layer, ui.ID_CTRL_BUTTON_BACK);
    p.SetBtn(back);
    
end

--��ť����¼�
function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then	
			WriteCon("�˻�������");
			p.CloseUI();
			GetTileMapMgr():GetMapNode():FadeOut();
			SetTimerOnce( p.OnTimer_BackMainUI, 0.5f );
		end				
	end
end

--��ʱ����������
function p.OnTimer_BackMainUI()
	world_map.CloseMap();
	mainui.ShowUI();
end

--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

