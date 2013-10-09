--------------------------------------------------------------
-- FileName: 	dlg_watch_player.lua
-- author:		zjj, 2013/08/30
-- purpose:		�����Ϣ����
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

--ѡ����
p.age = {};
p.month = {};
p.day = {};
p.sex = {};

--�����Ϣ��ȫ����
p.data = nil;
--������Ϣ (�ɱ༭)
p.playdata = {{age=nil},{birthday=nil},{sex=nil},{city=nil},{interest=nil},{sign=nil}};

--ѡ�еı༭��
p.selectedEdit = nil;
--�༭������Ϣ��ť
p.editBtn = nil;


--��ʾUI
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

--�����ʼ��
function p.InitAndShowUI( data )
    
    p.data = data;
    
    --���ڴ����ʾ��ϢLable(������)
    p.lableList = {{age=nil},{birthday=nil} ,{sex=nil},{city=nil},{interest=nil},{sign=nil}};
    --���ڴ�ű༭��ϢEdit
    p.editList = {{age=nil},{birthdayM=nil},{birthdayD=nil},{sex=nil},{city=nil},{interest=nil},{sign=nil}};
    --���ڴ��ѡ���б�
    p.selectbox_list = {{age=nil},{birthdayM=nil},{birthdayD=nil},{sex=nil}};
    p.InitSelectBox();
    
    --��ʼ��ѡ����
    local t = 12;
    for i=1,32 do
        if t < 46 then
             p.age[i] = tostring( t );
             t = t + 1;
        end
    end
    p.sex = { ToUtf8("��"),ToUtf8( "Ů" )};
    for i=1,12 do
        p.month[i] = tostring( i ) .. ToUtf8( "��" );
    end
    for i=1,31 do
        p.day[i] = tostring( i ) .. ToUtf8( "��" );
    end
    -----------------------��ʾ��-----------------------------
    
    --����
    p.lableList.age = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_AGE );
    p.lableList.age:SetText( tostring( data.target_user_status.age ));
    
    --����
    p.lableList.birthday = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_BIRTHDAY );
    p.lableList.birthday:SetText( p.GetBirthday( data.target_user_status.birthday));
    
    --�Ա�
    p.lableList.sex = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_SEX );
    p.lableList.sex:SetText( data.target_user_status.sex);
    
    --����
    p.lableList.city = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_CITY );
    p.lableList.city:SetText( data.target_user_status.city);
    
    --����
    p.lableList.interest = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_INTEREST );
    p.lableList.interest:SetText(data.target_user_status.hobby );
    
    --ǩ��
    p.lableList.sign = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_SIGN );
    p.lableList.sign:SetText( data.target_user_status.tag ); 
    
    ------------------------�༭��---------------------------------
    
    --����
    p.editList.age = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_AGE );
    p.editList.age:SetLuaDelegate(p.OnEditEvent);
    p.editList.age:SetId(1);
    
    --����(��)
    p.editList.birthdayM = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_MONTH );
    p.editList.birthdayM:SetLuaDelegate(p.OnEditEvent);
    p.editList.birthdayM:SetId(1);
    
    --����(��)
    p.editList.birthdayD = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_DAY );
    p.editList.birthdayD:SetLuaDelegate(p.OnEditEvent);
    p.editList.birthdayD:SetId(1);
    
    --�Ա�
    p.editList.sex = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_SEX );
    p.editList.sex:SetLuaDelegate(p.OnEditEvent);
    p.editList.sex:SetId(1);
    
    --����
    p.editList.city = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_CITY );
    
    --����
    p.editList.interest = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_INTEREST );
    
    --ǩ��
    p.editList.sign = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_SIGN );
    
    
    ------------------------����---------------------------------------

    --����
    local titleLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_TITLE );
    
    --ͷ��
    local iconPic = GetImage( p.layer,ui_dlg_watch_player.ID_CTRL_PICTURE_ICON );
    
    --����
    local nameLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_NAME );
    
    --�ȼ�
    local lvLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_LV );
    
    --�������
    local lastLoginLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_LAST_LOGIN_TIME );
    
    --������
    local friendNumLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_FIREND_NUM );
    
    --�༭������Ϣ��ť
    p.editBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_EDIT_INFO);
    p.editBtn:SetId(1);
    
    --������Ѱ�ť
    local applyBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_APPLY);
    
    --�������찴ť
    local chatBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_CHAT);
    
    
    --����ҳ������
	if p.intent == SELF_INFO then
	   titleLab:SetText( ToUtf8("������Ϣ����")); --���ñ���
	   p.editBtn:SetLuaDelegate(p.OnWatchPlayerUIEvent);
       --���ذ�ť
	   applyBtn:SetVisible( false );
	   chatBtn:SetVisible( false );
	end
	
	local backBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_BACK);
    backBtn:SetLuaDelegate(p.OnWatchPlayerUIEvent);
    p.HideSelectBox();
	--��ʼ��Ĭ�����ر༭��
	p.SetEditVisible( false);
end

