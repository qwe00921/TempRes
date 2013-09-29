--------------------------------------------------------------
-- FileName: 	dlg_mailbox_mainui.lua
-- author:		zjj, 2013/09/18
-- purpose:		�ʼ�����
--------------------------------------------------------------

dlg_mailbox_mainui = {}
local p = dlg_mailbox_mainui;

p.layer = nil;
local ui = ui_dlg_mailbox_mainui;

local UP = 1;
local DOWN = 2;
p.SYS = 1;
p.PRS = 2;

--ÿҳ��ʾ��
local showNum = 10;
--��ŵ�ǰ����
local current = nil;

--ϵͳ�ʼ�����
local sysMail = {
    currentPage = 1,
    maxPage = nil,
    mailList = nil,
    data = nil,
    uiType = p.SYS,
    selectlist = {},
    checkboxlist = {}
};

--�����ʼ�����
local prsMail = {
    currentPage = 1,
    maxPage = nil,
    mailList = nil,
    data = nil,
    uiType = p.PRS,
    selectlist = {},
    checkboxlist = {}
};

--��ʾUI
function p.ShowUI()
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_mailbox_mainui.xui", layer, nil);
	
	p.layer = layer;
	p.Init();
	mailbox_mgr.LoadAllMail();
end

--��ʼ��
function p.Init()

    sysMail.mailList = GetListBoxVert(p.layer , ui.ID_CTRL_VERTICAL_LIST_SYS_MAIL);
    prsMail.mailList = GetListBoxVert(p.layer , ui.ID_CTRL_VERTICAL_LIST_PRS_MAIL);
    
    --����
    local backBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --��һҳ
    local pageUpBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_PAGE_UP);
    pageUpBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --��һҳ
    local pageDownBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_PAGE_DOWN);
    pageDownBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --�ͷ�
    local gmBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_GM);
    gmBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --д��
    local wirteBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_WRITE_MAIL);
    wirteBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --ϵͳ�ʼ� 
    local sysUIBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_SYS_MAIL);
    sysUIBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --�����ʼ�
    local prsUIBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_PERSON_MAIL);
    prsUIBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --ȫѡ
    local selAllBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_SELECT_ALL);
    selAllBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --ɾ��
    local delBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_DELETE);
    delBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
end

--��ʾϵͳ�ʼ��б�
function p.ShowSysMail( sysMailData )

    prsMail.mailList:SetVisible( false );
    if sysMailData == nil or #sysMailData == 0 then
        tip.ShowTip( GetStr( "no_sys_mail" ));
        return;
    end
	current = sysMail;
	p.ShowByPage();
	p.RefreshPageNum();
end

--��ʾ�����ʼ��б�
function p.ShowPrsMail( prsMailData )

    sysMail.mailList:SetVisible( false );
    if prsMailData == nil or #prsMailData == 0 then
        tip.ShowTip( GetStr( "no_prs_mail" ));
        return;
    end
    current = prsMail;
    p.ShowByPage();
    p.RefreshPageNum();
end

