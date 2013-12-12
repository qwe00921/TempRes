quest_main = {}
local p = quest_main;

p.layer = nil;
local ui = ui_quest_main_view;
local uiList = ui_quest_list_view;
local missionIdGap = 10;
local num_easy = nil;
local num_normal = nil;
local num_difficult = nil;

p.stageId = nil;	--关卡ID
p.missionId = nil; 	--任务ID

p.stageTable = nil;		--关卡静态数据
--p.missionTable = nil;

p.missionList = {};	--服务端下发列表
p.curBtnNode = nil;		--选中标记
p.power = nil; 		--获取玩家体力值

function p.ShowUI(stageId)
	p.stageId  = stageId;
	
	--获取missionId初始值
	p.GetMissionId();
	--获取章节静态数据
	p.GetStageTable();

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
	layer:SetFrameRectFull();
	
	GetUIRoot():AddDlg(layer);
	LoadUI("quest_main_view.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	--设置章节名字
	local stageName = GetLabel(p.layer, ui.ID_CTRL_TEXT_QUEST_NAME_6);
	stageName:SetText(p.stageTable[1].stage_name);
	
	WriteCon("send mission request");
	local uid = GetUID();
	local param = "MachineType=Android&Stage_id="..p.stageId;
	SendReq("Mission","MissionList",uid,param);
	--p.ShowQuestList();
end

function p.GetMissionId()
	if p.stageId then
		p.missionId = tonumber(p.stageId.."011");
		WriteCon(tostring(p.missionId));
	end
end

function p.GetStageTable()
	local Table = SelectRowList(T_STAGE,"stage_id",p.stageId);
	if #Table == 1 then 
		p.stageTable = Table;
		num_easy = tonumber(p.stageTable[1].easy_count);
		num_normal = tonumber(p.stageTable[1].normal_count);
		num_difficult = tonumber(p.stageTable[1].difficult_count);
	else
		WriteCon("stageTable error");
	end
end

function p.SetDelegate()
	--返回
	local btnBack = GetButton( p.layer, ui.ID_CTRL_BTN_TETURN_2 );
	btnBack:SetLuaDelegate(p.OnBtnClick);
	--简单
	local btnEasy =  GetButton(p.layer, ui.ID_CTRL_BTN_EAYE_7);
	btnEasy:SetLuaDelegate(p.OnBtnClick);
	p.SetBtnCheckedFX( btnEasy );--设置初始状态
	--普通
	local BtnNormal =  GetButton(p.layer, ui.ID_CTRL_BTN_NORMAL_8);
	BtnNormal:SetLuaDelegate(p.OnBtnClick);
	--困难
	local BtnDifficult =  GetButton(p.layer, ui.ID_CTRL_BTN_HARD_9);
	BtnDifficult:SetLuaDelegate(p.OnBtnClick);
end

--按钮事件
function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_BTN_TETURN_2 == tag) then
			WriteCon("return");
			p.CloseUI();
			stageMap_1.OpenStageMap();
		elseif (ui.ID_CTRL_BTN_EAYE_7 == tag) then
			WriteCon("easy");
            p.SetBtnCheckedFX( uiNode );
			local missionStartId = p.missionId;
			p.loadMissionList(missionStartId,num_easy);
		elseif (ui.ID_CTRL_BTN_NORMAL_8 == tag) then
			WriteCon("normal");
            p.SetBtnCheckedFX( uiNode );
			local missionStartId = p.missionId + 1;
			p.loadMissionList(missionStartId,num_normal);
		elseif (ui.ID_CTRL_BTN_HARD_9 == tag) then
			WriteCon("hard");
            p.SetBtnCheckedFX( uiNode );
			local missionStartId = p.missionId + 2;
			p.loadMissionList(missionStartId,num_difficult);
		end
	end
end

--点击战斗按钮
function p.OnFightBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		WriteCon("=========OnFightBtnClick==========");
		local btnId = uiNode:GetId();
		local missionId = uiNode:GetId();
		local missionTable = SelectRowList(T_MISSION,"id",missionId);
		local powerLimit = tonumber(missionTable[1]["move_cost"]);
		local power = p.power;
		if power < powerLimit then
			dlg_msgbox.ShowOK("提示" ,  "体力值不足。");
			WriteCon("power not enough");
			return
		end
		local fightTimes = tonumber(p.missionList["M"..missionId]["Fight_num"])
		if fightTimes <= 0 then
			dlg_msgbox.ShowOK("提示" ,  "今日挑战次数已达上限。");
			return
		end
			
		--n_battle_mgr.EnterBattle( N_BATTLE_PVE, btnId );--进入战斗PVE
		local id = btnId;
		
		if p.missionList["M"..btnId] then
			local storyId = p.missionList["M"..btnId].Begin_story;
			WriteCon("storyId = "..storyId);
			if tonumber(storyId) ~= 0 then
				dlg_drama.ShowUI( id , storyId);
			else
				n_battle_mgr.EnterBattle( N_BATTLE_PVE, btnId );--进入战斗PVE
			end
		else
			n_battle_mgr.EnterBattle( N_BATTLE_PVE, btnId );--进入战斗PVE
		end
		p.CloseUI();
	end
