
maininterface = {}
local p = maininterface;

p.layer = nil;
p.m_bgImage = nil;
p.scrollList = nil;

p.billlayer = nil;

local ui = ui_main_interface;

function p.ShowUI(userinfo)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
--		dlg_battlearray.ShowUI();
		--p.ShowBattleArray();
		p.ShowBillboard();
		PlayMusic_MainUI();
		
		p.m_bgImage:SetVisible(true);
		
		p.scrollList:SetVisible(true);
		return;
	end

	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();

	p.m_bgImage = createNDUIImage();
	p.m_bgImage:Init();
	p.m_bgImage:SetFrameRectFull();
	GetUIRoot():AddChildZ(p.m_bgImage,-99);
		
	local pic = GetPictureByAni("lancer.temp_bg", 0); 
	p.m_bgImage:SetPicture( pic );
	
	GetUIRoot():AddChild(layer);
	LoadUI("main_interface.xui", layer, nil);
    
	p.layer = layer;
	p.SetDelegate();
	
	p.InitScrollList();
	
	p.ShowMailNum(userinfo);
	
	dlg_userinfo.ShowUI(userinfo);
	dlg_menu.ShowUI();
	--dlg_battlearray.ShowUI();
	--p.ShowBattleArray();
	
	p.ShowBillboardWithInit();
	PlayMusic_MainUI();
	
	GetTileMapMgr():OpenMapWorld( "main_ui.tmx", true );
end

--设置按钮
function p.SetBtn(btn)
	btn:SetLuaDelegate(p.OnBtnClick);
end

function p.SetDelegate()
	local mail = GetButton( p.layer, ui.ID_CTRL_BUTTON_MAIL );
	p.SetBtn( mail );
	
	local activity = GetButton( p.layer, ui.ID_CTRL_BUTTON_ACTIVITY );
	p.SetBtn( activity );
	
	local bgBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_BG_BTN );
	p.SetBtn( bgBtn );
	
	for i = 1, 6 do
		local btn = GetButton( p.layer, ui["ID_CTRL_BUTTON_CHA"..i] );
		p.SetBtn( btn );
	end
end

function p.InitScrollList()
	--位置基准控件
	local posCtrller = GetImage( p.layer, ui.ID_CTRL_PICTURE_106 );
	if posCtrller == nil then
		return;
	end
	
	local pList = createNDUIScrollContainerExpand();

	if nil == pList then
		WriteConWarning("createNDUIScrollContainerExpand() failed in test");
		return false;
	end
	
	p.scrollList = pList;
	
	local posXY = posCtrller:GetFramePos();
	local size = posCtrller:GetFrameSize();

	pList:Init();
	pList:SetFramePosXY( posXY.x, posXY.y+90 );
	pList:SetFrameSize( size.w, size.h );
	pList:SetSizeView( CCSizeMake( 230, 135 ) );
	
	for i = 1,6 do
		local pView1 = createNDUIScrollViewExpand();

		if nil == pView1 then
			WriteConWarning("createNDUIScrollViewExpand() failed in test");
			return true;
		end
		
		pView1:Init();
		pView1:SetViewId( math.mod(i,3) );
		LoadUI( "main_scrolllist_node.xui", pView1, nil );
		
		--[[local image = GetImage( pView1, ui_main_scrolllist_node.ID_CTRL_PICTURE_89 );
		if image then
			image:SetPicture( GetPictureByAni( "ui.mainui_scrolllist", math.mod(i,3) ) );
		end
		--]]
		--pView1:SetTag(i);
		local btn = GetButton( pView1, ui_main_scrolllist_node.ID_CTRL_BUTTON_108 );
		btn:SetImage( GetPictureByAni( "ui.mainui_scrolllist", math.mod(i,3) ) );
		btn:SetLuaDelegate( p.OnTouchImage );
		btn:SetId( math.mod(i,3) );
		
		--pView1:SetLuaDelegate( p.OnTouchImage );
		pList:AddView(pView1);
	end

	GetUIRoot():AddChild( pList );
end

function p.OnTouchImage(uiNode, uiEventType, param)
	WriteCon( "dadasdsadsad" );
	if IsClickEvent( uiEventType ) then
		local id = uiNode:GetId();
		if id == 1 then
			WriteCon("**========任务========**");
			stageMap_main.OpenWorldMap();
			PlayMusic_Task(1);

			maininterface.HideUI();
		end
	end
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_MAIL == tag then
			WriteCon("**========邮件========**");
			mail_main.ShowUI();
			
			--隐藏主UI
			maininterface.CloseAllPanel();
			--maininterface.HideUI();
			--隐藏用户信息
			dlg_userinfo.HideUI();
