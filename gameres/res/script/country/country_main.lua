country_main = {};
local p = country_main;
local ui = ui_country;

p.layer = nil;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
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
	

end

function p.InitController() 
	local storeName = GetLabel(p.layer, ui.ID_CTRL_TEXT_STORE_LV);
	local equipName = GetLabel(p.layer, ui.ID_CTRL_TEXT_EQUIP_LV);
	local mergeName = GetLabel(p.layer, ui.ID_CTRL_TEXT_MERGE_LV);
	local produceName = GetLabel(p.layer, ui.ID_CTRL_TEXT_PRODUCE_LV);
	local homeName = GetLabel(p.layer, ui.ID_CTRL_TEXT_HOME_LV);
	
	local storeTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_STORE_TIME);
	local equipTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_EQUIP_TIME);
	local mergeTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_MERGE_TIME);
	local produceTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_PRODUCE_ITEM);
	local homeTime = GetLabel(p.layer, ui.ID_CTRL_TEXT_HOME_TIME);
	
	local uid = GetUID();
	local param = "";
	SendReq("Build","GetUserBuilds",uid,param);
end

function p.ShowCount(backData)
		WriteConErr("missionTable error");


end


function p.SetDelegate()
	local mountainBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_MOUNTAIN );
	mountainBtn:SetLuaDelegate(p.OnBtnClick);
	local fieldBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_FIELD );
	fieldBtn:SetLuaDelegate(p.OnBtnClick);
	local treeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_TREE );
	treeBtn:SetLuaDelegate(p.OnBtnClick);
	local riverBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_RIVER );
	riverBtn:SetLuaDelegate(p.OnBtnClick);
	local homeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_HOME );
	homeBtn:SetLuaDelegate(p.OnBtnClick);
	local produceBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_PRODUCE );
	produceBtn:SetLuaDelegate(p.OnBtnClick);
	local mergeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_MERGE );
	mergeBtn:SetLuaDelegate(p.OnBtnClick);
	local equipBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_EQUIP );
	equipBtn:SetLuaDelegate(p.OnBtnClick);
	local storeBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_STORE );
	storeBtn:SetLuaDelegate(p.OnBtnClick);
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end