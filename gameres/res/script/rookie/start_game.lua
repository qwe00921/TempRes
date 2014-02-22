start_game = {}
local p = start_game;
local ui = ui_game_start;
p.layer = nil;
p.count = 0;

p.contentStr = nil;
p.contentNode = nil;
p.fontSize = nil;
p.contentStrLn = nil;
p.contentIndex = nil;
p.timerId = nil;

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
	p.contentNode = GetLabel(p.layer,ui.ID_CTRL_TEXT_TALK)
	p.fontSize = 20;
	
	p.contentStr = "    醒醒......醒醒，年轻的勇者啊，打扰你的睡眠也是迫不得已，来，请告诉我你的名字吧。"
	p.showText()
end

function p.showText()
	p.contentStrLn = GetCharCountUtf8 ( p.contentStr );
	p.contentIndex = 1;
    if p.contentStr ~= nil and p.contentStrLn > 1 then
    	p.timerId = SetTimer( p.DoEffectContent, 0.04 );
    end
	
end

function p.DoEffectContent()
	if p.contentNode == nil then
		return ;
	end
	
	local strText = GetSubStringUtf8( p.contentStr, p.contentIndex );
	--WriteCon(string.format("Font Size %d",p.fontSize));
	--p.contentNode:SetFontSize(tostring(p.fontSize));
	p.contentNode:SetText(strText);

	p.contentIndex = p.contentIndex + 1;
	if p.contentIndex > p.contentStrLn and p.timerId ~= nil then
		KillTimer( p.timerId );
		p.timerId = nil;
	end
	
end

function p.SetDelegate(layer)
	local btnNext = GetButton( p.layer, ui.ID_CTRL_BUTTON_NEXT );
	btnNext:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_BUTTON_NEXT == tag) then
			if p.timerId ~= nil then
                KillTimer( p.timerId );
                p.timerId = nil;
            end
			if p.count == 0 then
				p.count = p.count + 1;
				p.contentStr = "    恩..那么，先选择下将要跟随着你的星卡伙伴吧。"
				p.showText()
			elseif p.count == 1 then
				p.CloseUI()
				--rookie_main.ShowLearningStep(2)
				--暂时去除选择卡牌界面
				rookie_main.SendUpdateStep(rookie_main.stepId,0,"param=10175")
				-- local uid = GetUID();
				-- local param = "guide="..(rookie_main.stepId).."&param=10175";
				-- SendReq("User","Complete",uid,param);
				--choose_card.ShowUI();
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

function p.ClearData()
	p.count = 0
	p.contentStr = nil;
	p.contentNode = nil;
	p.fontSize = nil;
	p.contentStrLn = nil;
	p.contentIndex = nil;
	p.timerId = nil;
end
