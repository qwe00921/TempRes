--------------------------------------------------------------
-- FileName: 	world_map_mainui.lua
-- author:		xyd, 2013/09/05
-- purpose:		世界地图主界面
--------------------------------------------------------------

world_map_mainui = {}
local p = world_map_mainui;

p.layer = nil;
local ui = ui_world_map_mainui;

--显示UI
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

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
end

--设置事件处理
function p.SetDelegate(layer)
    --活动
	local back = GetButton(layer, ui.ID_CTRL_BUTTON_BACK);
    p.SetBtn(back);
    
end

--按钮点击事件
function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then	
			WriteCon("退回主界面");
			p.CloseUI();
			GetTileMapMgr():GetMapNode():FadeOut();
			SetTimerOnce( p.OnTimer_BackMainUI, 0.5f );
		end				
	end
end

--延时返回主界面
function p.OnTimer_BackMainUI()
	world_map.CloseMap();
	mainui.ShowUI();
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

