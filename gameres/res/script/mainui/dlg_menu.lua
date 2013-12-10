
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
	LoadUI("main_menu.xui", layer, nil);
	layer:SetZOrder(99);
    
	p.layer = layer;
	p.SetDelegate();
	
	local kRect = layer:GetFrameRect();
	local kOrigin = kRect.origin
	local kSize = kRect.size;
	local pImage = createNDUIImage();
	pImage:Init();
	local kWinSize = GetWinSizeInPixels();
	pImage:SetFrameRect(CCRectMake(0,kSize.h * 0.8f,kSize.w,999));
	local pPic = GetPictureByAni("lancer.mask",1);
	pImage:SetPicture(pPic);
	layer:AddChildZ(pImage,10);
end

function p.SetDelegate()
	local gashapon = GetButton( p.layer, ui.ID_CTRL_BUTTON_GASHAPON );
	gashapon:SetLuaDelegate( p.OnBtnClick );
	
	local pvp = GetButton( p.layer, ui.ID_CTRL_BUTTON_PVP );
	pvp:SetLuaDelegate( p.OnBtnClick );
	
	local bag = GetButton( p.layer, ui.ID_CTRL_BUTTON_BAG );
	bag:SetLuaDelegate( p.OnBtnClick );
	
	local card_group = GetButton( p.layer, ui.ID_CTRL_BUTTON_CARD_GROUP );
	card_group:SetLuaDelegate( p.OnBtnClick );
	
	local quest = GetButton( p.layer, ui.ID_CTRL_BUTTON_QUEST );
	quest:SetLuaDelegate( p.OnBtnClick );
	
	local home_page = GetButton( p.layer, ui.ID_CTRL_BUTTON_HOME_PAGE );
	home_page:SetLuaDelegate( p.OnBtnClick );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		--maininterface.CloseAllPanel();
		
		if ui.ID_CTRL_BUTTON_GASHAPON == tag then
			WriteCon("**========扭蛋========**");
			dlg_gacha.ShowUI( SHOP_ITEM );
			--p.SetNewUI( dlg_gacha );
			maininterface.BecomeBackground();
			
		elseif ui.ID_CTRL_BUTTON_PVP == tag then
			WriteCon("**=======竞技场=======**");
			--p.CloseLastUI( pNewSingleton );
			--p.preUI = dlg_gacha;
		elseif ui.ID_CTRL_BUTTON_BAG == tag then
			WriteCon("**========背包========**");
			pack_box.ShowUI();
			--p.SetNewUI( pack_box );
			--隐藏主UI
			--maininterface.CloseAllPanel();
			--maininterface.HideUI();
		elseif ui.ID_CTRL_BUTTON_CARD_GROUP == tag then
			WriteCon("**========卡组========**");
			--card_bag_mian.ShowUI();
			dlg_card_group_main.ShowUI();
			--p.SetNewUI( dlg_card_group_main );
		elseif ui.ID_CTRL_BUTTON_QUEST == tag then
			WriteCon("**========任务========**");
			stageMap_main.OpenWorldMap();
			PlayMusic_Task(1);
			--隐藏主UI
			--maininterface.CloseAllPanel();
			maininterface.HideUI();
		elseif ui.ID_CTRL_BUTTON_HOME_PAGE == tag then
			WriteCon("**========主页========**");
			world_map.CheckToCloseMap();
			--PlayMusic_MainUI();
			p.SetNewUI( {} );
			PlayMusic_MainUI();
		end
		maininterface.CloseAllPanel();
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

