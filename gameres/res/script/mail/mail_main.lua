-------------------------------------------------------------
-- FileName: 	mail_main.lua
-- author:		wjl, 2013年11月24日
-- purpose:		邮箱主界面
--------------------------------------------------------------

mail_main = {}
local p = mail_main;

------------------邮件类型类型------------------
p.MAIL_TYPE_SYS                    = 1;        -- 系统(网络定义)
p.MAIL_TYPE_USER  				   = 2;			-- 个人(网络定义)
p.MAIL_TYPE_GM					   = 3;			-- 客服(网络定义)

p.MAIL_IS_READED				   = 1;			-- 已读(网络定义)
p.MAIL_REWARD_UNGET				   = 0;			-- 未领取(网络定义)
p.MAIL_REWARD_GETED				   = 1;			-- 已领取(网络定义)
p.MAIL_REWARD_NONE				   = 2;			-- 无奖励(网络定义)

p.NET_CODE_LEVEL_NOT_ENOUGH     	=10001  	--等级不足(网络定义)
p.NET_CODE_REWARD_NOT_GOT			=10002     --奖品未领取(网络定义)
p.NET_CODE_MAIL_NOT_EXIST			=10003     --邮件不存在(网络定义)
p.NET_CODE_SEND_MAIL_SUCCESS		=10004     --发送成功(网络定义)
p.NET_CODE_NO_USER_OR_MAIL_TYPE		=10005     --未定义用户id或系统邮件类型(网络定义)
p.NET_CODE_MAIL_DELETE_SUCCESS		=10006     --邮件删除成功(网络定义)
p.NET_CODE_GET_UNREAD_NUM_SUCCESS	=10007     --返回未读邮件数成功(网络定义)
p.NET_CODE_REWARD_HAS_BEEN_TOKEN	=10008     --邮件附件（奖励）已被领取或无奖励(网络定义)
p.NET_CODE_NO_REWARD				=10009     --奖励不存在(网络定义)
p.NET_CODE_NO_ENOUGH_ITEM_SPACE		=10010     --背包空间不足(网络定义)
p.NET_CODE_REWARD_GET_SUCCESS		=10011     --附件（奖励）领取成功(网络定义)
p.NET_CODE_RECEIVER_NOT_EXIST		=10012     --发送邮件，接收方不存在(网络定义)

p.PAGE_SIZE = 6; --每页数量

p.layer = nil;
p.curListTypeTag = nil;
p.m_kCheckMail = nil;
p.isShowed = true;
p.curPage = 1;

p.msgs = {};
p.selIds = nil;

local ui = ui_mail_main
local ui_item_sys = ui_mail_list_item_sys
local ui_item_usr = ui_mail_list_item_user

function p.ShowUI(isReloadNet)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.isShowed = true
		--dlg_battlearray.ShowUI();
		local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_MAIN);
		if list then
			list:SetVisible(true);
		end
		if isReloadNet == true and p.msgs then
			p.msgs[p.curListTypeTag] = {};
		end
		p.ShowList(p.curListTypeTag);
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
	
	p.ShowList(p.MAIL_TYPE_SYS);
end


--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		p.isShowed = false;
		local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_MAIN);
		if list then
			list:SetVisible(false);
		end
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
		p.curListTypeTag = nil;
		p.msgs = {}
    end
end

--设置按钮
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
			WriteCon("**========返回========**");
			p.CloseUI();
			maininterface.ShowUI();
			dlg_userinfo.ShowUI();
		elseif ui.ID_CTRL_BUTTON_WRITE == tag then
			WriteCon("**========写信========**");
			p.HideUI();
			mail_write_mail.ShowUI();
		elseif ui.ID_CTRL_BUTTON_GM == tag then
			WriteCon("**========客服========**");
			p.HideUI();
			mail_gm_mail.ShowUI();
		elseif ui.ID_CTRL_BUTTON_SYS == tag then
			WriteCon("**======系统列表======**");
			if (p.curListTypeTag == p.MAIL_TYPE_SYS) then
				return
			else
				p.ShowList(p.MAIL_TYPE_SYS)
			end
			
		elseif ui.ID_CTRL_BUTTON_USER == tag then
			WriteCon("**======个人列表======**");
			if (p.curListTypeTag == p.MAIL_TYPE_USER) then
				return
			else
				p.ShowList(p.MAIL_TYPE_USER);
			end
		elseif ui.ID_CTRL_BUTTON_SELECT_ALL == tag then
			p.SelectAllItem();
		elseif ui.ID_CTRL_BUTTON_DEL == tag then
			--dlg_msgbox.ShowOK(GetStr("mail_tip_title"), GetStr("mail_tip_del_empty"),nil);
			p.DelMail();
		elseif ui.ID_CTRL_BUTTON_NEXT_PAGE == tag then
			p.NextPage();
		elseif ui.ID_CTRL_BUTTON_PRE_PAGE == tag then
			p.PrePage();
		end
	end
