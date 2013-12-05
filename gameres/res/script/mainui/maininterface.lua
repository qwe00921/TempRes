
maininterface = {}
local p = maininterface;

p.layer = nil;

local ui = ui_main_interface

function p.ShowUI(userinfo)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		dlg_battlearray.ShowUI();
		p.ShowBillboard();
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
	
	p.ShowMailNum(userinfo);
	
	dlg_userinfo.ShowUI(userinfo);
	dlg_menu.ShowUI();
	--dlg_battlearray.ShowUI();
	
	p.ShowBillboardWithInit();
	
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	--btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate()
	--[[
	local shop = GetButton( p.layer, ui.ID_CTRL_BUTTON_SHOP );
	p.SetBtn( shop );
	--]]
	local mail = GetButton( p.layer, ui.ID_CTRL_BUTTON_MAIL );
	p.SetBtn( mail );
	
	local activity = GetButton( p.layer, ui.ID_CTRL_BUTTON_ACTIVITY );
	p.SetBtn( activity );
	
	local more = GetButton( p.layer, ui.ID_CTRL_BUTTON_MORE );
	p.SetBtn( more );
	
	local bgBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_BG_BTN );
	p.SetBtn( bgBtn );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		--[[
		if ui.ID_CTRL_BUTTON_SHOP == tag then
			WriteCon("**========商城========**");
			dlg_gacha.ShowUI( SHOP_ITEM );
			p.BecomeBackground();
		end
		--]]
		
		if ui.ID_CTRL_BUTTON_MAIL == tag then
			WriteCon("**========邮件========**");
			mail_main.ShowUI();
			
			--隐藏主UI
			maininterface.CloseAllPanel();
			--maininterface.HideUI();
			--隐藏用户信息
			dlg_userinfo.HideUI();
		elseif ui.ID_CTRL_BUTTON_ACTIVITY == tag then
			WriteCon("**========活动========**");
			p.CloseAllPanel();
			
		elseif ui.ID_CTRL_BUTTON_MORE == tag then
			WriteCon("**======弹出按钮======**");
			dlg_btn_list.ShowUI();
		end
	end
end

--关闭子面板
function p.CloseAllPanel()
	dlg_btn_list.CloseUI();
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		dlg_battlearray.HideUI();
		p.HideBillboard();
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
		dlg_battlearray.CloseUI();
		billboard.CloseUI();
    end
end

--重新显示菜单按钮
function p.ShowMenuBtn()
	local menu = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_MEMU);
	if menu then
		menu:SetVisible(true);
	end
end

--邮件数量显示
function p.ShowMailNum(userinfo)
	local bg = GetImage( p.layer, ui.ID_CTRL_PICTURE_MAIL_TIPS_BG );
	local mailNum = GetLabel( p.layer, ui.ID_CTRL_TEXT_MAIL_TIPS_NUM );
	if userinfo == nil or userinfo.Email_num == 0 then
		mailNum:SetVisible( false );
		bg:SetVisible( false );
	else
		mailNum:SetVisible( true );
		bg:SetVisible( true );
		mailNum:SetText( userinfo.Email_num or 0 );
	end
end

--跑马灯显示
function p.ShowBillboardWithInit()
	billboard.ShowUIWithInit(layer); 
end

function p.HideBillboard()
	billboard.pauseBillBoard();
end

function p.ShowBillboard()
	billboard.resumeBillBoard();
end

--从子界面退出，刷新主界面
function p.BecomeFirstUI()
	dlg_userinfo.ShowUI();
	 p.ShowBillboard()
end
function p.BecomeBackground()
	p.HideBillboard()
end

