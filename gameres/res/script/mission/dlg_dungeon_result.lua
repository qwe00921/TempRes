--------------------------------------------------------------
-- FileName: 	dlg_dungeon_result.lua
-- author:		hst, 2013年8月13日
-- purpose:		副本结算界面
--------------------------------------------------------------

dlg_dungeon_result = {}
local p = dlg_dungeon_result;
p.layer = nil;

---------显示UI----------
function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
	else
		local layer = createNDUIDialog();
    	if layer == nil then
        	return false;
   		end
	
		layer:Init();
		GetUIRoot():AddDlg(layer);
	
    	LoadDlg("dlg_dungeon_result.xui", layer, nil);
	
		p.SetDelegate(layer);
		p.layer = layer;
		
		p.DoEffect();
		p.Init();
	end
end

--设置事件处理
function p.SetDelegate(layer)
	local pBtn01 = GetButton(layer,ui_dlg_dungeon_result.ID_CTRL_BUTTON_CONFIRM);
    pBtn01:SetLuaDelegate(p.OnUIEvent);
end

--事件处理
function p.OnUIEvent(uiNode, uiEventType, param)
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui_dlg_dungeon_result.ID_CTRL_BUTTON_CONFIRM == tag ) then	
        	p.CloseUI();
		end		
	end
end

function p.Init()
	local title = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_TITLE );
	local subTitle = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_SUBTITLE );
	
	--难度
	local difficulty_lab = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_LAB_DIFFICULTY );
	local difficulty_val = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_VAL_DIFFICULTY );
	
	--得分
	local score_lab = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_LAB_SCORE );
	local star1 = GetImage( p.layer,ui_dlg_dungeon_result.ID_CTRL_PICTURE_STAR1 );
	local star2 = GetImage( p.layer,ui_dlg_dungeon_result.ID_CTRL_PICTURE_STAR2 );
	local star3 = GetImage( p.layer,ui_dlg_dungeon_result.ID_CTRL_PICTURE_STAR3 );
	
	
	
	--通关奖励区
	--标题
	local ewward_title = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_REWARD_TITLE );
	
	--奖励宝箱图片
	local item = GetImage( p.layer,ui_dlg_dungeon_result.ID_CTRL_PICTURE_ITEM );
	item:SetPicture( GetPictureByAni("dungeon.1-1", 1) );
	
	--获得经验
	local exp_lab = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_LAB_EXP );
	local exp_val = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_VAL_EXP );
	
	--获得金线
	local coin_lab = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_LAB_COIN );
	local coin_val = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_VAL_COIN );
	
	--获得PT
	local pt_lab = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_LAB_PT );
	local pt_val = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_VAL_PT );
	
	--获得道具1
	local item1_lab = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_LAB_ITEM1 );
	local item1_val = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_VAL_ITEM1 );
	
	--获得道具2
	local item2_lab = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_LAB_ITEM2 );
	local item2_val = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_VAL_ITEM2 );
	
	--获得道具3
	local item3_lab = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_LAB_ITEM3 );
	local item3_val = GetLabel( p.layer, ui_dlg_dungeon_result.ID_CTRL_TEXT_VAL_ITEM3 );
end

function p.DoEffect()
      p.Star1();
      SetTimerOnce( p.Star2, 0.5 );
      SetTimerOnce( p.Star3, 1 );
end

function p.Star1()
	local star = GetImage( p.layer,ui_dlg_dungeon_result.ID_CTRL_PICTURE_STAR1 );
	p.SetStarFx( star );
end

function p.Star2()
    local star = GetImage( p.layer,ui_dlg_dungeon_result.ID_CTRL_PICTURE_STAR2 );
    p.SetStarFx( star );
end

function p.Star3()
    local star = GetImage( p.layer,ui_dlg_dungeon_result.ID_CTRL_PICTURE_STAR3 );
    p.SetStarFx( star );
end

function p.SetStarFx( node )
	node:AddFgEffect("ui_cmb.star_fx");
    node:AddActionEffect("ui.star_blur");
end

function p.HideUI()
	if p.layer ~= nil then
		p.layer:SetVisible( false );
	end
end

function p.CloseUI()	
    if p.layer ~= nil then
	    p.layer:LazyClose();
        p.layer = nil;
    end
end