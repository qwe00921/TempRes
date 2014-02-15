NOW_COUNTRY_NUM = 9

country_main = {};
local p = country_main;
local ui = ui_country;

p.layer = nil;
p.openViewTypeT = {};
p.openTypeNum = 1;
p.openViewT = {};
p.countryInfoT = {};

p.birdImage = {};
p.birdEffectNum = 0;
p.cloudEffectNum = 0;

p.timer1 = nil;
p.timer2 = nil;

p.randompool = {1,2,3,4,5,2,3,4,5};

local uiNodeT = {}

function p.ShowUI()
	if country_building then
		country_building.CloseUI()
	end
	dlg_menu.SetNewUI( p );
	maininterface.HideUI();
	dlg_userinfo.HideUI();
	PlayMusic_Country();
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
	
	local pic = GetPictureByAni("lancer.temp_bg", 2); 
	maininterface.m_bgImage:SetPicture( pic );
	maininterface.m_bgImage:SetFrameRectByPictrue(pic);
	
	p.layer = layer;
	
	--设置代理
	p.SetDelegate();
	
	--初始化控件
	p.InitController();
	
	--开启拾取队列计时器
	country_collect.StartTick();
	country_collect.SetLayer( p.layer );
	
	p.birdEffectNum = math.random(3,6);
	p.cloudEffectNum = math.random(4,7);
	
	p.BeginTimer();
end

function p.BeginTimer()
	if p.timer1 ~= nil then
		KillTimer( p.timer1 );
		p.timer1 = nil;
	end
	if p.timer2 ~= nil then
		KillTimer( p.timer2 );
		p.timer2 = nil;
	end
	p.timer1 = SetTimer( p.AddBirdEffect, 0.5 );
	p.timer2 = SetTimer( p.AddCloudEffect, 0.5 );
end

function p.AddBirdEffect( nTimerId )
	if p.birdEffectNum <= 0 then
		KillTimer( nTimerId );
		return;
	end
	
	p.birdEffectNum = p.birdEffectNum - 1;
	p.CreateBirdEffectNode();
end

function p.AddCloudEffect( nTimerId )
	if p.cloudEffectNum <= 0 then
		KillTimer( nTimerId );
		return;
	end
	
	p.cloudEffectNum = p.cloudEffectNum - 1;
	p.CreateCloudEffectNode();
end

function p.InitController()
	--名字
	uiNodeT.textNameT = {}
	uiNodeT.textNameT[1] = "建筑所";
	uiNodeT.textNameT[2] = "装备所";
	uiNodeT.textNameT[3] = "合成所";
	uiNodeT.textNameT[4] = "本宅";
	uiNodeT.textNameT[5] = "仓库";
	uiNodeT.textNameT[6] = "湖泊";
	uiNodeT.textNameT[7] = "百草田";
	uiNodeT.textNameT[8] = "矿山";
	uiNodeT.textNameT[9] = "森林";
	--名字
	local name_1 = GetImage(p.layer, ui.ID_CTRL_PICTURE_1);
	local name_2 = GetImage(p.layer, ui.ID_CTRL_PICTURE_2);
	local name_3 = GetImage(p.layer, ui.ID_CTRL_PICTURE_3);
	local name_4 = GetImage(p.layer, ui.ID_CTRL_PICTURE_4);
	local name_5 = GetImage(p.layer, ui.ID_CTRL_PICTURE_5);
	local name_6 = GetImage(p.layer, ui.ID_CTRL_PICTURE_6);
	local name_7 = GetImage(p.layer, ui.ID_CTRL_PICTURE_7);
	--local name_8 = GetImage(p.layer, ui.ID_CTRL_PICTURE_8);
	local name_9 = GetImage(p.layer, ui.ID_CTRL_PICTURE_9);
	name_1:SetVisible(false)
	name_2:SetVisible(false)
	name_3:SetVisible(false)
	name_4:SetVisible(false)
	name_5:SetVisible(false)
	name_6:SetVisible(false)
	name_7:SetVisible(false)
	--name_8:SetVisible(false)
	name_9:SetVisible(false)

	uiNodeT.headT = {}
	uiNodeT.headT[1] = name_1;
	uiNodeT.headT[2] = name_2;
	uiNodeT.headT[3] = name_3;
	uiNodeT.headT[4] = name_4;
	uiNodeT.headT[5] = name_5;
	uiNodeT.headT[6] = name_6;
	uiNodeT.headT[7] = name_7;
	--uiNodeT.headT[8] = name_8;
	uiNodeT.headT[9] = name_9;
	
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
	if p.layer == nil then
		return
	end
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
	for i = 1, 9 do
		if buildInfo["B"..i] then
			--显示名字，等级
			-- local headText = uiNodeT.textNameT[i].."LV:"..(buildInfo["B"..i].build_level);
			-- if uiNodeT.headT[i] then
				-- uiNodeT.headT[i]:SetText(headText);
			-- end
			--显示名字框
			--uiNodeT.headBoxT[i]:SetPicture( GetPictureByAni("common_ui.countNameBox", 0));
			uiNodeT.headT[i]:SetVisible(true);
			
			if i < 6 then
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
	
	p.ShowCollectEffect();
