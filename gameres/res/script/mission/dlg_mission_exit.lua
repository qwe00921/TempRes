--------------------------------------------------------------
-- FileName: 	dlg_mission_exit.lua
-- author:		xyd, 2013/05/28
-- purpose:		任务退出界面的功能
--------------------------------------------------------------

dlg_mission_exit = {}
local p = dlg_mission_exit;

p.layer = nil;

--显示UI
function p.ShowUI()
    
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	GetUIRoot():AddDlg(layer);	
    LoadDlg("dlg_mission_exit.xui", layer, p.OnClick);
	
	p.Init();
	--p.SetDelegate(layer);
	p.layer = layer;
end

--[[@del
--设置事件处理
function p.SetDelegate(layer)

	local pLeaveButton = GetButton(layer,ui_dlg_mission_exit.ID_CTRL_BUTTON_2);
    pLeaveButton:SetLuaDelegate(p.OnClick);
	
	local pGiveupButton = GetButton(layer,ui_dlg_mission_exit.ID_CTRL_BUTTON_3);
    pGiveupButton:SetLuaDelegate(p.OnClick);
	
	local pGogoButton = GetButton(layer,ui_dlg_mission_exit.ID_CTRL_BUTTON_4);
    pGogoButton:SetLuaDelegate(p.OnClick);
	
end
--]]

function p.Init()	
end

function p.OnClick(uiNode, uiEventType, param)	
	
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
	
        if ( ui_dlg_mission_exit.ID_CTRL_BUTTON_2 == tag ) then

			p.HideUI();
					
		elseif ( ui_dlg_mission_exit.ID_CTRL_BUTTON_3 == tag ) then
			WriteCon("放弃任务");
		elseif ( ui_dlg_mission_exit.ID_CTRL_BUTTON_4 == tag ) then
			WriteCon("继续任务");	
		end
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end