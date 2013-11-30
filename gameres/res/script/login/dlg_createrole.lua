
dlg_createrole = {};
local p = dlg_createrole;

local ui = ui_createrole;

p.faceID = nil;
p.gender = 0;
p.layer = nil;
p.selectGender = nil;
p.selectFace = nil;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible(true);
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
	LoadUI("createrole.xui", layer, nil);
	
	p.layer = layer;
	
	--��ʼ�����һ������
	p.RandomName();

	p.SetDelegate();
end

--����ί��
function p.SetDelegate()
	p.selectGender = GetImage( p.layer, ui.ID_CTRL_PICTURE_SELECT1);
	p.selectFace = GetImage( p.layer, ui.ID_CTRL_PICTURE_SELECT2);
	
	--��ʼ��Ϸ
	local startgame = GetButton( p.layer, ui.ID_CTRL_BUTTON_START_GAME );
	startgame:SetLuaDelegate( p.OnBtnClick );
	
	--����������
	local randName = GetButton( p.layer, ui.ID_CTRL_BUTTON_RAND_NAME );
	randName:SetLuaDelegate( p.OnBtnClick );
	
	--ͷ��ѡ��
	local face1 = GetButton( p.layer, ui.ID_CTRL_BUTTON_FACE1 );
	face1:SetLuaDelegate( p.OnBtnClick );
	p.ChooseFace( face1, 1);
	
	local face2 = GetButton( p.layer, ui.ID_CTRL_BUTTON_FACE2 );
	face2:SetLuaDelegate( p.OnBtnClick );
	
	local face3 = GetButton( p.layer, ui.ID_CTRL_BUTTON_FACE3 );
	face3:SetLuaDelegate( p.OnBtnClick );
	
	--�Ա�ѡ��
	local male = GetButton( p.layer, ui.ID_CTRL_BUTTON_MALE );
	male:SetLuaDelegate( p.OnBtnClick );
	
	local female = GetButton( p.layer, ui.ID_CTRL_BUTTON_FEMALE );
	female:SetLuaDelegate( p.OnBtnClick );
	
	p.RefreshFacePic();
end

--������ɫ
function p.CreateRole()
	WriteCon("**��������**");
    local uid = GetUID();
    if uid ~= nil and uid > 0 then
		local nameText = GetEdit( p.layer, ui.ID_CTRL_INPUT_TEXT_USER_NAME );
		SendReq("Login", "CreateRole", uid, string.format( "&name=%s&gender=%d&face_id=%d", nameText:GetText(), p.gender, p.faceID ) );
	end
end

--�������
function p.RandomName()
	local nameText = GetEdit( p.layer, ui.ID_CTRL_INPUT_TEXT_USER_NAME );
	if nameText then
		nameText:SetHorzAlign( 1 );
		nameText:SetVertAlign( 1 );
		local name = p.gender == 0 and GetRandomMaleName() or GetRandomFemaleName()
		nameText:SetText( name );
	end
end

--ѡ���Ա�
function p.ChooseGender( uiNode, gender )
	if gender == p.gender then
		return;
	end
	
	p.gender = gender;

	if p.selectGender then
		local pos = uiNode:GetFramePos();
		p.selectGender:SetFramePosXY( pos.x-2, pos.y-2 );
	end
	
	p.RefreshFacePic();
end

--ѡ��ͷ��
function p.ChooseFace( uiNode,index )
	p.faceID = index*10+p.gender;
	
	if p.selectFace then
		local pos = uiNode:GetFramePos();
		p.selectFace:SetFramePosXY( pos.x-2, pos.y-2 );
	end
end

--����ͷ��ͼƬ
function p.RefreshFacePic()
	local face1 = GetButton( p.layer, ui.ID_CTRL_BUTTON_FACE1 );
	local face2 = GetButton( p.layer, ui.ID_CTRL_BUTTON_FACE2 );
	local face3 = GetButton( p.layer, ui.ID_CTRL_BUTTON_FACE3 );
	
	face1:SetImage( GetPictureByAni( string.format("UserImage.Face%d", 10 + p.gender), 0 ));
	face2:SetImage( GetPictureByAni( string.format("UserImage.Face%d", 20 + p.gender), 0 ));
	face3:SetImage( GetPictureByAni( string.format("UserImage.Face%d", 30 + p.gender), 0 ));
	
	face1:SetTouchDownImage( GetPictureByAni( string.format("UserImage.Face%d", 10 + p.gender), 0 ));
	face2:SetTouchDownImage( GetPictureByAni( string.format("UserImage.Face%d", 20 + p.gender), 0 ));
	face3:SetTouchDownImage( GetPictureByAni( string.format("UserImage.Face%d", 30 + p.gender), 0 ));
	
	face1:SetDisabledImage( GetPictureByAni( string.format("UserImage.Face%d", 10 + p.gender), 0 ));
	face2:SetDisabledImage( GetPictureByAni( string.format("UserImage.Face%d", 20 + p.gender), 0 ));
	face3:SetDisabledImage( GetPictureByAni( string.format("UserImage.Face%d", 30 + p.gender), 0 ));
end

--��ť��Ӧ
function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_START_GAME == tag then
			WriteCon("**=======================��ʼ��Ϸ=======================**");
			p.CreateRole();
		elseif ui.ID_CTRL_BUTTON_RAND_NAME == tag then
			WriteCon("**=======================�������=======================**");
			p.RandomName();
		elseif ui.ID_CTRL_BUTTON_FACE1 == tag then
			WriteCon("**=======================01��ͷ��=======================**");
			p.ChooseFace( uiNode, 1 );
		elseif ui.ID_CTRL_BUTTON_FACE2 == tag then
			WriteCon("**=======================02��ͷ��=======================**");
			p.ChooseFace( uiNode, 2 );
		elseif ui.ID_CTRL_BUTTON_FACE3 == tag then
			WriteCon("**=======================03��ͷ��=======================**");
			p.ChooseFace( uiNode, 3 );
		elseif ui.ID_CTRL_BUTTON_MALE == tag then
			WriteCon("**=========================����=========================**");
			p.ChooseGender( uiNode, 0 )
		elseif ui.ID_CTRL_BUTTON_FEMALE == tag then
			WriteCon("**=========================Ů��=========================**");
			p.ChooseGender( uiNode, 1 )
		end
	end
end

--�ر�UI
function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end


