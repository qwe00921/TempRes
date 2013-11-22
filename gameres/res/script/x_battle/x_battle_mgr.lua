--------------------------------------------------------------
-- FileName: 	x_battle_mgr.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		战斗管理器（单实例）demo v2.0
--------------------------------------------------------------

x_battle_mgr = {}
local p = x_battle_mgr;

p.heroCamp = nil;			--玩家阵营
p.enemyCamp = nil;			--敌对阵营
p.uiLayer = nil;			--战斗层
p.heroUIArray = nil;		--玩家阵营站位UITag表
p.enemyUIArray = nil;		--敌对阵营站位UITag表

p.imageMask = nil			--增加蒙版特效

local isPVE = false;
local isActive = false;
local useParallelBatch = true; --是否使用并行批次

--开始战斗表现:pve
function p.play_pve()
	isPVE = true;	
	p.createHeroCamp();
	p.createEnemyCamp();
	p.GetBoss():SetBossFlag( true );	
end

--开始战斗表现:pvp
function p.play_pvp()
	isPVE = false;
	p.createHeroCamp();
	p.createEnemyCamp();
end

--取战斗层
function p:GetBattleLayer()
	if not isPVE then
		return x_battle_pvp.battleLayer;
	end
	return nil;
end

--添加蒙版图片
function p.AddMaskImage()
	if p.imageMask == nil then
		p.imageMask = createNDUIImage();
		p.imageMask:Init();
		p.imageMask:SetFrameRectFull();
		
		local pic = GetPictureByAni("lancer.mask", 0); 
		p.imageMask:SetPicture( pic );
		p.uiLayer:AddChildZ( p.imageMask,1);
		p.imageMask:AddActionEffect("x.imageMask_fadein");
	else
		p.ShowMaskImage();
	end
end

--显示蒙版
function p.ShowMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(true);
		p.imageMask:AddActionEffect("x.imageMask_fadein");
	end
end

--不显示蒙版
function p.HideMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(false);
		p.imageMask:AddActionEffect("x.imageMask_fadeout");
	end
end

--[[
--取boss
function p.GetBoss()
	return p.enemyCamp:GetFirstFighter();
end
--]]

--是否active
function p.IsActive()
    return isActive;
end

--取第一个hero
function p.GetFirstHero()
	return p.heroCamp:GetFirstFighter();
end

--取第一个enemy
function p.GetFirstEnemy()
	return p.enemyCamp:GetFirstFighter();
end

--创建玩家阵营
function p.createHeroCamp()
	p.heroCamp = x_battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray );
	p.heroCamp:AddShadows( p.heroUIArray );
	p.heroCamp:AddAllRandomTimeJumpEffect(true);
end

--创建敌对阵营
function p.createEnemyCamp()
	p.enemyCamp = x_battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	p.enemyCamp:AddFighters( p.enemyUIArray );
	p.enemyCamp:AddShadows( p.enemyUIArray );
	p.enemyCamp:AddAllRandomTimeJumpEffect(false);
end

--测试PVP
function p.TestPVP()

end

--测试随机打一次(PVP)
function p.JumpToPoint( pSeq,Pos )
	local batch = battle_show.GetNewBatch();
	local f1 = p.heroCamp:GetRandomFighter();
	local f2 = p.enemyCamp:GetRandomFighter();
	local f3,f4 = p.enemyCamp:GetRandomFighter_2();
	
--	f1:AtkSkillMul( f3, f4, batch );
--	do return end

end

--查找fighter
function p.FindFighter(id)
	local f = p.heroCamp:FindFighter(id);
	if f == nil then
		f = p.enemyCamp:FindFighter(id);
	end
	return f;
end

--战斗胜利
function p.OnBattleWin()
	--GetBattleShow():Stop();
	SetTimerOnce( p.OpenBattleWin, 1.0f );
end

--打开战斗胜利界面
function p.OpenBattleWin()
	PlayEffectSoundByName( "battle_win.mp3" );
	battle_ko.CloseUI();
	dlg_battle_win.ShowUI();
end

--战斗失败
function p.OnBattleLose()
	--GetBattleShow():Stop();
	SetTimerOnce( p.OpenBattleLose, 2.0f );
