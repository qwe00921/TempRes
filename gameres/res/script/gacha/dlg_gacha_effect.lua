

dlg_gacha_effect = {};
local p = dlg_gacha_effect;

local ui = ui_gacha_ing;

p.layer = nil;
p.gacharesult = nil;
p.magic = nil;
p.scaleImg = nil;
p.cardImg = nil;
p.index = 1;

function p.ShowUI( gacharesult )
	p.gacharesult = gacharesult;
	
	if p.layer ~= nil then
		p.layer:SetVisible( false );
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
	
	dlg_menu.HideUI();
	dlg_userinfo.HideUI();
	dlg_gacha.HideUI();
	
	GetUIRoot():AddDlg( layer );
	p.layer = layer;
	LoadDlg( "gacha_ing.xui", layer, nil );
	
	p.InitControllers();
	
	SetTimerOnce( p.DoShowCardEffect(), 0.5f );
end

function p.InitControllers()
	local btn = GetButton( p.layer, ui.ID_CTRL_BUTTON_9 );
	btn:SetLuaDelegate( p.OnBtnClick );
	
	p.magic = GetImage( p.layer, ui.ID_CTRL_SPRITE_MAGICCIRCLE);
	p.magic:AddFgEffect( "ui.gacha_magic_bg" );
	
	p.scaleImg = GetImage( p.layer, ui.ID_CTRL_PICTURE_SCALE );
	
	p.cardImg = GetImage( p.layer, ui.ID_CTRL_PICTURE_CARD );	
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
	
	SetTimerOnce( p.ShowCard, 1 );
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
	p.cardImg:SetVisible( true );
	SetTimerOnce( p.ShowNextCard, 0.5f );
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
	end
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible(false);
	end
end
