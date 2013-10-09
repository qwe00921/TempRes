--------------------------------------------------------------
-- FileName: 	battle_mgr.lua
-- author:		zhangwq, 2013/05/22
-- purpose:		战斗管理器（单实例）
--------------------------------------------------------------

battle_mgr = {}
local p = battle_mgr;

p.heroCamp = nil;		--玩家阵营
p.enemyCamp = nil;		--敌对阵营
p.heroUIArray = nil;	--玩家阵营站位UITag表
p.enemyUIArray = nil;	--敌对阵营站位UITag表
p.uiLayer = nil;		--战斗层

local isPVE = false;
local timerBattleWin;
local timerBattleLose;


--开始战斗表现
function p.play( in_isPVE )	
	p.isPVE = in_isPVE;

	p.createHeroCamp();
	p.createEnemyCamp();
	p.GetBoss():SetBossFlag( true );
end

--取boss
function p.GetBoss()
	return p.enemyCamp:GetFirstFighter();
end

--取hero
function p.GetFirstHero()
	return p.heroCamp:GetFirstFighter();
end

--测试用
function p.test()
	if p.isPVE then
		p.TestPVE();
	else
		p.TestPVP();
	end
end

--创建玩家阵营
function p.createHeroCamp()
	p.heroCamp = battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray );
end

--创建敌对阵营
function p.createEnemyCamp()
	p.enemyCamp = battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	p.enemyCamp:AddFighters( p.enemyUIArray );
end

--获取随机战士
function p.GetTwoRandomFighters()

end

--测试PVP
function p.TestPVP()
	for i=1,100 do
		p.FightOnce_PVP( true );
		p.FightOnce_PVP( false );
	end
end

--随机打一次(PVP)
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

--测试PVE
function p.TestPVE()
	local boss = p.enemyCamp:GetFirstFighter();

--[[	
	--hero攻击
	local heroCount = heroCamp:GetFighterCount();
	for i = 1, heroCount do
		local batch = battle_show.GetNewBatch();
		local hero = heroCamp:GetFighterAt(i);
		hero:AtkSkill( boss, batch );
	end
--]]
	
	--boss攻击
	local batch = battle_show.GetNewBatch();
	boss:AtkCamp( p.heroCamp, batch );
end


--玩家技能攻击
function p.HeroAtkSkill()
	WriteCon( "HeroAtkSkill()");
	
	local boss = p.enemyCamp:GetFirstFighter();
	
	--子弹旋转
	local bulletRotation = { -50+180, -30+180, 0+180, 20+180, 25+180 };
	
	--hero攻击
	local heroCount = p.heroCamp:GetFighterCount();
	for i = 1, heroCount do
		local batch = battle_show.GetNewBatch();
		local hero = p.heroCamp:GetFighterAt(i);
		--hero:AtkSkill( boss, batch, 2, bulletRotation[i], i );
		hero:AtkSkillTornado( boss, batch, 2, bulletRotation[i], i );
	end	
end

--玩家普通攻击
function p.HeroAtk()
	WriteCon( "HeroAtk()");
	
	local boss = p.enemyCamp:GetFirstFighter();
	
	--hero攻击
	local heroCount = p.heroCamp:GetFighterCount();
	for i = 1, heroCount do
		local batch = battle_show.GetNewBatch();
		local hero = p.heroCamp:GetFighterAt(i);
		hero:Atk( boss, batch );
	end	
end

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
	GetBattleShow():Stop();
	timerBattleWin = SetTimer( p.OpenBattleWin, 1.0f );
end

--打开战斗胜利界面
function p.OpenBattleWin()
	PlayEffectSoundByName( "battle_win.mp3" );
	dlg_battle_win.ShowUI();
	KillTimer( timerBattleWin );
end

--战斗失败
function p.OnBattleLose()
	--GetBattleShow():Stop();
	timerBattleLose = SetTimer( p.OpenBattleLose, 1.0f );
end

--打开战斗失败界面
function p.OpenBattleLose()
	dlg_battle_lose.ShowUI();
	KillTimer( timerBattleLose );
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
	--hide 
	GetTileMap():SetVisible( false );
	task_map_mainui.HideUI();
	
	--enter PVE
	battle_pve.ShowUI();	
	battle_mainui.ShowUI();	
	
	--音乐
	PlayMusic_Battle();
end

--退出战斗
function p.QuitBattle()
	--关闭战斗部分
	battle_pve.CloseUI();
	battle_mainui.CloseUI();
	
	--显示主界面和地图
	GetTileMap():SetVisible( true );
	task_map_mainui.ShowUI();
	hud.FadeIn();
	
	--音乐
	PlayMusic_Task();
end

--检查战斗结束
function p.IsBattleEnd()
	if p.heroCamp:IsAllFighterDead() then return true end
	if p.enemyCamp:IsAllFighterDead() then return true end
	return false;
end