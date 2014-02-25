
quest_result = {}

local p = quest_result;
local ui = ui_quest_reward_view2
p.layer= nil;
p.rewardAllData = nil;

function p.ShowUI(backData)
	if backData.result == false then
		dlg_msgbox.ShowOK("错误提示",backData.message,nil,p.layer);
		return
	end
	
	local rewardData = backData.Reward;
	
	if rewardData == nil then
		WriteConErr("rewardData error");
		return
	end
	p.rewardAllData = rewardData;
	maininterface.ShowUI();
	maininterface.HideUI();

	--如果战斗失败
	if tonumber(rewardData.victory) == 0 then
		p.CloseUI();
		-- quest_lost.ShowUI();
		-- dlg_userinfo.ShowUI();
		-- stageMap_main.OpenWorldMap();
		-- dlg_menu.ShowUI();
		quest_reward.ShowUI(rewardData)
	else
		local stotyId = tonumber(rewardData.endStory)
		if stotyId > 0 then
			dlg_drama.ShowUI(stotyId,after_drama_data.REWARD,0,0,rewardData)
		else
			p.ShowWinView(rewardData)
		end
	end
	
end
--是否有特殊奖励
function p.ShowWinView(rewardData)
	if rewardData == nil then
		WriteConErr("rewardData error");
		return
	end
	if rewardData.item and rewardData.item.item_type then
		p.ShowWin(rewardData)
	else
		p.CloseUI();
		quest_reward.ShowUI(rewardData)
	end
end

function p.ShowWin(rewardData)
	if p.layer ~= nil then 
		p.layer:SetVisible(true);
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end

	dlg_userinfo.ShowUI();
		
	layer:NoMask();
	layer:Init();

	GetUIRoot():AddChild(layer);
	LoadDlg("quest_reward_view2.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	p.ShowReward(rewardData);
end

function p.ShowReward(rewardData)
	local SpecialReward = GetImage(p.layer, ui.ID_CTRL_PICTURE_47);
	SpecialReward:AddFgEffect("ui.Special_reward");
	--SpecialReward:AddActionEffect( "ui_cmb.mainui_btn_scale" );

	local missionId = tonumber(rewardData.mission_id);

	--章节名
	local chapterName = GetLabel(p.layer, ui.ID_CTRL_TEXT_CHAPTER);
	local stageId = math.floor(missionId/1000)
		--WriteConErr("stageId =="..stageId);
	local stageT = SelectRowInner(T_STAGE,"stage_id",stageId);
	chapterName:SetText(stageT.stage_name);
	--任务名
	local missionName = GetLabel(p.layer, ui.ID_CTRL_TEXT_MISSION_NAME);
	local missionTable = SelectRowInner(T_MISSION,"id",missionId);
	missionName:SetText(missionTable.name);
		
	local itemType = tonumber(rewardData.item.item_type)
	local itemId = tonumber(rewardData.item.item_id)
	local itemNum = tonumber(rewardData.item.num)
	
	local itemPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_ITEM );
	--local rewardNumText = GetLabel(view,rewardNumIndex );
	local itemName = GetLabel(p.layer, ui.ID_CTRL_TEXT_ITEM_NAME);

	local picIndex = nil;
	local nameIndex = nil;
	local rewardT = nil
	local cardT = nil;
	if itemType == QUEST_ITEM_TYPE_MATERIAL then
		rewardT = SelectRowInner(T_MATERIAL,"id",itemId);
		picIndex = rewardT.item_pic;
		--itemNumText:SetText(tostring(itemNum));
		nameIndex = rewardT.name
	elseif itemType == QUEST_ITEM_TYPE_CARD then
		rewardT = SelectRowInner(T_CHAR_RES,"card_id",itemId);
		picIndex = rewardT.head_pic;
		
		cardT = SelectRowInner(T_CARD,"id",itemId);
		nameIndex = cardT.name
	elseif itemType == QUEST_ITEM_TYPE_EQUIP then
		rewardT = SelectRowInner(T_EQUIP,"id",itemId);
		picIndex = rewardT.item_pic;
		nameIndex = rewardT.name
	elseif itemType == QUEST_ITEM_TYPE_GIFT or itemType == QUEST_ITEM_TYPE_TREASURE or itemType == QUEST_ITEM_TYPE_OTHER or itemType == QUEST_ITEM_TYPE_SHOP then
		rewardT = SelectRowInner(T_ITEM,"id",itemId);
		picIndex = rewardT.item_pic;
		nameIndex = rewardT.name
	end
	itemPic:SetPicture( GetPictureByAni(picIndex,0));
	itemName:SetText(tostring(nameIndex));
end

function p.SetDelegate(layer)
	local btnOK = GetButton(layer, ui.ID_CTRL_BUTTON_BG );
	btnOK:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if(ui.ID_CTRL_BUTTON_BG == tag) then
			quest_reward.ShowUI(p.rewardAllData)
			p.CloseUI()
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
		p.rewardAllData = nil;
	end
end
