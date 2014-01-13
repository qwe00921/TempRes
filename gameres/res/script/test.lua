--------------------------------------------------------------
-- FileName: 	test.lua
-- author:		zhangwq, 2013/05/13
-- purpose:		测试用
--------------------------------------------------------------

test = {}
local p = test;
pLayer = nil

function p.test()
--	SetDebugDraw(true);

--[[	WriteFile("your output text","YourFileName.log");
	WriteFile("your output text","YourFileName");
	WriteFile("your output text");   --默认为"ClientLua.log"--]]
	
	--这里调用需要测试的函数
--	p.TestDB();
	
	--测试图片组合
	--p.TestPictureCombo();

	--测试Ani配置含图片组合
--	p.TestAniWithPictureCombo();

	--结合cmd测试图片组合
--	p.testPictureComboWithCmd();

	--测试音效、音乐、视频
--	p.TestSoundMusicVolume();

	--测试UIX
--	p.TestUIX();
--	p.TestUIX_SingleMode();

    --测试ScrollText
--    p.TestScrollText();

	--测试vector
--	p.TestVector();

    --测试
--    p.test1();
	
	--测试player命令
--	SetTimerOnce( p.testPlayerCmd, 2.0f );

    --测试子弹配置
--    p.TestBullet();

    --测试高斯模糊
--    SetTimerOnce( p.TestGaussianBlur, 2.0f );

	--测试卡包
--	p.TestCardBox();
	
	--测试发包
--	p.TestHttpSend();

    --测试删除Ani特效
--    p.TestDelAni();

    --测试玩家信息保存
--    p.TestUserConfig();

	--测试创建玩家
	--p.TestCreatePlayer();
	
	--测试Lua错误处理
--	p.TestLuaErrHandler();

	--测试消息提示框
--	p.TestMsgBox();

	--测试卡片翻转
--	p.TestCardRotate();

	--测试ColorLabel
--	p.TestColorLabel();

	--测试edit控件
--	p.TestEdit();

	--测试9宫格控件
--	p.Test9Slices();

	--测试扩展列表
	--p.TestNDUIScrollContainerExpand();

	--直接进战斗
	--p.EnterBattle();
	--x_battle_mgr.EnterBattle();
	--n_battle_mgr.EnterBattle( N_BATTLE_PVE, 101011 );
	--n_battle_mgr.EnterBattle( N_BATTLE_PVP, 10002 );
--	--测试utf8子串
--	p.TestUtf8String();
    
    --测试剧情
	--dlg_drama.ShowUI(2);

	--p.testFly();
	
	--测试创建角色
	--dlg_createrole.ShowUI();
	--dlg_create_player.ShowUI();
	
	--测试剧情后的请求战斗
	--local strParam = string.format("&target=%d",10002);
	--SendReq( "Fight","StartPvP",10001,strParam );
	
	--测试劫争
	--battle_ko.ShowUI();
	
	--p.testPost();
	--w_battle_pve.ShowUI();
	--w_battle_pass_bg.ShowUI();
end

function p.testPost()
	SendPost("command=Gacha&action=Start&user_id=112&gacha_id=2&charge_type=1&gacha_type=1&R=80&V=77&MachineType=WIN32");
end

function p.testFly()
	WriteCon("feafa");
	pLayer = createNDUIDialog();

	pLayer:Init();
	pLayer:SetSwallowTouch(true);
	pLayer:SetFrameRectFull();
	LoadDlg("test_fly.xui", pLayer, nil);
	
	local pButton = GetButton(pLayer,ui_test_fly.ID_CTRL_BUTTON_2);
	
	if nil == pButton then
		return false;
	end
	
	pButton:SetLuaDelegate(p.OnTestType);
	
	if nil == pLayer then
		WriteConWarning("NILNILNIL");
	end
	
	GetUIRoot():AddDlg(pLayer);
	
	return true;
end

function p.OnTestType(uiNode, uiEventType, param)
	WriteCon("feafaw");
	pLayer:LazyClose();
end

function p.EnterBattle()
    local battleType = BATTLE_PVE;
    local userTeamId = 23;
    local targetId = 1;
    card_battle_mgr.EnterBattle( battleType, userTeamId, targetId );
	mainui.HideUI();
end
	
function p.AniEffectCallBack(id)
    local str = string.format("AniEffectCallBack: id=%d", id);
    WriteCon(str)	
end

function p.AddEffect()
	local id = AddHudEffect("combo.cardmove");
	RegAniEffectCallBack(id, p.AniEffectCallBack);
