

dlg_menu = {};
local p = dlg_menu;

p.layer = nil;
local ui = ui_main_menu;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init(layer);
	layer:SetSwallowTouch(false);
    
	GetUIRoot():AddChild(layer);
	LoadUI("main_menu.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
end

function p.SetDelegate()
	for index, tag in pairs(ui) do
		if index ~= "ID_CTRL_MAIN_PICTURE_MENUBG" then
			local btn = GetButton(p.layer, tag);
			p.SetBtn(btn);
		end
	end
end

--[[
p.ID_CTRL_MAIN_BUTTON_OTHER			= 15;	--其他按钮
p.ID_CTRL_MAIN_BUTTON_FRIENDS			= 14;	--好友按钮
p.ID_CTRL_MAIN_BUTTON_PVP				 = 13;	--pvp按钮
p.ID_CTRL_MAIN_BUTTON_ITEM			 = 12;	--物品按钮
p.ID_CTRL_MAIN_BUTTON_FORMATION		= 11;	--阵型按钮
p.ID_CTRL_MAIN_BUTTON_TEAM			 = 10;	--队伍按钮
--]]

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_MAIN_BUTTON_OTHER == tag then
			--先作为隐藏菜单功能
			WriteCon("**其他**");

		elseif ui.ID_CTRL_MAIN_BUTTON_FRIENDS == tag then
			WriteCon("**好友**");
			--先接lancer原有UI
			dlg_friend.ShowUI();
			
		elseif ui.ID_CTRL_MAIN_BUTTON_PVP == tag then
			WriteCon("**PVP**");
			
		elseif ui.ID_CTRL_MAIN_BUTTON_ITEM == tag then
			WriteCon("**物品**");
			--先接lancer原有UI
			dlg_back_pack.ShowUI();	
			
		elseif ui.ID_CTRL_MAIN_BUTTON_FORMATION == tag then
			WriteCon("**阵型**");
			
		elseif ui.ID_CTRL_MAIN_BUTTON_TEAM == tag then
			WriteCon("**队伍**");
			
		end
	end
end

function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
	end
end
