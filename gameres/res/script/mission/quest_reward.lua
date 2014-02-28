quest_reward = {}
local p = quest_reward;
local ui_list = ui_quest_reward_view1;
local ui = ui_quest_reward_view;

p.layer = nil;
p.viewId = 0;
p.rewardDataT ={};

function p.ShowUI(rewardData)
	if rewardData == nil then
		WriteConErr("rewardData error");
	end
	maininterface.ShowUI();
	maininterface.HideUI();
	dlg_userinfo.ShowUI();

	--如果战斗失败
	-- if tonumber(rewardData.victory) == 0 then
		-- p.CloseUI();
		-- dlg_userinfo.ShowUI();
		-- stageMap_main.OpenWorldMap();
		-- dlg_menu.ShowUI();
		-- return
	-- end
	
	
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

	GetUIRoot():AddChild(layer);
	LoadDlg("quest_reward_view.xui",layer,nil);
	
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
			if p.viewId < 2 then
				WriteCon("p.viewId =="..p.viewId);
				p.viewId = p.viewId + 1;
				p.getRewardList(p.rewardDataT)
			else
				WriteCon("OK BUTTON");
				if E_DEMO_VER == 4 then
					n_battle_mgr.QuitBattle();
				elseif E_DEMO_VER == 5 then
					w_battle_mgr.QuitBattle();
				end;
				local playLv = tonumber(msg_cache.msg_player.Level)
				local rookieStep = tonumber(msg_cache.msg_player.Guide_id)
				local rookieSubstep = tonumber(msg_cache.msg_player.Sub_Guide_id)
				WriteConErr("playLv="..playLv.."  rookieStep="..rookieStep.."  rookieSubstep="..rookieSubstep);
				if playLv >= 5 and rookieStep == 13 and rookieSubstep == 1 then
					p.CloseUI();
					rookie_main.ShowLearningStep( rookieStep, rookieSubstep )
				else
					p.isShowPlot()
				end
			end
		end
	end
end

--是否显示剧情
function p.isShowPlot()
	local storyId = tonumber(p.rewardDataT.endStory)
	if tonumber(storyId) == 0 then
		local missionId = tonumber(p.rewardDataT.mission_id)
		local stageId = math.floor(missionId/1000)
		WriteCon("open stage id == "..stageId);
		p.CloseUI();
		quest_main.ShowUI(stageId)
		--stageMap_main.OpenWorldMap();
		--dlg_userinfo.ShowUI();
	else
		if p.rewardDataT.newChapterOrStage and p.rewardDataT.newChapterOrStage.chapter_id then
			local newChapter = tonumber(p.rewardDataT.newChapterOrStage.chapter_id)
			local newStage = tonumber(p.rewardDataT.newChapterOrStage.stage_id)
			if newChapter > 0 then
				p.CloseUI();
				--dlg_drama.ShowUI(storyId,after_drama_data.CHAPTER,newChapter)
				stageMap_main.openChapter(newChapter);
			elseif newStage > 0 then
				local viewId = math.floor(newStage/100);
				p.CloseUI();
				--dlg_drama.ShowUI(storyId,after_drama_data.CHAPTER,viewId)
				--quest_main.ShowUI(viewId);
				stageMap_main.openChapter(viewId);
			else
				local missionId = tonumber(p.rewardDataT.mission_id);
				local viewId = math.floor(missionId/1000);
				p.CloseUI();
				--dlg_drama.ShowUI(storyId,after_drama_data.STAGE,viewId)
				quest_main.ShowUI(viewId);
			end
		else
			local missionId = tonumber(p.rewardDataT.mission_id);
			local viewId = math.floor(missionId/1000);
			p.CloseUI();
			--dlg_drama.ShowUI(storyId,after_drama_data.STAGE,viewId)
			quest_main.ShowUI(viewId);
		end
	end
end


