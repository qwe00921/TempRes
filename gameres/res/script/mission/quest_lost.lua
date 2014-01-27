quest_lost = {}
local p = quest_lost;
local ui = ui_lost;


function p.ShowUI()
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init();

	GetUIRoot():AddDlg(layer);
	LoadUI("lost.xui",layer,nil);

	p.layer = layer;
	p.SetDelegate(layer);
	--p.init()
end

function p.SetDelegate(layer)
	local btnOK = GetButton(layer, ui.ID_CTRL_BUTTON_NEXT );
	btnOK:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if(ui.ID_CTRL_BUTTON_NEXT == tag) then
			p.CloseUI();
			stageMap_main.OpenWorldMap();
			dlg_userinfo.ShowUI();
			dlg_menu.ShowUI();
		end
	end
end

--Òþ²ØUI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
	end
end

--¹Ø±ÕUI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end
