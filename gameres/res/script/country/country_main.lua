NOW_COUNTRY_NUM = 9

country_main = {};
local p = country_main;
local ui = ui_country;

p.layer = nil;
p.openViewTypeT = {};
p.openTypeNum = 1;
p.openViewT = {};
p.countryInfoT = {};

local uiNodeT = {}

function p.ShowUI()
	if country_building then
		country_building.CloseUI()
	end
	
	dlg_menu.SetNewUI( p );
	dlg_userinfo.HideUI();
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		
		--开启拾取队列计时器
		--country_collect.StartTick();
		--country_collect.SetLayer( p.layer );
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	
	GetUIRoot():AddChild(layer);

	LoadUI( "country.xui" , layer, nil );
	
	p.layer = layer;
	
	--设置代理
	p.SetDelegate();
	
	--初始化控件
	p.InitController();
	
	--开启拾取队列计时器
	country_collect.StartTick();
	country_collect.SetLayer( p.layer );
	
	maininterface.HideUI();
end

function p.InitController()
	--名字
	uiNodeT.textNameT = {}
	uiNodeT.textNameT[1] = "生产屋";
	uiNodeT.textNameT[2] = "装备屋";
	uiNodeT.textNameT[3] = "融合屋";
	uiNodeT.textNameT[4] = "住宅";
	uiNodeT.textNameT[5] = "材料仓库";
	uiNodeT.textNameT[6] = "河流";
	uiNodeT.textNameT[7] = "农田";
	uiNodeT.textNameT[8] = "矿山";
	uiNodeT.textNameT[9] = "森林";
	--名字，等级
	local produceName = GetLabel(p.layer, ui.ID_CTRL_TEXT_PRODUCE_LV);
	local equipName = GetLabel(p.layer, ui.ID_CTRL_TEXT_EQUIP_LV);
	local mergeName = GetLabel(p.layer, ui.ID_CTRL_TEXT_MERGE_LV);
	local homeName = GetLabel(p.layer, ui.ID_CTRL_TEXT_HOME_LV);
	local storeName = GetLabel(p.layer, ui.ID_CTRL_TEXT_STORE_LV);
	uiNodeT.headT = {}
	uiNodeT.headT[1] = produceName;
	uiNodeT.headT[2] = equipName;
	uiNodeT.headT[3] = mergeName;
	uiNodeT.headT[4] = homeName;
	uiNodeT.headT[5] = storeName;
	--名字框
	local headBoxBoxProduce = GetImage(p.layer, ui.ID_CTRL_PIC_PRODUCE_HEAD_BG);
	local headBoxBoxEquit = GetImage(p.layer, ui.ID_CTRL_PIC_EQUIP_HEAD_BG);
	local headBoxBoxMerge = GetImage(p.layer, ui.ID_CTRL_PIC_MERGE_HEAD_BG);
	local headBoxBoxHome = GetImage(p.layer, ui.ID_CTRL_PIC_HOME_HEAD_BG);
	local headBoxBoxStore = GetImage(p.layer, ui.ID_CTRL_PIC_STORE_HEAD_BG);
	uiNodeT.headBoxT = {}
	uiNodeT.headBoxT[1] = headBoxBoxProduce;
	uiNodeT.headBoxT[2] = headBoxBoxEquit;
	uiNodeT.headBoxT[3] = headBoxBoxMerge;
	uiNodeT.headBoxT[4] = headBoxBoxHome;
	uiNodeT.headBoxT[5] = headBoxBoxStore;
	--倒计时背景
	local timeBgProduce = GetImage(p.layer, ui.ID_CTRL_PIC_PRODUCE_ITEM_BG);
	local timeBgEquit = GetImage(p.layer, ui.ID_CTRL_PIC_EQUIP_ITEM_BG);
	local timeBgMerge = GetImage(p.layer, ui.ID_CTRL_PIC_MERGE_TIME_BG);
	local timeBgHome = GetImage(p.layer, ui.ID_CTRL_PIC_HOME_ITEM_BG);
	local timeBgStore = GetImage(p.layer, ui.ID_CTRL_PIC_STORE_ITEM_BG);
	uiNodeT.timeBgT = {}
	uiNodeT.timeBgT[1] = timeBgProduce;
	uiNodeT.timeBgT[2] = timeBgEquit;
	uiNodeT.timeBgT[3] = timeBgMerge;
	uiNodeT.timeBgT[4] = timeBgHome;
	uiNodeT.timeBgT[5] = timeBgStore;
	--倒计时文本
	local produceTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_PRODUCE_ITEM);
	local equipTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_EQUIP_TIME);
	local mergeTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_MERGE_TIME);
	local homeTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_HOME_TIME);
	local storeTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_STORE_TIME);
	uiNodeT.timeTextT = {}
	uiNodeT.timeTextT[1] = produceTime;
	uiNodeT.timeTextT[2] = equipTime;
	uiNodeT.timeTextT[3] = mergeTime;
	uiNodeT.timeTextT[4] = homeTime;
	uiNodeT.timeTextT[5] = storeTime;
	--倒计时条
	local produceBar = GetExp( p.layer, ui.ID_CTRL_EXP_PRODUCE );
	local equipBar = GetExp( p.layer, ui.ID_CTRL_EXP_EQUIP );
	local mergeBar = GetExp( p.layer, ui.ID_CTRL_EXP_MERGE );
	local homeBar = GetExp( p.layer, ui.ID_CTRL_EXP_HOME );
	local storeBar = GetExp( p.layer, ui.ID_CTRL_EXP_STORE );
	uiNodeT.timeBar = {}
	uiNodeT.timeBar[1] = produceBar;
	uiNodeT.timeBar[2] = equipBar;
	uiNodeT.timeBar[3] = mergeBar;
	uiNodeT.timeBar[4] = homeBar;
	uiNodeT.timeBar[5] = storeBar;
	--隐藏提示界面
	p.hideUpBuildView()
	--请求数据
	local uid = GetUID();
	local param = "";
	SendReq("Build","GetUserBuilds",uid,param);
