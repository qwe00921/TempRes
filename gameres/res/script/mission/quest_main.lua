EASY = 1001;
HARD = 1002;

quest_main = {}
local p = quest_main;

p.layer = nil;
local ui = ui_quest_main_view;
local uiList = ui_quest_list_view;

p.power = nil;
p.stageId = nil;	--关卡ID
p.missionId = nil; 	--任务ID
p.missionList = nil;
p.missionMax = 9;
p.missionIdGap = 10;
local difficultKey = EASY;

function p.ShowUI(stageId)
	dlg_menu.SetNewUI( p );
	
	p.stageId  = stageId;
	--获取missionId初始值
	p.GetMissionId();
	dlg_userinfo.ShowUI();
	dlg_menu.ShowUI();
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
	LoadUI("quest_main_view.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	p.Init()
end

function p.Init()
--设置章节名字
	local stageTable =  SelectRowInner(T_STAGE,"stage_id",p.stageId);
	local stageName = GetLabel(p.layer, ui.ID_CTRL_TEXT_QUEST_NAME);
	stageName:SetText(stageTable.stage_name);
	p.setDifficultBtn()
	
	WriteCon("send mission request");
	local uid = GetUID();
	local param = "Stage_id="..p.stageId;
	SendReq("Mission","MissionList",uid,param);
	--p.ShowQuestList();
end

function p.GetMissionId()
	if p.stageId then
		p.missionId = tonumber(p.stageId.."0"..p.missionMax.."1");
		WriteCon(tostring(p.missionId));
	end
end

function p.SetDelegate()
	--返回
	local btnReturn = GetButton( p.layer, ui.ID_CTRL_BTN_TETURN );
	btnReturn:SetLuaDelegate(p.OnBtnClick);
	
	--普通
	local btnHard =  GetButton(p.layer, ui.ID_CTRL_BTN_HARD);
	btnHard:SetLuaDelegate(p.OnBtnClick);
end
--按钮事件
function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_BTN_TETURN == tag) then
			WriteCon("return");
			p.CloseUI();
			stageMap_1.ShowUI();
		elseif (ui.ID_CTRL_BTN_HARD == tag) then
			local missionStartId = nil;
			if difficultKey == EASY then
				local misKey = "M"..p.stageId.."012";
				if p.missionList[misKey] then
					difficultKey = HARD;
					missionStartId = p.missionId + 1;
					p.loadMissionList(missionStartId);
				else
					dlg_msgbox.ShowOK( "提示", "当所有任务都获得完美评价时，才能解锁困难难度！" , nil, nil );
				end
			elseif difficultKey == HARD then
				difficultKey = EASY;
				missionStartId = p.missionId;
				p.loadMissionList(missionStartId);
			end
			p.setDifficultBtn();
		end
	end
end
--点击战斗按钮
function p.OnFightBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if ( uiList.ID_CTRL_BUTTON_FIGHTING == tag) then
			local missionId = uiNode:GetId();
			WriteCon("OnFightBtnClick====="..missionId);
			local missionTable = SelectRowInner(T_MISSION,"id",missionId);
			local powerLimit = tonumber(missionTable.move_cost);
			local power = p.power;
			if power < powerLimit then
				dlg_msgbox.ShowOK("提示" ,  "体力值不足。");
				WriteCon("power not enough");
				return
			end
			local fightTimes = tonumber(p.missionList["M"..missionId]["fight_num"])
			if fightTimes <= 0 then
				dlg_msgbox.ShowOK("提示" ,  "今日挑战次数已达上限。");
				return
			end
			local storyId = nil;
			if p.missionList["M"..missionId] then
				storyId = p.missionList["M"..missionId].begin_story;
				WriteCon("storyId = "..storyId);
			end
			--p.HideUI()
			
			
			
			--local missionListTable = GetListBoxVert(p.layer, ui.ID_CTRL_VERTICAL_LIST);
			--missionListTable:SetVisible(false);
			--missionListTable:RemoveView();
			--p.layer:RemoveView(missionListTable);

			--quest_team_item.ShowUI(missionId,power);
			
			-- maininterface.m_bgImage:SetVisible(false);
			-- if p.missionList["M"..missionId] then
			-- local storyId = p.missionList["M"..missionId].begin_story;
				-- WriteCon("storyId = "..storyId);
				-- if tonumber(storyId) ~= 0 then
					-- dlg_drama.ShowUI( missionId , storyId);
				-- else
				   -- if E_DEMO_VER == 4 then
					-- n_battle_mgr.EnterBattle( N_BATTLE_PVE, missionId );--进入战斗PVE
				   -- else	
					-- w_battle_mgr.EnterBattle( W_BATTLE_PVE, missionId );--进入战斗PVE
				   -- end;
				-- end
			-- else
				-- if E_DEMO_VER== 4 then
				  -- n_battle_mgr.EnterBattle( N_BATTLE_PVE, missionId );--进入战斗PVE
				-- else
				  -- w_battle_mgr.EnterBattle( W_BATTLE_PVE, missionId );--进入战斗PVE
				-- end;
			-- end
			-- p.CloseUI();
			p.showTeamItem(missionId,storyId)
		end
	end
