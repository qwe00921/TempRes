--------------------------------------------------------------
-- FileName: 	dlg_watch_player.lua
-- author:		zjj, 2013/08/30
-- purpose:		玩家信息界面
--------------------------------------------------------------

dlg_watch_player = {}
local p = dlg_watch_player;

p.layer = nil;
p.intent = nil;

local SELF_INFO   = 1;
local PLAYER_INFO = 2;

local BOX_AGE     = 1;
local BOX_MONTH   = 2;
local BOX_DAY     = 3;
local BOX_SEX     = 4

p.lableList = {};
p.editList = {};
p.selectbox_list = {};

--选择项
p.age = {};
p.month = {};
p.day = {};
p.sex = {};

--存放信息（全部）
p.data = nil;
--保存信息 (可编辑)
p.playdata = {{age=nil},{birthday=nil},{sex=nil},{city=nil},{interest=nil},{sign=nil}};

--选中的编辑框
p.selectedEdit = nil;
--编辑个人信息按钮
p.editBtn = nil;


--显示UI
function p.ShowUI( intent )
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
    
	layer:Init();	
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_watch_player.xui", layer, nil);
	
	if intent ~= nil then
	   p.intent = intent;
	end
	p.layer = layer;
--	p.InitAndShowUI();
	p.GetUesrInfo();
end

--界面初始化
function p.InitAndShowUI( data )
    
    p.data = data;
    
    --用于存放显示信息Lable(需隐藏)
    p.lableList = {{age=nil},{birthday=nil} ,{sex=nil},{city=nil},{interest=nil},{sign=nil}};
    --用于存放编辑信息Edit
    p.editList = {{age=nil},{birthdayM=nil},{birthdayD=nil},{sex=nil},{city=nil},{interest=nil},{sign=nil}};
    --用于存放选择列表
    p.selectbox_list = {{age=nil},{birthdayM=nil},{birthdayD=nil},{sex=nil}};
    p.InitSelectBox();
    
    --初始化选择项
    local t = 12;
    for i=1,32 do
        if t < 46 then
             p.age[i] = tostring( t );
             t = t + 1;
        end
    end
    p.sex = { ToUtf8("男"),ToUtf8( "女" )};
    for i=1,12 do
        p.month[i] = tostring( i ) .. ToUtf8( "月" );
    end
    for i=1,31 do
        p.day[i] = tostring( i ) .. ToUtf8( "日" );
    end
    -----------------------显示用-----------------------------
    
    --年龄
    p.lableList.age = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_AGE );
    p.lableList.age:SetText( tostring( data.target_user_status.age ));
    
    --生日
    p.lableList.birthday = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_BIRTHDAY );
    p.lableList.birthday:SetText( p.GetBirthday( data.target_user_status.birthday));
    
    --性别
    p.lableList.sex = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_SEX );
    p.lableList.sex:SetText( data.target_user_status.sex);
    
    --城市
    p.lableList.city = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_CITY );
    p.lableList.city:SetText( data.target_user_status.city);
    
    --爱好
    p.lableList.interest = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_INTEREST );
    p.lableList.interest:SetText(data.target_user_status.hobby );
    
    --签名
    p.lableList.sign = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_SIGN );
    p.lableList.sign:SetText( data.target_user_status.tag ); 
    
    ------------------------编辑用---------------------------------
    
    --年龄
    p.editList.age = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_AGE );
    p.editList.age:SetLuaDelegate(p.OnEditEvent);
    p.editList.age:SetId(1);
    
    --生日(月)
    p.editList.birthdayM = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_MONTH );
    p.editList.birthdayM:SetLuaDelegate(p.OnEditEvent);
    p.editList.birthdayM:SetId(1);
    
    --生日(日)
    p.editList.birthdayD = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_DAY );
    p.editList.birthdayD:SetLuaDelegate(p.OnEditEvent);
    p.editList.birthdayD:SetId(1);
    
    --性别
    p.editList.sex = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_SEX );
    p.editList.sex:SetLuaDelegate(p.OnEditEvent);
    p.editList.sex:SetId(1);
    
    --城市
    p.editList.city = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_CITY );
    
    --爱好
    p.editList.interest = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_INTEREST );
    
    --签名
    p.editList.sign = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_SIGN );
    
    
    ------------------------共用---------------------------------------

    --标题
    local titleLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_TITLE );
    
    --头像
    local iconPic = GetImage( p.layer,ui_dlg_watch_player.ID_CTRL_PICTURE_ICON );
    
    --名称
    local nameLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_NAME );
    
    --等级
    local lvLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_LV );
    
    --最后上线
    local lastLoginLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_LAST_LOGIN_TIME );
    
    --好友数
    local friendNumLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_FIREND_NUM );
    
    --编辑个人信息按钮
    p.editBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_EDIT_INFO);
    p.editBtn:SetId(1);
    
    --申请好友按钮
    local applyBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_APPLY);
    
    --好友聊天按钮
    local chatBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_CHAT);
    
    
    --个人页面请求
	if p.intent == SELF_INFO then
	   titleLab:SetText( ToUtf8("个人信息界面")); --设置标题
	   p.editBtn:SetLuaDelegate(p.OnWatchPlayerUIEvent);
       --隐藏按钮
	   applyBtn:SetVisible( false );
	   chatBtn:SetVisible( false );
	end
	
	local backBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnWatchPlayerUIEvent);
    p.HideSelectBox();
	--初始化默认隐藏编辑框
	p.SetEditVisible( false);
