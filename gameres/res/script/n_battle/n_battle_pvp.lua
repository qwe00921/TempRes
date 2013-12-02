--------------------------------------------------------------
-- FileName: 	n_battle_pvp.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		玩家对战 (demo v2.0)
--------------------------------------------------------------

n_battle_pvp = {}
local p = n_battle_pvp;

local ui = ui_n_battle_pvp;
local heroUIArray = {
    ui.ID_CTRL_LEFT_SPRITE_1,
    ui.ID_CTRL_LEFT_SPRITE_2,
    ui.ID_CTRL_LEFT_SPRITE_3,
    ui.ID_CTRL_LEFT_SPRITE_4,
    ui.ID_CTRL_LEFT_SPRITE_5,
	ui.ID_CTRL_LEFT_SPRITE_6,
}
local enemyUIArray = {
	ui.ID_CTRL_RIGHT_SPRITE_1,
	ui.ID_CTRL_RIGHT_SPRITE_2,
	ui.ID_CTRL_RIGHT_SPRITE_3,
	ui.ID_CTRL_RIGHT_SPRITE_4,
	ui.ID_CTRL_RIGHT_SPRITE_5,
	ui.ID_CTRL_RIGHT_SPRITE_6,
}

-----
p.battleLayer = nil;
p.TestHeroFighter1 = nil;
p.pBgImage = nil;
-----

--设置可见
function p.HideUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( false );
		GetBattleShow():EnableTick( false );
	end
end

--显示UI
function p.ShowUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( true );
		GetBattleShow():EnableTick( true );
		return;
	end

	local layer = createCardBattleUILayer();
    if layer == nil then
        return false;
    end

	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
	GetRunningScene():AddChild(layer);

    LoadUI("n_battle_pvp.xui", layer, nil);

	layer:SetFramePosXY(0,0);
	p.battleLayer = layer;
	
	local skillNameBar = GetImage( p.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 )
	skillNameBar:SetFramePosXY(0,skillNameBar:GetFramePos().y);
	p.skillNameBarOldPos = skillNameBar:GetFramePos();
	
	p.pBgImage = GetImage(p.battleLayer,ui_n_battle_pvp.ID_CTRL_PICTURE_BG);
	
	if nil == p.pBgImage then
		WriteCon("pBgImage is null");
	end
	
	local batch = battle_show.GetNewBatch();
	local seqMove = batch:AddSerialSequence();
	
	--战斗
	p.InitBattle();
	return true;
end

--当前攻击卡牌信息
function p.SetAtkCardInfo()
	local pic = GetImage( p.layer,ui_n_battle_pvp.ID_CTRL_PICTURE_ATK_PIC );
	local lv = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_ATK_LV );
	local name = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_ATK_NAME );
end

--当前受击卡牌信息
function p.SetAtkTargetCardInfo()
    local pic = GetImage( p.layer,ui_n_battle_pvp.ID_CTRL_PICTURE_ATKTARGET_PIC );
    local lv = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_ATKTARGET_LV );
    local name = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_ATKTARGET_NAME );
end

function p.InitHeroPet()
	local petPic = GetImage( p.layer,ui_n_battle_pvp.ID_CTRL_PICTURE_PET_PIC_1 );
	local petSkillPic = GetImage( p.layer,ui_n_battle_pvp.ID_CTRL_PICTURE_PET_SKILL_1 );
    local lv = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_PET_LV_1 );
    local name = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_PET_NAME_1 );
    
    local petPic = GetImage( p.layer,ui_n_battle_pvp.ID_CTRL_PICTURE_PET_PIC_2 );
    local petSkillPic = GetImage( p.layer,ui_n_battle_pvp.ID_CTRL_PICTURE_PET_SKILL_2 );
    local lv = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_PET_LV_2 );
    local name = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_PET_NAME_2 );
    
end

function p.InitEnemyPet()
    local petPic = GetImage( p.layer,ui_n_battle_pvp.ID_CTRL_PICTURE_PET_PIC_3 );
    local petSkillPic = GetImage( p.layer,ui_n_battle_pvp.ID_CTRL_PICTURE_PET_SKILL_3 );
    local lv = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_PET_LV_3 );
    local name = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_PET_NAME_3 );
    
    local petPic = GetImage( p.layer,ui_n_battle_pvp.ID_CTRL_PICTURE_PET_PIC_4 );
    local petSkillPic = GetImage( p.layer,ui_n_battle_pvp.ID_CTRL_PICTURE_PET_SKILL_4 );
    local lv = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_PET_LV_4 );
    local name = GetLabel( p.layer, ui_n_battle_pvp.ID_CTRL_TEXT_PET_NAME_4 );
end

--关闭
function p.CloseUI()
	if p.battleLayer ~= nil then	
		p.battleLayer:LazyClose();
		p.battleLayer = nil;
	end
	GetBattleShow():EnableTick( false );
end

--设置技能名称栏UI到左边，以提供从左进入特效
function p.SetSkillNameBarToLeft()
	local skillNameBar = GetImage( p.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 )
	skillNameBar:SetFramePos(p.skillNameBarOldPos);
	
	local tempPos = skillNameBar:GetFramePos();
	tempPos.x = tempPos.x - GetScreenWidth();
	skillNameBar:SetFramePos(tempPos);
end

--设置技能名称栏UI到右边，以提供从右进入特效
function p.SetSkillNameBarToRight()
	local skillNameBar = GetImage( p.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 )
	skillNameBar:SetFramePos(p.skillNameBarOldPos);
	
	local tempPos = skillNameBar:GetFramePos();
	tempPos.x = tempPos.x + GetScreenWidth();
	skillNameBar:SetFramePos(tempPos);
end

--添加战斗背景框
function p.AddBattleBg()
	local bg = createNDUIImage();
	bg:Init();
	bg:SetFrameRectFull();
	p.battleLayer:AddChildZTag( bg, E_BATTLE_Z_GROUND, E_BATTLE_TAG_GROUND );
	
	--获取ani配置中的图片
	local pic = GetPictureByAni("x.battle_bg", 1);
	bg:SetPicture( pic );
	--bg:SetVisible( false );
end

--还原技能名称栏的位置
function p.ReSetSkillNameBarPos()
	local skillNameBar = GetImage( p.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 );
	skillNameBar:SetFramePos(p.skillNameBarOldPos);
	skillNameBar:DelAniEffect("x_cmb.skill_name_fx");
	skillNameBar:DelAniEffect("x_cmb.skill_name_fx_reverse");
end

--初始化战斗
function p.InitBattle()
	n_battle_mgr.uiLayer = p.battleLayer;
	n_battle_mgr.heroUIArray = heroUIArray;
	n_battle_mgr.enemyUIArray = enemyUIArray;
	n_battle_mgr.play_pvp();
	
	--SetTimerOnce(p.ReadyGo,1.5f);
end

function p.ReadyGo()
	n_battle_mainui.StartBattleEffect();
end