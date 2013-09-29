--------------------------------------------------------------
-- FileName: 	dlg_watch_player.lua
-- author:		zjj, 2013/08/30
-- purpose:		�����Ϣ����
--------------------------------------------------------------

dlg_watch_player = {}
local p = dlg_watch_player;

p.layer = nil;
p.intent = nil;

p.SELF_INFO   = 1;
p.PLAYER_INFO = 2;

local BOX_AGE     = 1;
local BOX_MONTH   = 2;
local BOX_DAY     = 3;

p.lableList = {};
p.editList = {};
p.selectbox_list = {};

--ѡ����
p.age = {};
p.month = {};
p.day = {};

--�����Ϣ��ȫ����
p.data = nil;
--������Ϣ (�ɱ༭)
p.playdata = {{age=nil},{birthday=nil},{gender=nil},{city=nil},{interest=nil},{sign=nil}};

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
	p.GetUesrInfo();
	--p.InitAndShowUI();
	
end

function p.InitData( data )
	p.data = data;
    p.playdata.age = data.target_user_status.age;
    p.playdata.birthday = data.target_user_status.birthday;
    p.playdata.city = data.target_user_status.city;
    p.playdata.interest = data.target_user_status.hobby;
    p.playdata.sign = data.target_user_status.tag;
    
    --���ڴ����ʾ��ϢLable(������)
    p.lableList = {{age=nil},{birthday=nil} ,{gender=nil},{city=nil},{interest=nil},{sign=nil}};
    --���ڴ�ű༭��ϢEdit
    p.editList = {{age=nil},{birthdayM=nil},{birthdayD=nil},{gender=nil},{city=nil},{interest=nil},{sign=nil}};
    --���ڴ��ѡ���б�
    p.selectbox_list = {{age=nil},{birthdayM=nil},{birthdayD=nil}};
    p.InitSelectBox();
    
    --��ʼ��ѡ����
    local t = 12;
    for i=1,32 do
        if t < 46 then
             p.age[i] = tostring( t );
             t = t + 1;
        end
    end
    for i=1,12 do
        p.month[i] = tostring( i ) .. GetStr( "month" );
    end
    for i=1,31 do
        p.day[i] = tostring( i ) .. GetStr( "day" );
    end
    
    p.InitAndShowUI( data );
end
--�����ʼ��
function p.InitAndShowUI( data )
    
    -----------------------��ʾ��-----------------------------
    
    --����
    p.lableList.age = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_AGE );
    p.lableList.age:SetText( tostring( p.playdata.age ));
    
    --����
    p.lableList.birthday = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_BIRTHDAY );
    p.lableList.birthday:SetText( p.GetBirthday( p.playdata.birthday ));
    
    --�Ա�
    p.lableList.gender = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_SEX );
    WriteCon(  "xinbie ******" .. data.target_user_status.gender  );
    p.lableList.gender:SetText( p.GetSexText( data.target_user_status.gender ));
    
    --����
    p.lableList.city = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_CITY );
    p.lableList.city:SetText( p.playdata.city);
   
    
    --����
    p.lableList.interest = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_INTEREST );
    p.lableList.interest:SetText(  p.playdata.interest );
    
     
    --ǩ��
    p.lableList.sign = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_SIGN );
    p.lableList.sign:SetText( p.playdata.sign ); 
    
    ------------------------�༭��---------------------------------
    
    --����
    p.editList.age = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_AGE );
    p.editList.age:SetLuaDelegate(p.OnEditEvent);
    p.editList.age:SetId(1);
    p.editList.age:SetText( p.playdata.age );
    
    --����(��)
    p.editList.birthdayM = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_MONTH );
    p.editList.birthdayM:SetLuaDelegate(p.OnEditEvent);
    p.editList.birthdayM:SetId(1);
    p.editList.birthdayM:SetText( p.GetBrithdayForMorD( p.playdata.birthday , BOX_MONTH) .. GetStr( "month" ));
    
    --����(��)
    p.editList.birthdayD = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_DAY );
    p.editList.birthdayD:SetLuaDelegate(p.OnEditEvent);
    p.editList.birthdayD:SetId(1);
    p.editList.birthdayD:SetText( p.GetBrithdayForMorD( p.playdata.birthday , BOX_DAY) .. GetStr( "day" ));
    
    --����
    p.editList.city = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_CITY );
    p.editList.city:SetText( p.playdata.city );
    
    --����
    p.editList.interest = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_INTEREST );
    p.editList.interest:SetText( p.playdata.interest );
    
    --ǩ��
    p.editList.sign = GetEdit( p.layer, ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_SIGN );
    p.editList.sign:SetText( p.playdata.sign );
    
    
    ------------------------����---------------------------------------

    --����
    local titleLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_TITLE );
    
    --ͷ��
    local iconPic = GetImage( p.layer,ui_dlg_watch_player.ID_CTRL_PICTURE_ICON );
    
    --����
    local nameLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_NAME );
    nameLab:SetText( tostring( data.target_user_status.user_name ));
    
    --�ȼ�
    local lvLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_LV );
    lvLab:SetText( tostring( data.target_user_status.level ));
    
    --�������
    local lastLoginLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_LAST_LOGIN_TIME );
    local date = Split(tostring( data.target_user_status.last_login_time ), " ");
    lastLoginLab:SetText( date[1]); 
    
    --������
    local friendNumLab = GetLabel( p.layer, ui_dlg_watch_player.ID_CTRL_TEXT_FIREND_NUM );
    
    --�༭������Ϣ��ť
    p.editBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_EDIT_INFO);
    p.editBtn:SetId(1);
    
    --������Ѱ�ť
    local applyBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_APPLY);
    applyBtn:SetVisible( false );
    
    --�������찴ť
    local chatBtn = GetButton(p.layer,ui_dlg_watch_player.ID_CTRL_BUTTON_CHAT);
    chatBtn:SetVisible( false );
    
    --����ҳ������
	if p.intent == p.SELF_INFO then
	   titleLab:SetText( ToUtf8("������Ϣ����")); --���ñ���
	   p.editBtn:SetLuaDelegate(p.OnWatchPlayerUIEvent);

	   
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
    