end

--打开战斗失败界面
function p.OpenBattleLose()
	dlg_battle_lose.ShowUI();
end

--检查是否战斗胜利
function p.CheckBattleWin()
	if p.enemyCamp:IsAllFighterDead() then
		p.OnBattleWin();
		return true;
	end
	return false;
end

--检查是否战斗失败
function p.CheckBattleLose()
	if p.heroCamp:IsAllFighterDead() then
		p.OnBattleLose();
		return true;
	end
	return false;
end

--进入战斗
function p.EnterBattle()
	WriteCon( "x_battle_mgr.EnterBattle()" );
	
	--hide 
	--GetTileMap():SetVisible( false );
	task_map_mainui.HideUI();
	
	--隐藏按钮
--	dlg_userinfo2.HideUI();
--	dlg_menu.CloseUI();
	
	--enter PVP
	x_battle_pvp.ShowUI();	
	x_battle_mainui.ShowUI();
	
	--音乐
	PlayMusic_Battle();
	
	isActive = true;
end

--退出战斗
function p.QuitBattle()
	WriteCon( "x_battle_mgr.QuitBattle()" );

	x_battle_pvp.CloseUI();
	x_battle_mainui.CloseUI();

	WriteCon( "========111111111111" );
	game_main.EnterWorldMap();
		
	hud.FadeIn();
	
	--音乐
	PlayMusic_Task();
	
	isActive = false;
end

--检查战斗结束
function p.IsBattleEnd()
	if p.heroCamp:IsAllFighterDead() then
		return true;
	end
	
	if p.enemyCamp:IsAllFighterDead() then
		return true;
	end

	return false;
end

--英雄回合
function p.HeroTurn()
	p.CampBattle(E_CARD_CAMP_HERO);
end

--敌人回合
function p.EnemyTurn()
	p.CampBattle(E_CARD_CAMP_ENEMY);
end

function p.CampBattle(campType)
	--攻击阵营
	local atkCamp;
	--防守阵营
	local defenseCamp;
	
	if campType==E_CARD_CAMP_HERO then
		atkCamp = p.heroCamp;
		defenseCamp = p.enemyCamp;
	else
		atkCamp = p.enemyCamp;
		defenseCamp = p.heroCamp;
	end
	
	--先记录临时血量
	local defenceFighters = defenseCamp:GetAliveFighters();
	for i = 1, #defenceFighters do
		defenceFighters[i]:SetTmpLife();
	end
	
	--获取未死亡的战士
	local atkCampAliveFighter = atkCamp:GetAliveFighters();
	
	local prevBatch = nil;
	for i = 1, #atkCampAliveFighter do
		local batch = battle_show.GetNewBatch();
		local attacker = atkCampAliveFighter[i];
		
		--每次重新取目标fighters，确保都是活的
		local defenseCampAliveFighter = defenseCamp:GetAliveFighters();
		if #defenseCampAliveFighter == 0 then break end
		
		local defenderId = 1;
		if #defenseCampAliveFighter > 1 then
			defenderId = math.random(1,#defenseCampAliveFighter);
		end
		
		local nAttakType = math.random(0,99);

		--@override
		if 30 > nAttakType then
			local target = defenseCampAliveFighter[defenderId];
			attacker:Atk( target, batch );
		elseif 50 > nAttakType then
			local target = defenseCampAliveFighter[defenderId];
			attacker:AtkSkill( target, batch,1,1,1);
		elseif 70 > nAttakType then
			local target = defenseCampAliveFighter[defenderId];
			attacker:AtkSkill( target, batch,1,1,2);
		elseif 85 > nAttakType then
			attacker:AtkSkillOneToCamp( atkCamp, batch,true);
		else
			attacker:AtkSkillOneToCamp( defenseCamp, batch,false);
		end
		
		--设置批次等待
		if useParallelBatch and (prevBatch ~= nil) then
			local cmdSpecial = prevBatch:GetSpecialCmd( E_BATCH_STAGE_HURT_END );
			if cmdSpecial ~= nil then
				batch:SetWaitEnd( cmdSpecial );
			end
		end
		prevBatch = batch;
	end
end
