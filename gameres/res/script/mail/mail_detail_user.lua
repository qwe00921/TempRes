--------------------------------------------------------------
-- FileName: 	mail_detail_sys.lua
-- author:		wjl, 2013年11月24日
-- purpose:		系统邮箱详细信息
--------------------------------------------------------------

mail_detail_user = {}
local p = mail_detail_user;

------------------邮件类型类型------------------
p.MAIL_TYPE                    = 0;        -- 系统
p.layer = nil;

local ui = ui_mail_detail_user
local ui_item = ui_mail_list_item_user_history

function p.ShowUI(item)
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST);
		if list then
			list:SetVisible(true);
		end
		return;
	end
	
	p.item = item;
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
    
	GetUIRoot():AddChild(layer);
	LoadUI("mail_detail_user.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
	p.SetViewInfo();
	--if p.item and p.item.state ~= mail_main.MAIL_IS_READED then
	p.LoadDetail();
	--end
	
end

function p.ReShowUI()
	p.ShowUI(p.item);
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	--btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate()
	local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_DEL );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_REPLY );
	p.SetBtn( bt );
	
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
		elseif ui.ID_CTRL_BUTTON_REPLY == tag then
			WriteCon("**========ID_CTRL_BUTTON_REPLY========**");
			p.replyMail();
		elseif ui.ID_CTRL_BUTTON_DEL == tag then
			WriteCon("**========ID_CTRL_BUTTON_DEL========**");
			p.DelMail();
		end
	end
end


--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST);
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
    end
end

function p.replyMail()
	--ocal item = {};
	--item.recieverId = "zzz";
	--item.class_id = "xxx";
	p.HideUI();
	mail_write_mail.ShowUI(p.item);
	
end


function p.SetViewInfo()
	local item = p.item or {};
	local parentV = p.layer;
	local idTags = ui
	
	--名称
	local timeV = GetLabel( parentV, idTags.ID_CTRL_TEXT_NAME);
	--timeV:SetText(item.nm or "");
	
	--标题
	local titleV = GetLabel( parentV, idTags.ID_CTRL_TEXT_TITLE);
	titleV:SetText(item.title or "");
	
	--时间
	local timeV = GetLabel( parentV, idTags.ID_CTRL_TEXT_TIME);
	timeV:SetText(item.tm or "");
	
	--内容
	local contentV = GetColorLabel( parentV, idTags.ID_CTRL_COLOR_LABEL_62);
	contentV:SetText(item.content or "");
	contentV:SetIsUseMutiColor(false);
	contentV:SetFontColor(ccc4(255,255,255,255));
	contentV:SetHorzAlign( 0 );
	contentV:SetVertAlign( 1 );
	contentV:SetFontSize(20);
end

function p.ShowHistory(pageItems)
	if pageItems == nil or #pageItems < 1 then
		local contentV = GetLabel( p.layer, ui.CTRL_TEXT_LABEL_HISTORY);
		contentV:SetVisible(false);
		return;
	end
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST);
	list:ClearView();

	if pageItems == nil or #pageItems <= 0 then
		WriteCon("refreshPage4Sys():pageItems is null");
		return ;
	end

	local listLenght = #pageItems;
	
	if listLenght > 30 then
		listLenght = 30;
	end

	for i = 1,listLenght do
		local view = p.CreateItem();
		p.SetItemInfo( view, pageItems[i]);
		view:SetId(i);
		list:AddView( view );
	end
end

function p.CreateItem()
	local view = createNDUIXView();
	view:Init();
	LoadUI( "mail_list_item_user_history.xui", view, nil );
	view:SetViewSize( GetUiNode( view, ui_item.ID_CTRL_PICTURE_BG ):GetFrameSize());
	
	return view;
end

function p.SetItemInfo( view, item )
	item = item or {};

	--标题
	local titleV = GetLabel( view, ui_item.ID_CTRL_TEXT_TITLE);
	titleV:SetText(item.title or "");

	--时间
	local timeV = GetLabel( view, ui_item.ID_CTRL_TEXT_TIME);
	timeV:SetText(item.tm or "");
	
	--内容
	local contentV = GetLabel( view, ui_item.ID_CTRL_TEXT_CONTENT);
	contentV:SetText(item.content or "");
	

end

function p.DelMail()
	
	
	if p.item == nil or p.item.mailId == nil then
		return;
	end
	
	
	
	dlg_msgbox.ShowYesNo(GetStr("mail_confirm_title"), string.format(GetStr("mail_confirm_del"),1),p.RequestDel);
	
	
	
end

---------------------------------------------------------网络请求---------------------------------------------------------
function p.LoadDetail()
	if p.item == nil or p.item.mailId == nil then
		return;
	end
	
	local uid = GetUID();
	if uid == 0 or uid == nil  then
		return ;
	end;
	
	local param = string.format("&mail_id=%d&mail_type=%d", tonumber(p.item.mailId), mail_main.MAIL_TYPE_USER);
	--uid = 123456
	SendReq("Mail","ReadDetailMail",uid,param);
end

function p.RequestDel(result)
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end;
	if result == true then
		local param = string.format("&mail_id=%s", p.item.mailId);
		--local param = "&mail_type=1&page=1&per_page_num=6"
		--uid = 123456
		WriteCon("**======requestDel======**");
		SendReq("Mail","DelMail",uid,param);
	end
end


function p.OnNetDelCallback(msg)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true  then
		dlg_msgbox.ShowOK(GetStr("mail_tip_title"), GetStr("mail_tip_del_suc"),p.OnDelSucClose);
	else
		local str = mail_main.GetNetResultError(msg);
		if str then
			dlg_msgbox.ShowOK(GetStr("mail_erro_title"), str,nil);
		else
			WriteCon("**======mail_detail_sys.OnNetDelCallback error======**");
		end
	end
	
end

function p.OnDelSucClose()
	p.CloseUI();
	mail_main.ShowUI(true);
end

function p.OnNetGetDetail(msg)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	if msg.result == true and p.item then
		p.item.state = 1;
	end
	
	local history = nil;
	if msg.class_mail_info and #msg.class_mail_info > 0 then
		history = {};
		for i = 1, #msg.class_mail_info do
			local item = {};
			item.title = msg.class_mail_info[i].Mail_title;
			item.content = msg.class_mail_info[i].Mail_text;
			item.tm = msg.class_mail_info[i].Time_start;
			history[i]=item;
		end
	end
	p.ShowHistory(history);
end