--��ʾϵͳ�ʼ�����
function p.ShowByPage() 
    current.mailList:SetVisible( true );
    current.mailList:ClearView();
    checkboxlist = {};
    
    --��ʼ��ѡ���б�
    p.InitSelectList(current.uiType);
    current.maxPage = math.ceil( #mailbox_mgr.sysMail / showNum);
    
    if current.uiType == p.SYS then
        for i=1, showNum do 
            if i > #mailbox_mgr.sysMail then
                return; 
            end
            --����λ�û�ȡ�ʼ�
            local mail = p.GetMailByIndex( i );
            --�޸����ʼ�
            if #mail.rewards == 0 then
                local view = createNDUIXView();
                view:Init();
                LoadUI( "mailbox_sys_view.xui", view, nil );
                local bg = GetUiNode( view, ui_mailbox_sys_view.ID_CTRL_PICTURE_BG );
                view:SetViewSize( bg:GetFrameSize());
                view:SetLuaDelegate(p.OnSysViewEvent); 
                view:SetId( i );
                
                p.SetSysMailInfo( view , mail );
                current.mailList:AddView( view );
                
                local checkBox = GetCheckBox( view , ui_mailbox_sys_view.ID_CTRL_CHECK_BUTTON_SELECT_ONE);
                checkBox:SetLuaDelegate(p.OnCheckEvent);
                sysMail.checkboxlist[ i ] = checkBox;
            --�и���
            else
                local view = createNDUIXView();
                view:Init();
                LoadUI( "mailbox_sys_reward_view.xui", view, nil );
                local bg = GetUiNode( view, ui_mailbox_sys_reward_view.ID_CTRL_PICTURE_BG );
                view:SetViewSize( bg:GetFrameSize());
                view:SetLuaDelegate(p.OnSysViewEvent); 
                view:SetId( i );
                
                p.SetSysRewardMailInfo( view , mail);
                current.mailList:AddView( view );
            end
            
            
        end
    else
        for i=1,showNum do 
            if i > #mailbox_mgr.prsMail then
                return; 
            end
            
            --����λ�û�ȡ�ʼ�
            local mail = p.GetMailByIndex( i );
            
            local view = createNDUIXView();
            view:Init();
            LoadUI( "mailbox_person_view.xui", view, nil );
            local bg = GetUiNode( view, ui_mailbox_person_view.ID_CTRL_PICTURE_BG );
            view:SetViewSize( bg:GetFrameSize());
            view:SetLuaDelegate(p.OnPrsViewEvent); 
            view:SetId( i );
            
            p.SetPrsMailInfo( view , mail);
            current.mailList:AddView( view );
            
            local checkBox = GetCheckBox( view , ui_mailbox_person_view.ID_CTRL_CHECK_BUTTON_SELECT_ONE);
            checkBox:SetLuaDelegate(p.OnCheckEvent);
            prsMail.checkboxlist[ i ] = checkBox;
        end
    end
end

--����ϵͳ�ʼ���Ϣ���޸�����
function p.SetSysMailInfo(view , mail)
    local ui = ui_mailbox_sys_view;
    --����
    local nameLab = GetLabel( view, ui.ID_CTRL_TEXT_SYSMAIL_NAME );
    nameLab:SetText( tostring( mail.title ));
    --ʱ��
    local timeLab = GetLabel( view, ui.ID_CTRL_TEXT_SYSMAIL_TIME );
    timeLab:SetText( tostring( mail.created_at ));
    --����
    local contentLab = GetLabel( view, ui.ID_CTRL_TEXT_SYSMAIL_CONTENT );
    contentLab:SetText( tostring( mail.text ));
end

--����ϵͳ�ʼ���Ϣ����������
function p.SetSysRewardMailInfo( view , mail)
    local ui = ui_mailbox_sys_reward_view;
    --����
    local titleLab = GetLabel( view , ui.ID_CTRL_TEXT_SYSMAIL_TITLE );
    titleLab:SetText( tostring( mail.title ));
    --ʱ��
    local timeLab = GetLabel( view , ui.ID_CTRL_TEXT_SYSMAIL_TIME );
    timeLab:SetText( tostring( mail.created_at ));
    --����
    local contentLab = GetLabel( view , ui.ID_CTRL_TEXT_SYSMAIL_CONTENT );
    contentLab:SetText( tostring( mail.text ));
    --״̬
    local stateLab = GetLabel( view , ui.ID_CTRL_TEXT_SYSMAIL_STATE );
    if mail.is_reward_received then
        stateLab:SetText( GetStr( "is_received" ));
    else
        stateLab:SetText( GetStr( "is_not_received" ));
    end
    
    --����
    local rewardImgs = p.InitReward( view );
    for i=1 , #mail.rewards do
        rewardImgs[ i ]:SetVisible( true );
    end
end

--��ʼ�������ؼ�
function p.InitReward( view )
    local ui = ui_mailbox_sys_reward_view;
	local imgs = {};
	imgs[1] = GetImage( view ,ui.ID_CTRL_PICTURE_ITEM1 );
	imgs[2] = GetImage( view ,ui.ID_CTRL_PICTURE_ITEM2 );
	imgs[3] = GetImage( view ,ui.ID_CTRL_PICTURE_ITEM3 );
	imgs[4] = GetImage( view ,ui.ID_CTRL_PICTURE_ITEM4 );
	imgs[5] = GetImage( view ,ui.ID_CTRL_PICTURE_ITEM5 );
	imgs[6] = GetImage( view ,ui.ID_CTRL_PICTURE_ITEM6 );
	for i = 1, 6 do
	   imgs[ i ]:SetVisible( false );
	end
	return imgs;
end

--���ø����ʼ���Ϣ
function p.SetPrsMailInfo( view , mail)
    local ui = ui_mailbox_person_view
	--����
	local nameLab = GetLabel( view , ui.ID_CTRL_TEXT_PERSONALMAIL_NAME );
	nameLab:SetText( tostring( mail.title) );
	
	--������
	local senderLab = GetLabel( view , ui.ID_CTRL_TEXT_ADDRESSER );
	senderLab:SetText( tostring( mail.sender_user_name) );
	
	--ʱ��
	local timeLab = GetLabel( view , ui.ID_CTRL_TEXT_PERSONALMAIL_TIME );
	timeLab:SetText( tostring( mail.created_at) );
	
	--����
	local contentLab = GetLabel( view , ui.ID_CTRL_TEXT_PERSONALMAIL_CONTENT );
	contentLab:SetText( tostring( mail.text) );
	
	--״̬
	local stateLab = GetLabel( view , ui.ID_CTRL_TEXT_PERSONALMAIL_STATE );
	if mail.is_read then
	   stateLab:SetText( GetStr( "is_read" ));
	else
	   stateLab:SetText( GetStr( "is_not_read"));
	end
end

--�¼�����
function p.OnMailBoxUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then	
			p.CloseUI();
	    elseif (ui.ID_CTRL_BUTTON_PAGE_DOWN == tag ) then --��һҳ
	        p.ChangePage( DOWN );
	    
	    elseif (ui.ID_CTRL_BUTTON_PAGE_UP == tag ) then --��һҳ
	       
            p.ChangePage( UP );
            
        elseif (ui.ID_CTRL_BUTTON_GM == tag ) then --�ͷ�
            dlg_mailbox_kf.ShowUI();
        
        elseif (ui.ID_CTRL_BUTTON_WRITE_MAIL == tag ) then  --д�� 
            dlg_mailbox_person_write.ShowUI();
            
        elseif (ui.ID_CTRL_BUTTON_SYS_MAIL == tag ) then --ϵͳ�ʼ�
            p.ShowSysMail( mailbox_mgr.sysMail);
            
        elseif (ui.ID_CTRL_BUTTON_PERSON_MAIL == tag ) then --�����ʼ�
            p.ShowPrsMail( mailbox_mgr.prsMail );
        
        elseif (ui.ID_CTRL_BUTTON_SELECT_ALL == tag ) then --ȫѡ
            p.SelectAll( current.currentPage);
        
        elseif (ui.ID_CTRL_BUTTON_DELETE == tag ) then --ɾ��
            p.DelectMail();    
		end					
	end
end

--���ϵͳ�ʼ��б�view�¼�
function p.OnSysViewEvent(uiNode, uiEventType, param)
    local view = ConverToView(uiNode);
    if IsClickEvent(uiEventType) then
        local index = view:GetId();
        local mail = p.GetMailByIndex( index );
        --�鿴ϵͳ�ʼ�����
        dlg_mailbox_sys_detail.ShowUI( mail );
    end 
end

--��������ʼ��б�view�¼�
function p.OnPrsViewEvent(uiNode, uiEventType, param)
    WriteCon( "view" );
    local view = ConverToView(uiNode);
    if IsClickEvent(uiEventType) then
        local index = view:GetId();
        local mail = p.GetMailByIndex( index );
        --�鿴ϵͳ�ʼ�����
        dlg_mailbox_person_detail.ShowUI( mail );
    end 
end

--���checkbtn�¼�
function p.OnCheckEvent(uiNode, uiEventType, param)
   
    local checkBox = ConverToCheckBox(uiNode);
    if IsClickEvent( uiEventType ) then
       --�Ѿ���ѡ��
       if checkBox:GetChecked() then
            checkBox:SetChecked( false );
            checkBox:SetImage( GetPictureByAni("ui.checkbox", 0 ));
            current.selectlist[ checkBox:GetParent():GetId()] = 0;
       else
            checkBox:SetChecked( true );
            checkBox:SetCheckImage( GetPictureByAni("ui.checkbox", 1));
            current.selectlist[ checkBox:GetParent():GetId()] = 1;
       end
      dump_obj(current.selectlist);
    end
end

--��ҳ
function p.ChangePage( category )
	if category == DOWN then 
       p.PageCheckDown();

	elseif category == UP then
       p.PageCheckUp();
	end
end

--�ж��Ƿ�������·�ҳ
function p.PageCheckDown()
    if current.currentPage + 1 > current.maxPage then
      return;
    end
    current.currentPage = current.currentPage + 1;
    p.ShowByPage();
    p.RefreshPageNum();
end

--�ж��Ƿ�������Ϸ�ҳ
function p.PageCheckUp()
    if current.currentPage - 1 < 1 then
        return;
    end
    current.currentPage = current.currentPage - 1;
    p.ShowByPage();
    p.RefreshPageNum();
end

--���·�ҳ��ʾ
function p.RefreshPageNum()
	local maxPageLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_MAX_PAGE );
    maxPageLab:SetText(" / " .. current.maxPage );
    local pageLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_PAGE );
    pageLab:SetText( tostring( current.currentPage ));
