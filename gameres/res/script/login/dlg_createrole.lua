dlg_createrole = {};
local p = dlg_createrole;
local ui = ui_createrole;

p.layer = nil;
p.gender = 0;

function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible(true);
		PlayMusic_LoginUI();
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
	
	p.RandomName();

	p.SetDelegate();
	PlayMusic_LoginUI();
end

function p.SetDelegate()
	--开始游戏
	local startgame = GetButton( p.layer, ui.ID_CTRL_BUTTON_START_GAME );
	startgame:SetLuaDelegate( p.OnBtnClick );

	--随机玩家姓名
	local randName = GetButton( p.layer, ui.ID_CTRL_BUTTON_RAND_NAME );
	randName:SetLuaDelegate( p.OnBtnClick );
	
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_START_GAME == tag then
			WriteCon("**==start game==**");
			p.CreateRole();
		elseif ui.ID_CTRL_BUTTON_RAND_NAME == tag then
			WriteCon("**====RAND_NAME=======**");
			p.RandomName();
		end
	end
end

--创建角色
function p.CreateRole()
	WriteCon("**创建人物**");
    local uid = GetUID();
    if uid ~= nil and uid > 0 then
		local nameText = GetEdit( p.layer, ui.ID_CTRL_INPUT_TEXT_USER_NAME );
		--SendReq("Login", "CreateRole", uid, string.format( "&name=%s&sex=%d&face_id=%d", nameText:GetText(), p.gender, p.faceID ) );
		SendReq("Login", "CreateRole", uid, string.format( "&name=%s", nameText:GetText() ) );
	end
end

--随机姓名
function p.RandomName()
	--开始先随机一次姓名
	p.RadomGender()
	local nameText = GetEdit( p.layer, ui.ID_CTRL_INPUT_TEXT_USER_NAME );
	if nameText then
		nameText:SetHorzAlign( 1 );
		nameText:SetVertAlign( 1 );
		local name = p.gender == 0 and GetRandomMaleName() or GetRandomFemaleName()
		nameText:SetText( name );
	end
end

--随机一个性别
function p.RadomGender()
	p.gender = math.random(0,1)
	if p.gender >= 0.5 then 
		p.gender = 1
	else 
		p.gender = 0
	end
	WriteCon("**==gender ="..(p.gender));
end

--关闭UI
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
