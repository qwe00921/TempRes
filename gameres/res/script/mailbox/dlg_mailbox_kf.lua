--------------------------------------------------------------
-- FileName: 	dlg_mailbox_kf.lua
-- author:		zjj, 2013/09/18
-- purpose:		客服界面
--------------------------------------------------------------

dlg_mailbox_kf = {}
local p = dlg_mailbox_kf;

p.layer = nil;
p.looklayer = nil;
p.commitlayer = nil;

local ui = ui_dlg_mailbox_kf;

local UP = 1;
local DOWN = 2;
local COMMIT_UI = true;
local LOOK_UI = false;

--记录当前页
local currentPage = 1;
--记录总页数
local maxPage = nil;

--问题主题
local questionTitle = nil;
--问题内容
local questionContent = nil;

--显示UI
function p.ShowUI()
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_mailbox_kf.xui", layer, nil);
	
	p.layer = layer;
	p.looklayer = GetUiLayer( p.layer , ui.ID_CTRL_LAYER_LOOK);
	p.commitlayer = GetUiLayer( p.layer , ui.ID_CTRL_LAYER_COMMIT);
	p.SetDelegate();
    p.SetUIByType( COMMIT_UI );
end

--设置事件处理
function p.SetDelegate(layer)
	--返回
	local backBtn = GetButton(p.layer, ui.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnKfUIEvent);
    
    --发送
    local sendBtn = GetButton(p.commitlayer,ui.ID_CTRL_BUTTON_SEND);
    sendBtn:SetLuaDelegate(p.OnKfUIEvent);
    
    --查看问题
    local checkBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_LOOK);
    checkBtn:SetLuaDelegate(p.OnKfUIEvent);
    
    --提交问题
    local commitBtn = GetButton(p.layer,ui.ID_CTRL_BUTTON_COMMIT);
    commitBtn:SetLuaDelegate(p.OnKfUIEvent);
    
     --上一页
    local pageUpBtn = GetButton(p.looklayer, ui.ID_CTRL_BUTTON_PAGE_UP);
    pageUpBtn:SetLuaDelegate(p.OnKfUIEvent);
    
    --下一页
    local pageDownBtn = GetButton(p.looklayer, ui.ID_CTRL_BUTTON_PAGE_DOWN);
    pageDownBtn:SetLuaDelegate(p.OnKfUIEvent);
    
end

--显示界面
function p.ShowLookUI( questtionData )
	if questionData == nil or #questionData == 0 then
        WriteCon( "no gm mail ! " );
--        return;
    end
    maxPage = math.ceil( 23 / 5);
    p.ShowQuestionList();
end

--显示问题列表
function p.ShowQuestionList()
    
	local list = GetListBoxVert(p.looklayer , ui.ID_CTRL_VERTICAL_LIST_QUESTION);
	list:ClearView();
	
	for i=1, 5 do 
	    if 5 * ( currentPage - 1 ) + i > 23 then 
	       return;
	    end
        local view = createNDUIXView();
        view:Init();
        LoadUI( "kf_question_view.xui", view, nil );
        local bg = GetUiNode( view, ui_kf_question_view.ID_CTRL_PICTURE_BG);
        view:SetViewSize( bg:GetFrameSize());
        view:SetLuaDelegate(p.OnPuestionViewEvent); 
        
        local nameLab = GetLabel( view, ui_kf_question_view.ID_CTRL_TEXT_CONTENT );
        nameLab:SetText( ToUtf8( "物品丢失   " ) .. 5 *( currentPage - 1) + i);
        list:AddView( view );
   end
end

--显示问题内容
function p.ShowQuestionContent( content )

	if questionData == nil or #questionData == 0 then
        WriteCon( "no content ! " );
--        return;
    end
    local list = GetListBoxVert(p.looklayer , ui.ID_CTRL_VERTICAL_LIST_CONTEN);
    list:ClearView();
    
    for i=1,2 do 
        local view = createNDUIXView();
        view:Init();
        LoadUI( "kf_content_view.xui", view, nil );
        local bg = GetUiNode( view, ui_kf_content_view.ID_CTRL_PICTURE_BG);
        view:SetViewSize( bg:GetFrameSize());
     
        list:AddView( view );
   end
end

--点击问题列表view事件
function p.OnPuestionViewEvent(uiNode, uiEventType, param)
    WriteCon( "view" );
    local view = ConverToView(uiNode);
    if IsClickEvent(uiEventType) then
        --查看问题内容
        p.ShowQuestionContent();
    end 
end

--事件处理
function p.OnKfUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui.ID_CTRL_BUTTON_BACK == tag ) then	
			p.CloseUI();
			
	    elseif (ui.ID_CTRL_BUTTON_SEND == tag) then
	        if p.GetSendMsg() then
	            mailbox_mgr.ReqSendMail( "99999999" , questionTitle , questionContent );
	        end
	        
	    --查看问题按钮
	    elseif (ui.ID_CTRL_BUTTON_LOOK == tag) then
	        p.SetUIByType( LOOK_UI );
            p.ShowLookUI();
            
        --提交问题按钮
        elseif (ui.ID_CTRL_BUTTON_COMMIT == tag) then
            p.SetUIByType( COMMIT_UI );
            
        elseif (ui.ID_CTRL_BUTTON_PAGE_DOWN == tag ) then --下一页
            p.ChangePage( DOWN );
        
        elseif (ui.ID_CTRL_BUTTON_PAGE_UP == tag ) then --上一页
           
            p.ChangePage( UP );
		end					
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
    if currentPage + 1 > maxPage then
      return;
    end
    currentPage = currentPage + 1;
    WriteCon( "-------" .. currentPage );
    p.ShowChangePage()
end

--判断是否可以向上翻页
function p.PageCheckUp()
    if currentPage - 1 < 1 then
        return;
    end
    currentPage = currentPage - 1;
    p.ShowChangePage()
end

--问题翻页显示
function p.ShowChangePage()
	p.ShowQuestionList();
	local list = GetListBoxVert(p.looklayer , ui.ID_CTRL_VERTICAL_LIST_CONTEN);
    list:ClearView();
end

--设置提交界面
function p.SetCommitUI( bEnabled )
	p.commitlayer:SetVisible( bEnabled );
end

--设置查看界面
function p.SetLookUI( bEnabled )
    p.looklayer:SetVisible( bEnabled );
end

--获取发送内容
function p.GetSendMsg()
	local titleEdt = GetEdit( p.commitlayer , ui.ID_CTRL_INPUT_TEXT_TITLE);
	local contentEdt = GetEdit( p.commitlayer , ui.ID_CTRL_INPUT_TEXT_CONTENT);
	local title = string.gsub( titleEdt:GetText() , " " , "");
	local content = string.gsub( contentEdt:GetText() , " " , "");
	if string.len(title) > 0 and string.len(content) > 0 then
	   questionTitle = title;
	   questionContent = content;
	   return true;
	else
	   tip.ShowTip( GetStr( "title_or_content_can_not_empty" ));
	   return false;
	end	
end

function p.SetUIByType( uiType )
   p.SetCommitUI( uiType );
   p.SetLookUI( not uiType );
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
        p.looklayer = nil;
        p.commitlayer = nil;
        local currentPage = 1;
        local maxPage = nil;
        local questionTitle = nil;
        local questionContent = nil;
    end
end