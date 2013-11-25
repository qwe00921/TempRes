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

p.datas = {size=100
			,cur=3
			,page={	{title="05-23abc", tm="05-21 19:33:33", content="efff:",state="0"}
					,{title="05-22abc", tm="05-22 19:33:33", content="ff,ff,ff..",state="1"}
					,{title="05-21abc", tm="05-21 19:33:33", content="aaaa",state="0"}
					,{title="05-20cde", tm="05-20 19:33:33", content="bbbbb",state="0"}
					,{title="05-19abc", tm="05-19 19:33:33", content="ccccc",state="0"}
					,{title="05-18abc", tm="05-18 19:33:33", content="dddddddd",state="0"}
				   }
			}

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
	
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_GO_BACK == tag then
			WriteCon("**========返回========**");
			p.CloseUI();
			mail_main.ShowUI();
		elseif ui.ID_CTRL_BUTTON_ANSWER == tag then
			WriteCon("**========提交问题========**");
			p.SetAnswerLayerVisible(true);
			p.SetAskLayerVisible(false);
		elseif ui.ID_CTRL_BUTTON_ASK == tag then
			WriteCon("**======查看问题======**");
			p.SetAskLayerVisible(true);
			p.SetAnswerLayerVisible(false);
		end
	end
end

function p.OnItemClick(uiNode, uiEventType, param)
	local id = uiNode:GetId();
	WriteCon("**======OnItemClick======** " .. tostring(id));
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
    end
end

--
function p.ShowGM()
	p.SetAnswerLayerVisible(true);
	p.SetAskLayerVisible(false);
	p.ShowGMList(p.datas);
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
	
	v = GetEdit( p.layer, ui.ID_CTRL_INPUT_TEXT_TITLE);
	v:SetVisible(visible);
	
	--v = GetUiNode( p.layer, ui.ID_CTRL_CHAT_TEXT_QUESTION);
	--v:SetVisible(visible);
	
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

function p.ShowGMList(datas)
	--p.SetTitleText(listLenght);
	p.ShowGMListItems(datas.page);
	p.SetGMCurItemDetail();
end

function p.ShowGMListItems(pageItems)
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_MAIN);
	list:ClearView();

	if pageItems == nil or #pageItems <= 0 then
		WriteCon("ShowGMListItems():pageItems is null");
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

function p.CreateItem()
	local view = createNDUIXView();
	view:Init();
	LoadUI( "mail_list_item_sys.xui", view, nil );
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
	--客服
	--local titleV = GetLabel( view, ui.ID_CTRL_TEXT_TITLE);
	--titleV:SetText(item.title or "");

	--时间
	local timeV = GetLabel( view, ui.ID_CTRL_TEXT_GM_TIME);
	--timeV:SetText(item.tm or "");
	
	local v = GetLabel( view, ui.ID_CTRL_TEXT_GM_CONTENT);
	--v:SetText(item.cm or "");
	
	v = GetLabel( view, ui.ID_CTRL_TEXT_USER_LABEL);
	--v:SetText(item.cm or "");
	
	v = GetLabel( view, ui.ID_CTRL_TEXT_USER_TIME);
	--v:SetText(item.cm or "");
	
	v = GetLabel( view, ui.ID_CTRL_TEXT_USER_CONTENT);
	--v:SetText(item.cm or "");
end
