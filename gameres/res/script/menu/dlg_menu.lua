

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

--���ð�ť
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
p.ID_CTRL_MAIN_BUTTON_OTHER			= 15;	--������ť
p.ID_CTRL_MAIN_BUTTON_FRIENDS			= 14;	--���Ѱ�ť
p.ID_CTRL_MAIN_BUTTON_PVP				 = 13;	--pvp��ť
p.ID_CTRL_MAIN_BUTTON_ITEM			 = 12;	--��Ʒ��ť
p.ID_CTRL_MAIN_BUTTON_FORMATION		= 11;	--���Ͱ�ť
p.ID_CTRL_MAIN_BUTTON_TEAM			 = 10;	--���鰴ť
--]]

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_MAIN_BUTTON_OTHER == tag then
			--����Ϊ���ز˵�����
			WriteCon("**����**");

		elseif ui.ID_CTRL_MAIN_BUTTON_FRIENDS == tag then
			WriteCon("**����**");
			--�Ƚ�lancerԭ��UI
			dlg_friend.ShowUI();
			
		elseif ui.ID_CTRL_MAIN_BUTTON_PVP == tag then
			WriteCon("**PVP**");
			
		elseif ui.ID_CTRL_MAIN_BUTTON_ITEM == tag then
			WriteCon("**��Ʒ**");
			--�Ƚ�lancerԭ��UI
			dlg_back_pack.ShowUI();	
			
		elseif ui.ID_CTRL_MAIN_BUTTON_FORMATION == tag then
			WriteCon("**����**");
			
		elseif ui.ID_CTRL_MAIN_BUTTON_TEAM == tag then
			WriteCon("**����**");
			
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
