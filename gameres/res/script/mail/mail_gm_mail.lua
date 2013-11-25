--------------------------------------------------------------
-- FileName: 	billboard.lua
-- author:		xyd, 2013年8月12日
-- purpose:		跑马灯管理器
--------------------------------------------------------------

mail_gm_mail = {}
local p = mail_gm_mail;

------------------邮件类型类型------------------
p.MAIL_TYPE                    = 0;        -- 系统
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

--设置按钮
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
			WriteCon("**========返回========**");
			p.CloseUI();
			mail_main.ShowUI();
		elseif ui.ID_CTRL_BUTTON_MAIL == tag then
			WriteCon("**========邮件========**");
		elseif ui.ID_CTRL_BUTTON_ACTIVITY == tag then
			WriteCon("**========活动========**");
		elseif ui.ID_CTRL_BUTTON_MORE == tag then
			WriteCon("**======弹出按钮======**");
			dlg_btn_list.ShowUI();
		end
	end
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