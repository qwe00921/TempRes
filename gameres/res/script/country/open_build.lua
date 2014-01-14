open_build = {}
local p = open_build;
local ui = ui_country_levelup_top

p.layer = nil;
p.typeId = nil;

function p.ShowUI(typeId)
	if typeId == nil or typeId == 0 then
		WriteConErr("typeId error");
		return
	end
	p.typeId = tonumber(typeId);
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
	LoadUI("country_levelup_top.xui",layer,nil);
	
	p.layer = layer;
	p.SetDelegate(layer);
	
	p.Init()
end

function p.Init()
	local indexPic = nil;
	if p.typeId == 1 then	--生产屋
		indexPic = "common_ui.countyOpenMerge"
	elseif p.typeId == 2 then	--装备屋
		indexPic = "common_ui.countyOpenMerge"
	elseif p.typeId == 3 then	--融合屋
		indexPic = "common_ui.countyOpenFacility"
	elseif p.typeId == 4 then	--住宅
		indexPic = "common_ui.countyOpenMerge"
	elseif p.typeId == 5 then	--材料仓库
		indexPic = "common_ui.countyOpenMerge"
	elseif p.typeId == 6 then	--河流
		indexPic = "common_ui.countyOpenLake"
	elseif p.typeId == 7 then	--农田
		indexPic = "common_ui.countyOpenField"
	elseif p.typeId == 8 then	--矿山
		indexPic = "common_ui.countyOpenMount"
	elseif p.typeId == 9 then	--森林
		indexPic = "common_ui.countyOpenForest"
	end
	
	local buildPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_BUILD)
	buildPic:SetPicture( GetPictureByAni(indexPic,0));
	
	local kaiPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_KAI);
	local fangPic = GetImage(p.layer,ui.ID_CTRL_PICTURE_FANG);
	kaiPic:SetPicture( GetPictureByAni("common_ui.country_open",0));
	fangPic:SetPicture( GetPictureByAni("common_ui.country_open",1));
	kaiPic:SetScale(0);
	fangPic:SetScale(0);
	kaiPic:AddActionEffect( "ui.country_open" );
	fangPic:AddActionEffect( "ui.country_open" );
	
end

function p.SetDelegate(layer)
	--返回
	local btnReturn = GetButton( p.layer, ui.ID_CTRL_BUTTON_CLOSE );
	btnReturn:SetLuaDelegate(p.OnBtnClick);
end

--点击退出
function p.OnBtnClick(uiNode,uiEventType,param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if (ui.ID_CTRL_BUTTON_CLOSE == tag) then
			WriteCon("return");
			p.CloseUI();
		end
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
		country_main.openTypeNum = country_main.openTypeNum + 1;
		country_main.showNewBuild(country_main.openViewT);
	end
end