end

function reload()
	DoFile("test.lua");
end


--测试数据库接口
function p.TestDB()
    WriteCon( "\r\n*** db test *** \r\n" );
	local t = GetTable(T_TEST);
	if t == nil then
		WriteCon( "get table failed" );
		return;
	end

	WriteCon( string.format("tid = %d, name=%s", t:GetId(), t:GetName()));
	WriteCon( string.format("rowCount = %d, colCount=%s", t:GetRowCount(), t:GetColCount()));

	local rowCount = t:GetRowCount();
	for i = 1, rowCount do
		local row = t:GetRow(i-1);
		local f0 = row:GetNum(0);--按索引取数值
		local f1 = row:GetStr(1);--按索引取串
		local f2 = row:GetNumByName("tel");--按字段名取数值
		local f3 = row:GetStrByName("addr");--按字段名取串
		local f4 = row:GetStr(4);
		
		local linestr = string.format( "%d %s %d %s %s", f0, f1, f2, f3, f4);
		if i == rowCount then linestr = linestr.."\r\n" end;
		WriteCon( linestr );
	end
	
	--查找行
	local rowIndex = t:FindRow( "id", "3" );
	if rowIndex ~= -1 then
		WriteCon( string.format("find row ok, rowIndex=%d\r\n", rowIndex ));
	end
end

--测试图片组合
function p.TestPictureCombo()
	--取出数字资源图片
	local pic0 = GetPictureByAni("effect.num", 0);
	local pic1 = GetPictureByAni("effect.num", 1);
	local pic2 = GetPictureByAni("effect.num", 2);
	local pic3 = GetPictureByAni("effect.num", 3);
	local pic4 = GetPictureByAni("effect.num", 4);
	local pic5 = GetPictureByAni("effect.num", 5);
	local pic6 = GetPictureByAni("effect.num", 6);
	local pic7 = GetPictureByAni("effect.num", 7);
	local pic8 = GetPictureByAni("effect.num", 8);
	local pic9 = GetPictureByAni("effect.num", 9);	
	local pic10= GetPictureByAni("effect.num", 10);	
		
	--创建图片组合
	local picCmb = createNDPictureCombo();
	picCmb:PushPicture( pic0 );
	picCmb:PushPicture( pic1 );
	picCmb:PushPicture( pic2 );
	picCmb:PushPicture( pic3 );
	picCmb:PushPicture( pic4 );
	picCmb:PushPicture( pic5 );
	picCmb:PushPicture( pic6 );
	picCmb:PushPicture( pic7 );
	picCmb:PushPicture( pic8 );
	picCmb:PushPicture( pic9 );
	picCmb:PushPicture( pic10 );
	
	--创建image控件
	local image = createNDUIImage();
	image:Init();
	image:SetPicture( picCmb );
	image:ResizeToFitPicture();
	image:SetFramePosXY(100,100);
	
	--添加到hud层
	GetHudLayer():AddChild( image );
end

--测试创建图片组合
function p.CreatePictureCombo( n1, n2, n3 )
	--取出数字资源图片
	local pic0 = GetPictureByAni("effect.num", n1);
	local pic1 = GetPictureByAni("effect.num", n2);
	local pic2 = GetPictureByAni("effect.num", n3);
		
	--创建图片组合
	local picCmb = createNDPictureCombo();
	picCmb:PushPicture( pic0 );
	picCmb:PushPicture( pic1 );
	picCmb:PushPicture( pic2 );
	
	return picCmb;
end

--在hud层创建一个image控件
function p.CreateUIImageInHudLayer( x, y )
	--创建image控件
	local image = createNDUIImage();
	image:Init();
	image:ResizeToFitPicture();
	image:SetFramePosXY( x, y );
	
	--添加到hud层
	GetHudLayer():AddChild( image );
	return image;
end

--测试Ani配置含图片组合
function p.TestAniWithPictureCombo()

	--创建图片组合
	local picCmb = p.CreatePictureCombo( 1, 2, 3 );

	--在hud层创建一个image控件	
	local image = p.CreateUIImageInHudLayer( 100, 100 );
	image:AddFgEffect( "effect.piccmb" );
	
	--设置变量环境
	ResetVarEnv();
	local env = GetVarEnv();
	env:SetPtr( "$1", picCmb );
end

