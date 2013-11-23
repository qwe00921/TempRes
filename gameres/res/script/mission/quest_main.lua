quest_main = {}
local p = quest_main;

p.layer = nil;
local ui = ui_quest_main_view;
local uiList = ui_quest_list_view;

p.stageId = nil;	--关卡ID
p.missionId = nil; 	--任务ID

p.stageTable = nil;		--静态数据
--p.missionTable = nil;

p.missionList = {};	--服务端下发列表
p.data = {};		--数据

p.power = nil; 		--体力



function p.ShowUI(stageId)
	p.stageId  = stageId;
	WriteCon(tostring(p.stageId));
	
	--获取missionId初始值
	GetMissionId();
	--获取章节静态数据
	GetStageTable();
	
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
	
	GetUIRoot():AddChild(layer);
	LoadUI("quest_main_view.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	--设置章节名字
	local stageName = GetLabel(p.layer, ui.ID_CTRL_TEXT_QUEST_NAME_6);
	stageName:SetText(ToUtf8(p.stageTable[1].stage_name));
	
	WriteCon("send mission request");
	local uid = GetUID();
	local param = "MachineType=Android&stage_id="..p.stageId;
	WriteCon(param);
	SendReq("Mission","MissionList",uid,param);
	--p.ShowQuestList();
end


function GetMissionId()
	if p.stageId then
		p.missionId = tonumber(p.stageId.."011");
		WriteCon(tostring(p.missionId));
	end
end

function GetStageTable()
	local Table = SelectRowList(T_STAGE,"stage_id",p.stageId);
	if #Table == 1 then 
		p.stageTable = Table;
	else
		WriteCon("stageTable error");
	end
end

function p.SetDelegate()
	--返回
	local btnBack = GetButton( p.layer, ui.ID_CTRL_BTN_TETURN_2 );
	p.SetBtn(btnBack);
	--简单
	local btnEasy =  GetButton(p.layer, ui.ID_CTRL_BTN_EAYE_7);
	p.SetBtn(btnEasy);
	--普通
	local BtnNormal =  GetButton(p.layer, ui.ID_CTRL_BTN_NORMAL_8);
	p.SetBtn(BtnNormal);
	--困难
	local BtnDifficult =  GetButton(p.layer, ui.ID_CTRL_BTN_HARD_9);
	p.SetBtn(BtnDifficult);
end

function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
end

--按钮事件
function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		
		if (ui.ID_CTRL_BTN_TETURN_2 == tag) then
			WriteCon("return");
			p.CloseUI();
			--game_main.EnterWorldMap();
		elseif (ui.ID_CTRL_BTN_EAYE_7 == tag) then
			WriteCon("easy");
		elseif (ui.ID_CTRL_BTN_NORMAL_8 == tag) then
			WriteCon("normal");
		elseif (ui.ID_CTRL_BTN_HARD_9 == tag) then
			WriteCon("hard");
		--	WriteCon("商店");
		end
	end
end

--显示列表
function p.ShowQuestList(List)

	if List["missions"] then
		p.missionList = List["missions"]
	end
	
	for k,v in pairs(p.missionList) do
		WriteCon("missionList==sfsfd=="..tostring(k));

	end
	-- end
	WriteCon("missionList===="..tostring(p.missionList));

	local missionListTable = GetListBoxVert(p.layer, ui.ID_CTRL_VERTICAL_LIST_5);
	local num = p.stageTable[1].easy_count;
	WriteCon("====="..num.."======");

	local MID = p.missionId;
	
	for i = 1,num do
		WriteCon("MID ========"..MID);
		local view = createNDUIXView();
		view:Init();
		LoadUI("quest_list_view.xui",view, nil);
		
		--隐藏默认UI
		p.HideStar(view);
		p.HideItem(view);
		
		local bg = GetUiNode(view, uiList.ID_CTRL_PIC_LIST_BG);
		view:SetViewSize( CCSizeMake(bg:GetFrameSize().w, bg:GetFrameSize().h));
		view:SetId(MID);
		
		--信息初始化
		p.InitMission(MID,view);
		
		--加载数据
		local k = MID;
		--战斗按钮
		local fightBtn = GetButton(view, uiList.ID_CTRL_BUTTON_FIGHTING);
		fightBtn:SetLuaDelegate(p.OnFightBtnClick);
			WriteCon("M"..k);

		if p.missionList["M"..k] then
			WriteCon("=====fsfsdfd=====");
			fightBtn:SetEnabled(true);
			fightBtn:SetId(k);
			
			local timesText = GetLabel(view, uiList.ID_CTRL_TEXT_TIEMS_V);
			local missionTable = SelectRowList(T_MISSION,"mission_id",mis_id);
			local text = p.missionList["M"..k]["Fight_num"].."/"..missionTable[1]["times"]
			timesText:SetText(ToUtf8(text));
			
		else
			WriteCon("=====false=====");
			fightBtn:SetEnabled(false);
		end
		
		missionListTable:AddView(view);
		MID = MID + 10;
		
	end

end

--信息初始化
function p.InitMission(MID, view)
	local mis_id = MID;
	local misstionName = GetLabel(view, uiList.ID_CTRL_TEXT_QUEST_NAME_V);
	local power = GetLabel(view, uiList.ID_CTRL_TEXT_POWER_V);
	local expText = GetLabel(view, uiList.ID_CTRL_TEXT_EXP_V);
	local moneyText = GetLabel(view, uiList.ID_CTRL_TEXT_MONEY_V);
	local timesText = GetLabel(view, uiList.ID_CTRL_TEXT_TIEMS_V);
	local item1 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD1);
	local item2 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD2);
	local item3 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD3);
	
	local missionTable = SelectRowList(T_MISSION,"mission_id",mis_id);
	if #missionTable == 1 then 
		misstionName:SetText(ToUtf8(missionTable[1]["name"]));
		power:SetText(ToUtf8(missionTable[1]["power"]));
		expText:SetText(ToUtf8(missionTable[1]["exp"]));
		moneyText:SetText(ToUtf8(missionTable[1]["money"]));
		local text = "0/"..missionTable[1]["times"]
		timesText:SetText(ToUtf8(text));
		
		local rewardId1 = tonumber(missionTable[1]["reward_1"]);
		local rewardId2 = tonumber(missionTable[1]["reward_2"]);
		local rewardId3 = tonumber(missionTable[1]["reward_3"]);
		if rewardId1 ~= nil  then
			item1:SetVisible(true);
			item1:SetPicture(GetPictureByAni("item.reward", rewardId1));
		end
		if rewardId2 ~= nil  then
			item2:SetVisible(true);
			item2:SetPicture(GetPictureByAni("item.reward", rewardId2));
		end
		if rewardId3 ~= nil  then
			item3:SetVisible(true);
			item3:SetPicture(GetPictureByAni("item.reward", rewardId3));
		end
	else
			WriteCon("missionTable error");
	end
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
	local item3 = GetImage(view, uiList.ID_CTRL_PICTURE_REWARD3)
	item3:SetVisible(false);
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
