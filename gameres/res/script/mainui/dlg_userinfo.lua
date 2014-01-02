
dlg_userinfo = {}
local p = dlg_userinfo;

p.layer = nil;
p.userinfo = nil;
p.updateTimer = nil;

p.move_time = 20;
p.energy_time = 30;

p.move_remain_time = 0;
p.energy_remain_time = 0;

p.levNum = nil;

local ui = ui_main_userinfo

function p.ShowUI(userinfo)
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		--dlg_battlearray.ShowUI();
		
		if userinfo ~= nil then
			p.RefreshUI(userinfo)
		else
			p.SendReqUserInfo();
		end
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init(layer);
	layer:SetSwallowTouch(false);
    
	GetUIRoot():AddChild(layer);
	LoadUI("main_userinfo.xui", layer, nil);
	layer:SetZOrder(9);
    
	p.layer = layer;
	
	--dlg_battlearray.ShowUI();
	
	if userinfo ~= nil then
		p.RefreshUI(userinfo)
	else
		p.SendReqUserInfo();
	end
	p.SetDelegate();
	
	p.updateTimer = SetTimer( p.OnUpdateInfo, 1.0f);
end

function p.CloseUI()    
    if p.layer ~= nil then
        p.layer:LazyClose();
        p.layer = nil;
		p.userinfo = nil;
		p.levNum = nil;
		if p.updateTimer then
			KillTimer( p.updateTimer );
		end
    end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
	end
end

function p.SendReqUserInfo()
	WriteCon("**请求玩家状态数据**");
    local uid = GetUID();
    if uid ~= nil and uid > 0 then
        SendReq("User","Update",uid,"");
	end
end

function p.RefreshUI(userinfo)
	p.userinfo = userinfo;

	local username = GetLabel( p.layer, ui.ID_CTRL_TEXT_NAME);
	username:SetText( userinfo.Name );
	
	local level = GetLabel(p.layer, ui.ID_CTRL_TEXT_LEVEL_NUM);
	level:SetText( " " );
	
	if p.levNum == nil then
		local levNum = effect_num:new();
		levNum:SetOwnerNode( level );
		levNum:Init();
		p.levNum = levNum;
		level:AddChild( levNum:GetNode() );
	end
	p.levNum:PlayNum( tonumber(userinfo.Level) );

	local money = GetLabel(p.layer, ui.ID_CTRL_TEXT_MONEY_NUM);
	money:SetText( userinfo.Money );
	
	local emoney = GetLabel(p.layer, ui.ID_CTRL_TEXT_EMONEY_NUM);
	emoney:SetText( userinfo.Emoney );
	
	local strength = GetExp( p.layer, ui.ID_CTRL_PROGRESSBAR_STRENGTH );
	strength:SetValue( 0, tonumber( userinfo.MaxMove ), tonumber( userinfo.Move ) );
	
	local energy = GetExp( p.layer, ui.ID_CTRL_PROGRESSBAR_ENERGY );
	if userinfo.MaxEnergy == nil or userinfo.Energy == nil then
		energy:SetValue( 0, tonumber( 0 ), tonumber( 0 ) );
	else
		energy:SetValue( 0, tonumber( userinfo.MaxEnergy ), tonumber( userinfo.Energy ) );
	end

	--energy:SetValue( 0, 100, tonumber( userinfo.Energy ) );
	
	local Exp = GetExp( p.layer, ui.ID_CTRL_PROGRESSBAR_EXP );
	Exp:SetValue( 0, tonumber( userinfo.MaxExp ), tonumber( userinfo.Exp ) );
	--Exp:SetValue( 0, 100, tonumber( userinfo.Exp ) );
	
	local pic = GetImage( p.layer, ui.ID_CTRL_PICTURE_FACE);
	pic:SetPicture( GetPictureByAni("UserImage.Face"..userinfo.Face, 0) );
	
	dlg_battlearray.RefreshUI(userinfo.User_Team);
	
	--行动力、精力恢复
	local m_time = tonumber( userinfo.MoveTime );
	if m_time ~= nil then
		p.move_time = m_time;
		p.move_remain_time = m_time;
	end
	
	local e_time = tonumber( userinfo.EnergyTime );
	if e_time ~= nil then
		p.energy_time = e_time;
		p.energy_remain_time = e_time;
	end
end

function p.SetDelegate()
	--[[
	local addEmoney = GetButton( p.layer, ui.ID_CTRL_BUTTON_ADD_EMONEY );
	addEmoney:SetLuaDelegate( p.OnBtnClick );
	--]]
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_ADD_EMONEY == tag then
			WriteCon("**========充值========**");
			--p.levNum:PlayNum( tostring( math.random(1, 999)));
		end
	end
end

--返回玩家信息
function p.GetUserInfo()
	return p.userinfo;
end

--更新玩家体力、精力
function p.OnUpdateInfo()
	if p.layer == nil or msg_cache.msg_player == nil then
		return;
	end
	
	local cache = msg_cache.msg_player;
	if tonumber(cache.Move) < tonumber(cache.MaxMove) then
		p.move_remain_time = p.move_remain_time - 1;
		if p.move_remain_time <= 0 then
			p.move_remain_time = p.move_time;
			cache.Move = cache.Move + 1;
			
			local strength = GetExp( p.layer, ui.ID_CTRL_PROGRESSBAR_STRENGTH );
			strength:SetValue( 0, tonumber( cache.MaxMove ), tonumber( cache.Move ) );
		end
	end
	
	if tonumber(cache.Energy) < tonumber(cache.MaxEnergy) then
		p.energy_remain_time = p.energy_remain_time - 1;
		if p.energy_remain_time <= 0 then
			p.energy_remain_time = p.energy_time;
			cache.Energy = cache.Energy + 1;
			
			local energy = GetExp( p.layer, ui.ID_CTRL_PROGRESSBAR_ENERGY );
			if cache.MaxEnergy == nil or cache.Energy == nil then
				energy:SetValue( 0, tonumber( 0 ), tonumber( 0 ) );
			else
				energy:SetValue( 0, tonumber( cache.MaxEnergy ), tonumber( cache.Energy ) );
			end
		end
	end
end