--测试Ani图片组合，结合cmd
function p.testPictureComboWithCmd()
	--创建图片组合
	local picCmb1 = p.CreatePictureCombo( 1, 2, 3 );
	local picCmb2 = p.CreatePictureCombo( 4, 5, 6 );
	
	--在hud层创建两个image控件	
	local image1 = p.CreateUIImageInHudLayer( 100, 100 );
	local image2 = p.CreateUIImageInHudLayer( 200, 200 );
	
	--用cmd给控件绑个特效
	local cmd1 = createCommandEffect():AddFgEffect( 0.25, image1, "combo.piccmb" );
	local cmd2 = createCommandEffect():AddFgEffect( 0.25, image2, "combo.piccmb" );
	
	battle_show.GetDefaultSerialSequence():AddCommand( cmd1 );
	battle_show.GetDefaultSerialSequence():AddCommand( cmd2 );
	
	--设置cmd的变量环境
	cmd1:GetVarEnv():SetPtr( "$1", picCmb1 );
	cmd2:GetVarEnv():SetPtr( "$1", picCmb2 );
end

--测试音效、音乐、视频
function p.TestSoundMusicVolume()
	PlayBGMusic(1);
	
--[[
	local seq = battle_show.GetDefaultSerialSequence();
	
	seq:AddCommand( createCommandSoundMusicVideo():PlaySound( 1 ));
	seq:AddCommand( createCommandInterval():Idle( 2 ));
	
	seq:AddCommand( createCommandSoundMusicVideo():PlaySound( 2 ));
	seq:AddCommand( createCommandInterval():Idle( 2 ));
	
	seq:AddCommand( createCommandSoundMusicVideo():PlayMusic( 2 ));
	seq:AddCommand( createCommandInterval():Idle( 5 ));
	
	seq:AddCommand( createCommandSoundMusicVideo():PlayVideo( "" ));
--]]	
end

--测试UIX
function p.TestUIX()
	p.TestUIX_ListHorz();
	p.TestUIX_ListVert();
end

function p.TestUIX_SingleMode()
	p.TestUIX_ListHorz_SingleMode();
	p.TestUIX_ListVert_SingleMode();
end

--测试横向列表
function p.TestUIX_ListHorz()
	local list = createNDUIXListBoxHorz();
	list:Init();
	list:SetFramePosXY( 350, 10 );
	list:SetFrameSize( 500, 150 );
	list:SetSpacing( 30 );
	
	for i=1,3 do
		local view = createNDUIXView();
		view:Init();
		LoadUI( "uix_view.xui", view, nil );
	
		local bg = GetUiNode( view, 1 );
		view:SetViewSize( bg:GetFrameSize());
	
		list:AddView( view );	
		
		--set btn event
	    local btn1 = GetButton( view, 2 );
	    local btn2 = GetButton( view, 3 );
        btn1:SetLuaDelegate(p.OnBtnEvent);
        btn2:SetLuaDelegate(p.OnBtnEvent);		
        
		--set text
		local label = GetLabel( view, 4 );
		label:SetText( "view"..tostring(i));
		
        --set view event
        view:SetLuaDelegate(p.OnViewEvent);
		view:SetEnabled( i%2==0 );
		view:EnableSelImage(true);
	end
	
	GetUIRoot():AddChild( list );
	--list:SetFirstVisibleIndex(3);
	list:SetLastVisibleIndex(0);
	list:MoveToLast();
end

--测试横向列表（仅单个view可见）
function p.TestUIX_ListHorz_SingleMode()
	local list = createNDUIXListBoxHorz();
	list:Init();
	list:SetFramePosXY( 350, 200 );
	list:SetFrameSize( 300, 150 );
	list:SetSpacing( 30 );
	list:SetSingleMode( true );
	
	for i=1,4 do
		local view = createNDUIXView();
		view:Init();
		LoadUI( "uix_view.xui", view, nil );
	
		local bg = GetUiNode( view, 1 );
		view:SetViewSize( bg:GetFrameSize());
	
		list:AddView( view );	
		
		--set btn event
	    local btn1 = GetButton( view, 2 );
	    local btn2 = GetButton( view, 3 );
        btn1:SetLuaDelegate(p.OnBtnEvent);
        btn2:SetLuaDelegate(p.OnBtnEvent);		
        
		--set text
		local label = GetLabel( view, 4 );
		label:SetText( "view"..tostring(i));
		
        --set view event
        view:SetLuaDelegate(p.OnViewEvent);
		view:SetEnabled( i%2==0 );
		view:EnableSelImage(true);
	end
	
	GetUIRoot():AddChild( list );
	
	--list:SetActiveView(1); --设置序号1的view为当前View
	--list:MoveToPrevView(); --滚到前一个view
	--list:MoveToNextView(); --滚到后一个view
