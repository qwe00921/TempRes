--------------------------------------------------------------
-- FileName: 	billboard.lua
-- author:		xyd, 2013��8��12��
-- purpose:		����ƹ�����
--------------------------------------------------------------

mail_gm_mail = {}
local p = mail_gm_mail;

------------------�ʼ���������------------------
p.MAIL_TYPE                    = 0;        -- ϵͳ
p.layer = nil;

local ui = ui_mail_gm_mail

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
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
	LoadUI("mail_gm_mail.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
	
end

--���ð�ť
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	--btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate()
	--local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_SEND );
	--p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_GO_BACK );
	p.SetBtn( bt );
	
	
	
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_GO_BACK == tag then
			WriteCon("**========����========**");
			p.CloseUI();
			mail_main.ShowUI();
		elseif ui.ID_CTRL_BUTTON_MAIL == tag then
			WriteCon("**========�ʼ�========**");
		elseif ui.ID_CTRL_BUTTON_ACTIVITY == tag then
			WriteCon("**========�========**");
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