
dlg_menu = {};
local p = dlg_menu;

local ui = ui_main_menu;
p.layer = nil;

p.preUI = nil;
p.curUI = nil;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	--layer:NoMask();
	layer:Init(layer);
	layer:SetSwallowTouch(false);
    
	--GetUIRoot():AddChild(layer);
	GetUIRoot():AddDlg(layer);
	GetUIRoot():AddDisableAllButNoThisLayer(layer);
	LoadUI("main_menu.xui", layer, nil);
	layer:SetZOrder(99);
	layer:SetLayoutType(1);
    
	p.layer = layer;
	p.SetDelegate();
	
	local pBgImage = GetImage(layer,ui.ID_CTRL_PICTURE_BG);
	local kRect = pBgImage:GetFrameRect();
	local kOrigin = kRect.origin;
	local kSize = kRect.size;
	local pImage = createNDUIImage();
	pImage:Init();
	local kWinSize = GetWinSizeInPixels();
	WriteConWarning(string.format("XXX is %d",kOrigin.y));
	pImage:SetFrameRect(CCRectMake(0,kSize.h + kOrigin.y,kSize.w,999));
	local pPic = GetPictureByAni("lancer.mask",1);
	pImage:SetPicture(pPic);
	layer:AddChildZ(pImage,10);
	
	maininterface.InitScrollList( p.layer );
	maininterface.OnListScrolled();
	
	--此处调整billboard位置
	--local lb = GetImage( p.layer, ui.ID_CTRL_PICTURE_8 );
	--local rect = lb:GetScreenRect();
	--billboard.SetFrameRect(rect);
end

function p.SetDelegate()
	--商店
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_GASHAPON );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--菜单
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_PVP );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--村落
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_BAG );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--伙伴
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_CARD_GROUP );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--任务
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_QUEST );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	--主页
	btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_HOME_PAGE );
	btn:SetLuaDelegate( p.OnBtnClick );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();

		if ui.ID_CTRL_BUTTON_GASHAPON == tag then
			WriteCon("**========扭蛋========**");
			dlg_gacha.ShowUI( SHOP_ITEM );
			maininterface.BecomeBackground();
		elseif ui.ID_CTRL_BUTTON_PVP == tag then
			WriteCon("**=======菜单=======**");
			dlg_btn_list.ShowUI();
			do return end;
			
		elseif ui.ID_CTRL_BUTTON_BAG == tag then
			WriteCon("**========村落========**");
			--[[
			WriteCon("**========菜单========**");
			pack_box.ShowUI();
			--]]
			country_main.ShowUI();
			--equip_room.ShowUI();
			
		elseif ui.ID_CTRL_BUTTON_CARD_GROUP == tag then
			WriteCon("**========伙伴========**");
			dlg_card_group_main.ShowUI();
			
		elseif ui.ID_CTRL_BUTTON_QUEST == tag then
			WriteCon("**========卡牌========**");
			--[[
			stageMap_main.OpenWorldMap();
			PlayMusic_Task(1);

			maininterface.HideUI();
			--]]
			card_bag_mian.ShowUI();
		elseif ui.ID_CTRL_BUTTON_HOME_PAGE == tag then
			WriteCon("**========主页========**");
			world_map.CheckToCloseMap();
			p.SetNewUI( {} );
			PlayMusic_MainUI();
			maininterface.ShowUI();

		end
		maininterface.CloseAllPanel();
	end
end

function p.GetBillboardRect()
	if (p.layer) then
		--local lb = GetImage( p.layer, ui.ID_CTRL_PICTURE_8 );
		--local rect = lb:GetFrameRect();--lb:GetScreenRect();
		--return rect;
	end
end

--外部调用接口
function p.SetNewUI( pSingleton )
	if pSingleton == nil then
		return;
	end
	
	p.curUI = pSingleton;
	p.CloseLastUI( );
end

--通过菜单打开界面时，先关闭上一个界面
function p.CloseLastUI( )
	if p.preUI and p.preUI ~= p.curUI then
		if p.preUI.UIDisappear then
			p.preUI.UIDisappear();
		end
	end
	p.preUI = p.curUI;
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		p.preUI = nil;
		p.curUI = nil;
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
	end
end