end

function p.TestNDUIScrollContainerExpand()
	local pList = createNDUIScrollContainerExpand();
	
	if nil == pList then
		WriteConWarning("createNDUIScrollContainerExpand() failed in test");
		return false;
	end
	
	pList:Init();
	pList:SetFramePosXY( 00, 100 );
	pList:SetFrameSize( 600, 120 );
	pList:SetSizeView(CCSizeMake(180,180));
	
	for i = 1,4 do
		local pView1 = createNDUIScrollViewExpand();
	
		if nil == pView1 then
			WriteConWarning("createNDUIScrollViewExpand() failed in test");
			return true;
		end
		
		pView1:Init();
		pView1:SetViewId(i);
		LoadUI( "test_list_640X960.xui", pView1, nil );

		local pButton = GetButton( pView1, ui_test_list.ID_CTRL_BUTTON_2 );		
		pButton:SetLuaDelegate(p.TestBB);
		pView1:SetTag(i);
		
		pList:AddView(pView1);
	end

	GetUIRoot():AddChild(pList);
	
	return true;
end

function p.TestBB(uiNode, uiEventType, param)
	WriteCon("feafae");
end

--测试纵向列表
function p.TestUIX_ListVert()
	local list = createNDUIXListBoxVert();
	list:Init();
	list:SetFramePosXY( 10, 10 );
	list:SetFrameSize( 300, 550 );
	list:SetSpacing( 30 );
	
	for i=1,5 do
		local view = createNDUIXView();
		view:Init();
		LoadUI( "uix_view.xui", view, nil );
	
		local bg = GetUiNode( view, 1 );
		view:SetViewSize( bg:GetFrameSize());
	
		list:AddView( view );	
		
		--set btn event
	    local btn1 = GetButton( view, 2 );
	    local btn2 = GetButton( view, 3 );
        btn1:SetLuaDelegate(p.OnBtnEvent);
        btn2:SetLuaDelegate(p.OnBtnEvent);
        
		--set text
		local label = GetLabel( view, 4 );
		label:SetText( "view"..tostring(i));
		
        --set view event
        view:SetLuaDelegate(p.OnViewEvent);   
		view:SetEnabled( i%2==0 );
		view:EnableSelImage(true);		
	end
	
    GetUIRoot():AddChild( list );
	list:SetFirstVisibleIndex(1);
	list:SetLastVisibleIndex(5);
	list:MoveToLast();
	
	--list:SetActiveView(4); --设置序号1的view为当前View
	--list:MoveToPrevView(); --滚到前一个view
	--list:MoveToNextView(); --滚到后一个view	
end

--测试纵向列表（仅单个view可见）
function p.TestUIX_ListVert_SingleMode()
	local list = createNDUIXListBoxVert();
	list:Init();
	list:SetFramePosXY( 10, 10 );
	list:SetFrameSize( 300, 180 );
	list:SetSpacing( 30 );
	list:SetSingleMode( true );
	
	for i=1,4 do
		local view = createNDUIXView();
		view:Init();
		LoadUI( "uix_view.xui", view, nil );
	
		local bg = GetUiNode( view, 1 );
		view:SetViewSize( bg:GetFrameSize());
	
		list:AddView( view );	
		
		--set btn event
	    local btn1 = GetButton( view, 2 );
	    local btn2 = GetButton( view, 3 );
        btn1:SetLuaDelegate(p.OnBtnEvent);
        btn2:SetLuaDelegate(p.OnBtnEvent);
        
		--set text
		local label = GetLabel( view, 4 );
		label:SetText( "view"..tostring(i));
		
        --set view event
        view:SetLuaDelegate(p.OnViewEvent); 
		view:SetEnabled( i%2==0 );
		view:EnableSelImage(true);
	end
	
    GetUIRoot():AddChild( list );
	
	--list:SetActiveView(1); --设置序号1的view为当前View
	--list:MoveToPrevView(); --滚到前一个view
	--list:MoveToNextView(); --滚到后一个view	
end

--按钮事件
function p.OnBtnEvent(uiNode, uiEventType, param)
	if IsClickEvent(uiEventType) then
		WriteCon( "on btn event" );
	end
end

