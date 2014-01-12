--------------------------------------------------------------
-- FileName: 	test.lua
-- author:		zhangwq, 2013/05/13
-- purpose:		������
--------------------------------------------------------------

test = {}
local p = test;
pLayer = nil

function p.test()
--	SetDebugDraw(true);

--[[	WriteFile("your output text","YourFileName.log");
	WriteFile("your output text","YourFileName");
	WriteFile("your output text");   --Ĭ��Ϊ"ClientLua.log"--]]
	
	--���������Ҫ���Եĺ���
--	p.TestDB();
	
	--����ͼƬ���
	--p.TestPictureCombo();

	--����Ani���ú�ͼƬ���
--	p.TestAniWithPictureCombo();

	--���cmd����ͼƬ���
--	p.testPictureComboWithCmd();

	--������Ч�����֡���Ƶ
--	p.TestSoundMusicVolume();

	--����UIX
--	p.TestUIX();
--	p.TestUIX_SingleMode();

    --����ScrollText
--    p.TestScrollText();

	--����vector
--	p.TestVector();

    --����
--    p.test1();
	
	--����player����
--	SetTimerOnce( p.testPlayerCmd, 2.0f );

    --�����ӵ�����
--    p.TestBullet();

    --���Ը�˹ģ��
--    SetTimerOnce( p.TestGaussianBlur, 2.0f );

	--���Կ���
--	p.TestCardBox();
	
	--���Է���
--	p.TestHttpSend();

    --����ɾ��Ani��Ч
--    p.TestDelAni();

    --���������Ϣ����
--    p.TestUserConfig();

	--���Դ������
	--p.TestCreatePlayer();
	
	--����Lua������
--	p.TestLuaErrHandler();

	--������Ϣ��ʾ��
--	p.TestMsgBox();

	--���Կ�Ƭ��ת
--	p.TestCardRotate();

	--����ColorLabel
--	p.TestColorLabel();

	--����edit�ؼ�
--	p.TestEdit();

	--����9����ؼ�
--	p.Test9Slices();

	--������չ�б�
	--p.TestNDUIScrollContainerExpand();

	--ֱ�ӽ�ս��
	--p.EnterBattle();
	--x_battle_mgr.EnterBattle();
	--n_battle_mgr.EnterBattle( N_BATTLE_PVE, 101011 );
	--n_battle_mgr.EnterBattle( N_BATTLE_PVP, 10002 );
--	--����utf8�Ӵ�
--	p.TestUtf8String();
    
    --���Ծ���
	--dlg_drama.ShowUI(2);

	--p.testFly();
	
	--���Դ�����ɫ
	--dlg_createrole.ShowUI();
	--dlg_create_player.ShowUI();
	
	--���Ծ���������ս��
	--local strParam = string.format("&target=%d",10002);
	--SendReq( "Fight","StartPvP",10001,strParam );
	
	--���Խ���
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


--�������ݿ�ӿ�
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
		local f0 = row:GetNum(0);--������ȡ��ֵ
		local f1 = row:GetStr(1);--������ȡ��
		local f2 = row:GetNumByName("tel");--���ֶ���ȡ��ֵ
		local f3 = row:GetStrByName("addr");--���ֶ���ȡ��
		local f4 = row:GetStr(4);
		
		local linestr = string.format( "%d %s %d %s %s", f0, f1, f2, f3, f4);
		if i == rowCount then linestr = linestr.."\r\n" end;
		WriteCon( linestr );
	end
	
	--������
	local rowIndex = t:FindRow( "id", "3" );
	if rowIndex ~= -1 then
		WriteCon( string.format("find row ok, rowIndex=%d\r\n", rowIndex ));
	end
end

--����ͼƬ���
function p.TestPictureCombo()
	--ȡ��������ԴͼƬ
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
		
	--����ͼƬ���
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
	
	--����image�ؼ�
	local image = createNDUIImage();
	image:Init();
	image:SetPicture( picCmb );
	image:ResizeToFitPicture();
	image:SetFramePosXY(100,100);
	
	--��ӵ�hud��
	GetHudLayer():AddChild( image );
end