end

function p.OnItemClick(uiNode, uiEventType, param)
	local id = uiNode:GetId();
	WriteCon("**======OnItemClick======** " .. tostring(id));
	if p.isShowed == true then
		p.HideUI();
		local lst = p.msgs[p.curListTypeTag] or {};
		local pages = lst.pages or {};
		local page = pages[lst.curPage or 1 ] or {};
		local item = page[id];
		local n = 0;
		if item and item.state ~= mail_main.MAIL_IS_READED then
			n = 1;
		end
		if p.curListTypeTag == p.MAIL_TYPE_SYS then
			mail_detail_sys.ShowUI(item);
			p.msgs.sysUnRead = p.msgs.sysUnRead - n;
		else
			mail_detail_user.ShowUI(item);
			p.msgs.userUnRead = p.msgs.userUnRead - n;
		end
	end
end

function p.OnCheckEvent(uiNode, uiEventType, param)
	
	local bt = ConverToButton(uiNode);
	local st = bt:GetChecked();
	if st == true then
		bt:SetChecked(false);
	else
		bt:SetChecked(true);
	end
	--p.m_kCheckMail:SetChecked(true);
end




--------------------数据控制逻辑--------------------------------------

------
function p.ShowList(msgType)
	p.curListTypeTag = msgType
	
	if p.curListTypeTag == p.MAIL_TYPE_USER then
		local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_USER)
		bt:SetChecked (true);
		local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_SYS)
		bt:SetChecked (false);
	else
		local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_SYS)
		bt:SetChecked (true);
		local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_USER)
		bt:SetChecked (false);
	end
	
	p.msgs[p.curListTypeTag] = p.msgs[p.curListTypeTag] or {};
	local lst = p.msgs[p.curListTypeTag];
	local pages = lst.pages or {};
	local page = pages[ lst.curPage or 1 ]

	
	p.RefreshPageInfo();
	
	if page and #page > 0 then
		p.RefreshCurList();
		return;
	else
		if lst.curPage == nil then
			lst.curPage = 1;
		end
		p.LoadMsgsByTpye(p.curListTypeTag,lst.curPage);
	end
end

function p.PrePage()
	local lst = p.msgs[p.curListTypeTag] or {};
	local curPage = lst.curPage or 1;
	curPage = tonumber(curPage);
	
	local total = 0;
	if p.curListTypeTag == p.MAIL_TYPE_SYS then
		total = p.msgs.sysTotal or 1;
	else
		total = p.msgs.userTotal or 1;
	end

	total = tonumber(total);
	local totalPage = math.ceil(total / p.PAGE_SIZE);	
	
	if curPage > 1 then
		lst.curPage = curPage -1;
	else
		return;
	end
	
	p.ShowList(p.curListTypeTag);
	
end

function p.NextPage()
	local lst = p.msgs[p.curListTypeTag] or {};
	local curPage = lst.curPage or 1;
	curPage = tonumber(curPage);
	
	local total = 0;
	if p.curListTypeTag == p.MAIL_TYPE_SYS then
		total = p.msgs.sysTotal or 1;
	else
		total = p.msgs.userTotal or 1;
	end

	total = tonumber(total);
	local totalPage = math.ceil(total / p.PAGE_SIZE);	
	
	if curPage < totalPage then
		lst.curPage = curPage + 1;
	else
		return;
	end
	
	p.ShowList(p.curListTypeTag);
	
end