end

function p.ShowCountry(backData)
	if backData.result == false then
		dlg_msgbox.ShowOK("错误提示","玩家数据错误。",nil,p.layer);
		return;
	end
	p.countryInfoT = backData.builds;
	if p.countryInfoT == nil then
		dlg_msgbox.ShowOK("错误提示","无村庄数据",nil,p.layer);
		return
	end
	--是否有新开启的建筑
	p.openViewT = backData.openani;
	-- p.openViewT["P1"] = 1;
	-- p.openViewT["P3"] = 3;
	-- p.openViewT["P7"] = 7;
	local openViewNum = 0;	
	if p.openViewT ~= nil then
		for k,v in pairs(p.openViewT) do
			openViewNum = openViewNum + 1;
		end
	end
	if openViewNum > 0 then
		WriteCon("openViewNum == "..openViewNum);
		--显示新开建筑
		p.showNewBuild(p.openViewT);
	else
		--显示村庄信息
		p.showCountryBuild(p.countryInfoT)
	end
end

--打开 开放建筑界面
function p.showNewBuild(openViewT)

	--WriteCon("p.openTypeNum == "..p.openTypeNum);
	--local keyNum = p.openTypeNum
	if p.openTypeNum <= NOW_COUNTRY_NUM then
		for i = p.openTypeNum,100 do
			WriteCon("p.openTypeNum == "..p.openTypeNum);
			if openViewT["P"..i] then
				WriteCon("showNewBuild");
				p.openTypeNum = i
				open_build.ShowUI(i)
				break;
			else
				p.openTypeNum = i + 1;
			end
			if i == 100 then
				p.showCountryBuild(p.countryInfoT)
			end
		end
	end
	--p.showCountryBuild(buildInfo)
	
