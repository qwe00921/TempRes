--------------------------------------------------------------
-- FileName: 	mail_write_mail.lua
-- author:		wjl, 2013年8月23日
-- purpose:		邮件系统--写信
--------------------------------------------------------------

mail_write_mail = {}
local p = mail_write_mail;

------------------邮件类型类型------------------
p.MAIL_TYPE                    = 1;        -- 系统
p.layer = nil;
p.item = nil;

local ui = ui_mail_write_mail

function p.ShowUI(item)
	p.item = item;
	
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
	LoadUI("mail_write_mail.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
	
	local recieverV = GetEdit(p.layer,ui.ID_CTRL_INPUT_TEXT_RECIEVER);
	local titleV = GetEdit(p.layer,ui.ID_CTRL_INPUT_TEXT_TITLE);
	local contentV = GetEdit(p.layer,ui.ID_CTRL_INPUT_CONTENT);
	recieverV:SetMaxLength(14);
	titleV:SetMaxLength(14);
	contentV:SetMaxLength(140);
	
	p.SetViewInfo();
	
end

function p.SetViewInfo()
	if p.item then
		local recieverV = GetEdit(p.layer,ui.ID_CTRL_INPUT_TEXT_RECIEVER);
		recieverV:SetVisible(false);
		
		local bt = GetButton(p.layer,ui.ID_CTRL_BUTTON_FRIENDS);
		bt:SetVisible(false);
		
		local textV = GetLabel( p.layer, ui.ID_CTRL_TEXT_LABEL_RECIEVER);
		textV:SetVisible(false);
		
	end
	
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
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_FRIENDS );
	p.SetBtn( bt );
	
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_GO_BACK == tag then
			WriteCon("**========返回========**");
			
			local isReply = false;
			if p.item then
				isReply = true;
			end
			p.CloseUI();
			if isReply == true then
				mail_detail_user.ReShowUI()
			else
				mail_main.ShowUI();
			end
		elseif ui.ID_CTRL_BUTTON_SEND  == tag then
			WriteCon("**======发送信息======**");
			p.SendEmail();
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
		p.item = nil;
    end
end

function p.SendEmail()
	local recieverV = GetEdit(p.layer,ui.ID_CTRL_INPUT_TEXT_RECIEVER);
	local titleV = GetEdit(p.layer,ui.ID_CTRL_INPUT_TEXT_TITLE);
	local contentV = GetEdit(p.layer,ui.ID_CTRL_INPUT_CONTENT);
	local reciever = recieverV:GetText();
	local title = titleV:GetText();
	local content = contentV:GetText();
	
	if string.len(reciever) <= 0 and p.item == nil then
		dlg_msgbox.ShowOK(GetStr("mail_tip_title"), GetStr("mail_tip_send_reciever_empty"),nil);
		return;
	end
	
	if string.len(title) <= 0 then
		dlg_msgbox.ShowOK(GetStr("mail_tip_title"), GetStr("mail_tip_send_title_empty"),nil);
		return;
	end
	
	if string.len(content) <= 0 then
		dlg_msgbox.ShowOK(GetStr("mail_tip_title"), GetStr("mail_tip_send_content_empty"),nil);
		return;
	end
	
	--ocal str = p.urlencode(content);
	--dlg_msgbox.ShowOK(GetStr("mail_tip_title"), URLEncode(content),nil);
	p.UpLoadEmail(URLEncode(reciever), URLEncode(title), URLEncode(content));
end

--请求发送消息
function p.UpLoadEmail(receiveName,title,content)
	local uid = GetUID();
	if uid == 0 or uid == nil then
		return ;
	end;
	
	local param = "&is_PP=1";
	if p.item and p.item.class_id then
		param = param .."&Class_id=" .. p.item.class_id;
	end
	
	if p.item and p.item.recieverId then
		param = param .."&Receive_id=" .. p.item.recieverId;
	end
	
	if receiveName then
		param = param .."&Receive_name=" .. receiveName;
	end
	
	
	param = string.format("%s&Mail_title=%s&Mail_text=%s",param,title,content)
	SendReq("Mail","SendPerMail",uid,param);		
end

--请求消息后回调
function p.NetCallback(msg)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true then
		dlg_msgbox.ShowOK(GetStr("mail_tip_title"), GetStr("mail_tip_send_suc"),nil);
	else
		local str = mail_main.GetNetResultError(msg);
		if str then
			dlg_msgbox.ShowOK(GetStr("mail_erro_title"), str,nil);
		else
			WriteCon("**======mail_write_mail.NetCallback error ======**");
		end
	end
end




