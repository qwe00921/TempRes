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
		p.uiLayer:AddChildZ( p.imageMask, 99 );
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
end

--创建敌对阵营
function p.createEnemyCamp()
	p.enemyCamp = x_battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	--p.enemyCamp:AddFighters( p.enemyUIArray );
	p.enemyCamp:AddBoss( );
end

--测试PVP
function p.TestPVP()
	for i=1,100 do
		p.FightOnce_PVP( true );
		p.FightOnce_PVP( false );
	end
end

--测试随机打一次(PVP)
function p.FightOnce_PVP( flag )
	local batch = battle_show.GetNewBatch();
	local f1 = p.heroCamp:GetRandomFighter();
	local f2 = p.enemyCamp:GetRandomFighter();
	local f3,f4 = p.enemyCamp:GetRandomFighter_2();
	
--	f1:AtkSkillMul( f3, f4, batch );
--	do return end
	
	if flag then
		if math.random(1,3) == 2 then
			f1:AtkSkillMul( f3, f4, batch );
		else
			f1:AtkSkill( f2, batch );
		end
	else
		f2:AtkSkill( f1, batch );
	end
end

--[[
--玩家技能攻击
function p.HeroAtkSkill()
	WriteCon( "HeroAtkSkill()");
	
	local boss = p.enemyCamp:GetFirstFighter();
	
	--子弹旋转
	local bulletRotation = { -50+180, -30+180, 0+180, 20+180, 25+180 };
	
	--hero攻击
	local heroCount = p.heroCamp:GetFighterCount();
	local enemyCount = p.enemyCamp:GetFighterCount();
	
	for i = 1, heroCount do
		local batch = battle_show.GetNewBatch();
		local hero = p.heroCamp:GetFighterAt(i);
		
		--随机攻击对象
		local enemyId= math.random(1,enemyCount);
		local enemy = p.enemyCamp:GetFighterAt(enemyId);
		
		local skillId= math.random(1,3);
		if skillId==1 then
			hero:AtkSkillTuc( enemy, batch, 2, bulletRotation[i], i );
		elseif skillId==2 then
			hero:AtkSkillFeilong( enemy, batch, 2, bulletRotation[i], i );
		elseif skillId==3 then	
			hero:AtkAOE(p.enemyCamp, batch);
		end
		
	end	
end
--]]
--[[
--双方阵营的普通攻击
function p.Atk(campType)
	WriteCon( "-------Atk-------");
	
	--攻击阵营
	local atkCamp;
	
	--防守阵营
	local defenseCamp;
	
	if campType==E_CARD_CAMP_HERO then
		WriteCon( "-------E_CARD_CAMP_HERO Atk-------");
		atkCamp = p.heroCamp:GetAliveFighters();
		defenseCamp = p.enemyCamp:GetAliveFighters();
	else
		WriteCon( "-------E_CARD_CAMP_ENEMY Atk-------");
		atkCamp = p.enemyCamp:GetAliveFighters();
		defenseCamp = p.heroCamp:GetAliveFighters();
	end
		
	if #atkCamp==0 or #defenseCamp==0 then
		WriteCon( "-------Atk():not Alive fighter-------");
		return ;
	end
	
	for i = 1, #atkCamp do
		local batch = battle_show.GetNewBatch();
		local attacker = atkCamp[i];	
		local defender = defenseCamp[math.random(1,#defenseCamp)];
		attacker:Atk( defender, batch );
	end	
end
--]]
--[[
--敌方技能攻击
function p:EnemyAtkSkill()
	WriteCon( "EnemyAtkSkill()");

	--子弹旋转
	local bulletRotation = { -50+180, -30+180, 0+180, 20+180, 25+180 };
	
	
	local enemyCount = p.enemyCamp:GetFighterCount();
	local heroCount = p.heroCamp:GetFighterCount();
	for i = 1, enemyCount do
		local batch = battle_show.GetNewBatch();
		local enemy = p.enemyCamp:GetFighterAt(i);
		
		--随机取攻击对象
		local heroId= math.random(1,heroCount);
		local hero = p.heroCamp:GetFighterAt(heroId);
		
		local skillId= math.random(1,3);
		if skillId==1 then
			enemy:AtkSkillTuc( hero, batch, 2, bulletRotation[i], i );
		elseif skillId==2 then
			enemy:AtkSkillFeilong( hero, batch, 2, bulletRotation[i], i );
		elseif skillId==3 then	
			enemy:AtkAOE(p.heroCamp, batch);
		end
	end	
end
--]]
--[[
--boss普通攻击（群攻）
function p.BossAtk()
	WriteCon( "BossAtk()");
	
	local boss = p.enemyCamp:GetFirstFighter();
	local batch = battle_show.GetNewBatch();
	boss:BossAtkCamp( p.heroCamp, batch );
end

--boss技能攻击（群攻）
function p.BossAtkSkill()
	WriteCon( "BossAtkSkill()");
	
	local boss = p.enemyCamp:GetFirstFighter();
	local batch = battle_show.GetNewBatch();
	--随机技能
	--local skillType = math.random(1,2);
	local skillType = 1;
	boss:BossAtkCamp_BySkill( p.heroCamp, batch ,skillType);
end
--]]

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
	SetTimerOnce( p.OpenBattleWin, 2.0f );
end

--打开战斗胜利界面
function p.OpenBattleWin()
	PlayEffectSoundByName( "battle_win.mp3" );
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
	GetTileMap():SetVisible( false );
	task_map_mainui.HideUI();
	
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
	
	--关闭战斗部分
	--x_battle_pve.CloseUI();
	x_battle_pvp.CloseUI();
	x_battle_mainui.CloseUI();
	
	--显示主界面和地图
	GetTileMap():SetVisible( true );
	task_map_mainui.ShowUI();
	hud.FadeIn();
	
	--音乐
	PlayMusic_Task();
	
	isActive = false;
end

--检查战斗结束
function p.IsBattleEnd()
	if p.heroCamp:IsAllFighterDead() then return true end
	if p.enemyCamp:IsAllFighterDead() then return true end
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
	for i=1, #defenceFighters do
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

		--@override
		if true and math.random(1,2)==2 then
			local target = defenseCampAliveFighter[defenderId];
			attacker:Atk( target, batch );
		else
			--if math.random(1,2)==2 then
			--	local skillType = math.random(1,2);
			--	attacker:AtkSkill(defenseCampAliveFighter[defenderId], batch, 2, i ,skillType);
			--else
			--	attacker:AtkSkillAOE(defenseCamp, batch);
			--end
			--local atkSkill = math.random(1,2);
			local atkSkill = 1;
			if atkSkill == 1 then
				if attacker.petTag == PET_BLUE_DEVIL_TAG  then
					attacker:UltimateSkill(defenseCamp, batch);
				else
					if attacker.idCamp == E_CARD_CAMP_ENEMY then
						for d = 1, #defenseCampAliveFighter do
							attacker:AtkSkillNearOneToOne(defenseCampAliveFighter[d], batch, 2, i ,skillType);
						end
					else
						attacker:AtkSkillNearOneToOne(defenseCampAliveFighter[defenderId], batch, 2, i ,skillType);
					end		
				end
			else
				attacker:AtkSkillOneToCamp(defenseCamp, batch);
			end		
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
