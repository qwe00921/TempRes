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
	ui.ID_CTRL_SPRITE_BOSS,
}    

-----
p.battleLayer = nil;
p.TestHeroFighter1 = nil;
p.pBgImage = nil;
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
	
	p.pBgImage = GetImage(p.battleLayer,ui_x_battle_pvp.ID_CTRL_PICTURE_BG);
	
	if nil == p.pBgImage then
		WriteCon("pBgImage is null");
	end
	
	p.pBgImage:SetFrameSize(960,640);
	p.pBgImage:SetFramePosXY(-280,p.pBgImage:GetFramePos().y);
	
	local batch = battle_show.GetNewBatch();
	local seqMove = batch:AddSerialSequence();
	local pos = p.pBgImage:GetFramePos();
	local pTar = p.pBgImage:GetFramePos();

	local x = pTar.x;
	local xx = pos.x;
	
	pos.x = xx + 280;
	
--	local cmd = CommandMoveTo(pos,pTar,seqMove,p.pBgImage); --ս�������ƶ�ȡ��
	
	
	--���ս������ͼƬ
	--p.AddBattleBg();
	
	--ս��
	p.InitBattle();
	return true;
end

function CommandMoveTo( playerNodePos, targetPos, seq,node)
	
	local duration = 0;
	local cmd = nil;
	--local fx = "x.hero_atk";
	local fx = "x_cmb.hero_atk";
	
	local selfPos = playerNodePos;
	
	local x = targetPos.x - playerNodePos.x;
	local y = targetPos.y - playerNodePos.y;
		
	-- cmd with var
	cmd = battle_show.AddActionEffect_ToSequence( duration, node, fx, seq );
	local varEnv = cmd:GetVarEnv();
	varEnv:SetFloat( "$1", x );
	varEnv:SetFloat( "$2", y );
	
	return cmd;
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