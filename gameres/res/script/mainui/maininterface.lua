
maininterface = {}
local p = maininterface;

p.layer = nil;

local ui = ui_main_interface

function p.ShowUI(userinfo)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		--[[dlg_userinfo2.ShowUI();
		local achievementList = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_8);
		achievementList:SetVisible(true);--]]
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
	LoadUI("main_interface.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
	
	dlg_userinfo.ShowUI(userinfo);
	--p.SendReqUserInfo();
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate()
	--任务
	local gift = GetButton( p.layer, ui.ID_CTRL_MAIN_BUTTON_GIFT );
	gift:SetLuaDelegate(p.OnBtnClick);
	
	--竞技场
	local pvp = GetButton( p.layer, ui.ID_CTRL_BUTTON_PVP);
	pvp:SetLuaDelegate(p.OnBtnClick);
	
	--工会按钮
	local union = GetButton( p.layer, ui.ID_CTRL_BUTTON_UNION );
	union:SetLuaDelegate(p.OnBtnClick);
	
	--商城
	local shop = GetButton( p.layer, ui.ID_CTRL_MAIN_BUTTON_SHOP);
	shop:SetLuaDelegate(p.OnBtnClick);
	
--[[	--进入世界地
	local map2 = GetButton(layer, ui.ID_CTRL_BUTTON_9);
	p.SetBtn(map2);
	
	--进入世界地
	local map3 = GetButton(layer, ui.ID_CTRL_BUTTON_8);
	p.SetBtn(map3);--]]
	
--[[	local bgBtn = GetButton(layer, ui.ID_CTRL_MIAN_BUTTON_DOWN);
	bgBtn:SetLuaDelegate(p.OnBtnClick);--]]
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_MAIN_BUTTON_GIFT == tag then
			WriteCon("**======================任务======================**");
			p.CloseAllPanel();

			game_main.EnterWorldMap();
			
			--隐藏主UI	
			p.HideUI();
		elseif ui.ID_CTRL_BUTTON_PVP == tag then
			WriteCon("**=====================竞技场=====================**");
		elseif ui.ID_CTRL_BUTTON_UNION == tag then
			WriteCon("**======================公会======================**");
		elseif ui.ID_CTRL_MAIN_BUTTON_SHOP == tag then
			WriteCon("**======================商城======================**");
		end
	end
end

--关闭子面板
function p.CloseAllPanel()
	--dlg_userinfo.CloseUI();
	
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		--local achievementList = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_8);
		--achievementList:SetVisible( false ); 
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

--重新显示菜单按钮
function p.ShowMenuBtn()
	local menu = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_MEMU);
	if menu then
		menu:SetVisible(true);
	end
end

--[[
--设置广告内容
function p.ShowAchievementList()
	local achievementList = GetListBoxVert( p.layer, ui.ID_CTRL_VERTICAL_LIST_8);	
	for i=1, 4 do
		local view = createNDUIXView();
		view:Init();
		LoadUI("main_actANDad.xui", view, nil);
		local bg = GetUiNode(view, ui_main_actandad.ID_CTRL_CTRL_BUTTON_24);
		view:SetViewSize( CCSizeMake(bg:GetFrameSize().w, bg:GetFrameSize().h+5.0));
		
		--礼包
		local btn = GetButton(view, ui_main_actandad.ID_CTRL_CTRL_BUTTON_24);
		btn:SetLuaDelegate(p.OnClickAD);

		achievementList:AddView( view );
	end
end
--]]

--[[
function p.OnClickAD()
	WriteCon("**=======AD=======**");
end
--]]