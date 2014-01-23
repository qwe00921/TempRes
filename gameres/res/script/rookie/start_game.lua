start_game = {}
local p = start_game;
local ui = ui_game_start;
p.layer = nil;

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
	layer:SetSwallowTouch(false);
	
	GetUIRoot():AddDlg(layer);
	LoadUI("game_start.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	--p.InitScrollList();
	p.Init()
end

function p.Init()
	--ID_CTRL_TEXT_TALK
end

function p.SetDelegate(layer)
	local btnNext = GetButton( p.layer, ui.ID_CTRL_BUTTON_NEXT );
	btnNext:SetLuaDelegate(p.OnBtnClick);

end

function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_BUTTON_NEXT == tag) then
			p.CloseUI()
			--rookie_main.ShowLearningStep(2)
			choose_card.ShowUI();
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
