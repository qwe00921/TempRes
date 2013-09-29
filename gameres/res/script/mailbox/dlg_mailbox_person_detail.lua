--------------------------------------------------------------
-- FileName:    dlg_mailbox_person_detail.lua
-- author:      zjj, 2013/09/22
-- purpose:     个人邮件详情界面
--------------------------------------------------------------

dlg_mailbox_person_detail = {}
local p = dlg_mailbox_person_detail;

p.layer = nil;
local ui = ui_dlg_mailbox_person_detail;
p.mail = nil;

--显示UI
function p.ShowUI( mail )
    local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
    layer:Init();   
    GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_mailbox_person_detail.xui", layer, nil);
    
    if mail ~= nil then
        p.mail = mail;
    end
    p.layer = layer;
    p.SetDelegate();
    p.ShowMail( mail );
end

--设置事件处理
function p.SetDelegate()
    --返回
    local backBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnKfUIEvent);
    
    --删除
    local delBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_DELETE );
    delBtn:SetLuaDelegate(p.OnKfUIEvent);
    
    --回复
    
end

--邮件显示
function p.ShowMail( mail )
    --发件人
    local senderLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_SENDER_NAME );
    senderLab:SetText( tostring( mail.sender_user_name));
    
    --时间
    local timeLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_PRSMAIL_TIME );
    timeLab:SetText( tostring( mail.created_at ));
    
    --主题
    local titleLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_PRSMAIL_TITLE );
    titleLab:SetText( tostring( mail.title ));
   
    --获取并显示内容
    p.GetContent();
end

function p.GetContent()
	mailbox_mgr.ReqGetOneMail( p.mail.id );
end

function p.ShowContent( content )
	local list = GetListBoxVert(p.layer , ui.ID_CTRL_VERTICAL_LIST_CONTENT);
    list:ClearView();
    if #content ==0 then
        WriteCon( "no mail content" );
        return;
    end
    
    for i=1, #content do
        local view = createNDUIXView();
        view:Init();
        LoadUI( "person_detail_view.xui", view, nil );
        local bg = GetUiNode( view, ui_person_detail_view.ID_CTRL_PICTURE_BG );
        view:SetViewSize( bg:GetFrameSize());
        
        local mail = content[i];
        p.SetMailInfo(view, mail , i);
        list:AddView( view );
    end
end

function p.SetMailInfo( view, mail , index )
    local ui = ui_person_detail_view;
    
    --主题
    local titleLab = GetLabel( view, ui.ID_CTRL_TEXT_TITLE );
    --发件人
    local senderLab = GetLabel( view, ui.ID_CTRL_TEXT_SENDER_NAME );
    --时间
    local timeLab = GetLabel( view , ui.ID_CTRL_TEXT_TIME );
    --内容
    local contentLab = GetLabel( view , ui.ID_CTRL_TEXT_CONTENT );
    
	if index == 1 then
	   --内容
	   contentLab:SetText( mail.text );
	   return;
	end
	titleLab:SetText( tostring( mail.title ) );
	senderLab:SetText( tostrint( mail.sender_user_name ));
	timeLab:SetText( tostring( mail.created_at ));
	contentLab:SetText( tostring( mail.text));
end

--事件处理
function p.OnKfUIEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then   
            p.CloseUI();
        elseif ( ui.ID_CTRL_BUTTON_DELETE == tag ) then   
            mailbox_mgr.ReqDelMial( p.mail.id );
        end                 
    end
end

function p.HideUI()
    if p.layer ~= nil then
        p.layer:SetVisible( false );
    end
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
    end
end