country_building = {}

local p = country_building;
local ui = ui_country_levelup;

p.layer = nil;
p.scrollList = nil;

function p.ShowUI()
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
		WriteConErr("posXY.x"..posXY.x.."posXY.y"..posXY.y);
		WriteConErr("size.w"..size.w.."size.h"..size.h);

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
	WriteCon( "dadasdsadsad" );
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
		elseif ui.ID_CTRL_BUTTON_UP == tag then
		elseif ui.ID_CTRL_BUTTON_LEFT == tag then
		elseif ui.ID_CTRL_BUTTON_RIGHT == tag then
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
	end
end
