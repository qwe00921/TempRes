
w_battle_pass_bg = {};
local p = w_battle_pass_bg;

p.layer = nil;

local ui = ui_n_battle_pass_bg;

function p.ShowUI()
	if p.layer ~= nil then
		SetTimerOnce( p.ShowAnimation, 0.2 );
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch( false );
    
	layer:SetVisible( false );
	
	GetUIRoot():AddChild( layer );
	LoadUI("n_battle_pass_bg.xui", layer, nil);
	
	p.layer = layer;

	SetTimerOnce( p.ShowAnimation, 0.2 );
end

function p.ShowAnimation()
	if p.layer == nil then
		return;
	end
	
	p.layer:SetFramePosXY(740, 0);
	p.layer:SetVisible( true );
	
	p.layer:AddActionEffect( "ui.w_battle_pass_bg_show" );

	--显示过场进度
	SetTimerOnce( p.ShowProcess, 0.8 );
end

function p.ShowProcess()
	--参数需要从w_battle_mgr中取值
	w_battle_pass.ShowUI( 5, 7 );
end

function p.HideAnimation()
	if p.layer == nil then
		return;
	end
	
	p.layer:SetFramePosXY( 0, 0 );

	p.layer:SetVisible( true );
	p.layer:AddActionEffect( "ui.w_battle_pass_bg_hide" );

	SetTimerOnce( p.CloseUI, 0.7 );
end

function p.CloseUI()    
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
	end
end