end

function p.showCountryBuild(buildInfo)
	WriteCon("showCountryBuild");
	--local buildNum = 0;
	-- for k,v in pairs(buildInfo) do 
		-- buildNum = buildNum + 1;
	-- end
	for i = 1, 5 do
		if buildInfo["B"..i] then
			--显示名字，等级
			local headText = uiNodeT.textNameT[i].."LV:"..(buildInfo["B"..i].build_level);
			if uiNodeT.headT[i] then
				uiNodeT.headT[i]:SetText(headText);
			end
			--显示名字框
			uiNodeT.headBoxT[i]:SetPicture( GetPictureByAni("common_ui.countNameBox", 0));
			--是否在升级
			if tonumber(buildInfo["B"..i].is_upgrade) == 1 then
				--显示背景图
				uiNodeT.timeBgT[i]:SetPicture( GetPictureByAni("common_ui.levelBg", 0));
				--剩余时间
				local countDownTime = tonumber(buildInfo["B"..i].upgrade_time);
				--local nowTime = os.time();
				--local lastTime = countDownTime - nowTime;
				--local lastTime = 100;
				--升级所需时间
				local nextLV = tonumber(buildInfo["B"..i].upgrade_level)
				--local nextLV = 3;
				local upbuildTable =  SelectRowList(T_BUILDING,"type",i);
				if upbuildTable == nil then
					WriteConErr("upbuildTable is nil ");
				end
				local timeNeed = nil;
				for k,v in pairs(upbuildTable) do
					if tonumber(v.level) == nextLV then
						timeNeed = tonumber(v.upgrade_time)*60
					end
				end
				WriteCon("timeNeed == "..timeNeed);
				--时间条和文本节点
				local timeBar = uiNodeT.timeBar[i];
				timeBar:SetNoText()
				local timeTextNode = uiNodeT.timeTextT[i]
				--显示时间条
				time_bar.ShowTimeBar(0,timeNeed,countDownTime,timeBar,timeTextNode) 
			
			--是否刚升级完
			elseif tonumber(buildInfo["B"..i].update) == 1 then
				--显示背景图
				uiNodeT.timeBgT[i]:SetPicture( GetPictureByAni("common_ui.levelBg", 0));
				uiNodeT.timeTextT[i]:SetText("升级完成！");
				local uplevel = buildInfo["B"..i].build_level
				p.showUpBuildView(i,uplevel)
			end
		end
	end
end

function p.showUpBuildView(i,uplevel)
	local upBuildBg = Get9SlicesImage(p.layer,ui.ID_CTRL_9SLICES_UPBUILD_BG);
	upBuildBg:SetVisible(true);
	local upBuildHead = GetImage(p.layer,ui.ID_CTRL_PICTURE_UPBUILD);
	upBuildHead:SetVisible(true);
	local uiBuildText = GetLabel(p.layer,ui.ID_CTRL_TEXT_UPDUILD);
	uiBuildText:SetVisible(true);
	local text = "尊敬的主人，您的"..(uiNodeT.textNameT[i]).."已经成功升级到"..uplevel.."级了哦!"
	uiBuildText:SetText(text)
	
	--SetTimerOnce(p.hideUpBuildView, 3);
end
function p.hideUpBuildView()
	local upBuildBg = Get9SlicesImage(p.layer,ui.ID_CTRL_9SLICES_UPBUILD_BG);
	upBuildBg:SetVisible(false);
	local upBuildHead = GetImage(p.layer,ui.ID_CTRL_PICTURE_UPBUILD);
	upBuildHead:SetVisible(false);
	local uiBuildText = GetLabel(p.layer,ui.ID_CTRL_TEXT_UPDUILD);
	uiBuildText:SetVisible(false);
end