end

--���ñ༭Ⱥ��ʾ����
function p.SetEditVisible( bEnable )
    p.editList.age:SetVisible( bEnable );
    p.editList.birthdayM:SetVisible( bEnable );
    p.editList.birthdayD:SetVisible( bEnable );
    p.editList.city:SetVisible( bEnable );
    p.editList.interest:SetVisible( bEnable );
    p.editList.sign:SetVisible( bEnable );
end

--������ʾȺ��ʾ����
function p.SetLableVisible( bEnable )
    p.lableList.age:SetVisible( bEnable );
    p.lableList.birthday:SetVisible( bEnable );
    p.lableList.city:SetVisible( bEnable );
    p.lableList.interest:SetVisible( bEnable );
    p.lableList.sign:SetVisible( bEnable );
end

--�༭���¼�����
function p.OnEditEvent(uiNode, uiEventType, param)
    local tag = uiNode:GetTag();
    if IsClickEvent( uiEventType ) then
       if ( ui_dlg_watch_player.ID_CTRL_INPUT_BUTTON_SEX == tag) then  

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
            
        elseif (ui_dlg_watch_player.ID_CTRL_BUTTON_BACK == tag) then --����
                p.CloseUI();
       end
    end
end

--����ѡ���б�
function p.HideSelectBox()
    p.selectbox_list.age:SetVisible( false );
    p.selectbox_list.birthdayM:SetVisible( false );
    p.selectbox_list.birthdayD:SetVisible( false );

    p.editList.age:SetId( 1 );
    p.editList.birthdayM:SetId( 1 );
    p.editList.birthdayD:SetId( 1 );
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
                p.editBtn:SetText( GetStr( "make_sure_edit" ));
            else                         --������ʾ
                p.SetEditVisible( false );
                p.SetLableVisible( true );
                uiNode:SetId(1);
                p.HideSelectBox();
                p.GetEditInfo();
                p.ReqEditUserInfo();
                
            end
       elseif ( ui_dlg_watch_player.ID_CTRL_BUTTON_BACK == tag ) then
            p.CloseUI();
       end
	end
end

--�޸ĳɹ��ص�����
function p.ForEditSuccess()
	p.ShowEditInfo();
    p.editBtn:SetText( GetStr( "edit_personal_info" ));
end

--����޸ĺ���Ϣ
function p.GetEditInfo()
	p.playdata.age = p.editList.age:GetText();
	p.playdata.city = p.editList.city:GetText();
	p.playdata.interest = p.editList.interest:GetText();
	p.playdata.sign = p.editList.sign:GetText();
    p.playdata.birthday = p.GetEditedBirthday();
    WriteCon( p.GetEditedBirthday() );
	
end

--����޸ĺ��������Ϣ
function p.GetEditedBirthday()
	local birStr = p.editList.birthdayM:GetText()..p.editList.birthdayD:GetText();
    
    local temp = Split(birStr , GetStr( "month" ));
    local month = temp[1];
    temp = Split( temp[2] , GetStr( "day" ));
    local day = temp[1];
    
    return string.format("1900-%s-%s 00:00:00", month, day);
end


--��ʾ��ң��ɱ༭����Ϣ
function p.ShowEditInfo()
	p.lableList.age:SetText(p.playdata.age)
    p.lableList.city:SetText(p.playdata.city)
    p.lableList.interest:SetText(p.playdata.interest)
    p.lableList.sign:SetText(p.playdata.sign)
    p.lableList.birthday:SetText( p.GetBirthday( p.playdata.birthday ));
end

--��ȡ�����Ϣ
function p.GetUesrInfo()
	WriteCon("**���������Ϣ**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    SendReq("User","GetUserProfile",uid,"");
end

--�޸������Ϣ
function p.ReqEditUserInfo()
	WriteCon("**�޸ĸ�����Ϣ**");
    local uid = GetUID();
    if uid == 0 then uid = 100 end; 
    local param ="&age="..p.playdata.age.."&city="..p.playdata.city.."&hobby="..p.playdata.interest.."&tag="..p.playdata.sign.."&birthday="..p.playdata.birthday;
    WriteCon( "--"..param );   
    SendReq("User","SaveUserProfile",uid,param);
end
--��������
function p.GetBirthday( birStr )
	local t = Split( birStr , " ");
	local k = Split( t[1] , "-" );
	return k[2] .. GetStr( "month" ) .. k[3] .. GetStr( "day" );
end

--��ȡ����
function p.GetBrithdayForMorD(birStr , category)
    local temp = Split( birStr , " ");
    temp = Split(temp[1], "-")
    WriteCon( "---" ..  temp[2] .. temp[3]);
	if category == BOX_MONTH then
	   return temp[2];
	elseif category == BOX_DAY then
	   return temp[3];
	end
end

--�ж��Ա�
function p.GetSexText( sex )
    if sex == "0" then
        return GetStr( "woman" );
    else 
        return GetStr( "man" );
    end
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
    end
end