--View事件
function p.OnViewEvent(uiNode, uiEventType, param)
	local view = ConverToView(uiNode);
    if IsClickEvent(uiEventType) then
		WriteCon( "on view clicked" );
		if view:IsSelected() then
			view:SetSelected( false );
		else
			view:SetSelected( true );
		end
	elseif IsSelectViewEvent(uiEventType) then
		WriteCon( "on view selected" );
	elseif IsUnSelectViewEvent(uiEventType) then
		WriteCon( "on view un-selected" );
	elseif IsActiveViewEvent(uiEventType) then
		WriteCon( string.format("on view active, viewIndex=%d", tonumber(param)));
	end	
end

--测试滚动文本
function p.TestScrollText()
    local text = createNDUIScrollText();
    text:Init();
    text:SetScrollDir(0);
    text:SetFontSize( FontSize(20));
    text:SetFontColor( ccc4( 255,0,0,255 ));
	--text:SetText( GetStr("s3") );
	text:RunText( GetStr("s3") );
	--text:RunText("");
    text:SetZOrder( 10 );
    text:SetFrameRect( CCRectMake( 50, 50, 400, 60 ));
    GetUIRoot():AddChild( text );
    --SetDebugDraw(true);
end

--测试vector
function p.TestVector()
	local v = vector:new();
	v:push( 100 );
	v:push( "hello" );
	v:push( "world" );
	v:push( 3.14159 );
	v:push( nil );
	v:push( "done" );
	v:push( 6699 );
	v:push( nil );
	v:set(3, "universe" );
	
--[[	
	print(v:find(100));
	print(v:find("hello"));
	print(v:find("world"));
	print(v:find(3.14159));
	print(v:find(nil));
	print(v:find("done"));
	print(v:find(6699));
--]]
	
--[[	
	print( "vector size: "..v:size());
	for i=1,v:size() do
		print( v:get(i));
	end
	
	v:clear();
	
	print( "vector size: "..v:size());
	for i=1,v:size() do
		print( v:get(i));
	end	
--]]	
end

--测试demo2.0 pvp
function p.test1()
	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();

	GetRunningScene():AddChildZTag(layer,0,500);
    LoadUI( "x_battle_pvp.xui", layer, nil );
end

--测试player命令
function p.testPlayerCmd()
    --[[
	--备注：playerCmd有：Standby, Atk, Skill, Defence, Hurt, Dead, PlayAnim
	if x_battle_mgr.IsActive() then
	    local node = x_battle_mgr.GetFirstHero():GetNode();
	    local cmd1 = createCommandPlayer():Atk( 0, node, "");
	    local cmd2 = createCommandPlayer():Standby( 0, node, "");
    	
	    battle_show.GetDefaultSerialSequence():AddCommand( cmd1 );
	    battle_show.GetDefaultSerialSequence():AddCommand( cmd2 );
    	
	    WriteCon(" -- testPlayerCmd() done -- ");
    end
    --]]
    
    --[[    
    --测试action位移
    if x_battle_mgr.IsActive() then
        local node = x_battle_mgr.GetFirstHero():GetNode();
        node:AddActionEffect( "fighter.move_test" );
        
        node = x_battle_mgr.GetFirstEnemy():GetNode();
        node:AddActionEffect( "fighter.move_test" );        
    end
    --]]
end

--测试子弹配置
function p.TestBullet()
    local bullet = GetBullet( "bullet.bullet1" );
    if bullet ~= nil then
        WriteCon( bullet:GetAni());
	else
		WriteConErr("get bullet failed");
    end
end

--测试高斯模糊
function p.TestGaussianBlur()
    if x_battle_mgr.IsActive() then
        local node = x_battle_mgr.GetFirstHero():GetNode();
        if node ~= nil then
            node:AddActionEffect( "test.gsblur" );
        end
    end
end

function p.TestCardBox()
	dlg_card_box_mainui.ShowUI();
end

--测试发送http请求
function p.TestHttpSend()
	SendReq( "Test", "TestAction", GetUID(), "a=1&b=2&str=hello" );
end

--测试删除Ani特效
function p.TestDelAni()
    local node = x_battle_mgr.GetFirstHero():GetNode();
    if node ~= nil then
        node:AddFgEffect( "effect.blink" );
        SetTimerOnce( p.DelAni, 2.0f );
    end
end

function p.DelAni()            
    local node = x_battle_mgr.GetFirstHero():GetNode();
    if node ~= nil then
        node:DelAniEffect( "effect.blink" );
    end
end


--测试玩家信息保存
function p.TestUserConfig()
    local uid = GetUID();
    uid = uid + 1;
    GetUserConfig():SetInt("uid", tonumber(uid));
    GetUserConfig():Save();
