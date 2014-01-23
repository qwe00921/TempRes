start_game = {}
local p = start_game;
local ui = ui_game_start;
p.layer = nil;
p.count = 0;
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
	local text = "    醒醒......醒醒，年轻的勇者啊，打扰你的睡眠也是迫不得已，来，请告诉俄我你的名字吧。";
	p.SetText(text)
end

function p.SetText(text)
	local talkText = GetLabel(p.layer,ui.ID_CTRL_TEXT_TALK)
	talkText:SetText(text);
end

function p.SetDelegate(layer)
	local btnNext = GetButton( p.layer, ui.ID_CTRL_BUTTON_NEXT );
	btnNext:SetLuaDelegate(p.OnBtnClick);

end

function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_BUTTON_NEXT == tag) then
			if p.count == 0 then
				p.count = p.count + 1;
				local text = "    恩..那么，先选择下将要跟随着你的星卡伙伴吧。"
				p.SetText(text)
			elseif p.count == 1 then
				p.CloseUI()
				--rookie_main.ShowLearningStep(2)
				choose_card.ShowUI();
			end
		end
	end
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end