end

--初始化选择框列表
function p.InitSelectBox()
    --年龄
    p.selectbox_list.age = GetListBoxVert(p.layer ,ui_dlg_watch_player.ID_CTRL_VERTICAL_LIST_AGE);
    
    --月
    p.selectbox_list.birthdayM = GetListBoxVert(p.layer ,ui_dlg_watch_player.ID_CTRL_VERTICAL_LIST_MON);
    
    --日
    p.selectbox_list.birthdayD = GetListBoxVert(p.layer ,ui_dlg_watch_player.ID_CTRL_VERTICAL_LIST_DAY);
    
    --性别
    p.selectbox_list.sex = GetListBoxVert(p.layer ,ui_dlg_watch_player.ID_CTRL_VERTICAL_LIST_SEX);
    
end

--设置编辑群显示隐藏
function p.SetEditVisible( bEnable )
    p.editList.age:SetVisible( bEnable );
    p.editList.birthdayM:SetVisible( bEnable );
    p.editList.birthdayD:SetVisible( bEnable );
    p.editList.sex:SetVisible( bEnable );
    p.editList.city:SetVisible( bEnable );
    p.editList.interest:SetVisible( bEnable );
    p.editList.sign:SetVisible( bEnable );
end

--设置显示群显示隐藏
function p.SetLableVisible( bEnable )
    p.lableList.age:SetVisible( bEnable );
    p.lableList.birthday:SetVisible( bEnable );
    p.lableList.sex:SetVisible( bEnable );
    p.lableList.city:SetVisible( bEnable );
    p.lableList.interest:SetVisible( bEnable );
    p.lableList.sign:SetVisible( bEnable );
end

--编辑框事件处理
function p.OnEditEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
       if ( ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_SEX == tag) then  --选择性别
            if uiNode:GetId() == 1 then  --显示列表
                p.selectedEdit = ConverToEdit(uiNode);
                p.HideSelectBox();
                p.SetandShowSelectBox( BOX_SEX );
                uiNode:SetId( 2 );
            else                         --隐藏
                p.HideSelectBox();
            end
       elseif (ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_AGE == tag) then --选择年龄
            if uiNode:GetId() == 1 then  --显示列表
                p.selectedEdit = ConverToEdit(uiNode);
                p.HideSelectBox();
                p.SetandShowSelectBox( BOX_AGE );
                uiNode:SetId( 2 );
            else                         --隐藏
                p.HideSelectBox();
            end
       elseif (ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_MONTH == tag) then --选择月
            if uiNode:GetId() == 1 then  --显示列表
                p.selectedEdit = ConverToEdit(uiNode);
                p.HideSelectBox();
                p.SetandShowSelectBox( BOX_MONTH );
                uiNode:SetId( 2 );
            else                         --隐藏
                p.HideSelectBox();
            end
        elseif (ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_DAY == tag) then --选择月
            if uiNode:GetId() == 1 then  --显示列表
                p.selectedEdit = ConverToEdit(uiNode);
                p.HideSelectBox();
                p.SetandShowSelectBox( BOX_DAY );
                uiNode:SetId( 2 );
            else                         --隐藏
                p.HideSelectBox();
            end
       end
    end
end

--隐藏选择列表
function p.HideSelectBox()
    p.selectbox_list.age:SetVisible( false );
    p.selectbox_list.birthdayM:SetVisible( false );
    p.selectbox_list.birthdayD:SetVisible( false );
    p.selectbox_list.sex:SetVisible( false );

    p.editList.age:SetId( 1 );
    p.editList.birthdayM:SetId( 1 );
    p.editList.birthdayD:SetId( 1 );
    p.editList.sex:SetId( 1 );
end

