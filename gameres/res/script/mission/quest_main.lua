quest_main = {}
local p = quest_main;

p.layer = nil;
local ui = ui_quest_main;

p.StageId = nil;
p.questId = nil;

p.questList = {};
p.data = {};

function p.ShowUI(Stage_id)
	p.StageId  = Stage_id;
	WriteCon(tostring(p.StageId));
	
	--获取StageId初始值
	GetQuestId();
	
	if p.layer ~= nil then
		p.layer:SetVisible(true);
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddChild(layer);
	LoadUI("quest_main_640X960.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	--p.ShowQuestList();
	WriteCon("发送任务列表请求");
	local uid = GetUID();
	local param = "MachineType=Android&stage_id="..p.StageId;
	WriteCon(param);
	SendReq("Mission","GetUserMissionProgress",uid,param);
end

function GetQuestId()
	if p.StageId == 101 then
		p.questId = 101011
	elseif p.StageId == 102 then
		p.questId = 101012
	else 
		p.questId = 101011
	end
end

function p.SetDelegate()
	--返回，关闭
	local btnBack = GetButton( p.layer, ui.ID_CTRL_BUTTON_BACK );
	p.SetBtn(btnBack);
end

function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
end

--按钮事件
function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		
		if (ui.ID_CTRL_BUTTON_BACK == tag) then
			WriteCon("关闭");
			p.CloseUI();
			--game_main.EnterWorldMap();
		--elseif () then
		--	WriteCon("商店");
		end
	end
end
	
	
function p.ShowQuestList(quest_list)
	p.questList = quest_list;

	local stageName = "Stage_"..p.StageId
	p.data = quest_data[stageName];
	
	
	local QuestListTable = GetListBoxVert(p.layer, ui.ID_CTRL_VERTICAL_LIST_QUEST);
	local num = p.data["questBattleNum"]
	WriteCon("====="..num.."======");
	
	for i = 1, num do
		local view = createNDUIXView();
		view:Init();
		LoadUI("quest_list_640X960.xui",view, nil);

		local bg = GetUiNode(view, ui_quest_list.ID_CTRL_PICTURE_QUESTLIST_BG);
		view:SetViewSize( CCSizeMake(bg:GetFrameSize().w, bg:GetFrameSize().h));
		view:SetId(p.questId);
		--隐藏默认UI
		p.HideStar(view);
		p.HideItem(view);
		
		local fightBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_MISSION_START);
		fightBtn:SetLuaDelegate(p.OnFightBtnClick);
		
		local easyBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_EASY);
		easyBtn:SetLuaDelegate(p.OnListBtnClick);
		local normalBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_NORMAL);
		normalBtn:SetLuaDelegate(p.OnListBtnClick);
		local difficultBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_DIFFICULT);
		difficultBtn:SetLuaDelegate(p.OnListBtnClick);

		local quest_Id = "quest_"..p.questId
		WriteCon(quest_Id);
		local questName = GetLabel(view, ui_quest_list.ID_CTRL_TEXT_25);
		questName:SetText(ToUtf8(p.data[quest_Id]["name"]));
		
		local moneyText = GetLabel(view, ui_quest_list.ID_CTRL_TEXT_MONEY);
		moneyText:SetText(ToUtf8(p.data[quest_Id]["easy"]["money"]));

		local expText = GetLabel(view, ui_quest_list.ID_CTRL_TEXT_EXP);
		expText:SetText(ToUtf8(p.data[quest_Id]["easy"]["exp"]));

		local timesText = GetLabel(view, ui_quest_list.ID_CTRL_TEXT_MISSION_TIMES);
		local text = "0/"..p.data[quest_Id]["easy"]["times"]
		timesText:SetText(ToUtf8(text));

		local ItemNum = p.data[quest_Id]["easy"]["item"]
		p.ShowItem(view,ItemNum);
		-- p.ShowStar(view,2);

		QuestListTable:AddView(view);
		p.questId = p.questId + 1;
	end
	local ListLength = 0
	for k,v in pairs(p.questList) do
		ListLength = ListLength + 1;
	end
	WriteCon("**ListLength = "..ListLength); 
	
	--for
end
	
function p.OnFightBtnClick(uiNode,uiEventType,param)
		WriteCon("战斗");
		p.CloseUI();
		x_battle_mgr.EnterBattle();

end

function p.OnListBtnClick(uiNode,uiEventType,param)
		WriteCon("难度");
end
	
--隐藏通关评价
function p.HideStar(view)
	local star1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR1)
	star1:SetVisible(false);
	local star2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR2)
	star2:SetVisible(false);
	local star3 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR3)
	star3:SetVisible(false);
end
	
function p.ShowStar(view,num)
	if num == 1 then
		local star1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR1)
		star1:SetVisible(true);
	elseif num == 2 then
		local star1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR1)
		star1:SetVisible(true);
		local star2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR2)
		star2:SetVisible(true);
	elseif num == 3 then
		local star1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR1)
		star1:SetVisible(true);
		local star2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR2)
		star2:SetVisible(true);
		local star3 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR3)
		star3:SetVisible(true);
	else
		return;
	end
end

--隐藏奖励物品图标
function p.HideItem(view)
	local Item1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM1)
	Item1:SetVisible(false);
	local Item2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM2)
	Item2:SetVisible(false);
	local item3 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM3)
	item3:SetVisible(false);
end
	
function p.ShowItem(view,num)
	if num == 1 then
		local Item1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM1)
		Item1:SetVisible(true);
	elseif num == 2 then
		local Item1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM1)
		Item1:SetVisible(true);
		local Item2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM2)
		Item2:SetVisible(true);
	elseif num == 3 then
		local Item1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM1)
		Item1:SetVisible(true);
		local Item2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM2)
		Item2:SetVisible(true);
		local item3 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM3)
		item3:SetVisible(true);
	else
		return;
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
