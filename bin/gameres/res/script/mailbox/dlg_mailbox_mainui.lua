--------------------------------------------------------------
-- FileName: 	dlg_mailbox_mainui.lua
-- author:		zjj, 2013/09/18
-- purpose:		邮件界面
--------------------------------------------------------------

dlg_mailbox_mainui = {}
local p = dlg_mailbox_mainui;

p.layer = nil;
local ui = ui_dlg_mailbox_mainui;

local UP = 1;
local DOWN = 2;
p.SYS = 1;
p.PRS = 2;

--每页显示数
local showNum = 10;
--存放当前参数
local current = nil;

--系统邮件参数
local sysMail = {
    currentPage = 1,
    maxPage = nil,
    mailList = nil,
    data = nil,
    uiType = p.SYS,
    selectlist = {},
    checkboxlist = {}
};

--个人邮件参数
local prsMail = {
    currentPage = 1,
    maxPage = nil,
    mailList = nil,
    data = nil,
    uiType = p.PRS,
    selectlist = {},
    checkboxlist = {}
};

--显示UI
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

--初始化
function p.Init()

    sysMail.mailList = GetListBoxVert(p.layer , ui.ID_CTRL_VERTICAL_LIST_SYS_MAIL);
    prsMail.mailList = GetListBoxVert(p.layer , ui.ID_CTRL_VERTICAL_LIST_PRS_MAIL);
    
    --返回
    local backBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --上一页
    local pageUpBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_PAGE_UP);
    pageUpBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --下一页
    local pageDownBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_PAGE_DOWN);
    pageDownBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --客服
    local gmBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_GM);
    gmBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --写信
    local wirteBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_WRITE_MAIL);
    wirteBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --系统邮件 
    local sysUIBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_SYS_MAIL);
    sysUIBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --个人邮件
    local prsUIBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_PERSON_MAIL);
    prsUIBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --全选
    local selAllBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_SELECT_ALL);
    selAllBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
    
    --删除
    local delBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_DELETE);
    delBtn:SetLuaDelegate(p.OnMailBoxUIEvent);
end

--显示系统邮件列表
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

--显示个人邮件列表
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

