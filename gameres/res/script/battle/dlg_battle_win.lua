--------------------------------------------------------------
-- FileName: 	dlg_battle_win.lua
-- author:		xyd, 2013/05/31
-- purpose:		Battle胜利界面的功能
--------------------------------------------------------------

dlg_battle_win = {}
local p = dlg_battle_win;

p.layer = nil;

--显示UI
function p.ShowUI()

	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
		
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	GetUIRoot():AddDlg(layer);
    LoadDlg("dlg_battle_win.xui", layer, nil);
	
	p.Init();
	p.layer = layer;

	--加个关闭按钮
	local closeBtn = createNDUIButton();
	closeBtn:Init();
	closeBtn:SetFrameRectFull();
	layer:AddChildZ(closeBtn,5);
	closeBtn:SetLuaDelegate(p.OnUIEventBtn);
	p.DoEffect();	
end

function p.DoEffect()
      p.Star1();
      SetTimerOnce( p.Star2, 0.5f );
      SetTimerOnce( p.Star3, 1f );
      
      --缩放效果  
      --SetTimerOnce( p.SetStarActionFx1, 0.8f );
      --SetTimerOnce( p.SetStarActionFx2, 1.2f );
      --SetTimerOnce( p.SetStarActionFx3, 1.6f );
    
end

function p.Star1()
	local star = GetImage( p.layer,ui_dlg_battle_win.ID_CTRL_PICTURE_10 );
	p.SetStarFx( star );
end

function p.Star2()
    local star = GetImage( p.layer,ui_dlg_battle_win.ID_CTRL_PICTURE_11 );
    p.SetStarFx( star );
end

function p.Star3()
    local star = GetImage( p.layer,ui_dlg_battle_win.ID_CTRL_PICTURE_12 );
    p.SetStarFx( star );
end

function p.SetStarFx( node )
    local bgNode = GetImage( p.layer,ui_dlg_battle_win.ID_CTRL_PICTURE_BG );
	node:AddFgEffect("ui_cmb.star_fx");
    --模糊效果
    node:AddActionEffect("ui.star_blur");
    --背景图片缩放效果
    bgNode:AddActionEffect("ui.star_bg_scale");
end
--[[
function p.SetStarActionFx1()
	local star = GetImage( p.layer,ui_dlg_battle_win.ID_CTRL_PICTURE_10 );
	local pic = GetPictureByAni( "ui.star_fx_1", 0 );
	star:SetPicture( pic );
	star:SetScale( 1.5f );
	star:AddActionEffect("ui_cmb.star_scale");
end

function p.SetStarActionFx2()
    local star = GetImage( p.layer,ui_dlg_battle_win.ID_CTRL_PICTURE_11 );
    local pic = GetPictureByAni( "ui.star_fx_1", 0 );
    star:SetPicture( pic );
    star:SetScale( 1.5f );
    star:AddActionEffect("ui_cmb.star_scale");
end

function p.SetStarActionFx3()
    local star = GetImage( p.layer,ui_dlg_battle_win.ID_CTRL_PICTURE_12 );
    local pic = GetPictureByAni( "ui.star_fx_1", 0 );
    star:SetPicture( pic );
    star:SetScale( 1.5f );
    star:AddActionEffect("ui_cmb.star_scale");
end
--]]

function p.OnUIEventBtn(uiNode, uiEventType, param)	
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
	
	if E_DEMO_VER == 2 then
	    x_battle_mgr.QuitBattle();
	elseif E_DEMO_VER == 3 then   
		card_battle_mgr.QuitBattle();
    elseif E_DEMO_VER == 1 then
        battle_mgr.QuitBattle();
    end
end

function p.Init()	
end

function p.Hide()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end