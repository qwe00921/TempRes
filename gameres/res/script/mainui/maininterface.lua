
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

--���ð�ť
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
			WriteCon("**========�̳�========**");
			dlg_gacha.ShowUI( SHOP_ITEM );
			p.BecomeBackground();
		end
		--]]
		
		if ui.ID_CTRL_BUTTON_MAIL == tag then
			WriteCon("**========�ʼ�========**");
			mail_main.ShowUI();
			
			--������UI
			maininterface.CloseAllPanel();
			--maininterface.HideUI();
			--�����û���Ϣ
			dlg_userinfo.HideUI();
		elseif ui.ID_CTRL_BUTTON_ACTIVITY == tag then
			WriteCon("**========�========**");
			p.CloseAllPanel();
			
		elseif ui.ID_CTRL_BUTTON_MORE == tag then
			WriteCon("**======������ť======**");
			dlg_btn_list.ShowUI();
		end
	end
end

--�ر������
function p.CloseAllPanel()
	dlg_btn_list.CloseUI();
end

--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		dlg_battlearray.HideUI();
		p.HideBillboard();
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
		dlg_battlearray.CloseUI();
		billboard.CloseUI();
    end
end

--������ʾ�˵���ť
function p.ShowMenuBtn()
	local menu = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_MEMU);
	if menu then
		menu:SetVisible(true);
	end
end

--�ʼ�������ʾ
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

--�������ʾ
function p.ShowBillboardWithInit()
	billboard.ShowUIWithInit(layer); 
end

function p.HideBillboard()
	billboard.pauseBillBoard();
end

function p.ShowBillboard()
	billboard.resumeBillBoard();
end

--���ӽ����˳���ˢ��������
function p.BecomeFirstUI()
	dlg_userinfo.ShowUI();
	 p.ShowBillboard()
end
function p.BecomeBackground()
	p.HideBillboard()
end

