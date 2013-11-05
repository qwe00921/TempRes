
maininterface = {}
local p = maininterface;

p.layer = nil;

local ui = ui_main_interface

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.SendReqUserInfo();
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
	
	p.SendReqUserInfo();
end

function p.SendReqUserInfo()
	WriteCon("**请求玩家状态数据**");
    local uid = GetUID();
    if uid ~= nil and uid > 0 then
        SendReq("Login","HandShake",uid,"");
	end
end

function p.RefreshUI(userinfo)
	--[[
	local user_status = msg.user_status;
	
	local username = GetLabel(p.layer, ui.ID_CTRL_TEXT_NAME);
	username:SetText(tostring(user_status.user_name));
	
	local level = GetLabel(p.layer, ui.ID_CTRL_TEXT_LEVEL);
	level:SetText(tostring(user_status.level));
	
	local cardnum = GetLabel(p.layer, ui.ID_CTRL_TEXT_CARD);
	cardnum:SetText(string.format("%s/%s",msg.card_num,msg.card_max)); 
	
	local money = GetLabel(p.layer, ui.ID_CTRL_TEXT_MONEY);
	money:SetText(tostring(msg.gold_num));
	
	local crystal = GetLabel(p.layer, ui.ID_CTRL_TEXT_CRYSTAL);
	crystal:SetText(tostring(msg.rmb_num)); 
	
	local health = GetExp( p.layer, ui.ID_CTRL_EXP_HEALTH);
    health:SetValue( 0, tonumber(user_status.mission_point), tonumber(user_status.mission_point_max) );
	
	local energy = GetExp( p.layer, ui.ID_CTRL_EXP_ENERGE);
	energy:SetValue( 0, tonumber(user_status.arena_point), tonumber(user_status.arena_point_max) );
	--]]
	
	local username = GetLabel( p.layer, ui.ID_CTRL_TEXT_USERNAME);
	username:SetText( userinfo.Name );
	
	local level = GetLabel(p.layer, ui.ID_CTRL_TEXT_20);
	level:SetText( userinfo.Level );
	
	local money = GetLabel(p.layer, ui.ID_CTRL_TEXT_16);
	money:SetText( userinfo.Money );
	
	local emoney = GetLabel(p.layer, ui.ID_CTRL_TEXT_18);
	emoney:SetText( userinfo.Emoney );
	
	local tili = GetLabel( p.layer, ui.ID_CTRL_TEXT_34);
	tili:SetText( string.format("%d/%d", userinfo.Move, userinfo.MaxMove ) );
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
	
	--队伍
	local team = GetButton( p.layer, ui.ID_CTRL_BUTTON_TEAM );
	team:SetLuaDelegate(p.OnBtnClick);

	--强化
	local strengthen = GetButton( p.layer, ui.ID_CTRL_BUTTON_IN );
	strengthen:SetLuaDelegate(p.OnBtnClick);
	
	--物品
	local item = GetButton( p.layer, ui.ID_CTRL_BUTTON_30 );
	item:SetLuaDelegate(p.OnBtnClick);
	
	--社交
	local social = GetButton( p.layer, ui.ID_CTRL_BUTTON_CON );
	social:SetLuaDelegate(p.OnBtnClick);
	
	--其他
	local other = GetButton( p.layer, ui.ID_CTRL_BUTTON_32 );
	other:SetLuaDelegate(p.OnBtnClick);
	
	--商城
	local shop = GetButton( p.layer, ui.ID_CTRL_MAIN_BUTTON_SHOP);
	shop:SetLuaDelegate(p.OnBtnClick);
	
	--返回主ui，用于直接关闭子界面
	local backmainui = GetButton( p.layer, ui.ID_CTRL_BUTTON_BACK );
	backmainui:SetLuaDelegate(p.OnBtnClick);
	
	
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
			
			game_main.EnterWorldMap();
			
			--进入世界地图，隐藏子界面，隐藏主UI
			p.CloseAllPanel();			
			p.HideUI();
		elseif ui.ID_CTRL_BUTTON_PVP == tag then
			WriteCon("**=====================竞技场=====================**");
		elseif ui.ID_CTRL_BUTTON_UNION == tag then
			WriteCon("**======================公会======================**");
		elseif ui.ID_CTRL_BUTTON_TEAM == tag then
			WriteCon("**======================队伍======================**");
		elseif ui.ID_CTRL_BUTTON_IN == tag then
			WriteCon("**======================强化======================**");
		elseif ui.ID_CTRL_BUTTON_30 == tag then
			WriteCon("**======================物品======================**");
		elseif ui.ID_CTRL_BUTTON_CON == tag then
			WriteCon("**======================社交======================**");
		elseif ui.ID_CTRL_BUTTON_32 == tag then
			WriteCon("**======================其他======================**");
		elseif ui.ID_CTRL_MAIN_BUTTON_SHOP == tag then
			WriteCon("**======================商城======================**");
		elseif ui.ID_CTRL_BUTTON_BACK == tag then
			WriteCon("**===================关闭子界面===================**");
			
			p.CloseAllPanel();
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