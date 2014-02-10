
maininterface = {}
local p = maininterface;

p.layer = nil;
p.mailLayer = nil;
p.m_bgImage = nil;
p.scrollList = nil;

p.billlayer = nil;

p.imageList = {};
p.showCard = 0;

p.effect_num = {};

local LEV_INDEX = 1;
local HP_INDEX = 2;
local ATK_INDEX = 3;
local DEF_INDEX = 4;
local SPEED_INDEX = 5;
local MAILNUM_INDEX = 6;

local ui = ui_main_interface;

function p.ShowUI(userinfo)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
--		dlg_battlearray.ShowUI();
		--p.ShowBattleArray();
		p.ShowBillboard();
		PlayMusic_MainUI();
		
		local pic = GetPictureByAni("lancer.temp_bg", 0); 
		p.m_bgImage:SetPicture( pic );
		p.m_bgImage:SetVisible(true);
		p.scrollList:SetVisible(true);
		
		p.mailLayer:SetVisible( true );
		--GetTileMapMgr():OpenMapWorld( "main_ui.tmx", true );
		
		for _,v in ipairs( p.imageList ) do
			v:SetVisible( true );
		end
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
	GetUIRoot():AddChildZ(p.m_bgImage,-99);
		
	local pic = GetPictureByAni("lancer.temp_bg", 0); 
	p.m_bgImage:SetPicture( pic );
	p.m_bgImage:SetFrameRectByPictrue(pic);
	
	GetUIRoot():AddChild(layer);
	LoadUI("main_interface.xui", layer, nil);
    
	p.layer = layer;
	
	
	--p.InitScrollList();
	--p.OnListScrolled();
	
	local maillayer = createNDUILayer();
	if maillayer == nil then
		return false;
	end
	
	maillayer:Init();
	maillayer:SetSwallowTouch(false);
	maillayer:SetFrameRectFull();
	GetUIRoot():AddChildZ( maillayer, 999 );
	p.mailLayer = maillayer;
	LoadUI( "main_mailbtn.xui", maillayer, nil);
	
	maillayer:SetLayoutType(1);
	p.SetDelegate();
	
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
	local mail = GetButton( p.mailLayer, ui_main_mailbtn.ID_CTRL_BUTTON_MAIL );
	p.SetBtn( mail );
	--local activity = GetButton( p.layer, ui.ID_CTRL_BUTTON_ACTIVITY );
	--p.SetBtn( activity );
	
	local bgBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_BG_BTN );
	p.SetBtn( bgBtn );
	
	for i = 1, 6 do
		local btn = GetButton( p.layer, ui["ID_CTRL_BUTTON_CHA"..i] );
		p.SetBtn( btn );
	end

	local cardBtn = GetButton( p.layer, ui.ID_CTRL_BUTTON_129 );
	cardBtn:SetLuaDelegate( p.OnClickCard );
end

function p.InitScrollList( layer )
	--位置基准控件
	local posCtrller = GetImage( layer, ui_main_menu.ID_CTRL_PICTURE_305 );
	if posCtrller == nil then
		return;
	end
	
	local image = GetImage( layer, ui_main_menu.ID_CTRL_PICTURE_22 );
	table.insert( p.imageList, image );
	image = GetImage( layer, ui_main_menu.ID_CTRL_PICTURE_23 );
	table.insert( p.imageList, image );
	image = GetImage( layer, ui_main_menu.ID_CTRL_PICTURE_24 );
	table.insert( p.imageList, image );
	
	local pList = createNDUIScrollContainerExpand();

	if nil == pList then
		WriteConWarning("createNDUIScrollContainerExpand() failed in test");
		return false;
	end
	
	p.scrollList = pList;
	
	local posXY = posCtrller:GetFramePos();
	local size = posCtrller:GetFrameSize();
	local winSize = GetWinSize();

	pList:Init();
	pList:SetFramePosXY( posXY.x, posXY.y + 60 );
	pList:SetFrameSize( winSize.w, size.h );
	pList:SetSizeView( CCSizeMake( 280, 100 ) );
	pList:SetLuaDelegate( p.OnListScrolled );
	
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
		btn:SetTouchDownImage( GetPictureByAni( "ui.mainui_scrolllist_highlight", math.mod(i,3) ) );
		btn:SetDisabledImage( GetPictureByAni( "ui.mainui_scrolllist_disabled", math.mod(i,3) ) );
		btn:SetLuaDelegate( p.OnTouchImage );
		btn:SetId( math.mod(i,3) );
		btn:SetEnabled( math.mod(i,3) == 1 )
		
		--pView1:SetLuaDelegate( p.OnTouchImage );
		pList:AddView(pView1);
	end

	--p.layer:AddChild( pList );
	layer:AddChild( pList );