end

function p.setDifficultBtn()
	local diffBtn = GetButton(p.layer, ui.ID_CTRL_BTN_HARD);
	if difficultKey == EASY then
		diffBtn:SetImage( GetPictureByAni("common_ui.mission_hard",0));
	elseif difficultKey == HARD then
		diffBtn:SetImage( GetPictureByAni("common_ui.mission_hard",1));
	end
end


function p.ShowQuestList(self)
	if self.result == false then
		dlg_msgbox.ShowOK("错误提示",self.message,nil,p.layer);
		return;
	end
	
	local List = self.data;
	for k,v in pairs(List) do
		if k == "missions" then
			p.missionList = List[k];
		elseif k == "move" then
			p.power = tonumber(List[k]);
			WriteCon("**p.power="..p.power); 
		end
	end
	
	if p.missionList == nil then
		WriteCon("**missionsList error**"); 
		return
	end
	
	--加载列表
	local missionStartId = p.missionId;
	p.loadMissionList(missionStartId);
end

function p.loadMissionList(missionStartId)
	local misId = missionStartId
	local count = p.missionMax;
	local missionListTable = GetListBoxVert(p.layer, ui.ID_CTRL_VERTICAL_LIST);
	if missionListTable == nil then
		return
	end
	missionListTable:ClearView();
	
	for i = 1,count do
		local misKey = "M"..misId;
		if p.missionList[misKey] then
			local view = createNDUIXView();
			view:Init();
			LoadUI("quest_list_view.xui",view, nil);
			local bg = GetUiNode(view, uiList.ID_CTRL_PIC_LIST_BG);
			view:SetViewSize( CCSizeMake(bg:GetFrameSize().w, bg:GetFrameSize().h));
			view:SetId(misId);
			--设置任务静态数据
			p.setMissionInfo(misId,view)
		
			--设置服务端下发数据
			local fightBtn = GetButton(view, uiList.ID_CTRL_BUTTON_FIGHTING);
			fightBtn:SetLuaDelegate(p.OnFightBtnClick);
			fightBtn:SetId(misId);
			
			local timesText = GetLabel(view, uiList.ID_CTRL_TEXT_TIEMS_V);
			local missionTable = SelectRowInner(T_MISSION,"id",misId);
			local text = p.missionList[misKey]["fight_num"].."/"..missionTable["fight_num"]
			timesText:SetText(text);
			
			local misHead = GetImage(view, uiList.ID_CTRL_PICTURE_NEW);
			local evaluate = tonumber(p.missionList[misKey]["score"]);
			if evaluate == 0 then
				misHead:SetPicture( GetPictureByAni("common_ui.evaluate_0", 0));
			--elseif evaluate == 1 then
				--misHead:SetPicture( GetPictureByAni("common_ui.evaluate", 1));
			elseif evaluate == 2 then
				misHead:SetPicture( GetPictureByAni("common_ui.evaluate_2", 0));
			end
			
			missionListTable:AddView(view);
		end
		misId = misId - p.missionIdGap;
	end
end

