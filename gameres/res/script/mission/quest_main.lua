quest_main = {}
local p = quest_main;

p.layer = nil;
local ui = ui_quest_main;

p.StageId = nil;	--关卡ID
p.questId = nil; 	--任务ID

p.questList = {};	--服务端下发列表
p.data = {};		--数据

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
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch(false);
	--layer:SetFrameRectFull();
	
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
	if p.StageId then
		p.questId = tonumber(p.StageId.."011");
		WriteCon(tostring(p.questId));
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
	--WriteCon(tostring(p.StageId));
	local SId = tonumber(p.StageId)
	p.data = quest_data[SId];
	
	local QuestListTable = GetListBoxVert(p.layer, ui.ID_CTRL_VERTICAL_LIST_QUEST);
	local num = p.data["questBattleNum"]
	WriteCon("====="..num.."======");
	
	local QId = p.questId;
	
	for i = 1, num do
		WriteCon("QID ========"..QId);

		local view = createNDUIXView();
		view:Init();
		LoadUI("quest_list_640X960.xui",view, nil);
		--隐藏默认UI
		p.HideStar(view);
		p.HideItem(view);
		
		local bg = GetUiNode(view, ui_quest_list.ID_CTRL_PICTURE_QUESTLIST_BG);
		view:SetViewSize( CCSizeMake(bg:GetFrameSize().w, bg:GetFrameSize().h));
		view:SetId(QId);
		
		--信息初始化
		p.InitText(QId, view);
				
		for k = QId, QId+2 do
			if k == QId then
				if p.questList["B"..k] then
					local easyBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_EASY);
					easyBtn:SetLuaDelegate(p.OnListBtnClick);
					easyBtn:SetEnabled(true);
					--easyBtn:SetChecked(true);
					easyBtn:SetId(k);
					WriteCon("k"..k);
					
				--设置挑战按钮ID
					local fightBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_MISSION_START);
					fightBtn:SetLuaDelegate(p.OnFightBtnClick);
					fightBtn:SetId(k);
					
				--显示通关评价和挑战次数
					local QKey = "B"..k;
					local StarNum = p.questList[QKey]["High_score"]
					p.ShowStar(view,StarNum)

					local times = p.questList[QKey]["Fight_num"]
					local text = times.."/"..p.data[k]["times"]
					local timesText = GetLabel(view, ui_quest_list.ID_CTRL_TEXT_MISSION_TIMES);
					timesText:SetText(ToUtf8(text));
				else
					local easyBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_EASY);
					easyBtn:SetLuaDelegate(p.OnListBtnClick);
					easyBtn:SetEnabled(false);
					--easyBtn:SetChecked(false);
					
					local fightBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_MISSION_START);
					fightBtn:SetLuaDelegate(p.OnFightBtnClick);
					fightBtn:SetEnabled(false);
				end
			elseif k == QId + 1 then
				if p.questList["B"..k] then
					local normalBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_NORMAL);
					normalBtn:SetLuaDelegate(p.OnListBtnClick);
					normalBtn:SetEnabled(true);
					--normalBtn:SetChecked(false);
					normalBtn:SetId(k);
					WriteCon("k"..k);
				else
					local normalBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_NORMAL);
					normalBtn:SetLuaDelegate(p.OnListBtnClick);
					normalBtn:SetEnabled(false);
					--normalBtn:SetChecked(false);
				end
			elseif k == QId + 2 then
				if p.questList["B"..k] then
					local difficultBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_DIFFICULT);
					difficultBtn:SetLuaDelegate(p.OnListBtnClick);
					difficultBtn:SetEnabled(true);
					--difficultBtn:SetChecked(false);
					difficultBtn:SetId(k);
					WriteCon("k"..k);
				else
					local difficultBtn = GetButton(view, ui_quest_list.ID_CTRL_BUTTON_DIFFICULT);
					difficultBtn:SetLuaDelegate(p.OnListBtnClick);
					difficultBtn:SetEnabled(false);
					--difficultBtn:SetChecked(false);
				end
			end
		end

		QuestListTable:AddView(view);
		QId = QId + 10;
	end
	
	local ListLength = 0;
	for k,v in pairs(p.questList) do
		ListLength = ListLength + 1;
		WriteCon(k);
	end
	WriteCon("**ListLength = "..ListLength); 
