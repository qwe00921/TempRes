
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

p.eneryList = {};

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
	p.SetDelegate();
	
	if userinfo ~= nil then
		p.RefreshUI(userinfo)
	else
		p.SendReqUserInfo();
	end

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
	money:SetText( tostring(userinfo.Money) );
	
	local emoney = GetLabel(p.layer, ui.ID_CTRL_TEXT_EMONEY_NUM);
	emoney:SetText( tostring(userinfo.Emoney) );
	
	local strength = GetExp( p.layer, ui.ID_CTRL_PROGRESSBAR_STRENGTH );
	strength:SetValue( 0, tonumber( userinfo.MaxMove ), tonumber( userinfo.Move ) );
	
	local bluesoul = GetLabel( p.layer, ui.ID_CTRL_TEXT_SOUL );
	bluesoul:SetText( tostring(userinfo.BlueSoul) );

	local Exp = GetExp( p.layer, ui.ID_CTRL_PROGRESSBAR_EXP );
	Exp:SetValue( 0, tonumber( userinfo.MaxExp ), tonumber( userinfo.Exp ) );
	
	maininterface.ShowBattleArray( userinfo.User_Team );
	
	--行动力、精力恢复
	--local m_time = 20;
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
	
	local timeText = GetLabel( p.layer, ui.ID_CTRL_TEXT_46 );
	if userinfo.Move < userinfo.MaxMove then
		timeText:SetText( ToUtf8( TimeToStr( p.move_remain_time ) ) );
	else
		timeText:SetText( ToUtf8( "恢复时间" ) );
	end
	
	local energy = tonumber(userinfo.Energy) or 0;
	for i = 1, #p.eneryList do
		local ctrller = p.eneryList[i];
		if ctrller then
			ctrller:SetVisible( i <= energy );
		end
	end
end

function p.SetDelegate()
	local image = GetImage( p.layer, ui.ID_CTRL_PICTURE_42 );
	table.insert( p.eneryList, image );
	image = GetImage( p.layer, ui.ID_CTRL_PICTURE_43 );
	table.insert( p.eneryList, image );
	image = GetImage( p.layer, ui.ID_CTRL_PICTURE_44 );
	table.insert( p.eneryList, image );
end

function p.OnBtnClick(uiNode, uiEventType, param)
	if IsClickEvent( uiEventType ) then
	    local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_ADD_EMONEY == tag then
			WriteCon("**========充值========**");
			
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
		
		local timeText = GetLabel( p.layer, ui.ID_CTRL_TEXT_46 );
		if cache.Move < cache.MaxMove then
			timeText:SetText( ToUtf8( TimeToStr( p.move_remain_time ) ) );
		else
			timeText:SetText( ToUtf8( "恢复时间" ) );
		end
	end

	if tonumber(cache.Energy) < 3 then
		p.energy_remain_time = p.energy_remain_time - 1;
		if p.energy_remain_time <= 0 then
			p.energy_remain_time = p.energy_time;
			cache.Energy = cache.Energy + 1;

			for i = 1, #p.eneryList do
				local ctrller = p.eneryList[i];
				if ctrller then
					ctrller:SetVisible( i <= cache.Energy );
				end
			end
		end
	end
end