end

--��ʼ��ѡ���б�
function p.InitSelectList( uiType )
    local temp = {};
    for i=1, showNum do
        temp[i] = 0 ;
    end
    if uiType == p.SYS then
        sysMail.selectlist = temp;
    else    
        prsMail.selectlist = temp;
    end
    dump_obj(current.selectlist);
end

--��ǰҳȫѡ
function p.SelectAll( currentPage )
    for i = 1 , 10 do
        current.selectlist[i] = 1 ; 
    end
    
    --����ѡ���״̬
    for i = 1, showNum do
         current.checkboxlist[ i ]:SetChecked( true );
         current.checkboxlist[ i ]:SetCheckImage( GetPictureByAni("ui.checkbox", 1));
    end
    dump_obj(current.selectlist);
end

--�������λ��
function p.GetIndexInList( page, index)
    return ( page - 1 ) * showNum + index ; 
end

--ɾ���ʼ�
function p.DelectMail()
    local temp = "";
    for i=1, #current.selectlist do
        --����ѡ��    
        if current.selectlist[i] == 1 then
            --��ȡ
            local id = p.GetMailByIndex( i ).id;
            temp = temp .. id ..",";
        end
    end
    local ids = string.sub(temp, 1 , #temp-1);
    mailbox_mgr.ReqDelMial( ids );
end

--��ȡ�ʼ�
function p.GetMailByIndex( index )
    if current.uiType == p.SYS then
        return mailbox_mgr.sysMail[ p.GetIndexInList( current.currentPage , index )];
    else 
        return mailbox_mgr.prsMail[ p.GetIndexInList( current.currentPage , index )];
    end
end

--���ؽ���
function p.ReloadUI()
	current.currentPage = 1;
	p.ShowByPage();
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