function p.SetDelegate()
	--建筑按钮
	local produceBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_PRODUCE );
	produceBtn:SetLuaDelegate(p.OnBtnClick);
	local equipBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_EQUIP );
	equipBtn:SetLuaDelegate(p.OnBtnClick);
	local mergeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_MERGE );
	mergeBtn:SetLuaDelegate(p.OnBtnClick);
	local homeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_HOME );
	homeBtn:SetLuaDelegate(p.OnBtnClick);
	local storeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_STORE );
	storeBtn:SetLuaDelegate(p.OnBtnClick);
	local riverBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RIVER );
	riverBtn:SetLuaDelegate(p.OnBtnClick);
	local fieldBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_FIELD );
	fieldBtn:SetLuaDelegate(p.OnBtnClick);
	local mountainBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_MOUNTAIN );
	mountainBtn:SetLuaDelegate(p.OnBtnClick);
	local treeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_TREE );
	treeBtn:SetLuaDelegate(p.OnBtnClick);

	uiNodeT.buildBtnT = {}
	uiNodeT.buildBtnT[1] = produceBtn;
	uiNodeT.buildBtnT[2] = equipBtn;
	uiNodeT.buildBtnT[3] = mergeBtn;
	uiNodeT.buildBtnT[4] = homeBtn;
	uiNodeT.buildBtnT[5] = storeBtn;
	uiNodeT.buildBtnT[6] = riverBtn;
	uiNodeT.buildBtnT[7] = fieldBtn;
	uiNodeT.buildBtnT[8] = mountainBtn;
	uiNodeT.buildBtnT[9] = treeBtn;
	
	--返回
	local returnBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RETURN );
	returnBtn:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		p.hideUpBuildView()
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_BUTTON_RETURN == tag) then
			WriteCon("return");
			p.CloseUI();
			time_bar.ClearData()
			
			--注销采集倒计时
			country_collect.EndTick();
		elseif ui.ID_CTRL_BUTTON_MOUNTAIN == tag then
			--country_collect.Collect( E_COLLECT_MOUNTAIN );
		elseif ui.ID_CTRL_BUTTON_TREE == tag then
			country_collect.Collect( E_COLLECT_TREE );
		elseif ui.ID_CTRL_BUTTON_RIVER == tag then
			country_collect.Collect( E_COLLECT_RIVER );
		elseif ui.ID_CTRL_BUTTON_FIELD == tag then
			country_collect.Collect( E_COLLECT_FIELD );
		elseif ui.ID_CTRL_BUTTON_PRODUCE == tag then
			if p.countryInfoT["B1"] then
				WriteCon("PRODUCE");
				--p.HideUI()
				country_building.ShowUI(p.countryInfoT)
			end
		elseif ui.ID_CTRL_BUTTON_EQUIP == tag then
			--p.HideUI()
			equip_room.ShowUI();
			WriteCon("EQUIP");
		elseif ui.ID_CTRL_BUTTON_MERGE == tag then
			WriteCon("MERGE");
			country_mixhouse.ShowUI();
			p.HideUI();
		elseif ui.ID_CTRL_BUTTON_HOME == tag then
			WriteCon("HOME");
			country_collect.Collect( E_COLLECT_HOME );
		elseif ui.ID_CTRL_BUTTON_STORE == tag then
			WriteCon("STORE");
			country_storage.ShowUI();
			p.HideUI();
		end
	end
end

function p.HideUI()
	WriteCon("country_main.HideUI");
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.ClearData()
		dlg_userinfo.ShowUI();
		maininterface.ShowUI();
	end
end
function p.ClearData()
	p.openViewTypeT = {};
	p.openTypeNum = 1;
	p.openViewT = {};
	p.countryInfoT = {};
	time_bar.ClearData()

end
function p.UIDisappear()
	p.CloseUI();
	country_building.CloseUI();
	maininterface.BecomeFirstUI();
	maininterface.CloseAllPanel();
	
	--注销采集倒计时
	country_collect.EndTick();
end