function p.RefreshPageInfo()
	
	local lst = p.msgs[p.curListTypeTag];
	if lst and lst.curPage and tonumber(lst.curPage) > 0 then
		local v = GetLabel( p.layer, ui.ID_CTRL_TEXT_PAGE_INFO);
		if v and p.curListTypeTag == p.MAIL_TYPE_SYS and p.msgs.sysTotal and tonumber(p.msgs.sysTotal) > 0 then
			local totlaPage = math.ceil(tonumber(p.msgs.sysTotal)/p.PAGE_SIZE);
			v:SetText(tostring(lst.curPage) .. "/" .. tostring(totlaPage));
		elseif v and p.curListTypeTag == p.MAIL_TYPE_USER and p.msgs.userTotal and tonumber(p.msgs.userTotal) > 0 then
			local totlaPage = math.ceil(tonumber(p.msgs.userTotal)/p.PAGE_SIZE);
			v:SetText(tostring(lst.curPage) .. "/" .. tostring(totlaPage));
		else
			v:SetText("0/0");
		end
	end
	
	local v = GetLabel( p.layer, ui.ID_CTRL_TEXT_SYS_UNREAD);
	if p.msgs.sysUnRead and tonumber(p.msgs.sysUnRead) > 0 then 
		v:SetText(tostring(p.msgs.sysUnRead));
		v:SetVisible(true);
	else
		v:SetVisible(false);
	end
	
	v = GetLabel( p.layer, ui.ID_CTRL_TEXT_USER_UNREAD);
	if p.msgs.userUnRead and tonumber(p.msgs.userUnRead) > 0 then 
		v:SetText(tostring(p.msgs.userUnRead));
		v:SetVisible(true);
	else 
		v:SetVisible(false);
	end
	
	
end

--------全选
function p.SelectAllItem()
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_MAIN);
	local count = list:GetViewCount ();
	for i = 1, count do
		local parentV = list:GetViewAt(i-1);
		local bt = nil;
		if p.curListTypeTag == p.MAIL_TYPE_SYS then
			bt = GetButton( parentV, ui_item_sys.ID_CTRL_CHECK_BUTTON_SEL)
		else 
			bt = GetButton( parentV, ui_item_usr.ID_CTRL_CHECK_BUTTON_SEL)
		end 
		if bt then
			bt:SetChecked(true);
		end
	end
end

function p.GetSelectedItems()
	
	local lst = p.msgs[p.curListTypeTag] or {};
	local pages = lst.pages or {};
	local page = pages[lst.curPage or 1 ] or {};
	
	if page == nil then
		return;
	end
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_MAIN);
	local count = list:GetViewCount ();
	local ids = {};
	for i = 1, count do
		local parentV = list:GetViewAt(i-1);
		local bt = nil;
		if p.curListTypeTag == p.MAIL_TYPE_SYS then
			bt = GetButton( parentV, ui_item_sys.ID_CTRL_CHECK_BUTTON_SEL)
		else 
			bt = GetButton( parentV, ui_item_usr.ID_CTRL_CHECK_BUTTON_SEL)
		end 
		if bt and bt:GetChecked() == true then
			local item = page[i] or {};
			ids[#ids + 1] = item.mailId;
		end
	end
	
	return ids;
end


--------刷新全部ui,在网络处理后请求-----
function p.RefreshUI()
	
	p.RefreshPageInfo();
	
	p.RefreshCurList();
end

---------刷新当前列表-----------
function p.RefreshCurList()
	local lst = p.msgs[p.curListTypeTag] or {};
	local pages = lst.pages or {};
	local page = pages[lst.curPage or 1 ] or {};
	
	if p.curListTypeTag == p.MAIL_TYPE_SYS then
		p.RefreshPage4Sys(page);
	else
		p.RefreshPage4User(page);
	end
	
	p.RefreshPageInfo();
end


function p.RefreshPage4Sys(pageItems)
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_MAIN);
	list:ClearView();

	if pageItems == nil or #pageItems <= 0 then
		WriteCon("refreshPage4Sys():pageItems is null");
		return ;
	end

	local listLenght = #pageItems;

	for i = 1,listLenght do
		local view = p.CreateItem4Sys();
		p.SetItemInfo4Sys( view, pageItems[i]);
		view:SetId(i);
		list:AddView( view );
	end
