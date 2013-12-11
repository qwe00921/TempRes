--------------------------------------------------------------
-- FileName: 	mainui.lua
-- author:		zhangwq, 2013/09/04
-- purpose:		������
--------------------------------------------------------------

mainui = {}
local p = mainui;

p.layer = nil;
local ui = ui_main_ui;

--��ʾUI
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
	
	--p.SendReqUserInfo(); @@��
end

function p.SendReqUserInfo()

	WriteCon("**�������״̬����**");
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

--���ð�ť
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

--�����¼�����
function p.SetDelegate(layer)
    --�
	local activity = GetButton(layer, ui.ID_CTRL_BUTTON_ACTIVITY);
    p.SetBtn(activity);
	
	--����
	local syndicate = GetButton(layer, ui.ID_CTRL_BUTTON_SYNDICATE);
    p.SetBtn(syndicate);
	
	--����
	local friend = GetButton(layer, ui.ID_CTRL_BUTTON_FRIEND);
    p.SetBtn(friend);
	
	--�˵�
	local menu = GetButton(layer, ui.ID_CTRL_BUTTON_MENU);
    p.SetBtn(menu);
	
	--ð��
	local adventure = GetButton(layer, ui.ID_CTRL_BUTTON_ADVENTURE);
    p.SetBtn(adventure);
	
	--����
	local cardGroup = GetButton(layer, ui.ID_CTRL_BUTTON_CARD_GROUP);
    p.SetBtn(cardGroup);
	
	--Ť��
	local gacha = GetButton(layer, ui.ID_CTRL_BUTTON_GACHA);
    p.SetBtn(gacha);
	
	--����
	local backPack = GetButton(layer, ui.ID_CTRL_BUTTON_BACK_PACK);
    p.SetBtn(backPack);
	
	--ͼ��
	local tuJian = GetButton(layer, ui.ID_CTRL_BUTTON_TUJIAN);
    p.SetBtn(tuJian);
	
	--����
	local forge = GetButton(layer, ui.ID_CTRL_BUTTON_FORGE);
    p.SetBtn(forge);
	
	--�ɾ�
	local achivement = GetButton(layer, ui.ID_CTRL_BUTTON_ACHIVEMENT);
    p.SetBtn(achivement);
    
    --��ֵ
    local charge = GetButton(layer, ui.ID_CTRL_BUTTON_CHARGE);
    p.SetBtn(charge);
    
    --�̳�
    local shop = GetButton(layer, ui.ID_CTRL_BUTTON_SHOP);
    p.SetBtn(shop);
    
    --����
    local mail = GetButton(layer, ui.ID_CTRL_BUTTON_MAIL);
    p.SetBtn(mail);
    
    local mailhint = GetButton(layer, ui.ID_CTRL_BUTTON_MAIL_HINT);
    p.SetBtn(mailhint);
    
end

--��ť����¼�
function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    p.CloseAllPanel();
	    local tag = uiNode:GetTag();
        if ( ui.ID_CTRL_BUTTON_ACTIVITY == tag ) then	
			WriteCon("�");
			
		elseif ( ui.ID_CTRL_BUTTON_SYNDICATE == tag ) then
			WriteCon("����");

		elseif ( ui.ID_CTRL_BUTTON_FRIEND == tag ) then
			WriteCon("����");
			dlg_friend.ShowUI();
			
		elseif ( ui.ID_CTRL_BUTTON_MENU == tag ) then
			WriteCon("�˵�");
            --WriteCon("�����Ϣ");
            --dlg_watch_player.ShowUI( SELF_INFO );
            			
		elseif ( ui.ID_CTRL_BUTTON_ADVENTURE == tag ) then
			WriteCon("ð��");
			p.HideUI();	
			game_main.EnterWorldMap();
			
		elseif ( ui.ID_CTRL_BUTTON_CARD_GROUP == tag ) then
			WriteCon("����");
			dlg_card_panel.ShowUI( uiNode );
			
		elseif ( ui.ID_CTRL_BUTTON_GACHA== tag ) then
			WriteCon("Ť��");
			dlg_gacha.ShowUI( SHOP_GACHA );
			
		elseif ( ui.ID_CTRL_BUTTON_BACK_PACK== tag ) then
			WriteCon("����");
			dlg_back_pack.ShowUI();	
			
		elseif ( ui.ID_CTRL_BUTTON_TUJIAN== tag ) then
			WriteCon("ͼ��");
			dlg_collect_mainui.ShowUI();

		elseif ( ui.ID_CTRL_BUTTON_FORGE== tag ) then
			WriteCon("����");
			dlg_card_forge_panel.ShowUI( uiNode );	
		
		elseif ( ui.ID_CTRL_BUTTON_ACHIVEMENT== tag ) then
			WriteCon("�ɾ�");	
			dlg_achievement.ShowUI();
			
		elseif ( ui.ID_CTRL_BUTTON_CHARGE== tag ) then
			WriteCon("��ֵ");
			
		elseif ( ui.ID_CTRL_BUTTON_SHOP== tag ) then
			WriteCon("�̳�");
			dlg_gacha.ShowUI(SHOP_ITEM);
			
		elseif ( ui.ID_CTRL_BUTTON_MAIL== tag ) then
			WriteCon("����");
						
		elseif ( ui.ID_CTRL_BUTTON_MAIL_HINT== tag ) then
			WriteCon("��������");
			
			--��ʱ����ɾ����ɫ
			p.DelUser();
		end				
	end
end

--�ر��ӻ���
function p.CloseAllPanel()
	dlg_card_panel.CloseUI();
	dlg_card_forge_panel.CloseUI();
end

--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end

--��ʱ����ɾ����ɫ
function p.DelUser()
    local msg = ToUtf8( "ȷ��Ҫɾ����ɫ��\n�����ͻ�������userid����Ӱ�����ˣ�" );
    local uid = string.format( "\nuser_id=%d", GetUID());
    msg = msg .. uid;
    
	dlg_msgbox.ShowYesNo( 
		ToUtf8( "ɾ����ɫ" ), 
		msg,
		p.OnMsgBoxCallback, p.layer );
end
				
--��ʾ��ص�����
function p.OnMsgBoxCallback( result )
	if result then
--		SetUID(0);
		GetUserConfig():Save();
		
		p.CloseUI();
		game_main.main();
	end
end