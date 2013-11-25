-------------------------------------------------------------
-- FileName: 	mail_main.lua
-- author:		wjl, 2013年11月24日
-- purpose:		邮箱主界面
--------------------------------------------------------------

mail_main = {}
local p = mail_main;

------------------邮件类型类型------------------
p.MAIL_TYPE_SYS                    = 0;        -- 系统
p.MAIL_TYPE_USER  				   = 1;			-- 个人

p.PAGE_SIZE = 6; --每页数量

p.layer = nil;
p.curListTypeTag = nil;
p.isShowed = true;

local ui = ui_mail_main
local ui_item_sys = ui_mail_list_item_sys
local ui_item_usr = ui_mail_list_item_user

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		p.isShowed = true
		--dlg_battlearray.ShowUI();
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
	
	p.ShowList4Sys();
	--p.ShowList4User();
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
				local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_USER)
				bt:SetChecked (false);
				p.ShowList4Sys();
			end
			
		elseif ui.ID_CTRL_BUTTON_USER == tag then
			WriteCon("**======个人列表======**");
			if (p.curListTypeTag == p.MAIL_TYPE_USER) then
				return
			else
				local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_SYS)
				bt:SetChecked (false);
				p.ShowList4User();
			end
		end
	end
end

function p.OnItemClick(uiNode, uiEventType, param)
	local id = uiNode:GetId();
	WriteCon("**======OnItemClick======** " .. tostring(id));
	if p.isShowed == true then
		p.HideUI();
		if p.curListTypeTag == p.MAIL_TYPE_SYS then
			mail_detail_sys.ShowUI();
		else
			mail_detail_user.ShowUI();
		end
	end
end


--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		p.isShowed = false;
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
		p.curListTypeTag = nil;
    end
end

--------------------数据控制逻辑--------------------------------------

-------- 系统邮件Item
function p.ShowList4Sys(datas)
	p.curListTypeTag = p.MAIL_TYPE_SYS
	datas = {size=100
			,cur=3
			,page={	{title="05-23abc", tm="05-21 19:33:33", content="efff:",state="0"}
					,{title="05-22abc", tm="05-22 19:33:33", content="ff,ff,ff..",state="1"}
					,{title="05-21abc", tm="05-21 19:33:33", content="aaaa",state="0"}
					,{title="05-20cde", tm="05-20 19:33:33", content="bbbbb",state="0"}
					,{title="05-19abc", tm="05-19 19:33:33", content="ccccc",state="0"}
					,{title="05-18abc", tm="05-18 19:33:33", content="dddddddd",state="0"}
				   }
			}
	
	--p.SetTitleText(listLenght);
	local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_SYS)
	bt:SetChecked (true);
	p.ShowListItems4Sys(datas.page);
	
end

function p.ShowListItems4Sys(pageItems)
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_MAIN);
	list:ClearView();

	if pageItems == nil or #pageItems <= 0 then
		WriteCon("ShowListItems4Sys():pageItems is null");
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
	if stN ==1 then
		stateV:SetText("Readed");
	else
		stateV:SetText("Unreaded");
	end
	
	--local cardPicNode = GetButton( view, cardPic );
	--cardPicNode:SetImage( user_skill_mgr.GetCardPicture(item.skill_id) );
	--cardPicNode:SetTouchDownImage( user_skill_mgr.GetCardPicture(item.skill_id) );
	--cardPicNode:SetId( tonumber(item.id));
	--增加事件
	--cardPicNode:SetLuaDelegate(p.OnBtnClicked);
	
	view:SetLuaDelegate(p.OnItemClick);
end

-------- 个人邮件Item
function p.ShowList4User(datas)
	p.curListTypeTag = p.MAIL_TYPE_USER
	datas = {size=100
			,cur=3
			,sysunre=6
			,personunread=7
			,page={	{title="abc", nm="Jason",tm="05-21 19:33:33", content="efff:",state="0"}
					,{title="abc", nm="Jon",tm="05-22 19:33:33", content="ffff",state="1"}
					,{title="abc", nm="Eva", tm="05-21 19:33:33", content="aaaa",state="0"}
					,{title="cde", nm="Eve",tm="05-20 19:33:33", content="bbbbb",state="0"}
					,{title="abc", nm="Kita",tm="05-19 19:33:33", content="ccccc",state="0"}
					,{title="abc", nm="Kitahe", tm="05-18 19:33:33", content="dddddddd",state="0"}
				   }
			}
	
	--p.SetTitleText(listLenght);
	local bt = GetButton( p.layer, ui.ID_CTRL_BUTTON_USER)
	bt:SetChecked (true);
	p.ShowListItems4User(datas.page);
end

function p.ShowListItems4User(pageItems)
	
	local list = GetListBoxVert(p.layer ,ui.ID_CTRL_VERTICAL_LIST_MAIN);
	list:ClearView();

	if pageItems == nil or #pageItems <= 0 then
		WriteCon("ShowListItems4User():pageItems is null");
		return ;
	end

	local listLenght = #pageItems;

	for i = 1,listLenght do
		local view = p.CreateItem4User();
		p.SetItemInfo4User( view, pageItems[i]);
		list:AddView( view );
	end
end

function p.CreateItem4User()
	local view = createNDUIXView();
	view:Init();
	LoadUI( "mail_list_item_user.xui", view, nil );
	view:SetViewSize( GetUiNode( view, ui_item_usr.ID_CTRL_PICTURE_BG ):GetFrameSize());
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
	if stN ==1 then
		stateV:SetText("Readed");
	else
		stateV:SetText("Unreaded");
	end
	
	--local cardPicNode = GetButton( view, cardPic );
	--cardPicNode:SetImage( user_skill_mgr.GetCardPicture(item.skill_id) );
	--cardPicNode:SetTouchDownImage( user_skill_mgr.GetCardPicture(item.skill_id) );
	--cardPicNode:SetId( tonumber(item.id));
	--增加事件
	--cardPicNode:SetLuaDelegate(p.OnBtnClicked);
	view:SetLuaDelegate(p.OnItemClick);
end




