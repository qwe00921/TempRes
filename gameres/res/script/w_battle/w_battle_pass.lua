
w_battle_pass = {};
local p = w_battle_pass;
p.layer = nil;
p.chapterName = nil;
p.missionName = nil;
p.expText = nil;
p.pExp = nil;
p.TimerId = nil;

p.fromNum = nil;
p.totalNum = nil;

p.passTime = 0.875f;
p.addValue = 1;

local ui = ui_n_battle_pass;

function p.ShowUI( nFrom, nTotal )
	p.fromNum = nFrom or 0;
	p.totalNum = nTotal or 1;
	
	if p.layer ~= nil then
		p.InitController();
		p.layer:SetVisible( true );
		p.StartTimer();
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
	LoadDlg("n_battle_pass.xui", layer, nil);
	
	layer:SetVisible( true );
	
	p.layer = layer;
	p.InitController();
	p.StartTimer();
end

function p.InitController()
	p.chapterName = GetLabel( p.layer, ui.ID_CTRL_TEXT_CHAPTER );
	p.chapterName:SetText( ToUtf8("测试章节") );
	
	p.missionName = GetLabel( p.layer, ui.ID_CTRL_TEXT_MISSION );
	p.missionName:SetText( ToUtf8("测试关卡") );
	
	p.expText = GetLabel( p.layer, ui.ID_CTRL_TEXT_222 );
	p.expText:SetText( string.format( "%d/%d", math.min( p.fromNum, p.totalNum), p.totalNum ) );
	
	p.pExp = GetExp( p.layer, ui.ID_CTRL_EXP_218 );
	p.pExp:SetTextStyle( 2 );--进度条本身不显示文字
	p.pExp:SetReverseExp( true );
	p.pExp:SetValue( 0, 100, math.min( math.floor( p.fromNum/p.totalNum*100 ), 100 ));
end

function p.StartTimer()
	if p.TimerId then
		KillTimer( p.TimerId );
		p.TimerId = nil;
	end
	local totalValue = math.min( math.floor( 1/p.totalNum*100 ), 100 );
	p.addValue = totalValue*0.05/p.passTime;
	
	p.TimerId = SetTimer( p.updateExp, 0.05 );
end

function p.updateExp()
	local value = p.pExp:GetProcess();
	value = math.min( value + p.addValue, 100 );
	local maxValue = math.min( math.floor( (p.fromNum+1)/p.totalNum*100 ), 100);
	p.pExp:SetValue( 0, 100, value );
	if value >= maxValue then
		if p.TimerId then
			KillTimer( p.TimerId );
			p.TimerId = nil;
			p.expText:SetText( string.format( "%d/%d", math.min( p.fromNum+1, p.totalNum), p.totalNum ) );
			
			SetTimerOnce( p.Exit, 0.5 );
		end
	end
end

function p.Exit()
	p.HideUI();
	p.CloseUI();
	
	SetTimerOnce( w_battle_pass_bg.HideAnimation, 0.15 );
end

function p.CloseUI()    
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.chapterName = nil;
		p.missionName = nil;
		p.expText = nil;
		p.pExp = nil;
		if p.TimerId then
			KillTimer( p.TimerId );
			p.TimerId = nil;
		end
	end
end

function p.HideUI()
	if p.layer ~= nil then
        p.layer:SetVisible(false);
	end
end
