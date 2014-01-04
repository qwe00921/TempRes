--------------------------------------------------------------
-- FileName:    dlg_beast_main.lua
-- author:      crj,2013/11/12
-- purpose:     �ٻ���������
--------------------------------------------------------------

dlg_beast_main = {};
local p = dlg_beast_main;

p.layer = nil;

local ui = ui_beast_mainui;

p.groupFlag = false;
p.mainUIFlag = false;

--��ʾUI
function p.ShowUI( bgroupFlag , mainUIFlag )
	if bgroupFlag ~= nil then
		p.groupFlag = bgroupFlag;
	else
		dlg_menu.SetNewUI( p );
	end
	
	if mainUIFlag ~= nil then
		p.mainUIFlag = mainUIFlag;
		dlg_menu.SetNewUI( p );
	end
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
	
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end

	layer:NoMask();
    layer:Init();
	layer:SetSwallowTouch(false);
	
    GetUIRoot():AddDlg( layer );
    LoadDlg ("beast_mainui.xui" , layer , nil );

	p.layer = layer;
    p.SetDelegate();
	
    --��������
    beast_mgr.LoadData( p.layer );
end

--����ί��
function p.SetDelegate()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_BACK);
	btn:SetLuaDelegate( p.OnBtnClick );
end

--��ť����
function p.OnBtnClick( uiNode, uiEventType, param )
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ui.ID_CTRL_BUTTON_BACK == tag then
			--�˳�UI
			p.CloseUI();
			beast_mgr.ClearData();
			maininterface.BecomeFirstUI();
		end
	end
end

function p.RefreshUI( source )
	local numLabel = GetLabel( p.layer, ui.ID_CTRL_TEXT_NUM );
	if numLabel then
		local num = 0;
		if source.pet and type(source.pet) == "table" then
			num = table.getn( source.pet );
		end
		numLabel:SetText( string.format("%d/%d", num , source.pet_bag or 0 ) );
	end
	
	p.ShowBeastList( source.pet );
end

--��ʾ�ٻ����б�
function p.ShowBeastList( petList )
	local list = GetListBoxVert( p.layer ,ui_beast_mainui.ID_CTRL_VERTICAL_LIST_7);
    list:ClearView();
    
    if petList == nil or #petList <= 0 then
        WriteCon("ShowBeastList():petList is null");
        return ;
    end
	
	local lenth = #petList;

	for i = 1, lenth do
		local view = createNDUIXView();
        view:Init();
		
		if p.groupFlag then
			LoadUI( "card_group_select_pet.xui", view, nil );
			local bg = GetUiNode( view, ui_card_group_select_pet.ID_CTRL_PICTURE_LISTBG );
			view:SetViewSize( bg:GetFrameSize());
			
			view:SetLuaDelegate( p.OnViewClick );
			p.ShowSelectPetInfo( view, petList[i]);
		else
			LoadUI( "beast_main_list.xui", view, nil );
			local bg = GetUiNode( view, ui_beast_main_list.ID_CTRL_PICTURE_LISTBG );
			view:SetViewSize( bg:GetFrameSize());

			p.ShowBeastInfo( view, petList[i] );
		end
		
		list:AddView( view );
	end
end

--���ÿ�ѡ�ٻ��޵�����ͼ
function p.ShowSelectPetInfo(  view, pet )
	if view == nil or pet == nil then
		WriteCon("data error");
		return;
	end
	
	view:SetId( pet.id );
	
	local spLabel = GetLabel( view, ui_card_group_select_pet.ID_CTRL_TEXT_22 );
	if spLabel then
		spLabel:SetText( tostring(pet.Sp));
	end
	
	local atkLabel = GetLabel( view, ui_card_group_select_pet.ID_CTRL_TEXT_ATTACK2 );
	if atkLabel then
		atkLabel:SetText( tostring(pet.Atk) );
	end
	
	local levLabel = GetLabel( view, ui_card_group_select_pet.ID_CTRL_TEXT_12 );
	if levLabel then
		levLabel:SetText( string.format("Lv %d", pet.Level) );
	end
	
	--������ʾ������type��csv����
	local pet_type = pet.Pet_id;
	local nameLabel = GetLabel( view, ui_card_group_select_pet.ID_CTRL_TEXT_14 );
	if nameLabel then
		nameLabel:SetText( SelectRowInner( T_PET, "id", tostring( pet_type ), "name" ) );
	end
	
	--������ʾ
	local skillPic = GetImage( view, ui_card_group_select_pet.ID_CTRL_PICTURE_SKILL );
	local skillText = GetLabel( view, ui_card_group_select_pet.ID_CTRL_TEXT_51 );
	
	if tonumber(pet.Skill_id) ~= 0 then 
		local skillPicData = GetPictureByAni( SelectCell( T_SKILL_RES, pet.Skill_id, "icon" ), 0 );
		if skillPic and skillPicData then
			skillPic:SetPicture( skillPicData );
		end
		skillText:SetText( SelectCell( T_SKILL, pet.Skill_id, "Description" ) );
	else
		skillPic:SetVisible( false );
		skillText:SetVisible( false );
	end
	
	local face = GetImage( view, ui_card_group_select_pet.ID_CTRL_PICTURE_21 );

	local faceData = GetPictureByAni( SelectCell( T_PET_RES, pet.Pet_id, "face_pic" ) ,0 );
	if face and faceData then
		face:SetPicture( faceData );
	end

	for i = 1, 3 do
		local pic = GetImage( view, ui_card_group_select_pet["ID_CTRL_PICTURE_TEAM"..i] );
		if pic then
			pic:SetVisible( pet.Team_id == i );
		end
	end
	
	local attrLabel = GetLabel( view, ui_card_group_select_pet.ID_CTRL_TEXT_ELEMENT );
	--local attrLaImg = GetImage( view, ui_card_group_select_pet.ID_CTRL_PICTURE_ELEMENT );
	attrLabel:SetText( tonumber(SelectCell( T_PET, pet.Pet_id, "pet_type" )) == 1 and ToUtf8("������") or ToUtf8("������") );