end

function p.CreateItem4Sys()
	local view = createNDUIXView();
	view:Init();
	LoadUI( "mail_list_item_sys.xui", view, nil );
	view:SetViewSize( GetUiNode( view, ui_item_sys.ID_CTRL_PICTURE_BG ):GetFrameSize());

	
	local kCheckBox = GetButton(view,ui_item_sys.ID_CTRL_CHECK_BUTTON_SEL);
	kCheckBox:SetLuaDelegate(p.OnCheckEvent);
	
	return view;
end

function p.SetItemInfo4Sys( view, item )

	--标题
	local titleV = GetLabel( view, ui_item_sys.ID_CTRL_TEXT_TITLE);
	titleV:SetText(item.title or "");

	--时间
	local timeV = GetLabel( view, ui_item_sys.ID_CTRL_TEXT_TIME);
	timeV:SetText(item.tm or "");
	
	--内容
	local contentV = GetLabel( view, ui_item_sys.ID_CTRL_TEXT_CONTENT);
	contentV:SetText(item.content or "");
	
	--状态
	local stateV = GetLabel( view, ui_item_sys.ID_CTRL_TEXT_STATE);
	local stN = tonumber(item.state) or 0;
	local stRe = tonumber(item.rewardState) or 2
	--local str = "";
	if stN ==p.MAIL_IS_READED then
		--str = "Readed"
		titleV:SetFontColor(ccc4(144,144,144,255));
		timeV:SetFontColor(ccc4(144,144,144,255));
		contentV:SetFontColor(ccc4(144,144,144,255));
		--stateV:SetText("Readed");
	else
		--str = "Unreaded"
		--stateV:SetText("Unreaded");
	end
	
	if item.rewardId and item.rewardId ~= 0 and  stRe == p.MAIL_REWARD_UNGET then 
		stateV:SetText(GetStr("main_ungain"));
		stateV:SetFontColor(ccc4(255,0,0,255));
	elseif item.rewardId and item.rewardId ~= 0 and stRe == p.MAIL_REWARD_GETED then
		stateV:SetText(GetStr("mail_gained"));
		if stN ==p.MAIL_IS_READED then
			stateV:SetFontColor(ccc4(144,144,144,255));
		end
	else
		--str = str.. "  non"
	end
	
	--stateV:SetText(str);
	
	--local cardPicNode = GetButton( view, cardPic );
	--cardPicNode:SetImage( user_skill_mgr.GetCardPicture(item.skill_id) );
	--cardPicNode:SetTouchDownImage( user_skill_mgr.GetCardPicture(item.skill_id) );
	--cardPicNode:SetId( tonumber(item.id));
	--增加事件
	--cardPicNode:SetLuaDelegate(p.OnBtnClicked);
	
	view:SetLuaDelegate(p.OnItemClick);
end

-------- 个人邮件Item

function p.RefreshPage4User(pageItems)
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_MAIN);
	list:ClearView();

	if pageItems == nil or #pageItems <= 0 then
		WriteCon("refreshPage4User():pageItems is null");
		return ;
	end

	local listLenght = #pageItems;

	for i = 1,listLenght do
		local view = p.CreateItem4User();
		p.SetItemInfo4User( view, pageItems[i]);
		view:SetId(i);
		list:AddView( view );
	end
end

function p.CreateItem4User()
	local view = createNDUIXView();
	view:Init();
	LoadUI( "mail_list_item_user.xui", view, nil );
	view:SetViewSize( GetUiNode( view, ui_item_usr.ID_CTRL_PICTURE_BG ):GetFrameSize());
	local kCheckBox = GetButton(view,ui_item_usr.ID_CTRL_CHECK_BUTTON_SEL);
	kCheckBox:SetLuaDelegate(p.OnCheckEvent);
	return view;
end

