--------------------------------------------------------------
-- FileName: 	mainui.lua
-- author:		zhangwq, 2013/09/04
-- purpose:		主界面
--------------------------------------------------------------

mainui = {}
local p = mainui;

p.layer = nil;
local ui = ui_main_ui;

--显示UI
function p.ShowUI()
    
    if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.SendReqUserInfo();
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
    LoadUI("main_ui.xui", layer, nil);
    
	p.layer = layer;
	p.InitExp();
	p.SetDelegate(layer);
	
	--p.SendReqUserInfo(); @@郭
end

function p.SendReqUserInfo()

	WriteCon("**请求玩家状态数据**");
    local uid = GetUID();
    if uid ~= nil and uid > 0 then
        SendReq("User","GetUserStatus",uid,"");
	end
end

function p.InitExp()
	local health = GetExp( p.layer, ui.ID_CTRL_EXP_HEALTH);
	health:SetUse3Slices( false, true ); --bg,fg
	
	local energy = GetExp( p.layer, ui.ID_CTRL_EXP_ENERGE);
	energy:SetUse3Slices( false, true ); --bg,fg
end

function p.RefreshUI(msg)
	
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
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

--设置事件处理
function p.SetDelegate(layer)
    --活动
	local activity = GetButton(layer, ui.ID_CTRL_BUTTON_ACTIVITY);
    p.SetBtn(activity);
	
	--公会
	local syndicate = GetButton(layer, ui.ID_CTRL_BUTTON_SYNDICATE);
    p.SetBtn(syndicate);
	
	--好友
	local friend = GetButton(layer, ui.ID_CTRL_BUTTON_FRIEND);
    p.SetBtn(friend);
	
	--菜单
	local menu = GetButton(layer, ui.ID_CTRL_BUTTON_MENU);
    p.SetBtn(menu);
	
	--冒险
	local adventure = GetButton(layer, ui.ID_CTRL_BUTTON_ADVENTURE);
    p.SetBtn(adventure);
	
	--卡组
	local cardGroup = GetButton(layer, ui.ID_CTRL_BUTTON_CARD_GROUP);
    p.SetBtn(cardGroup);
	
	--扭蛋
	local gacha = GetButton(layer, ui.ID_CTRL_BUTTON_GACHA);
    p.SetBtn(gacha);
	
	--背包
	local backPack = GetButton(layer, ui.ID_CTRL_BUTTON_BACK_PACK);
    p.SetBtn(backPack);
	
	--图鉴
	local tuJian = GetButton(layer, ui.ID_CTRL_BUTTON_TUJIAN);
    p.SetBtn(tuJian);
	
	--锻造
	local forge = GetButton(layer, ui.ID_CTRL_BUTTON_FORGE);
    p.SetBtn(forge);
	
	--成就
	local achivement = GetButton(layer, ui.ID_CTRL_BUTTON_ACHIVEMENT);
    p.SetBtn(achivement);
    
    --充值
    local charge = GetButton(layer, ui.ID_CTRL_BUTTON_CHARGE);
    p.SetBtn(charge);
    
    --商城
    local shop = GetButton(layer, ui.ID_CTRL_BUTTON_SHOP);
    p.SetBtn(shop);
    
    --邮箱
    local mail = GetButton(layer, ui.ID_CTRL_BUTTON_MAIL);
    p.SetBtn(mail);
    
    local mailhint = GetButton(layer, ui.ID_CTRL_BUTTON_MAIL_HINT);
    p.SetBtn(mailhint);
    
end

--按钮点击事件
function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    p.CloseAllPanel();
	    local tag = uiNode:GetTag();
        if ( ui.ID_CTRL_BUTTON_ACTIVITY == tag ) then	
			WriteCon("活动");
			
		elseif ( ui.ID_CTRL_BUTTON_SYNDICATE == tag ) then
			WriteCon("公会");

		elseif ( ui.ID_CTRL_BUTTON_FRIEND == tag ) then
			WriteCon("好友");
			dlg_friend.ShowUI();
			
		elseif ( ui.ID_CTRL_BUTTON_MENU == tag ) then
			WriteCon("菜单");
            --WriteCon("玩家信息");
            --dlg_watch_player.ShowUI( SELF_INFO );
            			
		elseif ( ui.ID_CTRL_BUTTON_ADVENTURE == tag ) then
			WriteCon("冒险");
			p.HideUI();	
			game_main.EnterWorldMap();
			
		elseif ( ui.ID_CTRL_BUTTON_CARD_GROUP == tag ) then
			WriteCon("卡组");
			dlg_card_panel.ShowUI( uiNode );
			
		elseif ( ui.ID_CTRL_BUTTON_GACHA== tag ) then
			WriteCon("扭蛋");
			dlg_gacha.ShowUI( SHOP_GACHA );
			
		elseif ( ui.ID_CTRL_BUTTON_BACK_PACK== tag ) then
			WriteCon("背包");
			dlg_back_pack.ShowUI();	
			
		elseif ( ui.ID_CTRL_BUTTON_TUJIAN== tag ) then
			WriteCon("图鉴");
			dlg_collect_mainui.ShowUI();

		elseif ( ui.ID_CTRL_BUTTON_FORGE== tag ) then
			WriteCon("锻造");
			dlg_card_forge_panel.ShowUI( uiNode );	
		
		elseif ( ui.ID_CTRL_BUTTON_ACHIVEMENT== tag ) then
			WriteCon("成就");	
			dlg_achievement.ShowUI();
			
		elseif ( ui.ID_CTRL_BUTTON_CHARGE== tag ) then
			WriteCon("充值");
			
		elseif ( ui.ID_CTRL_BUTTON_SHOP== tag ) then
			WriteCon("商城");
			dlg_gacha.ShowUI(SHOP_ITEM);
			
		elseif ( ui.ID_CTRL_BUTTON_MAIL== tag ) then
			WriteCon("邮箱");
						
		elseif ( ui.ID_CTRL_BUTTON_MAIL_HINT== tag ) then
			WriteCon("开启邮箱");
			
			--暂时用于删除角色
			p.DelUser();
		end				
	end
end

--关闭子画版
function p.CloseAllPanel()
	dlg_card_panel.CloseUI();
	dlg_card_forge_panel.CloseUI();
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

--暂时用于删除角色
function p.DelUser()
    local msg = ToUtf8( "确定要删除角色吗？\n（仅客户端忘记userid，不影响服务端）" );
    local uid = string.format( "\nuser_id=%d", GetUID());
    msg = msg .. uid;
    
	dlg_msgbox.ShowYesNo( 
		ToUtf8( "删除角色" ), 
		msg,
		p.OnMsgBoxCallback, p.layer );
end
				
--提示框回调处理
function p.OnMsgBoxCallback( result )
	if result then
--		SetUID(0);
		GetUserConfig():Save();
		
		p.CloseUI();
		game_main.main();
	end
end