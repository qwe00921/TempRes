Reward = {}
Reward["item"] = {}
Reward["item"][1] = {}
Reward["item"][1]["Reward_id"] = 101
Reward["item"][1]["Type"] = 2
Reward["item"][1]["Num"] = 1
Reward["item"][1]["Group"] = 1

Reward["item"][2] = {}
Reward["item"][2]["Reward_id"] = 1
Reward["item"][2]["Type"] = 3
Reward["item"][2]["Num"] = 1
Reward["item"][2]["Group"] = 2

Reward["Mission_id"] = 101011
Reward["Res"] = 1
Reward["Difficulty"]= 1
Reward["Score"] = 3
Reward["Reward_exp"] = 130
Reward["reward_money"] = nil;


quest_reward = {}
local p = quest_reward;

p.layer = nil;
local ui = ui_quest_reward_view;

function p.ShowUI()
	rewardData = Reward
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
	LoadUI("quest_reward_view.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	p.ShowQuestRewardView(rewardData);
end

function p.SetDelegate(layer)
	local btnOK = GetButton(layer, ui.ID_CTRL_BUTTON_BG );
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

function p.ShowQuestRewardView(rewardData)
	--成功失败图片
	local resultPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_HRED_RESULT);
	if tonumber(rewardData.Res) == 0 then	--失败
		resultPic:SetPicture( GetPictureByAni(common_ui.mission_result, 0) );
	elseif tonumber(rewardData.Res) == 1 then	--胜利
		resultPic:SetPicture( GetPictureByAni("common_ui.mission_result", 0) );
	end
	--任务名称
	local missionName = GetLabel(p.layer, ui.ID_CTRL_TEXT_MISSION_NAME);
	local missionId = tonumber(Reward.Mission_id);
	local missionTable = SelectRowInner(T_MISSION,"id",missionId);
	missionName:SetText(missionTable.mission_name);
	--难度图片
	local difficltPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_DIFF);
	difficltPic:SetPicture( GetPictureByAni("common_ui.mission_difficult", tonumber(rewardData.Difficulty)) );

	--评价
	local Star1 = GetImage(p.layer, ui.ID_CTRL_PICTURE_STAR1);
	local Star2 = GetImage(p.layer, ui.ID_CTRL_PICTURE_STAR2);
	local Star3 = GetImage(p.layer, ui.ID_CTRL_PICTURE_STAR3);
	
	local startNum = tonumber(rewardData.Score)
	if startNum == 3 then
		Star1:SetVisible(true);
		Star1:SetVisible(true);
		Star1:SetVisible(true);
	elseif startNum == 2 then
		Star1:SetVisible(true);
		Star1:SetVisible(true);
		Star1:SetVisible(false);
	elseif startNum == 1 then 
		Star1:SetVisible(true);
		Star1:SetVisible(false);
		Star1:SetVisible(false);
	elseif startNum == 0 then
		Star1:SetVisible(false);
		Star1:SetVisible(false);
		Star1:SetVisible(false);
	end
	
	--经验
	local missionExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_GET_EXP);
	missionExp:SetText(tostring(rewardData.Reward_exp));
	--金币
	local missionMoney = GetLabel(p.layer, ui.ID_CTRL_TEXT_GET_MONEY);
	missionExp:SetText(tostring(rewardData.reward_money));

	local itemPic_1 = GetImage(p.layer, ui.ID_CTRL_PICTURE_ITEM1);
	local itemName_1 = GetLabel(p.layer, ui.ID_CTRL_TEXT_ITEM_NAME1);
	local itemPic_2 = GetImage(p.layer, ui.ID_CTRL_PICTURE_ITEM2);
	local itemName_2 = GetLabel(p.layer, ui.ID_CTRL_TEXT_ITEM_NAME2);
	local touchText = GetImage(p.layer, ui.ID_CTRL_PICTURE_TOUCH);

	if rewardData.item then
	
	
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