function p.SetItemInfo4User( view, item )

	--标题
	local titleV = GetLabel( view, ui_item_usr.ID_CTRL_TEXT_TITLE);
	titleV:SetText(item.title or "");
	
	--名称
	local timeV = GetLabel( view, ui_item_usr.ID_CTRL_TEXT_NAME);
	timeV:SetText(item.nm or "");

	--时间
	local timeV = GetLabel( view, ui_item_usr.ID_CTRL_TEXT_TIME);
	timeV:SetText(item.tm or "");
	
	--内容
	local contentV = GetLabel( view, ui_item_usr.ID_CTRL_TEXT_CONTENT);
	contentV:SetText(item.content or "");
	
	--状态
	local stateV = GetLabel( view, ui_item_usr.ID_CTRL_TEXT_STATE);
	local stN = tonumber(item.state) or 0;
	local stRe = tonumber(item.rewardState) or 2
	--local str = "";
	if stN ==1 then
		--str = "Readed"
		titleV:SetFontColor(ccc4(144,144,144,255));
		timeV:SetFontColor(ccc4(144,144,144,255));
		contentV:SetFontColor(ccc4(144,144,144,255));
		stateV:SetFontColor(ccc4(144,144,144,255));
		stateV:SetText(GetStr("mail_readed"));
		--stateV:SetText("Readed");
	else
		--str = "Unreaded"
		stateV:SetText(GetStr("mail_unread"));
		stateV:SetFontColor(ccc4(255,0,0,255));
		--stateV:SetText("Unreaded");
	end
	
	--if stRe == p.MAIL_REWARD_UNGET then 
		--str = str.. "  unget"
	--elseif stRe == p.MAIL_REWARD_GETED then
		--str = str.. "  getted"
	--else
		--str = str.. "  non"
	--end
	
	--stateV:SetText(str);
	
	--local cardPicNode = GetButton( view, cardPic );
	--cardPicNode:SetImage( user_skill_mgr.GetCardPicture(item.skill_id) );
	--cardPicNode:SetTouchDownImage( user_skill_mgr.GetCardPicture(item.skill_id) );
	--cardPicNode:SetId( tonumber(item.id));
	--增加事件
	--cardPicNode:SetLuaDelegate(p.OnBtnClicked);
	view:SetLuaDelegate(p.OnItemClick);
end

