
dlg_userinfo = {}
local p = dlg_userinfo;

p.layer = nil;

local ui = ui_userinfo

function p.ShowUI(userinfo)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		if userinfo ~= nil then
			p.RefreshUI(userinfo)
		else
			p.SendReqUserInfo();
		end
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init(layer);
	layer:SetSwallowTouch(false);
    
	GetUIRoot():AddChild(layer);
	LoadUI("userinfo.xui", layer, nil);
	layer:SetZOrder(9);
    
	p.layer = layer;
	
	if userinfo ~= nil then
		p.RefreshUI(userinfo)
	else
		p.SendReqUserInfo();
	end

	p.SetDelegate();
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
	end
end

function p.SendReqUserInfo()
	WriteCon("**�������״̬����**");
    local uid = GetUID();
    if uid ~= nil and uid > 0 then
        SendReq("User","Update",uid,"");
	end
end

function p.RefreshUI(userinfo)
--[[	--��½������ֱ������һ�����ݣ����ܴ���layerδ������ˢ�µ����
	if p.layer == nil then
		return;
	end
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

function p.SetDelegate()
	--����
	local team = GetButton( p.layer, ui.ID_CTRL_BUTTON_TEAM );
	team:SetLuaDelegate(p.OnBtnClick);

	--ǿ��
	local strengthen = GetButton( p.layer, ui.ID_CTRL_BUTTON_IN );
	strengthen:SetLuaDelegate(p.OnBtnClick);
	
	--��Ʒ
	local item = GetButton( p.layer, ui.ID_CTRL_BUTTON_30 );
	item:SetLuaDelegate(p.OnBtnClick);
	
	--�罻
	local social = GetButton( p.layer, ui.ID_CTRL_BUTTON_CON );
	social:SetLuaDelegate(p.OnBtnClick);
	
	--����
	local other = GetButton( p.layer, ui.ID_CTRL_BUTTON_32 );
	other:SetLuaDelegate(p.OnBtnClick);

	--������ui������ֱ�ӹر��ӽ���
	local backmainui = GetButton( p.layer, ui.ID_CTRL_BUTTON_BACK );
	backmainui:SetLuaDelegate(p.OnBtnClick);
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_TEAM == tag then
			WriteCon("**======================����======================**");
		elseif ui.ID_CTRL_BUTTON_IN == tag then
			WriteCon("**======================ǿ��======================**");
		elseif ui.ID_CTRL_BUTTON_30 == tag then
			WriteCon("**======================��Ʒ======================**");
		elseif ui.ID_CTRL_BUTTON_CON == tag then
			WriteCon("**======================�罻======================**");
		elseif ui.ID_CTRL_BUTTON_32 == tag then
			WriteCon("**======================����======================**");
		elseif ui.ID_CTRL_BUTTON_BACK == tag then
			WriteCon("**===================�ر��ӽ���===================**");

			world_map.CheckToCloseMap();
			maininterface.CloseAllPanel();
		end
	end
end