end

function p.SetBtnCheckedFX( node )
    local btnNode = ConverToButton( node );
    if p.curBtnNode ~= nil then
        p.curBtnNode:SetChecked( false );
    end
    btnNode:SetChecked( true );
    p.curBtnNode = btnNode;
end

--显示列表
function p.ShowQuestList(self)
	if self.result == false then
		dlg_msgbox.ShowOK("错误提示","玩家数据错误，请联系开发人员。",nil,p.layer);
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

	p.setHardBtn();
	
	--加载列表
	local missionStartId = p.missionId;
	p.loadMissionList(missionStartId,num_easy);
end

function p.setHardBtn()
	local BtnDifficult =  GetButton(p.layer, ui.ID_CTRL_BTN_HARD_9);
	local BtnNormal =  GetButton(p.layer, ui.ID_CTRL_BTN_NORMAL_8);
	local normal_id = p.missionId + 1;
	local difficult_id = normal_id + 1;

	if p.missionList["M"..difficult_id] then
		BtnDifficult:SetEnabled(true);
		BtnNormal:SetEnabled(true);
	elseif p.missionList["M"..normal_id] then
		BtnDifficult:SetEnabled(false);
		BtnNormal:SetEnabled(true);
	else
		BtnDifficult:SetEnabled(false);
		BtnNormal:SetEnabled(false);
	end
end

function p.loadMissionList(missionStartId,num)
	local MisId = missionStartId;
	local count = num;
	local missionListTable = GetListBoxVert(p.layer, ui.ID_CTRL_VERTICAL_LIST_5);
	missionListTable:ClearView();
	
	for i = 1,count do
		--WriteCon("MisId =="..MisId);
		local view = createNDUIXView();
		view:Init();
		LoadUI("quest_list_view.xui",view, nil);
		
		--隐藏默认UI
		p.HideStar(view);
		p.HideItem(view);
		
		local bg = GetUiNode(view, uiList.ID_CTRL_PIC_LIST_BG);
		view:SetViewSize( CCSizeMake(bg:GetFrameSize().w, bg:GetFrameSize().h));
		view:SetId(MisId);
		
		--信息初始化
		p.setMissionInif(MisId,view);
		
		--加载服务端下发数据
		--战斗按钮
		local fightBtn = GetButton(view, uiList.ID_CTRL_BUTTON_FIGHTING);
		fightBtn:SetLuaDelegate(p.OnFightBtnClick);
		local MisKey = "M"..MisId;
		if p.missionList[MisKey] then
			--WriteCon("=====true");
			fightBtn:SetEnabled(true);
			fightBtn:SetId(MisId);
			local timesText = GetLabel(view, uiList.ID_CTRL_TEXT_TIEMS_V);
			local missionTable = SelectRowInner(T_MISSION,"id",MisId);
			local text = p.missionList[MisKey]["Fight_num"].."/"..missionTable["fight_limit"]
			timesText:SetText(text);
			--显示星级
			local StarNum = p.missionList[MisKey]["High_score"]
			p.ShowStar(view,StarNum)
		else
			--WriteCon("=====false=====");
			fightBtn:SetEnabled(false);
		end
			
		missionListTable:AddView(view);
		MisId = MisId + missionIdGap;
	end
end