function p.DelMail()
	
	local ids = p.GetSelectedItems();
	
	if ids and #ids > 0 then
		p.selIds = ids;
		dlg_msgbox.ShowYesNo(GetStr("mail_confirm_title"), string.format(GetStr("mail_confirm_del"),#ids),p.RequestDelSel);
		return;
	else
		dlg_msgbox.ShowOK(GetStr("mail_erro_title"), GetStr("mail_tip_del_empty"),nil);
	end
	
	
end


----------------------------------------------网络请求处理-------------------------------------------------------------
function p.LoadMsgsByTpye(iType,iCurPage)
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end;
			
			
	--1是系统,2是个人
	local param = string.format("&mail_type=%d&page=%d&per_page_num=%d", iType, iCurPage,p.PAGE_SIZE);
	--local param = "&mail_type=1&page=1&per_page_num=6"
	uid = 123456
	SendReq("Mail","ReadMail",uid,param);
end

function p.OnNetCallback(msg)
	
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	local page = p.ParseMsg(msg);
	p.msgs[p.curListTypeTag] = p.msgs[p.curListTypeTag] or {};
	local lst = p.msgs[p.curListTypeTag] or {};
	lst.pages = lst.pages or {};
	
	lst.pages[lst.curPage or 1 ] = lst.pages[lst.curPage or 1 ] or {}; 
	
	lst.pages[lst.curPage or 1 ] = page;
	
	p.RefreshUI();

end

function p.ParseMsg(msg)
	local netPages = msg.show_mail or {};
	local page = {}; 
	local size = #netPages or 0
	for i = 1,  size do
		--title="abc", nm="Jason",tm="05-21 19:33:33", content="efff:",state="0"
		--reward
		local item = {};
		local netP = netPages[i];
		item.title = netP.Mail_title;
		item.mailId = netP.id;
		item.content = netP.Mail_text;
		item.tm = netP.Time_start;
		item.state = tonumber(netP.Is_read);
		item.rewardId = tonumber(netP.Reward_id);
		local rewardState = tonumber(netP.Is_reward);
		item.rewardState = rewardState;
				
		if netP.Rewards and rewardId ~= 0 and (rewardState == p.MAIL_REWARD_GETED or rewardState == p.MAIL_REWARD_UNGET )then
			item.rewards = {};
			local ary = netP.Rewards[1] or {};
			local count = 1;
			for j = 1, 6 do
				local id = ary["Reward_id"..j] or 0;
				id = tonumber(id);
				if id ~= 0 then
					item.rewards[count] = {};
					item.rewards[count].rewordId = id
					item.rewards[count].rewordType = ary["Reward_type"..j]
					item.rewards[count].num = ary["Reward_num"..j]
					count = count + 1;
				end
			end
		end
		page[i]  = item;
	end
	
	local pageInfo = msg.page_info or {};
	p.msgs.sysUnRead = pageInfo.sys_unread_num or 0;
	p.msgs.userUnRead = pageInfo.personal_unread_num or 0;
	p.msgs.sysTotal = pageInfo.sys_mail_num or 0; --页码?
	p.msgs.userTotal = pageInfo.per_mail_num or 0; --页码?
	p.msgs.gmUnRead = pageInfo.server_unread_num or 0;
	p.msgs.gmTotal = pageInfo.server_mail_num or 0;
	
	return page;
end

function p.OnNetDelCallback(msg)
	
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		WriteCon("OnNetDelCallback()");
		local str = GetStr("mail_tip_del_suc") 
		if msg and msg.callback_msg and msg.callback_msg.msg_id then
			local errCode = tonumber(msg.callback_msg.msg_id);
			
			if errCode == p.NET_CODE_REWARD_NOT_GOT then
				local unDelNum = 1;
				local delNum = (#p.selIds) - unDelNum;
				str = string.format(GetStr("mail_del_part"), delNum,unDelNum);
			end
		end
		
		dlg_msgbox.ShowOK(GetStr("mail_tip_title"), str,p.forceReload);
		
	else
	
		local str = mail_main.GetNetResultError(msg);
		if str then
			dlg_msgbox.ShowOK(GetStr("mail_erro_title"), str,nil);
		else
			WriteCon("**======mail_main.OnNetDelCallback error ======**");
		end
			
	end
	
end

function p.forceReload()
	if p.msgs then	
		p.msgs[p.curListTypeTag] = {};
		p.ShowList(p.curListTypeTag);
	end
end

function p.RequestDelSel()
	local ids = p.selIds
	
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end;
	
	if ids == nil or #ids == 0 then
		return;
	end
	
	local idstr="";
	for i = 1, #ids do
		if i > 1 then
			idstr = idstr..",";
		end
		idstr = idstr .. ids[i];
	end
	local param = string.format("&mail_id=%s", idstr);
	uid = 123456
	SendReq("Mail","DelMail",uid,param);
	WriteCon("RequestDelSel()");
end

function p.GetNetResultError(msg)
	local str = nil;
	if msg and msg.callback_msg and msg.callback_msg.msg_id then
		local errCode = tonumber(msg.callback_msg.msg_id);
		
		if errCode == p.NET_CODE_LEVEL_NOT_ENOUGH then
			str = GetStr("mail_result_level_not_enough");
		elseif errCode == p.NET_CODE_REWARD_NOT_GOT then
			str = GetStr("mail_result_reward_not_got");
		elseif errCode == p.NET_CODE_MAIL_NOT_EXIST then
			str = GetStr("mail_result_mail_not_exist");
		elseif errCode == p.NET_CODE_NO_USER_OR_MAIL_TYPE or errCode == p.NET_CODE_RECEIVER_NOT_EXIST then
			str = GetStr("mail_result_reciever_not_exist");
		elseif errCode == p.NET_CODE_REWARD_HAS_BEEN_TOKEN then
			str = GetStr("mail_result_has_been_gained");
		elseif errCode == p.NET_CODE_NO_REWARD then
			str = GetStr("mail_result_no_reward");
		elseif errCode == p.NET_CODE_NO_ENOUGH_ITEM_SPACE then
			str = GetStr("mail_result_no_enough_space");
		else
			str = msg.callback_msg.msg.."("..msg.callback_msg.msg_id..")";
		end
	end
	
	return str;
end