--选择列表共用方法
function p.SetandShowSelectBox( boxid )
	if boxid == BOX_AGE then
	   p.selectbox_list.age:ClearView();
        for i=1 ,#p.age do
           local view = createNDUIXView();
           view:Init();
           LoadUI( "combox_view.xui", view, nil );
           local bg = GetUiNode( view, ui_combox_view.ID_CTRL_PICTURE_BG );
           view:SetViewSize( bg:GetFrameSize());
           view:SetLuaDelegate(p.OnViewEvent); 
           local age = GetLabel( view, ui_combox_view.ID_CTRL_TEXT_OPTION );
           age:SetText( p.age[i]);
           
           p.selectbox_list.age:AddView( view );
        end
        p.selectbox_list.age:SetVisible( true );
        
	elseif boxid == BOX_MONTH then
	    p.selectbox_list.birthdayD:ClearView();
        for i=1 ,#p.month do
           local view = createNDUIXView();
           view:Init();
           LoadUI( "combox_view.xui", view, nil );
           local bg = GetUiNode( view, ui_combox_view.ID_CTRL_PICTURE_BG );
           view:SetViewSize( bg:GetFrameSize());
           view:SetLuaDelegate(p.OnViewEvent); 
           local month = GetLabel( view, ui_combox_view.ID_CTRL_TEXT_OPTION );
           month:SetText( p.month[i]);
           
           p.selectbox_list.birthdayM:AddView( view );
        end
        p.selectbox_list.birthdayM:SetVisible( true );
        
	elseif boxid == BOX_DAY then
  	   p.selectbox_list.birthdayM:ClearView();
          for i=1 ,#p.day do
             local view = createNDUIXView();
             view:Init();
             LoadUI( "combox_view.xui", view, nil );
             local bg = GetUiNode( view, ui_combox_view.ID_CTRL_PICTURE_BG );
             view:SetViewSize( bg:GetFrameSize());
             view:SetLuaDelegate(p.OnViewEvent); 
             local day = GetLabel( view, ui_combox_view.ID_CTRL_TEXT_OPTION );
             day:SetText( p.day[i]);
             
             p.selectbox_list.birthdayD:AddView( view );
          end
          p.selectbox_list.birthdayD:SetVisible( true );
	elseif boxid == BOX_SEX then
	    p.selectbox_list.sex:ClearView();
	    for i=1 ,#p.sex do
	       local view = createNDUIXView();
           view:Init();
           LoadUI( "combox_view.xui", view, nil );
           local bg = GetUiNode( view, ui_combox_view.ID_CTRL_PICTURE_BG );
           view:SetViewSize( bg:GetFrameSize());
           view:SetLuaDelegate(p.OnViewEvent); 
           local sex = GetLabel( view, ui_combox_view.ID_CTRL_TEXT_OPTION );
           sex:SetText( p.sex[i]);
           
           p.selectbox_list.sex:AddView( view );
	    end
	    p.selectbox_list.sex:SetVisible( true );
	end
end

--选择框选中事件
function p.OnViewEvent(uiNode, uiEventType, param)
    local view = ConverToView(uiNode);
    if IsClickEvent(uiEventType) then
       local lab = GetLabel( view, ui_combox_view.ID_CTRL_TEXT_OPTION );
       p.selectedEdit:SetText( lab:GetText() );
       p.HideSelectBox();
       p.selectedEdit = nil;
    end 
end

--事件处理
function p.OnWatchPlayerUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
       if ( ui_dlg_watch_player.ID_CTRL_BUTTON_EDIT_INFO == tag ) then  --编辑个人信息
            if uiNode:GetId() == 1 then  --进入编辑
                p.SetEditVisible( true );
                p.SetLableVisible( false );
                uiNode:SetId(2);
                p.editBtn:SetText( ToUtf8( "确定编辑" ));
            else                         --返回显示
                p.SetEditVisible( false );
                p.SetLableVisible( true );
                uiNode:SetId(1);
                p.HideSelectBox();
                p.GetEditInfo();
                p.ShowEditInfo();
                p.editBtn:SetText( ToUtf8( "编辑个人信息" ));
            end
       elseif ( ui_dlg_watch_player.ID_CTRL_BUTTON_BACK == tag ) then
            p.CloseUI();
       end
	end
end

--获得修改后信息
function p.GetEditInfo()
	p.playdata.age = p.editList.age:GetText();
	p.playdata.sex = p.editList.sex:GetText();
	p.playdata.city = p.editList.city:GetText();
	p.playdata.interest = p.editList.interest:GetText();
	p.playdata.sign = p.editList.sign:GetText();
end

--显示玩家（可编辑）信息
function p.ShowEditInfo()
	p.lableList.age:SetText(p.playdata.age)
    p.lableList.sex:SetText(p.playdata.sex)
    p.lableList.city:SetText(p.playdata.city)
    p.lableList.interest:SetText(p.playdata.interest)
    p.lableList.sign:SetText(p.playdata.sign)
end

--获取玩家信息
function p.GetUesrInfo()
	WriteCon("**请求个人信息**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("User","GetUserProfile",uid,"");
end

--解析生日
function p.GetBirthday( birStr )
	local t = Split( birStr , " ");
	local k = Split( t[1] , "-" );
	return k[2] .. ToUtf8( "月" ) .. k[3] .. ToUtf8( "日" );
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()	
    if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
        p.lableList = {};
        p.editList = {};
        p.selectbox_list = {};
        p.age = {};
        p.month = {};
        p.day = {};
        p.sex = {};
    end
end