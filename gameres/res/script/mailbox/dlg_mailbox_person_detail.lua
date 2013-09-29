--------------------------------------------------------------
-- FileName:    dlg_mailbox_person_detail.lua
-- author:      zjj, 2013/09/22
-- purpose:     �����ʼ��������
--------------------------------------------------------------

dlg_mailbox_person_detail = {}
local p = dlg_mailbox_person_detail;

p.layer = nil;
local ui = ui_dlg_mailbox_person_detail;
p.mail = nil;

--��ʾUI
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

--�����¼�����
function p.SetDelegate()
    --����
    local backBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnKfUIEvent);
    
    --ɾ��
    local delBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_DELETE );
    delBtn:SetLuaDelegate(p.OnKfUIEvent);
    
    --�ظ�
    
end

--�ʼ���ʾ
function p.ShowMail( mail )
    --������
    local senderLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_SENDER_NAME );
    senderLab:SetText( tostring( mail.sender_user_name));
    
    --ʱ��
    local timeLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_PRSMAIL_TIME );
    timeLab:SetText( tostring( mail.created_at ));
    
    --����
    local titleLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_PRSMAIL_TITLE );
    titleLab:SetText( tostring( mail.title ));
   
    --��ȡ����ʾ����
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
    
    --����
    local titleLab = GetLabel( view, ui.ID_CTRL_TEXT_TITLE );
    --������
    local senderLab = GetLabel( view, ui.ID_CTRL_TEXT_SENDER_NAME );
    --ʱ��
    local timeLab = GetLabel( view , ui.ID_CTRL_TEXT_TIME );
    --����
    local contentLab = GetLabel( view , ui.ID_CTRL_TEXT_CONTENT );
    
	if index == 1 then
	   --����
	   contentLab:SetText( mail.text );
	   return;
	end
	titleLab:SetText( tostring( mail.title ) );
	senderLab:SetText( tostrint( mail.sender_user_name ));
	timeLab:SetText( tostring( mail.created_at ));
	contentLab:SetText( tostring( mail.text));
end

--�¼�����
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