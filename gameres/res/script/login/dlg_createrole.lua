
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
	
	--开始先随机一次姓名
	p.RandomName();
	p.ChooseCard(ui.ID_CTRL_BUTTON_CARD1);
end

--设置委托
function p.SetDelegate()
	--开始游戏
	local startgame = GetButton( p.layer, ui.ID_CTRL_BUTTON_START_GAME );
	startgame:SetLuaDelegate( p.OnBtnClick );
	
	--随机玩家姓名
	local randName = GetButton( p.layer, ui.ID_CTRL_BUTTON_RAND_NAME );
	randName:SetLuaDelegate( p.OnBtnClick );
	
	for _, tag in pairs(cardTag) do
		local btn = GetButton( p.layer, tag);
		btn:SetLuaDelegate( p.OnBtnClick );
	end
end

--创建角色
function p.CreateRole()
	WriteCon("**创建人物**");
    local uid = GetUID();
    if uid ~= nil and uid > 0 then
		local nameText = GetEdit( p.layer, ui.ID_CTRL_INPUT_TEXT_USER_NAME );
        SendReq("Login","CreateRole", uid, string.format("card_id=%d&name=%s", p.cardID, nameText:GetText()));
	end
end

--随机姓名
function p.RandomName()
	--[[
	local firstName = {"赵","钱","孙","李","周","吴","郑","王"};
	local secondName = {"一","二","三","四","五","六","七","八"};
	
	local name = string.format("%s%s", firstName[math.random(1, #firstName)], secondName[math.random(1, #secondName)]);
	--]]
	local nameText = GetEdit( p.layer, ui.ID_CTRL_INPUT_TEXT_USER_NAME );
	if nameText then
		nameText:SetHorzAlign( 1 );
		nameText:SetVertAlign( 1 );
		nameText:SetText( GetRandomMaleName() );
	end
end

--选择卡牌
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

--按钮响应
function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_START_GAME == tag then
			WriteCon("**=======================开始游戏=======================**");
			p.CreateRole();
		elseif ui.ID_CTRL_BUTTON_RAND_NAME == tag then
			WriteCon("**=======================随机姓名=======================**");
			p.RandomName();
		else
			p.ChooseCard(tag);
		end
	end
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