--读取静态表数据
function p.setMissionInif(MisId, view)
	local mis_id = MisId;
	local misstionName = GetLabel(view, uiList.ID_CTRL_TEXT_QUEST_NAME_V);
	local power = GetLabel(view, uiList.ID_CTRL_TEXT_POWER_V);
	local expText = GetLabel(view, uiList.ID_CTRL_TEXT_EXP_V);
	local moneyText = GetLabel(view, uiList.ID_CTRL_TEXT_MONEY_V);
	local timesText = GetLabel(view, uiList.ID_CTRL_TEXT_TIEMS_V);
	local item1 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD1);
	local item2 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD2);
	--local item3 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD3);
	
	local missionTable = SelectRowInner(T_MISSION,"id",mis_id);
	if 	missionTable == nil then
		WriteCon("missionTable error");
		return;
	end
	misstionName:SetText(missionTable.mission_name);
	power:SetText(missionTable.move_cost);
	expText:SetText(missionTable.reward_exp);
	moneyText:SetText(missionTable.reward_money);
	local text = missionTable["fight_limit"].."/"..missionTable["fight_limit"]
	timesText:SetText(text);
	
	local rewardId = missionTable.reward_id;
	--WriteCon("rewardId==="..rewardId);

	local rewardTable = SelectRowList(T_MISSION_REWARD,"reward_id",rewardId);
	if rewardTable == nil then
		WriteCon("rewardTable error");
		return
	end
	local rewardGroupTable = {};
	for k,v in pairs(rewardTable) do
		if tonumber(v.group) == 1 then
			rewardGroupTable[#rewardGroupTable + 1] = v;
		end
	end
	local rewardItemId = nil;
	if rewardGroupTable[1]["type_id"] then
		rewardItemId = tonumber(rewardGroupTable[1]["type_id"]);
		local typeID = tonumber(rewardGroupTable[1]["type"]);
		if typeID == 1 then	--物品
			local itemTable = SelectRowInner(T_ITEM,"id",rewardItemId);
			item1:SetVisible(true);
			item1:SetPicture( GetPictureByAni(itemTable.item_pic, 0) );
		elseif typeID == 2 then --卡牌
			--local itemInfoTable = SelectRowInner(T_CARD,"id",rewardItemId);
			local cardTable = SelectRowInner(T_CHAR_RES,"card_id",rewardItemId);
			item1:SetVisible(true);
			item1:SetPicture( GetPictureByAni(cardTable.head_pic, 0) );
			--WriteCon("tonumberv.type==="..tonumber(v.type));
		elseif typeID == 4 then	--装备
			local equipTable = SelectRowInner(T_EQUIP,"id",rewardItemId);
			item1:SetVisible(true);
			item1:SetPicture( GetPictureByAni(equipTable.item_pic, 0) );
		end
	end
	if rewardGroupTable[2]["type_id"] then
		rewardItemId = tonumber(rewardGroupTable[2]["type_id"]);
		local typeID = tonumber(rewardGroupTable[2]["type"]);
		if typeID == 1 then	--物品
			local itemTable = SelectRowInner(T_ITEM,"id",rewardItemId);
			item2:SetVisible(true);
			item2:SetPicture( GetPictureByAni(itemTable.item_pic, 0) );
		elseif typeID == 2 then --卡牌
			--local itemInfoTable = SelectRowInner(T_CARD,"id",rewardItemId);
			local cardTable = SelectRowInner(T_CHAR_RES,"card_id",rewardItemId);
			item2:SetVisible(true);
			item2:SetPicture( GetPictureByAni(cardTable.head_pic, 0) );
			--WriteCon("tonumberv.type==="..tonumber(v.type));
		elseif typeID == 4 then	--装备
			local equipTable = SelectRowInner(T_EQUIP,"id",rewardItemId);
			item2:SetVisible(true);
			item2:SetPicture( GetPictureByAni(equipTable.item_pic, 0) );
		end
	end
	--local rewardId1 = tonumber(missionTable["reward_1"]);
	--local rewardId2 = tonumber(missionTable["reward_2"]);
	--local rewardId3 = tonumber(missionTable[1]["reward_3"]);
	-- if rewardId1 ~= nil  then
		-- item1:SetPicture(GetPictureByAni("item.reward", rewardId1));
	-- end
	-- if rewardId2 ~= nil  then
		-- item2:SetPicture(GetPictureByAni("item.reward", rewardId2));
	-- end
	--if rewardId3 ~= nil  then
	--	item3:SetVisible(true);
	--	item3:SetPicture(GetPictureByAni("item.reward", rewardId3));
	--end

end


--隐藏通关评价
function p.HideStar(view)
	local star1 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR1)
	star1:SetVisible(false);
	local star2 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR2)
	star2:SetVisible(false);
	local star3 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR3)
	star3:SetVisible(false);
end

function p.ShowStar(view,num)
	if num == 1 or num == "1" then
		local star1 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR1)
		star1:SetVisible(true);
		local star2 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR2)
		star2:SetVisible(false);
		local star3 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR3)
		star3:SetVisible(false);
	elseif num == 2 or num == "2" then
		local star1 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR1)
		star1:SetVisible(true);
		local star2 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR2)
		star2:SetVisible(true);
		local star3 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR3)
		star3:SetVisible(false);
	elseif num == 3 or num == "3" then
		local star1 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR1)
		star1:SetVisible(true);
		local star2 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR2)
		star2:SetVisible(true);
		local star3 = GetImage(view, uiList.ID_CTRL_PICTURE_STAR3)
		star3:SetVisible(true);
	else
		return;
	end
end

--隐藏奖励物品图标
function p.HideItem(view)
	local Item1 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD1)
	Item1:SetVisible(false);
	local Item2 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD2)
	Item2:SetVisible(false);
	--local item3 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD3)
	--item3:SetVisible(false);
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
	p.stageId = nil;	--关卡ID
	p.missionId = nil; 	--任务ID
	p.stageTable = nil;		--关卡静态数据
	p.missionList = {};	--服务端下发列表
	p.curBtnNode = nil;		--选中标记
	p.power = nil; 		--获取玩家体力值
end
