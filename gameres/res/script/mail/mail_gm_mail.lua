--------------------------------------------------------------
-- FileName: 	mail_gm_mail.lua
-- author:		wjl, 2013年8月23日
-- purpose:		邮件系统--客服
--------------------------------------------------------------

mail_gm_mail = {}
local p = mail_gm_mail;

------------------邮件类型类型------------------
p.MAIL_TYPE                    = 0;        -- 系统
p.layer = nil;

p.datas = {};


local ui = ui_mail_gm_mail
local ui_item = ui_mail_list_item_gm

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
	
	p.SetAskLayerVisible(true);
	p.SetAnswerLayerVisible(false);
	
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	--btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate()
	local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_SEND );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_GO_BACK );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_ANSWER );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_ASK );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_PAGE_NEXT );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_PAGE_PRE );
	p.SetBtn( bt );
	
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_GO_BACK == tag then
			WriteCon("**========返回========**");
			p.CloseUI();
			mail_main.ShowUI();
		elseif ui.ID_CTRL_BUTTON_ANSWER == tag then
			WriteCon("**======查看问题======**");
			p.ShowGM();
		elseif ui.ID_CTRL_BUTTON_ASK == tag then
			WriteCon("**========提交问题========**");
			p.SetAnswerLayerVisible(false);
			p.SetAskLayerVisible(true);
		elseif ui.ID_CTRL_BUTTON_SEND == tag then
			p.SendEmail();
		elseif ui.ID_CTRL_BUTTON_PAGE_PRE then
			p.PrePage();
		elseif ui.ID_CTRL_BUTTON_PAGE_NEXT then
			p.NextPage();
		end
	end
end

function p.OnItemClick(uiNode, uiEventType, param)
	local id = uiNode:GetId();
	WriteCon("**======OnItemClick======** " .. tostring(id));
	
	local lst = p.datas or {};
	local pages = lst.pages or {};
	local page = pages[lst.curPage or 1 ] or {};
	local item = page[id] or {};
	p.LoadDetail(item.mailId);
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
		p.datas = {};
    end
end

--
function p.ShowGM()
	p.SetAnswerLayerVisible(true);
	p.SetAskLayerVisible(false);
	p.ShowList();
end

--设置两界面状态
function p.SetAskLayerVisible(visible)
	
	local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_ASK)
	if visible == true then
		bt:SetChecked (true);
	else
		bt:SetChecked (false);
	end
	
	local v = GetLabel( p.layer, ui.ID_CTRL_TEXT_TITLE_LABEL);
	v:SetVisible(visible);
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_TIP);
	v:SetVisible(visible);
	v:SetText(GetStr("mail_label_gm_tip"));
	
	v = GetEdit( p.layer, ui.ID_CTRL_INPUT_TEXT_TITLE);
	v:SetVisible(visible);
	
	v = GetEdit( p.layer, ui.ID_CTRL_CHAT_TEXT_QUESTION);
	v:SetVisible(visible);
	
	v = GetButton(p.layer, ui.ID_CTRL_BUTTON_SEND);
	v:SetVisible(visible);
	
end

function p.SetAnswerLayerVisible(visible)
	
	local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_ANSWER)
	if visible == true then
		bt:SetChecked (true);
	else
		bt:SetChecked (false);
	end
	
	local v = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST);
	v:SetVisible(visible);
	if visible == true then
		p.ShowList();
	end
	
	v = GetButton( p.layer, ui.ID_CTRL_BUTTON_PAGE_PRE );
	v:SetVisible(visible);
	v = GetButton( p.layer, ui.ID_CTRL_BUTTON_PAGE_NEXT );
	v:SetVisible(visible);
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_PAGE_INFO);
	v:SetVisible(visible);
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_GM_LABEL);
	v:SetVisible(visible);
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_GM_TIME);
	v:SetVisible(visible);
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_GM_CONTENT);
	v:SetVisible(visible);
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_USER_LABEL);
	v:SetVisible(visible);
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_USER_TIME);
	v:SetVisible(visible);
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_USER_CONTENT);
	v:SetVisible(visible);
end


function p.CreateItem()
	local view = createNDUIXView();
	view:Init();
	LoadUI( "mail_list_item_gm.xui", view, nil );
	view:SetViewSize( GetUiNode( view, ui_item.ID_CTRL_PICTURE_BG ):GetFrameSize());
	return view;