function p.setMissionInfo(misId,view)
	local misName = GetLabel(view, uiList.ID_CTRL_TEXT_QUEST_NAME_V);
	local misStep = GetLabel(view, uiList.ID_CTRL_TEXT_DIF_V);
	local misPower = GetLabel(view, uiList.ID_CTRL_TEXT_POWER_V);
	local misMoney = GetLabel(view, uiList.ID_CTRL_TEXT_MONEY_V);
	local misExp = GetLabel(view, uiList.ID_CTRL_TEXT_EXP_V);
	local misGhost = GetLabel(view, uiList.ID_CTRL_TEXT_GHO_V);
	local misReward1 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD1);
	local misReward2 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD2);
	local misReward3 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD3);
	local misRewardT = {}
	misRewardT[1] = misReward1;
	misRewardT[2] = misReward2;
	misRewardT[3] = misReward3;
	local missionTable = SelectRowInner(T_MISSION,"id",misId);
	if 	missionTable == nil then
		WriteCon("missionTable error");
		return;
	end
	misName:SetText(missionTable.name);
	misStep:SetText(missionTable.step);
	misPower:SetText(missionTable.move_cost);
	misMoney:SetText(missionTable.money);
	misExp:SetText(missionTable.exp);
	misGhost:SetText(missionTable.soul);

	local rewardId = missionTable.reward_id;
	WriteConErr("rewardId == "..rewardId);

	local rewardTable = SelectRowList(T_MISSION_REWARD,"id",rewardId);
	if rewardTable == nil then
		WriteCon("rewardTable error");
		return
	end
	--local rewardGroupTable = rewardTable
	--local rewardGroupTable = {};
	-- for k,v in pairs(rewardTable) do
		-- if tonumber(v.group) == 1 then
			-- rewardGroupTable[#rewardGroupTable + 1] = v;
		-- end
	-- end
	
	local picIndex = nil;
	local itemT = nil;
	local itemType = nil;
	local itemId = nil;
	for i = 1,#rewardTable do
		itemType = tonumber(rewardTable[i].item_type)
		itemId = tonumber(rewardTable[i].item_id)

		if itemType == QUEST_ITEM_TYPE_MATERIAL then
			itemT = SelectRowInner(T_MATERIAL,"id",itemId);
			picIndex = itemT.item_pic;
		elseif itemType == QUEST_ITEM_TYPE_CARD then
			itemT = SelectRowInner(T_CHAR_RES,"card_id",itemId);
			picIndex = itemT.head_pic;
		elseif itemType == QUEST_ITEM_TYPE_EQUIP then
			itemT = SelectRowInner(T_EQUIP,"id",itemId);
			picIndex = itemT.item_pic;
		elseif itemType == QUEST_ITEM_TYPE_GIFT or itemType == QUEST_ITEM_TYPE_TREASURE 
				or itemType == QUEST_ITEM_TYPE_OTHER or itemType == QUEST_ITEM_TYPE_SHOP then
			itemT = SelectRowInner(T_ITEM,"id",itemId);
			picIndex = itemT.item_pic;
		end
		misRewardT[i]:SetPicture( GetPictureByAni(picIndex, 0));
	end
--	local misDifficultPic = GetImage(view, uiList.ID_CTRL_PICTURE_DIFFICULT);
	
	local rewardBtn = GetButton(view, uiList.ID_CTRL_BUTTON_REWARD);
	rewardBtn:SetLuaDelegate(p.OnRewardBtnClick)
	rewardBtn:SetId(misId);
end

function p.OnRewardBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if ( uiList.ID_CTRL_BUTTON_REWARD == tag) then
			WriteCon("OnRewardBtnClick");
		end
	end
end

function p.showTeamItem(missionId,storyId)
	local teamId = tonumber(msg_cache.msg_player.CardTeam)
	WriteCon("now team Id = "..teamId);
	quest_team_item.ShowUI(missionId,p.stageId,teamId,storyId);
	p.CloseUI()
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
		p.Clear();
	end
end

function p.Clear()
	p.power = nil;
	p.stageId = nil;	--关卡ID
	p.missionId = nil; 	--任务ID
	p.missionList = nil;
end
function p.UIDisappear()
	p.CloseUI();
	--maininterface.BecomeFirstUI();
	maininterface.BecomeFirstUI();
	maininterface.CloseAllPanel();
	maininterface.ShowUI();
end