end

--���õ����ٻ�����ͼ
function p.ShowBeastInfo( view, pet )
	if view == nil or pet == nil then
		WriteCon("data error");
		return;
	end
	
	view:SetId( pet.id );
	
	local levLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_28 );
	if levLabel then
		levLabel:SetText( string.format("Lv %d", pet.Level) );
	end

	local spLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_22 );
	if spLabel then
		spLabel:SetText( tostring(pet.Sp));
	end
	
	local atkLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_ATTACK2 );
	if atkLabel then
		atkLabel:SetText( tostring(pet.Atk) );
	end
	
	--������ʾ������type��csv����
	local pet_type = pet.Pet_id;
	local nameLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_14 );
	if nameLabel then
		nameLabel:SetText( SelectRowInner( T_PET, "id", tostring( pet_type ), "name" ) );
	end

	--������ť
	local trainBtn = GetButton( view, ui_beast_main_list.ID_CTRL_BUTTON_INCUBATE );
	trainBtn:SetLuaDelegate( p.OnListBtnClick );
	trainBtn:SetVisible( false );

	local sellBtn = GetButton( view, ui_beast_main_list.ID_CTRL_BUTTON_SELL );
	sellBtn:SetLuaDelegate( p.OnListBtnClick );
	--sellBtn:SetVisible( false );
	
	local pic = GetImage( view, ui_beast_main_list.ID_CTRL_PICTURE_BEAST );
	local picData = GetPictureByAni( SelectCell( T_PET_RES, pet_type , "face_pic" ), 0 );
	if picData then
		pic:SetPicture( picData );
	end
	
	--������ʾ
	local skillPic = GetImage( view, ui_beast_main_list.ID_CTRL_PICTURE_SKILL );
	local skillText = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_51 );
	if tonumber(pet.Skill_id) ~= 0 then
		local skillPicData = GetPictureByAni( SelectCell( T_SKILL_RES, pet.Skill_id, "icon" ), 0 );
		if skillPic and skillPicData then
			skillPic:SetPicture( skillPicData );
		end

		skillText:SetText( SelectCell( T_SKILL, pet.Skill_id, "Description" ) );
	else
		skillPic:SetVisible( false );
		skillText:SetVisible( false );
	end
	
	for i = 1, 3 do
		local pic = GetImage( view, ui_beast_main_list["ID_CTRL_PICTURE_TEAM"..i] );
		if pic then
			pic:SetVisible( pet.Team_id == i );
		end
	end

	local attrLabel = GetLabel( view, ui_beast_main_list.ID_CTRL_TEXT_69 );
	attrLabel:SetText( tonumber(SelectCell( T_PET, pet.Pet_id, "pet_type" )) == 1 and ToUtf8("������") or ToUtf8("������") );
end

--�ٻ����б����Ӱ�ť�ص�
function p.OnListBtnClick( uiNode, uiEventType, param )
	local node = uiNode:GetParent();
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
		if ui_beast_main_list.ID_CTRL_BUTTON_INCUBATE == tag then
			WriteCon("**===============��ʾ����===============**");
			--��ʾ�������棬����ͨ��node:GetId()����ȡ��Ҫ��ʾ��һ���ٻ��޵���������
			dlg_beast_train.ShowUI( node:GetId() );
			
		elseif ui_beast_main_list.ID_CTRL_BUTTON_SELL == tag then
			WriteCon("**=================����=================**");
			
			--beast_mgr.SetFight( node );
			beast_mgr.SellPet( node );
		end
	end
end

--����༭���ڵ�ѡ��
function p.OnViewClick( uiNode, uiEventType, param )
	if p.mainUIFlag then
--		dlg_battlearray.UpdatePosCard( uiNode:GetId() );
	else
		p.CloseUI();
		beast_mgr.ClearData();

		dlg_card_group_main.UpdatePosCard( uiNode:GetId() );
	end
end

--ˢ�³�ս��ť
function p.SetFightBtnCheck( node, flag )
	if node == nil then
		return;
	end	
	
	--��ս��ť
	local fightBtn = GetButton( node, ui_beast_main_list.ID_CTRL_BUTTON_FIGHT );
	if fightBtn then
		fightBtn:SetChecked( flag );
		
		local str = flag and "��Ϣ" or "��ս";
		fightBtn:SetText( ToUtf8( str ) );
	end
end

--����UI
function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.groupFlag = false;
	end
end

function p.UIDisappear()
	dlg_beast_train.CloseUI();
	p.CloseUI();
end