end

function p.OnListScrolled()
	--WriteConErr( tostring( p.scrollList:GetCurrentIndex() ));
	local listindex = p.scrollList:GetCurrentIndex();
	local index = math.mod(listindex, 3)+1;
	
	for i = 1, #p.imageList do
		local node = p.imageList[i];
		if node then
			local frame = i == index and 1 or 0;
			local picData = GetPictureByAni( "ui.list_node_effect", frame );
			if picData then
				node:SetPicture( picData );
			end
		end
	end
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
		if ui_main_mailbtn.ID_CTRL_BUTTON_MAIL == tag then
			WriteCon("**========邮件========**");
			mail_main.ShowUI();
			
			--隐藏主UI
			maininterface.CloseAllPanel();
			--maininterface.HideUI();
			--隐藏用户信息
			--dlg_userinfo.HideUI();
--			dlg_battlearray.HideUI();
--[[		elseif ui.ID_CTRL_BUTTON_ACTIVITY == tag then
			WriteCon("**========活动========**");
			country_main.ShowUI();
			maininterface.HideUI();
			p.CloseAllPanel();
--]]
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

		p.mailLayer:SetVisible( false );
		for _,v in ipairs( p.imageList ) do
			v:SetVisible( false );
		end
	end
end

--关闭UI
function p.CloseUI()
	if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
		p.scrollList = nil;
		--p.m_bgImage = nil;
--		dlg_battlearray.CloseUI();
		billboard.CloseUI();
		p.imageList = {};
		p.showCard = 0;
		p.effect_num = {};
    end
	
	if p.billlayer ~= nil then
		--p.billlayer:LazyClose();
		--p.billlayer:SetVisible( false );
		p.billlayer = nil;
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
	local bg = GetImage( p.mailLayer , ui_main_mailbtn.ID_CTRL_PICTURE_MAIL_TIPS_BG );
	local mailNum = GetLabel( p.mailLayer, ui_main_mailbtn.ID_CTRL_TEXT_MAIL_TIPS_NUM );
	mailNum:SetText( "" );
	local num = tonumber(userinfo.MailNum) or 0;
	if p.effect_num[MAILNUM_INDEX] == nil then
		local effect = effect_num:new();
		effect:SetNumFont();
		effect:SetOwnerNode( mailNum );
		effect:Init();
		p.effect_num[MAILNUM_INDEX] = effect;
		mailNum:AddChild( effect:GetNode() );
	end

	if num ~= 0 then
		local scale = 0.5;
		local rect = mailNum:GetFrameRect();
		local x = rect.size.w/2;
		local len = string.len(tostring(num));
		
		p.effect_num[MAILNUM_INDEX]:SetScale( scale );
		p.effect_num[MAILNUM_INDEX]:SetOffset( x-len*23/2, -36*(1-scale)/2 );
		p.effect_num[MAILNUM_INDEX]:PlayNum( num );
		p.effect_num[MAILNUM_INDEX]:GetNode():SetVisible(true);
		bg:SetVisible( true );
		
	else
		p.effect_num[MAILNUM_INDEX]:GetNode():SetVisible(false);
		bg:SetVisible( false );
	end
end

--显示阵容界面
function p.ShowBattleArray( user_team, pos )
	user_team = user_team or {};
	if user_team["Formation"..pos] ~= nil then
		local formation = user_team["Formation"..pos];
		local index = 0;
		for i = 1, 6 do
			local btn = GetButton( p.layer, ui["ID_CTRL_BUTTON_CHA" .. i] );
			local nature = GetImage( p.layer, ui["ID_CTRL_PICTURE_NATURE" .. i] );
			local image = GetImage( p.layer, ui["ID_CTRL_PICTURE_CARD" .. i] );
			if btn ~= nil and nature ~= nil then
				btn:SetLuaDelegate( p.OnClickCard );
				btn:SetId( i );
				if formation["Pos"..i] ~= nil then
					if index == 0 then
						index = i;
					end
					btn:SetVisible( true );
					nature:SetVisible( true );
					local cardType = formation["Pos"..i].CardID;
					local path = SelectRowInner( T_CHAR_RES, "card_id", cardType, "mainui_card_head" );
					local picData = nil;
					if path then
						picData = GetPictureByAni( path, 0 );
					end
					--btn:SetImage(picData);
					image:SetPicture( picData );
					
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
		
		p.ShowSelectCard( index );
	end
end

