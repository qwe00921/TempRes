

dlg_gacha_effect = {};
local p = dlg_gacha_effect;

local ui = ui_gacha_ing;

p.layer = nil;
p.gacharesult = nil;
p.magic = nil;
p.scaleImg = nil;
p.cardImg = nil;
p.index = 1;
p.continueImg = nil;

function p.ShowUI( gacharesult )
	p.gacharesult = gacharesult;
	
	dlg_gacha_result.CloseUI();
	
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		dlg_menu.HideUI();
		return;
	end
	
	local layer = createNDUIDialog();
	if layer == nil then
		return false;
	end
	
	layer:Init();
	layer:SetSwallowTouch(true);
	layer:SetFrameRectFull();
	layer:SetLayoutType(1);

	dlg_menu.HideUI();
	dlg_userinfo.HideUI();
	dlg_gacha.HideUI();
	
	GetUIRoot():AddChild( layer );
	p.layer = layer;
	LoadDlg( "gacha_ing.xui", layer, nil );
	
	p.InitControllers();

	--SetTimerOnce( p.DoShowCardEffect, 0.71f );
end

function p.InitControllers()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_9 );
	btn:SetLuaDelegate( p.OnBtnClick );
	--btn:SetVisible( false );
	
	p.magic = GetImage( p.layer, ui.ID_CTRL_SPRITE_MAGICCIRCLE);
	p.ShowBgEffect();
	
	p.scaleImg = GetImage( p.layer, ui.ID_CTRL_PICTURE_SCALE );
	
	p.cardImg = GetImage( p.layer, ui.ID_CTRL_PICTURE_CARD );
	
	p.continueImg = GetImage( p.layer, ui.ID_CTRL_PICTURE_6 );
	p.continueImg:SetVisible( false );
end

function p.ShowBgEffect()
	p.index = 1;
	local batch1 = battle_show.GetNewBatch();
	local seq1 = batch1:AddSerialSequence();
	local cmd1 = createCommandEffect():AddFgEffect( 0, p.magic, "ui.gacha_magic_bg_appear" );
	seq1:AddCommand( cmd1 );

	local cmdLua = createCommandLua():SetCmd( "gacha_effect_show", 1, 1, "" );
	seq1:AddCommand( cmdLua );
	
	local batch2 = battle_show.GetNewBatch();
	local seq2 = batch2:AddSerialSequence();
	local cmd2 = createCommandLua():SetCmd( "gacha_effect_show_end", 1, 1, "" );
	seq2:AddCommand( cmd2 );
	seq2:SetWaitEnd( cmd1 );
end

function p.ShowLoopEffect()
	if p.magic == nil then
		return;
	end
	
	if p.magic:HasAniEffect( "ui_cmb.gacha_bg_loop" ) then
		p.magic:DelAniEffect( "ui_cmb.gacha_bg_loop" );
	end
	
	p.magic:AddFgEffect( "ui_cmb.gacha_bg_loop" );
end

function p.DoShowCardEffect()
	if p.layer == nil then
		return;
	end

	if p.gacharesult == nil or p.gacharesult.card_ids == nil then
		return;
	end
	
	local cardList = p.gacharesult.card_ids;
	local card = cardList[p.index];
	if card == nil then
		return;
	end

	p.cardImg:SetVisible( false );
	
	if p.scaleImg:HasAniEffect( "ui.gacha_card_scale" ) then
		p.scaleImg:DelAniEffect( "ui.gacha_card_scale" );
	end
	p.scaleImg:AddFgEffect( "ui.gacha_card_scale" );
	
	SetTimerOnce( p.ShowCard, 0.5f );
end

function p.ShowCard()
	if p.layer == nil then
		return;
	end
	
	if p.gacharesult == nil or p.gacharesult.card_ids == nil then
		return;
	end
	
	local cardList = p.gacharesult.card_ids;
	local card = cardList[p.index];
	if card == nil then
		return;
	end
	
	local cardid = card.id;
	local path = SelectRowInner( T_CHAR_RES, "card_id", cardid, "card_pic" );
	--WriteCon( tostring(path) .. " " .. cardid );
	local picData = GetPictureByAni( path, 0 );
	if picData then
		p.cardImg:SetPicture( picData );
	end
	p.cardImg:SetScale( 0.7 );
	p.cardImg:SetVisible( true );
	
	if p.cardImg:FindActionEffect( "lancer.gacha_show_card" ) then
		p.cardImg:DelActionEffect( "lancer.gacha_show_card" );
	end
	p.cardImg:AddActionEffect( "lancer.gacha_show_card" );
	
	if cardList[p.index+1] ~= nil then
		SetTimerOnce( p.ShowNextCard, 1.1f );
	else
		SetTimerOnce( p.ShowContinue, 0.6f );
	end
end

function p.ShowContinue()
	if p.continueImg ~= nil then
		p.continueImg:SetVisible(true);
		p.continueImg:AddActionEffect( "ui_cmb.gacha_effect_scale" );
	end
end

function p.ShowNextCard()
	p.index = p.index + 1;
	p.DoShowCardEffect();
end

function p.OnBtnClick( uiNode, uiEventType, param )
	if IsClickEvent( uiEventType ) then
		local tag = uiNode:GetTag();
		if ui.ID_CTRL_BUTTON_9 == tag then
			WriteCon( "关闭动画，显示扭蛋结果" );
			
			dlg_gacha_result.ShowUI( p.gacharesult );
			p.HideUI();
			p.CloseUI();
		end
	end
end

function p.CloseUI()
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
		p.gacharesult = nil;
		p.magic = nil;
		p.scaleImg = nil;
		p.cardImg = nil;
		p.index = 1;
		p.continueImg = nil;
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
	end
end