--显示系统邮件内容
function p.ShowByPage() 
    current.mailList:SetVisible( true );
    current.mailList:ClearView();
    checkboxlist = {};
    
    --初始化选择列表
    p.InitSelectList(current.uiType);
    current.maxPage = math.ceil( #mailbox_mgr.sysMail / showNum);
    
    if current.uiType == p.SYS then
        for i=1, showNum do 
            if i > #mailbox_mgr.sysMail then
                return; 
            end
            --根据位置获取邮件
            local mail = p.GetMailByIndex( i );
            --无附件邮件
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
            --有附件
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
            
            --根据位置获取邮件
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

--设置系统邮件信息（无附件）
function p.SetSysMailInfo(view , mail)
    local ui = ui_mailbox_sys_view;
    --名称
    local nameLab = GetLabel( view, ui.ID_CTRL_TEXT_SYSMAIL_NAME );
    nameLab:SetText( tostring( mail.title ));
    --时间
    local timeLab = GetLabel( view, ui.ID_CTRL_TEXT_SYSMAIL_TIME );
    timeLab:SetText( tostring( mail.created_at ));
    --内容
    local contentLab = GetLabel( view, ui.ID_CTRL_TEXT_SYSMAIL_CONTENT );
    contentLab:SetText( tostring( mail.text ));
end

--设置系统邮件信息（带附件）
function p.SetSysRewardMailInfo( view , mail)
    local ui = ui_mailbox_sys_reward_view;
    --名称
    local titleLab = GetLabel( view , ui.ID_CTRL_TEXT_SYSMAIL_TITLE );
    titleLab:SetText( tostring( mail.title ));
    --时间
    local timeLab = GetLabel( view , ui.ID_CTRL_TEXT_SYSMAIL_TIME );
    timeLab:SetText( tostring( mail.created_at ));
    --内容
    local contentLab = GetLabel( view , ui.ID_CTRL_TEXT_SYSMAIL_CONTENT );
    contentLab:SetText( tostring( mail.text ));
    --状态
    local stateLab = GetLabel( view , ui.ID_CTRL_TEXT_SYSMAIL_STATE );
    if mail.is_reward_received then
        stateLab:SetText( GetStr( "is_received" ));
    else
        stateLab:SetText( GetStr( "is_not_received" ));
    end
    
    --附件
    local rewardImgs = p.InitReward( view );
    for i=1 , #mail.rewards do
        rewardImgs[ i ]:SetVisible( true );
    end
end

--初始化附件控件
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

--设置个人邮件信息
function p.SetPrsMailInfo( view , mail)
    local ui = ui_mailbox_person_view
	--名称
	local nameLab = GetLabel( view , ui.ID_CTRL_TEXT_PERSONALMAIL_NAME );
	nameLab:SetText( tostring( mail.title) );
	
	--发件人
	local senderLab = GetLabel( view , ui.ID_CTRL_TEXT_ADDRESSER );
	senderLab:SetText( tostring( mail.sender_user_name) );
	
	--时间
	local timeLab = GetLabel( view , ui.ID_CTRL_TEXT_PERSONALMAIL_TIME );
	timeLab:SetText( tostring( mail.created_at) );
	
	--内容
	local contentLab = GetLabel( view , ui.ID_CTRL_TEXT_PERSONALMAIL_CONTENT );
	contentLab:SetText( tostring( mail.text) );
	
	--状态
	local stateLab = GetLabel( view , ui.ID_CTRL_TEXT_PERSONALMAIL_STATE );
	if mail.is_read then
	   stateLab:SetText( GetStr( "is_read" ));
	else
	   stateLab:SetText( GetStr( "is_not_read"));
	end
end

--事件处理
function p.OnMailBoxUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then	
			p.CloseUI();
	    elseif (ui.ID_CTRL_BUTTON_PAGE_DOWN == tag ) then --下一页
	        p.ChangePage( DOWN );
	    
	    elseif (ui.ID_CTRL_BUTTON_PAGE_UP == tag ) then --上一页
	       
            p.ChangePage( UP );
            
        elseif (ui.ID_CTRL_BUTTON_GM == tag ) then --客服
            dlg_mailbox_kf.ShowUI();
        
        elseif (ui.ID_CTRL_BUTTON_WRITE_MAIL == tag ) then  --写信 
            dlg_mailbox_person_write.ShowUI();
            
        elseif (ui.ID_CTRL_BUTTON_SYS_MAIL == tag ) then --系统邮件
            p.ShowSysMail( mailbox_mgr.sysMail);
            
        elseif (ui.ID_CTRL_BUTTON_PERSON_MAIL == tag ) then --个人邮件
            p.ShowPrsMail( mailbox_mgr.prsMail );
        
        elseif (ui.ID_CTRL_BUTTON_SELECT_ALL == tag ) then --全选
            p.SelectAll( current.currentPage);
        
        elseif (ui.ID_CTRL_BUTTON_DELETE == tag ) then --删除
            p.DelectMail();    
		end					
	end
end

--点击系统邮件列表view事件
function p.OnSysViewEvent(uiNode, uiEventType, param)
    local view = ConverToView(uiNode);
    if IsClickEvent(uiEventType) then
        local index = view:GetId();
        local mail = p.GetMailByIndex( index );
        --查看系统邮件详情
        dlg_mailbox_sys_detail.ShowUI( mail );
    end 
end

--点击个人邮件列表view事件
function p.OnPrsViewEvent(uiNode, uiEventType, param)
    WriteCon( "view" );
    local view = ConverToView(uiNode);
    if IsClickEvent(uiEventType) then
        local index = view:GetId();
        local mail = p.GetMailByIndex( index );
        --查看系统邮件详情
        dlg_mailbox_person_detail.ShowUI( mail );
    end 
end

--点击checkbtn事件
function p.OnCheckEvent(uiNode, uiEventType, param)
   
    local checkBox = ConverToCheckBox(uiNode);
    if IsClickEvent( uiEventType ) then
       --已经被选中
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

--翻页
function p.ChangePage( category )
	if category == DOWN then 
       p.PageCheckDown();

	elseif category == UP then
       p.PageCheckUp();
	end
end

--判断是否可以向下翻页
function p.PageCheckDown()
    if current.currentPage + 1 > current.maxPage then
      return;
    end
    current.currentPage = current.currentPage + 1;
    p.ShowByPage();
    p.RefreshPageNum();
end

--判断是否可以向上翻页
function p.PageCheckUp()
    if current.currentPage - 1 < 1 then
        return;
    end
    current.currentPage = current.currentPage - 1;
    p.ShowByPage();
    p.RefreshPageNum();
end

--更新分页显示
function p.RefreshPageNum()
	local maxPageLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_MAX_PAGE );
    maxPageLab:SetText(" / " .. current.maxPage );
    local pageLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_PAGE );
    pageLab:SetText( tostring( current.currentPage ));
end

--初始化选择列表
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

--当前页全选
function p.SelectAll( currentPage )
    for i = 1 , 10 do
        current.selectlist[i] = 1 ; 
    end
    
    --更改选择框状态
    for i = 1, showNum do
         current.checkboxlist[ i ]:SetChecked( true );
         current.checkboxlist[ i ]:SetCheckImage( GetPictureByAni("ui.checkbox", 1));
    end
    dump_obj(current.selectlist);
end

--计算具体位置
function p.GetIndexInList( page, index)
    return ( page - 1 ) * showNum + index ; 
end

--删除邮件
function p.DelectMail()
    local temp = "";
    for i=1, #current.selectlist do
        --若被选中    
        if current.selectlist[i] == 1 then
            --获取
            local id = p.GetMailByIndex( i ).id;
            temp = temp .. id ..",";
        end
    end
    local ids = string.sub(temp, 1 , #temp-1);
    mailbox_mgr.ReqDelMial( ids );
end

--获取邮件
function p.GetMailByIndex( index )
    if current.uiType == p.SYS then
        return mailbox_mgr.sysMail[ p.GetIndexInList( current.currentPage , index )];
    else 
        return mailbox_mgr.prsMail[ p.GetIndexInList( current.currentPage , index )];
    end
end

--重载界面
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