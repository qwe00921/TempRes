quest_reward = {}
local p = quest_reward;

p.layer = nil;
local ui = ui_quest_reward_view;

function p.ShowUI(data)
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
	LoadUI("quest_main_view.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	p.ShowQuestRewardView(data);
end

function p.SetDelegate(layer)
	local btnOK = GetButton( p.layer, ui.ID_CTRL_BUTTON_OK );
	btnOK:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if(ui.ID_CTRL_BUTTON_OK == tag) then
			WriteCon("OK BUTTON");
			p.CloseUI();
		end
	end
end

function p.ShowQuestRewardView(data)
	local resultPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_HRED_RESULT);
	local missionName = GetLable(p.layer, ui.ID_CTRL_TEXT_MISSION_NAME);
	local difficltPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_DIFF);
	local Star1 = GetImage(p.layer, ui.ID_CTRL_PICTURE_STAR1);
	local Star2 = GetImage(p.layer, ui.ID_CTRL_PICTURE_STAR2);
	local Star3 = GetImage(p.layer, ui.ID_CTRL_PICTURE_STAR3);
	local missionExp = GetLable(p.layer, ui.ID_CTRL_TEXT_GET_EXP);
	local missionMoney = GetLable(p.layer, ui.ID_CTRL_TEXT_GET_MONEY);
	local itemPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_ITEM);
	local itemName = GetLable(p.layer, ui.ID_CTRL_TEXT_ITEM_NAME);
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

