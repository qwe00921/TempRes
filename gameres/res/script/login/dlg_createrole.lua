
dlg_createrole = {};
local p = dlg_createrole;

local ui = ui_createrole;
local cardTag = {
	ui.ID_CTRL_BUTTON_CARD1,
	ui.ID_CTRL_BUTTON_CARD2,
	ui.ID_CTRL_BUTTON_CARD3,
	ui.ID_CTRL_BUTTON_CARD4,
};

p.cardID = nil;
p.layer = nil;

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

	p.SetDelegate();
	
	--��ʼ�����һ������
	p.RandomName();
	p.ChooseCard(ui.ID_CTRL_BUTTON_CARD1);
end

--����ί��
function p.SetDelegate()
	--��ʼ��Ϸ
	local startgame = GetButton( p.layer, ui.ID_CTRL_BUTTON_START_GAME );
	startgame:SetLuaDelegate( p.OnBtnClick );
	
	--����������
	local randName = GetButton( p.layer, ui.ID_CTRL_BUTTON_RAND_NAME );
	randName:SetLuaDelegate( p.OnBtnClick );
	
	for _, tag in pairs(cardTag) do
		local btn = GetButton( p.layer, tag);
		btn:SetLuaDelegate( p.OnBtnClick );
	end
end

--������ɫ
function p.CreateRole()
	WriteCon("**��������**");
    local uid = GetUID();
    if uid ~= nil and uid > 0 then
		local nameText = GetEdit( p.layer, ui.ID_CTRL_INPUT_TEXT_USER_NAME );
        SendReq("Login","CreateRole", uid, string.format("card_id=%d&name=%s", p.cardID, nameText:GetText()));
	end
end

--�������
function p.RandomName()
	--[[
	local firstName = {"��","Ǯ","��","��","��","��","֣","��"};
	local secondName = {"һ","��","��","��","��","��","��","��"};
	
	local name = string.format("%s%s", firstName[math.random(1, #firstName)], secondName[math.random(1, #secondName)]);
	--]]
	local nameText = GetEdit( p.layer, ui.ID_CTRL_INPUT_TEXT_USER_NAME );
	if nameText then
		nameText:SetHorzAlign( 1 );
		nameText:SetVertAlign( 1 );
		nameText:SetText( GetRandomMaleName() );
	end
end

--ѡ����
function p.ChooseCard(tag)
	local index = 1;
	for i, btnTag in pairs(cardTag) do
		local btn = GetButton( p.layer, btnTag);
		btn:SetChecked( btnTag == tag );
		if btnTag == tag then
			index = i;
		end
	end
	
	local petName = GetLabel( p.layer, ui.ID_CTRL_TEXT_PET_NAME );
	if petName then
		petName:SetText( string.format("cardTag:%d", tag) );
	end
	
	p.cardID = 100 + index;
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
		else
			p.ChooseCard(tag);
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