end

function p.SetItemInfo( view, item )

	--标题
	local titleV = GetLabel( view, ui_item.ID_CTRL_TEXT_TITLE);
	titleV:SetText(item.title or "");

	--时间
	local timeV = GetLabel( view, ui_item.ID_CTRL_TEXT_TIME);
	timeV:SetText(item.tm or "");
	
	view:SetLuaDelegate(p.OnItemClick);
end

function p.SetGMCurItemDetail(item)
	
	item = item or {};
	
	--客服
	local titleV = GetLabel( p.layer, ui.ID_CTRL_TEXT_GM_LABEL);
	titleV:SetText(item.title1 or "");
	--if item.cm then
	--	titleV:SetVisible(true);
	--else
	--	titleV:SetVisible(false);
	--end

	--时间
	local timeV = GetLabel( p.layer, ui.ID_CTRL_TEXT_GM_TIME);
	timeV:SetText(item.tm1 or "");
	
	local v = GetLabel( p.layer, ui.ID_CTRL_TEXT_GM_CONTENT);
	v:SetText(item.content1 or "");
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_USER_LABEL);
	v:SetText(item.title2 or "");
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_USER_TIME);
	v:SetText(item.tm2 or "");
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_USER_CONTENT);
	v:SetText(item.content2 or "");
end


function p.SendEmail()
	
	local titleV = GetEdit(p.layer,ui.ID_CTRL_INPUT_TEXT_TITLE);
	local contentV = GetEdit(p.layer,ui.ID_CTRL_CHAT_TEXT_QUESTION);
	
	local title = titleV:GetText();
	local content = contentV:GetText();
	
	if string.len(title) <= 0 then
		dlg_msgbox.ShowOK(GetStr("mail_tip_title"), GetStr("mail_tip_send_title_empty"),nil);
		return;
	end
	
	if string.len(content) <= 0 then
		dlg_msgbox.ShowOK(GetStr("mail_tip_title"), GetStr("mail_tip_send_content_empty"),nil);
		return;
	end
	
	p.UpLoadEmail(URLEncode(title), URLEncode(content));
	
end

function p.ShowList(pageNum)
	p.datas = p.datas or {};
	p.datas.curPage = pageNum or p.datas.curPage;
	
	
	p.datas.pages = p.datas.pages or {};
	
	local pages = p.datas.pages or {};
	local page = pages[ p.datas.curPage ]

	p.RefreshPageInfo();
	p.datas.curPage = p.datas.curPage or 1;
	
	if page and #page > 0 then
		p.RefreshCurList();
		return;
	else
		if p.datas.curPage == nil then
			p.datas.curPage = 1;
		end
		p.LoadMsgs(p.datas.curPage);
	end
end

function p.PrePage()
	local lst = p.datas or {};
	local curPage = lst.curPage or 1;
	curPage = tonumber(curPage);
	
	local total = lst.gmTotal or 0;
	total = tonumber(total);
	local totalPage = math.ceil(total / mail_main.PAGE_SIZE);
	
	if curPage > 1 then
		lst.curPage = curPage -1;
	else
		return;
	end
	
	p.ShowList(lst.curPage);
	
end

function p.NextPage()
	local lst = p.datas or {};
	local curPage = lst.curPage or 1;
	curPage = tonumber(curPage);
	
	local total = lst.gmTotal or 0;
	total = tonumber(total);
	local totalPage = math.ceil(total / mail_main.PAGE_SIZE);
	
	
	if curPage < totalPage then
		lst.curPage = curPage + 1;
	else
		return;
	end
	
	p.ShowList(lst.curPage);
	
end

--------刷新全部ui,在网络处理后请求-----
function p.RefreshUI()
	
	p.RefreshPageInfo();
	
	p.RefreshCurList();
end


function p.RefreshPageInfo()
	
	local lst = p.datas;
	local v = GetLabel( p.layer, ui.ID_CTRL_TEXT_PAGE_INFO);
	if lst and lst.curPage and tonumber(lst.curPage) > 0 and lst.gmTotal and tonumber(lst.gmTotal) > 0 then
		local totlaPage = math.ceil(tonumber(lst.gmTotal)/mail_main.PAGE_SIZE);
		v:SetText(tostring(lst.curPage) .. "/" .. tostring(totlaPage));
	else
		v:SetText("0/0");
	end