--��ʼ��ѡ����б�
function p.InitSelectBox()
    --����
    p.selectbox_list.age = GetListBoxVert(p.layer ,ui_dlg_watch_player.ID_CTRL_VERTICAL_LIST_AGE);
    
    --��
    p.selectbox_list.birthdayM = GetListBoxVert(p.layer ,ui_dlg_watch_player.ID_CTRL_VERTICAL_LIST_MON);
    
    --��
    p.selectbox_list.birthdayD = GetListBoxVert(p.layer ,ui_dlg_watch_player.ID_CTRL_VERTICAL_LIST_DAY);
    
    --�Ա�
    p.selectbox_list.sex = GetListBoxVert(p.layer ,ui_dlg_watch_player.ID_CTRL_VERTICAL_LIST_SEX);
    
end

--���ñ༭Ⱥ��ʾ����
function p.SetEditVisible( bEnable )
    p.editList.age:SetVisible( bEnable );
    p.editList.birthdayM:SetVisible( bEnable );
    p.editList.birthdayD:SetVisible( bEnable );
    p.editList.sex:SetVisible( bEnable );
    p.editList.city:SetVisible( bEnable );
    p.editList.interest:SetVisible( bEnable );
    p.editList.sign:SetVisible( bEnable );
end

--������ʾȺ��ʾ����
function p.SetLableVisible( bEnable )
    p.lableList.age:SetVisible( bEnable );
    p.lableList.birthday:SetVisible( bEnable );
    p.lableList.sex:SetVisible( bEnable );
    p.lableList.city:SetVisible( bEnable );
    p.lableList.interest:SetVisible( bEnable );
    p.lableList.sign:SetVisible( bEnable );
end

--�༭���¼�����
function p.OnEditEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
       if ( ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_SEX == tag) then  --ѡ���Ա�
            if uiNode:GetId() == 1 then  --��ʾ�б�
                p.selectedEdit = ConverToEdit(uiNode);
                p.HideSelectBox();
                p.SetandShowSelectBox( BOX_SEX );
                uiNode:SetId( 2 );
            else                         --����
                p.HideSelectBox();
            end
       elseif (ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_AGE == tag) then --ѡ������
            if uiNode:GetId() == 1 then  --��ʾ�б�
                p.selectedEdit = ConverToEdit(uiNode);
                p.HideSelectBox();
                p.SetandShowSelectBox( BOX_AGE );
                uiNode:SetId( 2 );
            else                         --����
                p.HideSelectBox();
            end
       elseif (ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_MONTH == tag) then --ѡ����
            if uiNode:GetId() == 1 then  --��ʾ�б�
                p.selectedEdit = ConverToEdit(uiNode);
                p.HideSelectBox();
                p.SetandShowSelectBox( BOX_MONTH );
                uiNode:SetId( 2 );
            else                         --����
                p.HideSelectBox();
            end
        elseif (ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_DAY == tag) then --ѡ����
            if uiNode:GetId() == 1 then  --��ʾ�б�
                p.selectedEdit = ConverToEdit(uiNode);
                p.HideSelectBox();
                p.SetandShowSelectBox( BOX_DAY );
                uiNode:SetId( 2 );
            else                         --����
                p.HideSelectBox();
            end
       end
    end
end

--����ѡ���б�
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

--ѡ���б��÷���
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

--ѡ���ѡ���¼�
function p.OnViewEvent(uiNode, uiEventType, param)
    local view = ConverToView(uiNode);
    if IsClickEvent(uiEventType) then
       local lab = GetLabel( view, ui_combox_view.ID_CTRL_TEXT_OPTION );
       p.selectedEdit:SetText( lab:GetText() );
       p.HideSelectBox();
       p.selectedEdit = nil;
    end 
end

--�¼�����
function p.OnWatchPlayerUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
       if ( ui_dlg_watch_player.ID_CTRL_BUTTON_EDIT_INFO == tag ) then  --�༭������Ϣ
            if uiNode:GetId() == 1 then  --����༭
                p.SetEditVisible( true );
                p.SetLableVisible( false );
                uiNode:SetId(2);
                p.editBtn:SetText( ToUtf8( "ȷ���༭" ));
            else                         --������ʾ
                p.SetEditVisible( false );
                p.SetLableVisible( true );
                uiNode:SetId(1);
                p.HideSelectBox();
                p.GetEditInfo();
                p.ShowEditInfo();
                p.editBtn:SetText( ToUtf8( "�༭������Ϣ" ));
            end
       elseif ( ui_dlg_watch_player.ID_CTRL_BUTTON_BACK == tag ) then
            p.CloseUI();
       end
	end
end

--����޸ĺ���Ϣ
function p.GetEditInfo()
	p.playdata.age = p.editList.age:GetText();
	p.playdata.sex = p.editList.sex:GetText();
	p.playdata.city = p.editList.city:GetText();
	p.playdata.interest = p.editList.interest:GetText();
	p.playdata.sign = p.editList.sign:GetText();
end

--��ʾ��ң��ɱ༭����Ϣ
function p.ShowEditInfo()
	p.lableList.age:SetText(p.playdata.age)
    p.lableList.sex:SetText(p.playdata.sex)
    p.lableList.city:SetText(p.playdata.city)
    p.lableList.interest:SetText(p.playdata.interest)
    p.lableList.sign:SetText(p.playdata.sign)
end

--��ȡ�����Ϣ
function p.GetUesrInfo()
	WriteCon("**���������Ϣ**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("User","GetUserProfile",uid,"");
end

--��������
function p.GetBirthday( birStr )
	local t = Split( birStr , " ");
	local k = Split( t[1] , "-" );
	return k[2] .. ToUtf8( "��" ) .. k[3] .. ToUtf8( "��" );
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