end
	

--战斗按钮
function p.OnFightBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		WriteCon("=========OnFightBtnClick==========");
		p.CloseUI();
		world_map.CloseMap();
		local btnId = uiNode:GetId();
		WriteCon("btnID======"..btnId);
		dlg_drama.ShowUI(1);
		--x_battle_mgr.EnterBattle();
	end
end

function p.OnListBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		WriteCon("=========OnListBtnClick==========");
		local parentNode = uiNode:GetParent();
		local viewId = parentNode:GetId();
		local btnID = uiNode:GetId();
		WriteCon("viewId====="..viewId);
		WriteCon("btnID======"..btnID);
		local moneyText = GetLabel(parentNode, ui_quest_list.ID_CTRL_TEXT_MONEY);
		moneyText:SetText(ToUtf8(p.data[btnID]["money"]));
		
		local expText = GetLabel(parentNode, ui_quest_list.ID_CTRL_TEXT_EXP);
		expText:SetText(ToUtf8(p.data[btnID]["exp"]));
		
		local ItemNum = p.data[btnID]["item"]
		p.ShowItem(parentNode,ItemNum);
		
		local QKey = "B"..btnID;
		
		local StarNum = p.questList[QKey]["High_score"]
		p.ShowStar(parentNode,StarNum)

		local times = p.questList[QKey]["Fight_num"]
		local text = times.."/"..p.data[btnID]["times"]
		local timesText = GetLabel(parentNode, ui_quest_list.ID_CTRL_TEXT_MISSION_TIMES);
		timesText:SetText(ToUtf8(text));
		
		local fightBtn = GetButton(parentNode, ui_quest_list.ID_CTRL_BUTTON_MISSION_START);
		fightBtn:SetLuaDelegate(p.OnFightBtnClick);
		fightBtn:SetId(btnID);
	end
end
	
--信息初始化
function p.InitText(QId, view)
	local quest_Id = QId;
	local questName = GetLabel(view, ui_quest_list.ID_CTRL_TEXT_25);
	questName:SetText(ToUtf8(p.data[quest_Id]["name"]));
	
	local moneyText = GetLabel(view, ui_quest_list.ID_CTRL_TEXT_MONEY);
	moneyText:SetText(ToUtf8(p.data[quest_Id]["money"]));

	local expText = GetLabel(view, ui_quest_list.ID_CTRL_TEXT_EXP);
	expText:SetText(ToUtf8(p.data[quest_Id]["exp"]));

	local timesText = GetLabel(view, ui_quest_list.ID_CTRL_TEXT_MISSION_TIMES);
	local text = "0/"..p.data[quest_Id]["times"]
	timesText:SetText(ToUtf8(text));

	local ItemNum = p.data[quest_Id]["item"]
	p.ShowItem(view,ItemNum);
end

--通关评价
function p.HideStar(view)
	local star1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR1)
	star1:SetVisible(false);
	local star2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR2)
	star2:SetVisible(false);
	local star3 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR3)
	star3:SetVisible(false);
end
	
function p.ShowStar(view,num)
	if num == 1 or num == "1" then
		local star1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR1)
		star1:SetVisible(true);
		local star2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR2)
		star2:SetVisible(false);
		local star3 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR3)
		star3:SetVisible(false);
	elseif num == 2 or num == "2" then
		local star1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR1)
		star1:SetVisible(true);
		local star2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR2)
		star2:SetVisible(true);
		local star3 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_STAR3)
		star3:SetVisible(false);
	elseif num == 3 or num == "3" then
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

--奖励物品图标
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
		local Item2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM2)
		Item2:SetVisible(false);
		local item3 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM3)
		item3:SetVisible(false);
	elseif num == 2 then
		local Item1 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM1)
		Item1:SetVisible(true);
		local Item2 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM2)
		Item2:SetVisible(true);
		local item3 = GetImage(view, ui_quest_list.ID_CTRL_PICTURE_ITEM3)
		item3:SetVisible(false);
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
