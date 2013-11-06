quest_main = {}
local p = quest_main;

p.layer = nil;
local ui = ui_quest_main;

p.StageId = nil;

p.questList = {};
p.data = {};
p.viewId = 10001;

function p.ShowUI(Stage_id)
	p.StageId  = Stage_id;
	WriteCon(tostring(p.StageId));
	
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
	local stage_id = p.StageId;
	local param = "MachineType=Android&stage_id="..stage_id
	WriteCon(param);
	SendReq("Mission","GetUserMissionProgress",uid,param);
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

	local Stage_Id = p.StageId;
	local stageName = "Stage_"..Stage_Id
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
		view:SetId(p.viewId);
		
		local questId = p.viewId;
		local questName = GetLabel(view, ui_quest_list.ID_CTRL_TEXT_25);
		local quest_Id = "quest_"..questId
		local name = p.data[quest_Id]["name"]
		questName:SetText(ToUtf8(name));
		
		
		--隐藏通关评价和奖励物品
		p.HideStar(view);
		p.HideItem(view);
		--显示
		WriteCon("===========");
		p.ShowStar(view,2);
		p.ShowItem(view,1);
		
		QuestListTable:AddView(view);
		p.viewId = p.viewId + 1;
	end
	--for k,v in pairs() do
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