function p.ShowSelectCard( index )
	if p.showCard ~= 0 and p.showCard == index then
		return;
	end
	local cache = msg_cache.msg_player or {};
	local team = cache.User_Team or {};
	local teamIndex = cache.CardTeam or 0;
	if team["Formation".. teamIndex] then
		local cardInfo = team["Formation".. teamIndex]["Pos"..index];
		p.showCard = index;
		
		local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_129 );
		btn:SetId( index );
		
		local levLab = GetLabel( p.layer, ui.ID_CTRL_TEXT_76 );
		--levLab:SetText( tostring(cardInfo.Level) );
		p.CreateEffectNum( LEV_INDEX, levLab, 0.6, 0, -10, cardInfo.Level );
		
		local life = GetLabel( p.layer, ui.ID_CTRL_TEXT_77 );
		--life:SetText( tostring(cardInfo.Hp) );
		p.CreateEffectNum( HP_INDEX, life, 0.6, 0, -10, cardInfo.Hp );
		
		local atk = GetLabel( p.layer, ui.ID_CTRL_TEXT_78 );
		--atk:SetText( tostring(cardInfo.Attack) );
		p.CreateEffectNum( ATK_INDEX, atk, 0.6, 0, -10, cardInfo.Attack );
		
		local def = GetLabel( p.layer, ui.ID_CTRL_TEXT_79 );
		--def:SetText( tostring(cardInfo.Defence) );
		p.CreateEffectNum( DEF_INDEX, def, 0.6, 0, -10, cardInfo.Defence );
		
		local speed = GetLabel( p.layer, ui.ID_CTRL_TEXT_80 );
		--speed:SetText( tostring(cardInfo.Speed) );
		p.CreateEffectNum( SPEED_INDEX, speed, 0.6, 0, -10, cardInfo.Speed );
		
		local skill = GetLabel( p.layer, ui.ID_CTRL_TEXT_81 );
		local skillName = SelectCell( T_SKILL, cardInfo.Skill, "name" ) or "";
		skill:SetText( skillName );
		
		local cardName = GetLabel( p.layer, ui.ID_CTRL_TEXT_CARD_NAME );
		local str = SelectCell( T_CARD, cardInfo.CardID, "name" ) or "";
		cardName:SetText( str );
		
		local cardPic = GetImage( p.layer, ui.ID_CTRL_PICTURE_106 );
		local path = SelectRowInner( T_CHAR_RES, "card_id", cardInfo.CardID, "mainui_card_small" );
		local picData = nil;
		if path then
			picData = GetPictureByAni( path, 0 );
		end
		cardPic:SetPicture( picData );
		
		local starPic = GetImage( p.layer, ui.ID_CTRL_PICTURE_180 );
		local rare = cardInfo.Rare or 0;
		local star = GetPictureByAni( "ui.card_star", rare-1 );
		if star then
			starPic:SetPicture( star );
		end
	end
end

function p.CreateEffectNum( index, node, scale, offestX, offestY, num )
	if p.effect_num[index] == nil then
		local effect = effect_num:new();
		effect:SetNumFont();
		effect:SetOwnerNode( node );
		effect:Init();
		p.effect_num[index] = effect;
		node:AddChild( effect:GetNode() );
	end
	local rect = node:GetFrameRect();
	local x = rect.size.w;
	local len = string.len(tostring(num));
	p.effect_num[index]:SetScale( scale );
	p.effect_num[index]:SetOffset( x+offestX-len*23+(1-scale)/2*len*23 , offestY);
	p.effect_num[index]:PlayNum( tonumber(num) );
end

function p.OnClickCard(uiNode, uiEventType, param)
	if IsClickEvent(uiEventType) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_129 == tag then
			local id = uiNode:GetId() or 0;
			local user_team = msg_cache.msg_player.User_Team or {};
			local cardTeam = tonumber(msg_cache.msg_player.CardTeam) or 1;
			local formation = user_team["Formation"..cardTeam] or {};
			local card = formation["Pos"..id];
			if card then
				dlg_card_attr_base.ShowUI( card );
				maininterface.HideUI();
			end
		else
			local id = uiNode:GetId() or 0;
			local user_team = msg_cache.msg_player.User_Team or {};
			local cardTeam = tonumber(msg_cache.msg_player.CardTeam) or 1;
			local formation = user_team["Formation"..cardTeam] or {};
			local card = formation["Pos"..id];
			if card then
				p.ShowSelectCard( id );
			end
		end
	end
end

--跑马灯显示
function p.ShowBillboardWithInit()
	--[[
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
	--]]
	p.billlayer = GetColorLabel( dlg_menu.layer, ui_main_menu.ID_CTRL_COLOR_LABEL_140 );
	
	--local bg = GetImage( p.billlayer, ui_main_billboard_bg.ID_CTRL_PICTURE_BILLBOARD_BG);
	local bg = p.billlayer;
	
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