function p.ShowQuestRewardView(rewardData)
	for k,v in pairs(rewardData) do
		if k == "mission_id" then
			WriteConErr("v =="..v);
		end
	end
	p.rewardDataT = rewardData;
	
	local failText = GetLabel(p.layer, ui.ID_CTRL_TEXT_24);
	if tonumber(rewardData.victory) == 0 then
		failText:SetVisible(true)
	else
		failText:SetVisible(false)
	end
	
	local missionId = tonumber(rewardData.mission_id);
		WriteConErr("missionId =="..missionId);
	--章节名
	local chapterName = GetLabel(p.layer, ui.ID_CTRL_TEXT_CHAPTER);
	local stageId = math.floor(missionId/1000)
		WriteConErr("stageId =="..stageId);
	local stageT = SelectRowInner(T_STAGE,"stage_id",stageId);
	chapterName:SetText(stageT.stage_name);
	--任务名
	local missionName = GetLabel(p.layer, ui.ID_CTRL_TEXT_MISSION_NAME);
	local missionTable = SelectRowInner(T_MISSION,"id",missionId);
	missionName:SetText(missionTable.name);
	--金币
	local missionMoney = GetLabel(p.layer, ui.ID_CTRL_TEXT_MONEY_V);
	local moneyText = tonumber(rewardData.money) or "0"
	missionMoney:SetText(tostring(moneyText));
	--魂
	local missionSoul = GetLabel(p.layer, ui.ID_CTRL_TEXT_SOUL_V);
	local soulText = tonumber(rewardData.soul) or "0"
	missionSoul:SetText(tostring(soulText));
	--经验
	local missionExp = GetLabel(p.layer, ui.ID_CTRL_TEXT_EXP_V);
	local getExp = tonumber(rewardData.addExp) or 0
	missionExp:SetText(tostring(getExp));
	
	local expMax = tonumber(rewardData.maxExp)
	local expNow = tonumber(rewardData.exp)
	local level = tonumber(rewardData.level)

	local expBar = p.setExpBar()
	expbar_move_effect.showEffect(expBar,0,expMax,expNow,getExp,level)
	
	p.getRewardList(rewardData)
	
	
end

function p.getRewardList(rewardData)
	local getText = GetLabel(p.layer, ui.ID_CTRL_TEXT_ITEM);
	if p.viewId == 0 then
		getText:SetText("获得材料");
		p.rewardListT = rewardData.rewarditems.item
		p.checkList(p.rewardListT)
	end
	if p.viewId == 1 then
		getText:SetText("获得装备");
		p.rewardListT = rewardData.rewarditems.equip
		p.checkList(p.rewardListT)
	end
	if p.viewId == 2 then
		getText:SetText("获得卡牌");
		p.rewardListT = rewardData.rewarditems.card
		p.checkList(p.rewardListT)
	end
	p.showRewardList(p.rewardListT)
end

function p.checkList(list)
	if list == nil or #list <= 0 then
		p.viewId = p.viewId + 1;
		WriteConErr("p.viewId =="..p.viewId);
	end
end


function p.showRewardList(rewardList)
	local rewardListT = GetListBoxVert(p.layer, ui.ID_CTRL_VERTICAL_LIST_ITEMANDCHA);
	rewardListT:ClearView();
	
	if rewardList == nil or #rewardList <= 0 then
		return
	end
	
	local rewardNum = #rewardList
	WriteCon("rewardNum ===== "..rewardNum);
	
	local row = math.ceil(rewardNum/6);
	WriteCon("row ===== "..row);
	
	for i = 1,row do
		local view = createNDUIXView();
		view:Init();
		LoadUI("quest_reward_view1.xui",view,nil);
		local bg = GetUiNode( view, ui_list.ID_CTRL_PICTURE_80);
        view:SetViewSize( bg:GetFrameSize());
		
		local row_index = i;
		local start_index = (row_index-1)*6+1
        local end_index = start_index + 5;
		
		--设置列表信息，一行6个物品
		for j = start_index,end_index do
			if j <= rewardNum then
				local reward = rewardList[j];
				local rewardIndex = j - start_index + 1;
				p.ShowRewardInfo( view, reward, rewardIndex );
			end
		end
		rewardListT:AddView( view );
	end