end

---------刷新当前列表-----------
function p.RefreshCurList()
	local lst = p.datas or {};
	local pages = lst.pages or {};
	local page = pages[lst.curPage or 1 ] or {};
	
	p.RefreshPage(page);
	p.SetGMCurItemDetail({});
end


function p.RefreshPage(pageItems)
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST);
	list:ClearView();

	if pageItems == nil or #pageItems <= 0 then
		WriteCon("RefreshPage():pageItems is null");
		return ;
	end

	local listLenght = #pageItems;

	for i = 1,listLenght do
		local view = p.CreateItem();
		p.SetItemInfo( view, pageItems[i]);
		view:SetId(i);
		list:AddView( view );
	end
end


------------------------------------------------------网络请求-----------------------------------------------------------------

function p.LoadMsgs(iCurPage)
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end;
			
			
	--1是系统,2是个人,3客服
	local param = string.format("&mail_type=3&page=%d&per_page_num=%d", iCurPage,mail_main.PAGE_SIZE);
	--local param = "&mail_type=1&page=1&per_page_num=6"
	--uid = 123456
	SendReq("Mail","ReadMail",uid,param);
end


--请求发送消息
function p.UpLoadEmail(title,content)
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end;
	
	--local param = string.format("&is_PP=0&Receive_id=%s&Mail_title=%s&Mail_text=%s",receiveId,title,content)
	local param = string.format("&is_PP=0&Mail_title=%s&Mail_text=%s",title,content)
	SendReq("Mail","SendPerMail",uid,param);		
	
end

function p.LoadDetail(mailId)
	if mailId == nil then
		return;
	end
	
	local uid = GetUID();
	if uid == 0 or uid == nil  then
		return ;
	end;
	
	local param = string.format("&mail_id=%d&mail_type=3", tonumber(mailId));
	--uid = 123456
	SendReq("Mail","ReadDetailMail",uid,param);
end


--请求消息后回调
function p.NetCallback(msg)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		dlg_msgbox.ShowOK(GetStr("mail_tip_title"), GetStr("mail_tip_send_suc"),nil);
	elseif msg and msg.callback_msg and msg.callback_msg.msg_id then
		local errCode = tonumber(msg.callback_msg.msg_id);
		if errCode == mail_main.NET_CODE_NO_USER_OR_MAIL_TYPE or errCode == mail_main.NET_CODE_RECEIVER_NOT_EXIST then
			dlg_msgbox.ShowOK(GetStr("mail_erro_title"), GetStr("mail_tip_send_reciver_unknow"),nil);
		else
			dlg_msgbox.ShowOK(GetStr("mail_erro_title"), msg.callback_msg.msg.."("..msg.callback_msg.msg_id..")",nil);
		end
	end
end

function p.OnNetGetListCallback(msg)
	
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	p.datas = p.datas or {};
	p.datas.pages = p.datas.pages or {}; 
	
	local lst = p.datas;
	lst.pages[p.datas.curPage or 1 ] = lst.pages[p.datas.curPage or 1 ] or {}; 
	
	local page = mail_main.ParseMsg(msg);
	lst.pages[p.datas.curPage or 1 ] = page;
	
	local pageInfo = msg.page_info or {};
	p.datas.gmUnRead = pageInfo.server_unread_num or 0;
	p.datas.gmTotal = pageInfo.server_mail_num or 0;
	
	p.RefreshUI();

end

function p.OnNetGetDetail(msg)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	local item = {};
	if msg.result == true  and msg.class_mail_info and #msg.class_mail_info > 0 then
		local  info1 = msg.class_mail_info[1]
		if info1 then
			item.title1=info1.Mail_title
			item.content1 = info1.Mail_text;
			item.tm1 = info1.Time_start;
		end
		
		local  info2 = msg.class_mail_info[2]
		if info2 then
			item.title2=info2.Mail_title
			item.content2 = info2.Mail_text;
			item.tm2 = info2.Time_start;
		end
		
	end
	
	p.SetGMCurItemDetail(item)
	
end