--			dlg_battlearray.HideUI();
		elseif ui.ID_CTRL_BUTTON_ACTIVITY == tag then
			WriteCon("**========活动========**");
			p.CloseAllPanel();
		elseif ui.ID_CTRL_BUTTON_BG_BTN == tag then
			p.CloseAllPanel();
		end
	end
end

--关闭子面板
function p.CloseAllPanel()
	dlg_btn_list.CloseUI();
end

--隐藏UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
		p.scrollList:SetVisible(false);
		p.m_bgImage:SetVisible(false);
--		dlg_battlearray.HideUI();
		--p.HideBillboard();
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
		p.scrollList = nil;
		p.m_bgImage = nil;
--		dlg_battlearray.CloseUI();
		billboard.CloseUI();
    end
	
	if p.billlayer ~= nil then
		p.billlayer:LazyClose();
		p.billlayer:SetVisible( false );
	end
end

--重新显示菜单按钮
function p.ShowMenuBtn()
	local menu = GetButton(p.layer, ui.ID_CTRL_MAIN_BUTTON_MEMU);
	if menu then
		menu:SetVisible(true);
	end
end

--邮件数量显示
function p.ShowMailNum(userinfo)
	local bg = GetImage( p.layer, ui.ID_CTRL_PICTURE_MAIL_TIPS_BG );
	local mailNum = GetLabel( p.layer, ui.ID_CTRL_TEXT_MAIL_TIPS_NUM );
	local num = tonumber(userinfo.MailNum) or 0;
	if num ~= 0 then
		mailNum:SetVisible( true );
		bg:SetVisible( true );
		mailNum:SetText( tostring(num) );
	else
		mailNum:SetVisible( false );
		bg:SetVisible( false );
	end
end

--显示阵容界面
function p.ShowBattleArray( user_team, pos )
	user_team = user_team or {};
	if user_team["Formation"..pos] ~= nil then
		local formation = user_team["Formation"..pos];
		for i = 1, 6 do
			local btn = GetButton( p.layer, ui["ID_CTRL_BUTTON_CHA" .. i] );
			local nature = GetImage( p.layer, ui["ID_CTRL_PICTURE_NATURE" .. i] );
			if btn ~= nil and nature ~= nil then
				btn:SetLuaDelegate( p.OnClickCard );
				btn:SetId( i );
				if formation["Pos"..i] ~= nil then
					btn:SetVisible( true );
					nature:SetVisible( true );
					local cardType = formation["Pos"..i].CardID;
					local path = SelectRowInner( T_CHAR_RES, "card_id", cardType, "hero_pic" );
					local picData = nil;
					if path then
						picData = GetPictureByAni( path, 0 );
					end
					btn:SetImage(picData);
					
					local element = formation["Pos"..i].element;
					WriteCon( "element  " .. tostring(element) );
					local attrpic = GetPictureByAni( "card_element.".. tostring(element), 0 );
					nature:SetPicture( attrpic );
				else
					btn:SetVisible( false );
					nature:SetVisible( false );
				end
			end
		end
	end
end

function p.OnClickCard(uiNode, uiEventType, param)
	if IsClickEvent(uiEventType) then
		local id = uiNode:GetId() or 0;
		local user_team = msg_cache.msg_player.User_Team or {};
		local cardTeam = tonumber(msg_cache.msg_player.CardTeam) or 1;
		local formation = user_team["Formation"..cardTeam] or {};
		local card = formation["Pos"..id];
		if card then
			dlg_card_attr_base.ShowUI( card );
		end
	end
end

--跑马灯显示
function p.ShowBillboardWithInit()
	if p.billlayer == nil then
		local layer = createNDUILayer();
		if layer == nil then
			return false;
		end
		layer:Init();
		layer:SetSwallowTouch(false);
		layer:SetFrameRectFull();
		
		GetUIRoot():AddChildZ( layer, -1 );
		p.billlayer = layer;
		
		LoadUI( "main_billboard_bg.xui", layer, nil );
	end
	
	local bg = GetImage( p.billlayer, ui_main_billboard_bg.ID_CTRL_PICTURE_BILLBOARD_BG);
	local rect = bg:GetFrameRect() or {};
	local pt = rect.origin or {};
	billboard.ShowUIWithInit(p.layer, nil, UIOffsetY(pt.y-222)); 
end

function p.HideBillboard()
	WriteCon("**HideBillboard**");
	billboard.pauseBillBoard();
end

function p.ShowBillboard()
	
	billboard.resumeBillBoard();
end

--从子界面退出，刷新主界面
function p.BecomeFirstUI()
	WriteCon("**BecomeFirstUI**");
	dlg_userinfo.ShowUI();
	p.ShowBillboard();
end
function p.BecomeBackground()
	p.HideBillboard()
end