end

function p.ShowRewardInfo( view, reward, rewardIndex )
	local rewardPicIndex = nil;
	local rewardNumIndex = nil;
	WriteCon("rewardIndex ===== "..rewardIndex);

	if rewardIndex == 1 then
		rewardPicIndex = ui_list.ID_CTRL_PICTURE_ITEM1;
		rewardNumIndex = ui_list.ID_CTRL_TEXT_NUM1;
	elseif rewardIndex == 2 then
		rewardPicIndex = ui_list.ID_CTRL_PICTURE_ITEM2;
		rewardNumIndex = ui_list.ID_CTRL_TEXT_NUM2;
	elseif rewardIndex == 3 then
		rewardPicIndex = ui_list.ID_CTRL_PICTURE_ITEM3;
		rewardNumIndex = ui_list.ID_CTRL_TEXT_NUM3;
	elseif rewardIndex == 4 then
		rewardPicIndex = ui_list.ID_CTRL_PICTURE_ITEM4;
		rewardNumIndex = ui_list.ID_CTRL_TEXT_NUM4;
	elseif rewardIndex == 5 then
		rewardPicIndex = ui_list.ID_CTRL_PICTURE_ITEM5;
		rewardNumIndex = ui_list.ID_CTRL_TEXT_NUM5;
	elseif rewardIndex == 6 then
		rewardPicIndex = ui_list.ID_CTRL_PICTURE_ITEM6;
		rewardNumIndex = ui_list.ID_CTRL_TEXT_NUM6;
	end
	local rewardPic = GetImage(view,rewardPicIndex );
	local rewardNumText = GetLabel(view,rewardNumIndex );
	
	local rewardType = tonumber(reward.item_type);
	local rewardId = tonumber(reward.item_id);
	local rewardNum = tonumber(reward.num);
	WriteCon("rewardType ===== "..rewardType);
	WriteCon("rewardId ===== "..rewardId);

	local picIndex = nil;
	local rewardT = nil
	if rewardType == QUEST_ITEM_TYPE_MATERIAL then
		rewardT = SelectRowInner(T_MATERIAL,"id",rewardId);
		picIndex = rewardT.item_pic;
		rewardNumText:SetText(tostring(rewardNum));
	elseif rewardType == QUEST_ITEM_TYPE_CARD then
		rewardT = SelectRowInner(T_CHAR_RES,"card_id",rewardId);
		picIndex = rewardT.head_pic;
	elseif rewardType == QUEST_ITEM_TYPE_EQUIP then
		rewardT = SelectRowInner(T_EQUIP,"id",rewardId);
		picIndex = rewardT.item_pic;
	elseif rewardType == QUEST_ITEM_TYPE_GIFT or rewardType == QUEST_ITEM_TYPE_TREASURE or rewardType == QUEST_ITEM_TYPE_OTHER or rewardType == QUEST_ITEM_TYPE_SHOP then
		rewardT = SelectRowInner(T_ITEM,"id",rewardId);
		picIndex = rewardT.item_pic;
	end
	
	rewardPic:SetPicture( GetPictureByAni(picIndex,0));
end


function p.setExpUpNeed(needExp)
	if p.layer == nil then 
		return;
	end
	local needExpText = GetLabel(p.layer, ui.ID_CTRL_TEXT_NEED_EXP_V);
	needExpText:SetText(tostring(needExp))
end

function p.setExpBar()
	local expBar = GetExp( p.layer, ui.ID_CTRL_EXP_EXP );
	return expBar
end

function p.showLevelUp()
	local levelUpPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_LEVELUP );
	levelUpPic:SetPicture( GetPictureByAni("common_ui.level_up",0));
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
		p.viewId = 0;
		expbar_move_effect.ClearData();
		p.rewardDataT =nil;
	end
end
