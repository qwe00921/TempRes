QUEST_ITEM_TYPE_MATERIAL = 1;		--material
QUEST_ITEM_TYPE_CARD = 2;			--char_res
QUEST_ITEM_TYPE_EQUIP = 3;			--equip
QUEST_ITEM_TYPE_MONEY = 4;
QUEST_ITEM_TYPE_BLUESOUL = 5;
QUEST_ITEM_TYPE_EMONEY = 6;
QUEST_ITEM_TYPE_GIFT = 7;			--item
QUEST_ITEM_TYPE_TREASURE = 8;		--item
QUEST_ITEM_TYPE_OTHER = 9;			--item
QUEST_ITEM_TYPE_SHOP = 10;			--item


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
	dlg_userinfo.ShowUI();

	--如果战斗失败
	if tonumber(rewardData.victory) == 0 then
		p.CloseUI();
		dlg_userinfo.ShowUI();
		stageMap_main.OpenWorldMap();
		dlg_menu.ShowUI();
		return
	end
	
	
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
				p.isShowPlot()
			end
		end
	end
end

--是否显示剧情
function p.isShowPlot()
	local storyId = tonumber(p.rewardDataT.story)
	if storyId == 0 then
		p.CloseUI();
		dlg_userinfo.ShowUI();
		stageMap_main.OpenWorldMap();
	else
		p.CloseUI();
		dlg_drama.ShowUI(0,storyId,after_drama_data.CHAPTER)
		WriteCon("OK BUTTON");
	end

end


function p.ShowQuestRewardView(rewardData)
	for k,v in pairs(rewardData) do
		if k == "mission_id" then
			WriteConErr("v =="..v);
		end
	end
	p.rewardDataT = rewardData;
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
	if p.viewId == 0 then
		p.rewardListT = rewardData.rewarditems.item
	elseif p.viewId == 1 then
		p.rewardListT = rewardData.rewarditems.equip
	elseif p.viewId == 2 then
		p.rewardListT = rewardData.rewarditems.card
	end
	p.showRewardList(p.rewardListT)
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

