--------------------------------------------------------------
-- FileName: 	mail_detail_sys.lua
-- author:		wjl, 2013年11月24日
-- purpose:		系统邮箱详细信息
--------------------------------------------------------------

mail_detail_sys = {}
local p = mail_detail_sys;

------------------邮件类型类型------------------
p.MAIL_TYPE                    = 0;        -- 系统
p.layer = nil;
p.item = nil;

local ui = ui_mail_detail_sys

function p.ShowUI(item)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
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
	LoadUI("mail_detail_sys.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
	p.SetViewInfo();
	if p.item and p.item.state ~= mail_main.MAIL_IS_READED then
		p.LoadDetail();
	end
	
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
	--btn:AddActionEffect( "ui_cmb.mainui_btn_scale" );
end

function p.SetDelegate()
	local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_DEL );
	p.SetBtn( bt );
	
	bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_GAIN );
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
		elseif ui.ID_CTRL_BUTTON_MAIL == tag then
			WriteCon("**========邮件========**");
		elseif ui.ID_CTRL_BUTTON_ACTIVITY == tag then
			WriteCon("**========活动========**");
		elseif ui.ID_CTRL_BUTTON_MORE == tag then
			WriteCon("**======弹出按钮======**");
			dlg_btn_list.ShowUI();
		elseif ui.ID_CTRL_BUTTON_GAIN == tag then
			p.GainReward();
		elseif ui.ID_CTRL_BUTTON_DEL == tag then
			p.DelMail();
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
	local contentV = GetLabel( parentV, idTags.ID_CTRL_TEXT_CONTENT);
	contentV:SetText(item.content or "");
	
	local rewards = item.rewards or {};
	for i = 1, 6 do
		local rewrad = rewards[i] or {};
		local picTagName = "ID_CTRL_PICTURE_ITEM_"..i;
		local numTagName = "ID_CTRL_TEXT_ITEM_NUM_"..i;
		local nameTagName = "ID_CTRL_TEXT_ITEM_NAME_"..i;
		local picV = GetImage(parentV,idTags[picTagName]);
		local numV = GetLabel( parentV, idTags[numTagName]);
		local nameV = GetLabel( parentV, idTags[nameTagName]);
		
		if rewrad.rewordId and tonumber(rewrad.rewordId) ~= 0 then
			--rewrad.rewordId = "10002"
			numV:SetText("X"..(rewrad.num or "1"))
			local aniIndex = "item."..rewrad.rewordId;
			picV:SetPicture( GetPictureByAni(aniIndex,0) );
			
			local txt = p.SelectItemName(tonumber(rewrad.rewordId));
			nameV:SetText(txt or "");
		else
			picV:SetVisible(false);
			numV:SetVisible(false);
			nameV:SetVisible(false);
		end
	end
	
	local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_GAIN );
	if item.rewardId and item.rewardState and item.rewardState == mail_main.MAIL_REWARD_UNGET then
		bt:SetVisible(true);
	else 
		bt:SetVisible(false);
	end
end

function p.DelMail()
	
	
	if p.item == nil or p.item.mailId == nil then
		return;
	end
	
	
	if p.item.rewardId and p.item.rewardState and p.item.rewardState == mail_main.MAIL_REWARD_UNGET then
		dlg_msgbox.ShowOK(GetStr("mail_erro_title"), GetStr("mail_del_has_reward"),nil);
		return;
	else
		dlg_msgbox.ShowYesNo(GetStr("mail_confirm_title"), string.format(GetStr("mail_confirm_del"),1),p.RequestDel);
	end
	
	
end

function p.SelectItemName(id)
	local itemTable = SelectRowList(T_ITEM,"id",id);
	if #itemTable == 1 then
		local text = itemTable[1].Name;
		return ToUtf8(text);
	else
		WriteConErr("itemTable error ");
	end
end


---------------------------------------------------------网络---------------------------------------------------------------


function p.LoadDetail()
	if p.item == nil or p.item.mailId == nil then
		return;
	end
	
	local uid = GetUID();
	if uid == 0 or uid == nil  then
		return ;
	end;
	
	local param = string.format("&mail_id=%d&mail_type=%d", tonumber(p.item.mailId), mail_main.MAIL_TYPE_SYS);
	--uid = 123456
	SendReq("Mail","ReadDetailMail",uid,param);
end

function p.GainReward()
	if p.item == nil or p.item.mailId == nil then
		return;
	end
	
	local uid = GetUID();
	if uid == 0 or uid == nil  then
		return ;
	end;
	
	local param = string.format("&mail_id=%d", tonumber(p.item.mailId));
	--uid = 123456
	SendReq("Mail","GetMailReward",uid,param);
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
	if p.item then
		p.item.state = 1;
	end
end

function p.OnNetGainReward(msg)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	
	if msg.result == true  then
		local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_GAIN );
		if bt then
			bt:SetVisible(false);
		end
		
		if p.item then
			p.item.rewardState = mail_main.MAIL_REWARD_GETED;
		end
		dlg_msgbox.ShowOK(GetStr("mail_tip_title"), GetStr("mail_tip_gain_suc"),nil);
	else
		local str = mail_main.GetNetResultError(msg);
		if str then
			dlg_msgbox.ShowOK(GetStr("mail_erro_title"), str,nil);
		else
			WriteCon("**======mail_detail_sys.OnNetGainReward error======**");
		end
	end
end
