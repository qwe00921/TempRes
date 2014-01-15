quest_reward = {}
local p = quest_reward;

p.layer = nil;
local ui = ui_quest_reward_view;
local expLeast = nil;
local expMax = nil;
local expNow = nil;

function p.ShowUI(rewardData)
	if rewardData == nil then
		WriteConErr("rewardData error");
	end
	
	dlg_userinfo.ShowUI();
	expLeast = 0;
	expMax = tonumber(msg_cache.msg_player.MaxExp);
	expNow = tonumber(msg_cache.msg_player.Exp);

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
	local missionId = tonumber(rewardData.mission_id);
	--章节名
	local chapterName = GetLabel(p.layer, ui.ID_CTRL_TEXT_CHAPTER);
	local stageId = math.floor(missionId/1000)
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
	local expText = tonumber(rewardData.exp) or "0"
	missionExp:SetText(tostring(expText));
	
	--升级所需经验
	local needExpText = GetLabel(p.layer, ui.ID_CTRL_TEXT_NEED_EXP_V);
	local expUpNeed = expMax - expNow - tonumber(expText);
	needExpText:SetText(tostring(expUpNeed))
	
	local expBar = GetExp( p.layer, ui.ID_CTRL_EXP_EXP );
	local expStartNum = expNow;
	local expEndNum = expNow + tonumber(expText);
	expbar_move_effect.showEffect(expBar,expLeast,expMax,expStartNum,expEndNum)
	
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
		expbar_move_effect.ClearData();
	end
end