--���Դ���ͼƬ���
function p.CreatePictureCombo( n1, n2, n3 )
	--ȡ��������ԴͼƬ
	local pic0 = GetPictureByAni("effect.num", n1);
	local pic1 = GetPictureByAni("effect.num", n2);
	local pic2 = GetPictureByAni("effect.num", n3);
		
	--����ͼƬ���
	local picCmb = createNDPictureCombo();
	picCmb:PushPicture( pic0 );
	picCmb:PushPicture( pic1 );
	picCmb:PushPicture( pic2 );
	
	return picCmb;
end

--��hud�㴴��һ��image�ؼ�
function p.CreateUIImageInHudLayer( x, y )
	--����image�ؼ�
	local image = createNDUIImage();
	image:Init();
	image:ResizeToFitPicture();
	image:SetFramePosXY( x, y );
	
	--��ӵ�hud��
	GetHudLayer():AddChild( image );
	return image;
end

--����Ani���ú�ͼƬ���
function p.TestAniWithPictureCombo()

	--����ͼƬ���
	local picCmb = p.CreatePictureCombo( 1, 2, 3 );

	--��hud�㴴��һ��image�ؼ�	
	local image = p.CreateUIImageInHudLayer( 100, 100 );
	image:AddFgEffect( "effect.piccmb" );
	
	--���ñ�������
	ResetVarEnv();
	local env = GetVarEnv();
	env:SetPtr( "$1", picCmb );
end

--����AniͼƬ��ϣ����cmd
function p.testPictureComboWithCmd()
	--����ͼƬ���
	local picCmb1 = p.CreatePictureCombo( 1, 2, 3 );
	local picCmb2 = p.CreatePictureCombo( 4, 5, 6 );
	
	--��hud�㴴������image�ؼ�	
	local image1 = p.CreateUIImageInHudLayer( 100, 100 );
	local image2 = p.CreateUIImageInHudLayer( 200, 200 );
	
	--��cmd���ؼ������Ч
	local cmd1 = createCommandEffect():AddFgEffect( 0.25, image1, "combo.piccmb" );
	local cmd2 = createCommandEffect():AddFgEffect( 0.25, image2, "combo.piccmb" );
	
	battle_show.GetDefaultSerialSequence():AddCommand( cmd1 );
	battle_show.GetDefaultSerialSequence():AddCommand( cmd2 );
	
	--����cmd�ı�������
	cmd1:GetVarEnv():SetPtr( "$1", picCmb1 );
	cmd2:GetVarEnv():SetPtr( "$1", picCmb2 );
end

--������Ч�����֡���Ƶ
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

--����UIX
function p.TestUIX()
	p.TestUIX_ListHorz();
	p.TestUIX_ListVert();
end

function p.TestUIX_SingleMode()
	p.TestUIX_ListHorz_SingleMode();
	p.TestUIX_ListVert_SingleMode();
end

--���Ժ����б�
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

--���Ժ����б�������view�ɼ���
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
	
	--list:SetActiveView(1); --�������1��viewΪ��ǰView
	--list:MoveToPrevView(); --����ǰһ��view
	--list:MoveToNextView(); --������һ��view
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

--���������б�
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
	
	--list:SetActiveView(4); --�������1��viewΪ��ǰView
	--list:MoveToPrevView(); --����ǰһ��view
	--list:MoveToNextView(); --������һ��view	
end

--���������б�������view�ɼ���
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
	
	--list:SetActiveView(1); --�������1��viewΪ��ǰView
	--list:MoveToPrevView(); --����ǰһ��view
	--list:MoveToNextView(); --������һ��view	
end

--��ť�¼�
function p.OnBtnEvent(uiNode, uiEventType, param)
	if IsClickEvent(uiEventType) then
		WriteCon( "on btn event" );
	end
end

--View�¼�
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

--���Թ����ı�
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

--����vector
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

--����demo2.0 pvp
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

--����player����
function p.testPlayerCmd()
    --[[
	--��ע��playerCmd�У�Standby, Atk, Skill, Defence, Hurt, Dead, PlayAnim
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
    --����actionλ��
    if x_battle_mgr.IsActive() then
        local node = x_battle_mgr.GetFirstHero():GetNode();
        node:AddActionEffect( "fighter.move_test" );
        
        node = x_battle_mgr.GetFirstEnemy():GetNode();
        node:AddActionEffect( "fighter.move_test" );        
    end
    --]]
end

