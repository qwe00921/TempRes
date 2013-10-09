--------------------------------------------------------------
-- FileName: 	x_battle_pvp.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		��Ҷ�ս (demo v2.0)
--------------------------------------------------------------

x_battle_pvp = {}
local p = x_battle_pvp;

local ui = ui_x_battle_pvp;
local heroUIArray = { 
    ui.ID_CTRL_SPRITE_1, 
    ui.ID_CTRL_SPRITE_2, 
    ui.ID_CTRL_SPRITE_3, 
    ui.ID_CTRL_SPRITE_4, 
    ui.ID_CTRL_SPRITE_5, 
}
local enemyUIArray = { 
    ui.ID_CTRL_SPRITE_6,
    ui.ID_CTRL_SPRITE_7,
    ui.ID_CTRL_SPRITE_8,
    ui.ID_CTRL_SPRITE_9,
    ui.ID_CTRL_SPRITE_10,
}    

-----
p.battleLayer = nil;
p.TestHeroFighter1 = nil;
-----

--���ÿɼ�
function p.HideUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( false );
		GetBattleShow():EnableTick( false );
	end
end

--��ʾUI
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

    LoadUI("x_battle_pvp.xui", layer, nil);

	layer:SetFramePosXY(0,0);
	p.battleLayer = layer;
	
	local skillNameBar = GetImage( p.battleLayer ,ui_x_battle_pvp.ID_CTRL_PICTURE_13 )
	skillNameBar:SetFramePosXY(0,skillNameBar:GetFramePos().y);
	p.skillNameBarOldPos = skillNameBar:GetFramePos();
	
	--���ս������ͼƬ
	--p.AddBattleBg();
	
	--ս��
	p.InitBattle();
	return true;
end

--�ر�
function p.CloseUI()
	if p.battleLayer ~= nil then	
		p.battleLayer:LazyClose();
		p.battleLayer = nil;
	end
	GetBattleShow():EnableTick( false );
end

--���ü���������UI����ߣ����ṩ���������Ч
function p.SetSkillNameBarToLeft()
	local skillNameBar = GetImage( p.battleLayer ,ui_x_battle_pvp.ID_CTRL_PICTURE_13 )
	skillNameBar:SetFramePos(p.skillNameBarOldPos);
	
	local tempPos = skillNameBar:GetFramePos();
	tempPos.x = tempPos.x - GetScreenWidth();
	skillNameBar:SetFramePos(tempPos);
end

--���ü���������UI���ұߣ����ṩ���ҽ�����Ч
function p.SetSkillNameBarToRight()
	local skillNameBar = GetImage( p.battleLayer ,ui_x_battle_pvp.ID_CTRL_PICTURE_13 )
	skillNameBar:SetFramePos(p.skillNameBarOldPos);
	
	local tempPos = skillNameBar:GetFramePos();
	tempPos.x = tempPos.x + GetScreenWidth();
	skillNameBar:SetFramePos(tempPos);
end

--���ս��������
function p.AddBattleBg()
	local bg = createNDUIImage();
	bg:Init();
	bg:SetFrameRectFull();
	p.battleLayer:AddChildZTag( bg, E_BATTLE_Z_GROUND, E_BATTLE_TAG_GROUND );
	
	--��ȡani�����е�ͼƬ
	local pic = GetPictureByAni("x.battle_bg", 1);
	bg:SetPicture( pic );
	--bg:SetVisible( false );
end

--��ԭ������������λ��
function p.ReSetSkillNameBarPos()
	local skillNameBar = GetImage( p.battleLayer ,ui_x_battle_pvp.ID_CTRL_PICTURE_13 );
	skillNameBar:SetFramePos(p.skillNameBarOldPos);
	skillNameBar:DelAniEffect("x_cmb.skill_name_fx");
	skillNameBar:DelAniEffect("x_cmb.skill_name_fx_reverse");
end


--��ʼ��ս��
function p.InitBattle()
	x_battle_mgr.uiLayer = p.battleLayer;
	x_battle_mgr.heroUIArray = heroUIArray;
	x_battle_mgr.enemyUIArray = enemyUIArray;
	x_battle_mgr.play_pvp();
end