--------------------------------------------------------------
-- FileName: 	billboard.lua
-- author:		xyd, 2013��8��12��
-- purpose:		����ƹ�����
--------------------------------------------------------------

mail_main = {}
local p = mail_main;

------------------�ʼ���������------------------
p.MAIL_TYPE                    = 0;        -- ϵͳ
p.layer = nil;

local ui = ui_mail_main

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		--dlg_battlearray.ShowUI();
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
	LoadUI("mail_main.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
	
end

--���ð�ť
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	--btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate()
	local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_WRITE );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_GM );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_NEXT_PAGE );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_PRE_PAGE );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_DEL );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_SELECT_ALL );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_GO_BACK );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_USER );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_SYS );
	p.SetBtn( bt );
	
	
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_GO_BACK == tag then
			WriteCon("**========����========**");
			p.CloseUI();
			maininterface.ShowUI();
			dlg_userinfo.ShowUI();
		elseif ui.ID_CTRL_BUTTON_WRITE == tag then
			WriteCon("**========д��========**");
			p.HideUI();
			mail_write_mail.ShowUI();
		elseif ui.ID_CTRL_BUTTON_GM == tag then
			WriteCon("**========�ͷ�========**");
			p.HideUI();
			mail_gm_mail.ShowUI();
		elseif ui.ID_CTRL_BUTTON_MORE == tag then
			WriteCon("**======������ť======**");
			dlg_btn_list.ShowUI();
		end
	end
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