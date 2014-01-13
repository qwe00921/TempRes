country_building = {}

local p = country_building;
local ui = ui_country_levelup;

p.layer = nil;
p.scrollList = nil;
p.countryInfoT = nil;

p.upNeedTime = nil;
p.upNeed = nil;
p.buildLevel = nil;
p.upNeedHome = nil;

function p.ShowUI(countryInfo)
	dlg_menu.SetNewUI( p );
	if countryInfo == nil then
		WriteConErr("countryInfo error");
		return
	end
	p.countryInfoT = countryInfo;
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
	LoadUI("country_levelup.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	p.InitScrollList();
	
	p.Init()
end

function p.Init()
	p.upNeedTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_UP1);
	p.upNeed = GetLabel(p.layer, ui.ID_CTRL_TEXT_UP2);
	p.upNeedHome = GetLabel(p.layer, ui.ID_CTRL_TEXT_UP3);
	p.buildLevel = GetLabel(p.layer, ui.ID_CTRL_TEXT_BUILD_LV);
	
	
	p.getBuildInfo(1)
	
end

function p.getBuildInfo(typeId)
	local nowBuildLv = nil;
	local upIng = nil;
	for k,v in pairs(p.countryInfoT) do
		if k == "B"..typeId then
			nowBuildLv = tonumber(v.build_level);
			upIng = v.is_upgrade
		end
	end
	p.getBuildNeedTable(typeId,nowBuildLv)
end
-- "build_type": 2,
-- "build_level": 1,
-- "is_upgrade": 0,
-- "upgrade_time": 0,
-- "upgrade_level": 0,
-- "update": 0
function p.getBuildNeedTable(typeId,nowLevel)
	local buildTable =  SelectRowList(T_BUILDING,"type",typeId);
	if buildTable == nil then
		WriteConErr("upbuildTable is nil ");
	end
	local desText = nil;
	local moneyNeed = nil;
	local soulNeed = nil;
	local timeNeed = nil;
	local homeLvNeed = nil;
	local playLvNeed = nil;
	for k,v in pairs(buildTable) do
		if tonumber(v.level) == tonumber(nowLevel) then
			desText = v.description;
			moneyNeed = v.cost_money
			soulNeed = v.cost_soul
			timeNeed = v.upgrade_time;
			homeLvNeed = v.house_level_limit;
			playLvNeed = v.player_level_limit;
		end
	end

	p.upNeedTime:SetText("建造需要时间:"..timeNeed);
	p.upNeed:SetText("金币:"..moneyNeed.."  蓝魂:"..soulNeed);
	p.upNeedHome:SetText("住宅:"..homeLvNeed);
	p.buildLevel:SetText("LV"..nowLevel);
end

function p.InitScrollList()
	local posCtrller = GetImage( p.layer, ui.ID_CTRL_PICTURE_BUILD );
	local bList = createNDUIScrollContainerExpand();
	if nil == bList then
		WriteConErr("createNDUIScrollContainerExpand() error");
		return false;
	end
	p.scrollList = bList;
	local posXY = posCtrller:GetFramePos();
	local size = posCtrller:GetFrameSize();
	bList:Init();
	bList:SetFramePosXY( posXY.x, posXY.y+33 );
	bList:SetFrameSize( size.w, size.h );
	bList:SetSizeView( CCSizeMake(216,100) );
	for i = 1,18 do
		local bView = createNDUIScrollViewExpand();
		if bView == nil then
			WriteConErr("createNDUIScrollViewExpand() error");
			return true;
		end
		bView:Init();
		bView:SetViewId(math.mod(i,9));
		LoadUI( "country_levelup_btn.xui", bView, nil );

		local btn = GetButton( bView, ui_country_levelup_btn.ID_CTRL_BUTTON_21 );
		btn:SetImage( GetPictureByAni( "common_ui.buildBoxPic", math.mod(i,9) ) );
		btn:SetLuaDelegate( p.OnTouchImage );
		btn:SetId( math.mod(i,9) );
		bList:AddView(bView);
	end
	p.layer:AddChild( bList );
end

function p.OnTouchImage(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
		local id = uiNode:GetId();
		if id == 0 then
			WriteCon("**========produceBtn========**");
			-- stageMap_main.OpenWorldMap();
			-- PlayMusic_Task(1);

			-- maininterface.HideUI();
		-- end
	-- end
		elseif id == 1 then
			WriteCon("**========equipBtn========**");
		elseif id == 2 then
			WriteCon("**========mergeBtn========**");
		elseif id == 3 then
			WriteCon("**========homeBtn========**");
		elseif id == 4 then
			WriteCon("**========storeBtn========**");
		elseif id == 5 then
			WriteCon("**========riverBtn========**");
		elseif id == 6 then
			WriteCon("**========fieldBtn========**");
		elseif id == 7 then
			WriteCon("**========mountainBtn========**");
		elseif id == 8 then
			WriteCon("**========treeBtn========**");
		end
	end
end

function p.SetDelegate()
	local returnBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RETURN );
	returnBtn:SetLuaDelegate(p.OnBtnClick);

	local upBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_UP );
	upBtn:SetLuaDelegate(p.OnBtnClick);

	local leftBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_LEFT );
	leftBtn:SetLuaDelegate(p.OnBtnClick);

	local rightBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RIGHT );
	rightBtn:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_BUTTON_RETURN == tag) then
			p.CloseUI()
			country_main.ShowUI()
		elseif ui.ID_CTRL_BUTTON_UP == tag then
			WriteCon( "BUTTON_UP" );
			p.upBuild();
		elseif ui.ID_CTRL_BUTTON_LEFT == tag then
			WriteCon( "BUTTON_LEFT" );
		elseif ui.ID_CTRL_BUTTON_RIGHT == tag then
			WriteCon( "BUTTON_RIGHT" );
		end
	end
end

function p.upBuild()
	local typeID = 1
	local uid = GetUID();
	local param = "build_type="..typeID;
	SendReq("Build","UpBuild",uid,param);
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
function p.UIDisappear()
	p.CloseUI();
end