end

--测试创建玩家
function p.TestCreatePlayer()
	dlg_create_player:ShowUI();
end

--测试Lua错误处理
function p.TestLuaErrHandler()
	WriteConWarning( "--- TestLuaErrHandler() ---\r\n" );
	local t = {};
	if t.wtf > 0 then
	end
	--t:wtf():damn(); --err
end

--测试消息提示框
function p.TestMsgBox(layer)
	dlg_msgbox.ShowYesNo( ToUtf8("询问"), ToUtf8("测试消息提示框！！！！！！！！！！！"), p.OnMsgBoxCallback , layer );
end

--消息框回调
function p.OnMsgBoxCallback( result )
	WriteConErr("!!! OnMsgBoxCallback: "..tostring(result));
end

--测试卡片翻转
function p.TestCardRotate()
	local x0 = 100;
	local x = x0;
	local y = 100;
	for row = 1,3 do
		for col = 1,8 do
			local image = createNDUIImage();
			image:Init();
			image:SetPicture( GetPictureByAni("sk_test.small_card", 0));
			image:SetPictureBackFace( GetPictureByAni("sk_test.small_card", 1));
			image:SetFramePosXY( x, y );
			image:ResizeToFitPicture();
			GetUIRoot():AddChildZ( image, 10 );	
			
			--image:AddActionEffect( "engine_cmb.view_select" );
			if row == 1 then
				image:AddActionEffect( "test_cmb.card_rotate_x" );
			elseif row == 2 then
				image:AddActionEffect( "test_cmb.card_rotate_y" );
			elseif row == 3 then
				image:AddActionEffect( "test_cmb.card_rotate" );
			end
			
			--if row > 1 then image:SetRotationDegY(45); end
			x = x + 120;
		end
		
		x = x0;
		y = y + 200;
	end
end

--测试ColorLabel
function p.TestColorLabel()
	local crLabel = createNDUIColorLabel();
	local text = "<#red>好好学习，<#green>天天向上，<#blue>good good study, day day up! \none two three four five six seven eight nine ten.";
	--local text = "<#ff0000ff>好好学习，<#00ff00ff>天天向上，<#0000ffff>good good study, day day up! \n<#000000ff>one two three four five six seven eight nine ten.";
	--local text = "<#red>哈哈范德萨\n<#blue>good\n<#gray>good\<#yellow>study\n\n<#green>xx\none\ntwo\nthree\nfour\nfive\nsix";
	crLabel:Init();
	crLabel:SetText( ToUtf8(text));
	crLabel:SetFontSize( FontSize(25));
	crLabel:SetFrameRect( CCRectMake(50,400,260,200));
	crLabel:SetHorzAlign(1); --0=left, 1=mid, 2=right
	crLabel:SetVertAlign(1); --0=top, 1=mid, 2=bottom
	GetUIRoot():AddChild(crLabel);
end

--测试edit控件
function p.TestEdit()
	--事件通过Layer派发给Edit控件
	local layer = createNDUILayer();
	layer:Init();
	layer:SetFrameRectFull();
	layer:SetSwallowTouch( false );
	GetUIRoot():AddChild(layer);
	
	local edit = createNDUIEdit();
	edit:Init();
	edit:SetFrameRect( CCRectMake(10,10,300,60));
	edit:SetText( ToUtf8("发的刷卡防静电撒"));
	edit:SetTextColor( ccc4(255,255,255,255));
	edit:SetMaxLength(20); --限制为20个字符，汉字算2个字符，英文和数字算1个字符
	edit:SetHorzAlign(0);
	layer:AddChild(edit);
	
	SetDebugDraw(true);
end

--测试9宫格控件
function p.Test9Slices()
	local widget = createNDUI9SlicesImage();
	widget:Init();
	widget:SetFrameRect( CCRectMake( 10,10,300,120));
	widget:SetPicture( GetPictureByAni("effect.9slices", 0));
	GetUIRoot():AddChild(widget);
end

--测试utf8子串
function p.TestUtf8String()
	g_str = GetStr("s3"); --global
	g_str_index = 1;
	g_str_count = GetCharCountUtf8( g_str );
	
	SetTimer( p.OnTimer_UpdateSubString, 0.1f );
end

--定时更新子串
function p.OnTimer_UpdateSubString( idTimer )
	WriteCon( GetSubStringUtf8( g_str, g_str_index ));
	g_str_index = g_str_index + 1;
	if g_str_index  > g_str_count then
		KillTimer( idTimer );
	end
end