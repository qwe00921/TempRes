
w_battle_pass_bg = {};
local p = w_battle_pass_bg;

p.masklayer = nil;
p.layer = nil;

local ui = ui_n_battle_pass_bg;

function p.ShowUI()
	if p.layer ~= nil then
		if p.masklayer then
			p.masklayer:SetVisible( true );
		end
		SetTimerOnce( p.ShowAnimation, 0.2 );
		return;
	end
	
	local layer = createNDUILayer();
	if layer == nil then
		return false;
	end
	
	--layer:NoMask();
	layer:Init();
	layer:SetSwallowTouch( false );
    
	layer:SetVisible( false );
	
	GetUIRoot():AddChild( layer );
	LoadDlg("n_battle_pass_bg.xui", layer, nil);
	
	p.layer = layer;
	
	local masklayer = createNDUILayer();
	if masklayer == nil then
		return false;
	end
	--masklayer:NoMask();
	masklayer:Init();
	masklayer:SetSwallowTouch( true );
	
	GetUIRoot():AddChild( masklayer );
	LoadDlg("n_battle_mask.xui", masklayer, nil);
	
	p.masklayer = masklayer;
	
	SetTimerOnce( p.ShowAnimation, 0.2 );
end

function p.ShowAnimation()
	if p.layer == nil then
		return;
	end
	
	local pos = p.layer:GetFramePos();
	local size = p.layer:GetFrameSize();
	p.layer:SetFramePosXY(740*GetUIScale(), pos.y);
	p.layer:SetVisible( true );

	local batch = battle_show.GetNewBatch();
	local seq = batch:AddSerialSequence();
	local cmd = createCommandEffect():AddActionEffect( 0, p.layer, "ui.w_battle_pass_bg_show" );
	seq:AddCommand( cmd );
	
	local env = cmd:GetVarEnv();
	env:SetFloat( "$1", -740*GetUIScale() );
	
	local batch1 = battle_show.GetNewBatch();
	local seq1 = batch1:AddSerialSequence();
	local cmdLua = createCommandLua():SetCmd( "w_battle_passby", 1, 1, "" );
	seq1:AddCommand( cmdLua );
	seq1:SetWaitEnd( cmd );

	--显示过场进度
	--SetTimerOnce( p.ShowProcess, 0.8 );
end

function p.ShowProcess()
	--参数需要从w_battle_mgr中取值
	w_battle_pass.ShowUI( math.max(w_battle_db_mgr.step-1, 1), w_battle_db_mgr.maxStep );
end

function p.HideAnimation()
	if p.layer == nil then
		return;
	end
	
	local pos = p.layer:GetFramePos();
	p.layer:SetFramePosXY( 0, pos.y );
	p.layer:SetVisible( true );
	
	local batch = battle_show.GetNewBatch();
	local seq = batch:AddSerialSequence();
	local cmd = createCommandEffect():AddActionEffect( 0, p.layer, "ui.w_battle_pass_bg_hide" );
	seq:AddCommand( cmd );
	
	local env = cmd:GetVarEnv();
	env:SetFloat( "$1", 740*GetUIScale() );
	
	local batch1 = battle_show.GetNewBatch();
	local seq1 = batch1:AddSerialSequence();
	local cmdLua = createCommandLua():SetCmd( "w_battle_passby", 1, 2, "" );
	seq1:AddCommand( cmdLua );
	seq1:SetWaitEnd( cmd );

	--SetTimerOnce( p.PassOver, 0.7 );
end

function p.CmdLuaCallBack( id, num )
	if num == 1 then
		p.ShowProcess();
	else
		p.PassOver();
	end
end

function p.PassOver()
	p.CloseUI();
	
	w_battle_pve.RefreshUI();
	w_battle_mgr.starFighter();
end

function p.CloseUI()    
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
	
	if p.masklayer then
		p.masklayer:LazyClose();
		p.masklayer = nil;
	end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
	end
	if p.masklayer ~= nil then
        p.masklayer:SetVisible(false);
	end
end