end

--显示光效
function p.ShowCollectEffect()
	local homeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_HOME );	--4
	local riverBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RIVER );	--6
	local fieldBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_FIELD );	--7
	local mountainBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_MOUNTAIN );	--8
	local treeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_TREE );	--9
	
	if homeBtn:HasAniEffect("ui.collect_effect_home") then
		homeBtn:DelAniEffect("ui.collect_effect_home");
	end
	
	if riverBtn:HasAniEffect("ui.collect_effect_river") then
		riverBtn:DelAniEffect("ui.collect_effect_river");
	end
	
	if fieldBtn:HasAniEffect("ui.collect_effect_farm") then
		fieldBtn:DelAniEffect("ui.collect_effect_farm");
	end
	
	if mountainBtn:HasAniEffect("ui.collect_effect") then
		mountainBtn:DelAniEffect("ui.collect_effect");
	end
	
	if treeBtn:HasAniEffect("ui.collect_effect_forest") then
		treeBtn:DelAniEffect("ui.collect_effect_forest");
	end
	
	local cache = msg_cache.msg_count_data or {};
	local build = cache.builds or {};
	local times = cache.times or {};
	--房屋
	if build["B4"] then
		local nTimes = tonumber(times.Home) or 0;
		local collectTimes = 0;
		if country_collect.collectResult and country_collect.collectResult.Home and country_collect.collectResult.Home.times then
			collectTimes = tonumber(country_collect.collectResult.Home.times);
		end
		if nTimes - collectTimes > 0 then
			if not homeBtn:HasAniEffect("ui.collect_effect_home") then
				homeBtn:AddFgEffect("ui.collect_effect_home");
			end
		end
	end
	--河流
	if build["B6"] then
		local nTimes = tonumber(times.River) or 0;
		local collectTimes = 0;
		if country_collect.collectResult and country_collect.collectResult.River and country_collect.collectResult.River.times then
			collectTimes = tonumber(country_collect.collectResult.River.times);
		end
		if nTimes - collectTimes > 0 then
			if not riverBtn:HasAniEffect("ui.collect_effect_river") then
				riverBtn:AddFgEffect("ui.collect_effect_river");
			end
		end
	end
	--农田
	if build["B7"] then
		local nTimes = tonumber(times.Farm) or 0;
		local collectTimes = 0;
		if country_collect.collectResult and country_collect.collectResult.Farm and country_collect.collectResult.Farm.times then
			collectTimes = tonumber(country_collect.collectResult.Farm.times);
		end
		if nTimes - collectTimes > 0 then
			if not fieldBtn:HasAniEffect("ui.collect_effect_farm") then
				fieldBtn:AddFgEffect("ui.collect_effect_farm");
			end
		end
	end
	--山地
	if build["B8"] then
		local nTimes = tonumber(times.Hill) or 0;
		local collectTimes = 0;
		if country_collect.collectResult and country_collect.collectResult.Hill and country_collect.collectResult.Hill.times then
			collectTimes = tonumber(country_collect.collectResult.Hill.times);
		end
		if nTimes - collectTimes > 0 then
			if not mountainBtn:HasAniEffect("ui.collect_effect") then
				mountainBtn:AddFgEffect("ui.collect_effect");
			end
		end
	end
	--森林
	if build["B9"] then
		local nTimes = tonumber(times.Forest) or 0;
		local collectTimes = 0;
		if country_collect.collectResult and country_collect.collectResult.Forest and country_collect.collectResult.Forest.times then
			collectTimes = tonumber(country_collect.collectResult.Forest.times);
		end
		if nTimes - collectTimes > 0 then
			if not treeBtn:HasAniEffect("ui.collect_effect_forest") then
				treeBtn:AddFgEffect("ui.collect_effect_forest");
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
			maininterface.ShowUI();

			--注销采集倒计时
			country_collect.EndTick();
			
			dlg_menu.SetSelectButton( -1 );
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
				maininterface.ShowUI();
				country_building.ShowUI(p.countryInfoT)
				--p.HideUI()
				p.CloseUI();
			end
		elseif ui.ID_CTRL_BUTTON_EQUIP == tag then
			if p.countryInfoT["B2"] then
				--p.HideUI()
				equip_room.ShowUI();
				WriteCon("EQUIP");
			end
		elseif ui.ID_CTRL_BUTTON_MERGE == tag then
			if p.countryInfoT["B3"] then
				WriteCon("MERGE");
				country_mixhouse.ShowUI();
				p.HideUI();
			end
		elseif ui.ID_CTRL_BUTTON_HOME == tag then
			if p.countryInfoT["B4"] then
				WriteCon("HOME");
				country_collect.Collect( E_COLLECT_HOME );
			end
		elseif ui.ID_CTRL_BUTTON_STORE == tag then
			if p.countryInfoT["B5"] then
				WriteCon("STORE");
				country_storage.ShowUI();
				p.HideUI();
			end
		end
	end