--�����ӵ�����
function p.TestBullet()
    local bullet = GetBullet( "bullet.bullet1" );
    if bullet ~= nil then
        WriteCon( bullet:GetAni());
	else
		WriteConErr("get bullet failed");
    end
end

--���Ը�˹ģ��
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

--���Է���http����
function p.TestHttpSend()
	SendReq( "Test", "TestAction", GetUID(), "a=1&b=2&str=hello" );
end

--����ɾ��Ani��Ч
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


--���������Ϣ����
function p.TestUserConfig()
    local uid = GetUID();
    uid = uid + 1;
    GetUserConfig():SetInt("uid", tonumber(uid));
    GetUserConfig():Save();
end

--���Դ������
function p.TestCreatePlayer()
	dlg_create_player:ShowUI();
end

--����Lua������
function p.TestLuaErrHandler()
	WriteConWarning( "--- TestLuaErrHandler() ---\r\n" );
	local t = {};
	if t.wtf > 0 then
	end
	--t:wtf():damn(); --err
end

--������Ϣ��ʾ��
function p.TestMsgBox(layer)
	dlg_msgbox.ShowYesNo( ToUtf8("ѯ��"), ToUtf8("������Ϣ��ʾ�򣡣�������������������"), p.OnMsgBoxCallback , layer );
end

--��Ϣ��ص�
function p.OnMsgBoxCallback( result )
	WriteConErr("!!! OnMsgBoxCallback: "..tostring(result));
end

--���Կ�Ƭ��ת
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

--����ColorLabel
function p.TestColorLabel()
	local crLabel = createNDUIColorLabel();
	local text = "<#red>�ú�ѧϰ��<#green>�������ϣ�<#blue>good good study, day day up! \none two three four five six seven eight nine ten.";
	--local text = "<#ff0000ff>�ú�ѧϰ��<#00ff00ff>�������ϣ�<#0000ffff>good good study, day day up! \n<#000000ff>one two three four five six seven eight nine ten.";
	--local text = "<#red>����������\n<#blue>good\n<#gray>good\<#yellow>study\n\n<#green>xx\none\ntwo\nthree\nfour\nfive\nsix";
	crLabel:Init();
	crLabel:SetText( ToUtf8(text));
	crLabel:SetFontSize( FontSize(25));
	crLabel:SetFrameRect( CCRectMake(50,400,260,200));
	crLabel:SetHorzAlign(1); --0=left, 1=mid, 2=right
	crLabel:SetVertAlign(1); --0=top, 1=mid, 2=bottom
	GetUIRoot():AddChild(crLabel);
end

--����edit�ؼ�
function p.TestEdit()
	--�¼�ͨ��Layer�ɷ���Edit�ؼ�
	local layer = createNDUILayer();
	layer:Init();
	layer:SetFrameRectFull();
	layer:SetSwallowTouch( false );
	GetUIRoot():AddChild(layer);
	
	local edit = createNDUIEdit();
	edit:Init();
	edit:SetFrameRect( CCRectMake(10,10,300,60));
	edit:SetText( ToUtf8("����ˢ����������"));
	edit:SetTextColor( ccc4(255,255,255,255));
	edit:SetMaxLength(20); --����Ϊ20���ַ���������2���ַ���Ӣ�ĺ�������1���ַ�
	edit:SetHorzAlign(0);
	layer:AddChild(edit);
	
	SetDebugDraw(true);
end

--����9����ؼ�
function p.Test9Slices()
	local widget = createNDUI9SlicesImage();
	widget:Init();
	widget:SetFrameRect( CCRectMake( 10,10,300,120));
	widget:SetPicture( GetPictureByAni("effect.9slices", 0));
	GetUIRoot():AddChild(widget);
end

--����utf8�Ӵ�
function p.TestUtf8String()
	g_str = GetStr("s3"); --global
	g_str_index = 1;
	g_str_count = GetCharCountUtf8( g_str );
	
	SetTimer( p.OnTimer_UpdateSubString, 0.1f );
end

--��ʱ�����Ӵ�
function p.OnTimer_UpdateSubString( idTimer )
	WriteCon( GetSubStringUtf8( g_str, g_str_index ));
	g_str_index = g_str_index + 1;
	if g_str_index  > g_str_count then
		KillTimer( idTimer );
	end
end