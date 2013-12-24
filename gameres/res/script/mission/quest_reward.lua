quest_reward = {}
local p = quest_reward;

p.layer = nil;
local ui = ui_quest_reward_view;

function p.ShowUI(rewardData)
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
		if(ui.ID_CTRL_BUTTON_BG == tag) then
			WriteCon("OK BUTTON");
			if E_DEMO_VER == 4 then
				n_battle_mgr.QuitBattle();
			elseif E_DEMO_VER == 5 then
				w_battle_mgr.QuitBattle();
			end;
			p.CloseUI();
			dlg_userinfo.ShowUI();
			stageMap_main.OpenWorldMap();
		end
	end
end

function p.ShowQuestRewardView(rewardData)
	--成功失败图片
	local resultPic = GetImage(p.layer, ui.ID_CTRL_PICTURE_HRED_RESULT);
	if tonumber(rewardData.Res) == 0 then	--失败
		resultPic:SetPicture( GetPictureByAni("common_ui.mission_result", 0) );
	elseif tonumber(rewardData.Res) == 1 then	--胜利
		resultPic:SetPicture( GetPictureByAni("common_ui.mission_result", 1) );
	end
	--任务名称
	local missionName = GetLabel(p.layer, ui.ID_CTRL_TEXT_MISSION_NAME);
	local missionId = tonumber(rewardData.Mission_id);
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
		Star2:SetVisible(true);
		Star3:SetVisible(true);
	elseif startNum == 2 then
		Star1:SetVisible(true);
		Star2:SetVisible(true);
		Star3:SetVisible(false);
	elseif startNum == 1 then 
		Star1:SetVisible(true);
		Star2:SetVisible(false);
		Star3:SetVisible(false);
	elseif startNum == 0 then
		Star1:SetVisible(false);
		Star2:SetVisible(false);
		Star3:SetVisible(false);
	end
	
	--经验
	local missionExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_GET_EXP);
	local expText = tonumber(rewardData.Reward_exp);
	if expText == nil or expText == 0 then
		expText = "0";
	end
	missionExp:SetText(tostring(expText));
	
	--金币
	local missionMoney = GetLabel(p.layer, ui.ID_CTRL_TEXT_GET_MONEY);
	local moneyText = tonumber(rewardData.reward_money)
	if moneyText == nil or moneyText == 0 then
		moneyText = "0";
	end
	missionMoney:SetText(tostring(moneyText));

	local itemPic_1 = GetImage(p.layer, ui.ID_CTRL_PICTURE_ITEM1);
	local itemName_1 = GetLabel(p.layer, ui.ID_CTRL_TEXT_ITEM_NAME1);
	local itemPic_2 = GetImage(p.layer, ui.ID_CTRL_PICTURE_ITEM2);
	local itemName_2 = GetLabel(p.layer, ui.ID_CTRL_TEXT_ITEM_NAME2);
	local itemBox_1 = GetImage(p.layer, ui.ID_CTRL_PICTURE_25);
	local itemBox_2 = GetImage(p.layer, ui.ID_CTRL_PICTURE_26);

	if rewardData["item"] then
		if rewardData["item"][1] then
			local itemType = tonumber(rewardData["item"][1]["Type"])
			local itemId = tonumber(rewardData["item"][1]["Reward_id"])
			if itemType == 1 then --物品
				local itemTable = SelectRowInner(T_ITEM,"id",itemId);
				itemPic_1:SetPicture( GetPictureByAni(itemTable.item_pic, 0) );
				itemName_1:SetText(itemTable.name);
			elseif itemType == 2 then		--卡牌
				local cardTable = SelectRowInner(T_CHAR_RES,"card_id",itemId);
				itemPic_1:SetPicture( GetPictureByAni(cardTable.head_pic, 0) );
				local cardTable2 = SelectRowInner(T_CARD,"id",itemId);
				itemName_1:SetText(cardTable2.name);
			elseif itemType == 4 then		--装备
				local equipTable = SelectRowInner(T_EQUIP,"id",itemId);
				itemPic_1:SetPicture( GetPictureByAni(equipTable.item_pic, 0) );
				itemName_1:SetText(equipTable.name);
			elseif itemType == 3 then 	--宠物
				WriteConErr("error reward type error ");
			end
		else
			itemPic_1:SetVisible(false);
			itemName_1:SetVisible(false);
			itemBox_1:SetVisible(false);
		end
	
		if rewardData["item"][2] then
			local itemType = tonumber(rewardData["item"][2]["Type"])
			local itemId = tonumber(rewardData["item"][2]["Reward_id"])
			if itemType == 1 or itemType == 3 then --物品
				local itemTable = SelectRowInner(T_ITEM,"id",itemId);
				itemPic_2:SetPicture( GetPictureByAni(itemTable.item_pic, 0) );
				itemName_2:SetText(itemTable.name)
			elseif itemType == 2 then		--卡牌
				local cardTable = SelectRowInner(T_CHAR_RES,"card_id",itemId);
				itemPic_2:SetPicture( GetPictureByAni(cardTable.head_pic, 0) );
				local cardTable2 = SelectRowInner(T_CARD,"id",itemId);
				itemName_2:SetText(cardTable2.name);
			elseif itemType == 4 then		--装备
				local equipTable = SelectRowInner(T_EQUIP,"id",itemId);
				itemPic_2:SetPicture( GetPictureByAni(equipTable.item_pic, 0) );
				itemName_2:SetText(equipTable.name);
			end
		else
			itemPic_2:SetVisible(false);
			itemName_2:SetVisible(false);
			itemBox_2:SetVisible(false);
		end
	else
		itemPic_1:SetVisible(false);
		itemName_1:SetVisible(false);
		itemPic_2:SetVisible(false);
		itemName_2:SetVisible(false);
		itemBox_1:SetVisible(false);
		itemBox_2:SetVisible(false);
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