end

function p.ShowBuildUP()
	WriteCon("PRODUCE");
	--maininterface.ShowUI();
	country_building.ShowUI(p.countryInfoT)
	p.CloseUI();
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
		--maininterface.ShowUI();
		p.birdEffectNum = 0;
		p.cloudEffectNum = 0;
		p.randompool = {1,2,3,4,5};
		
		if p.timer1 ~= nil then
			KillTimer( p.timer1 );
			p.timer1 = nil;
		end
		if p.timer2 ~= nil then
			KillTimer( p.timer2 );
			p.timer2 = nil;
		end
	end
	
	if #p.birdImage ~= 0 then
		for _,v in ipairs(p.birdImage) do
			v:RemoveFromParent( true );
		end
		p.birdImage = {};
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
	
	equip_room.CloseUI();
	country_building.CloseUI();
	country_storage.UIDisappear();
	country_mixhouse.UIDisappear();
	p.CloseUI();
	
	maininterface.BecomeFirstUI();
	maininterface.CloseAllPanel();
	maininterface.ShowUI();

	--注销采集倒计时
	country_collect.EndTick();
end

--创建特效节点
function p.CreateBirdEffectNode()
	if p.layer == nil then
		return;
	end
	
	local image = createNDRole();
	image:Init();

	p.layer:AddChildZ( image, 99 );
	
	table.insert( p.birdImage, image );
	
	local size = GetWinSize();
	
	local random = math.random(1,100);
	WriteConErr( tostring(random) );
	
	image:SetFramePosXY( random%2==0 and 0 or 640 , math.random(10, 100) );
	image:AddFgEffect( "ui.country_effect_bird_" .. math.random(1, 5) );
	image:SetLookAt( random%2==0 and E_LOOKAT_RIGHT or E_LOOKAT_LEFT );

	p.CreateBirdEffect( image );
end

function p.CreateBirdEffect( image )
	image:AddActionEffect( "lancer_cmb.country_effect_move_"..math.random(1,6) );
end

function p.CreateCloudEffectNode()
	if p.layer == nil then
		return;
	end
	
	local image = createNDUIImage();
	image:Init();
	local random = math.random( 1, #p.randompool );
	local index = p.randompool[random];
	
	image:SetPicture( GetPictureByAni( "ui.country_cloud", index - 1 ) );
	table.remove( p.randompool, random );
	
	image:ResizeToFitPicture();
	image:SetScale( math.random(3,7)/10 );
	
	p.layer:AddChild( image );

	local dir = math.random(1,100);
	image:SetFramePosXY( dir%2 == 0 and -30 or 600, -60 );
	p.CreateCloudEffect( image, dir%2 );
end

function p.CreateCloudEffect( image, dir )
	image:AddActionEffect( "lancer_cmb.country_cloud_move".. dir .. "_"..math.random(1,5) );
end