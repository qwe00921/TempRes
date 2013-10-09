--------------------------------------------------------------
-- FileName: 	card_battle_mgr.lua
-- author:		zhangwq, 2013/08/14
-- purpose:		卡牌战斗管理器（单实例）
--------------------------------------------------------------

card_battle_mgr = {}
local p = card_battle_mgr;

p.heroCamp = nil;			--玩家阵营
p.enemyCamp = nil;			--敌对阵营
p.heroes = nil;				--玩家卡牌数量
p.enemies = nil;			--敌方卡牌数量
p.heroRageNum = 0;          --英雄方队伍的怒气值
p.enemyRageNum = 0;         --敌方队伍的怒气值
p.tempSkillHero = nil;      --临时保存，当需要选择目标时使用
p.waitingSelectTarge = false;

p.Battle_Stage_Hand_Skill_hero = nil; --起手阶段技能列表
p.Battle_Stage_Hand_Skill_enemy = nil; --起手阶段技能列表

p.uiLayer = nil;			--战斗层
p.heroUIArray = nil;		--玩家阵营站位UITag表
p.enemyUIArray = nil;		--敌对阵营站位UITag表

p.imageMask = nil			--增加蒙版特效

local isPVE = false;
local isActive = false;
local useParallelBatch = true; --是否使用并行批次

local BATTLE_PVE = 1;
local BATTLE_PVP = 2;
local MIN_RAGE_NUM = 0;     --怒气值最小值
local MAX_RAGE_NUM = 100;   --怒气值最大值

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
	card_battle_stage.Init();
	p.ShowTurnNum();
	card_battle_stage.EnterBattle_Stage_Loading();
	p.SendStartBattleReq( BATTLE_PVP );
end

--显示回合数
function p.ShowTurnNum()
    local turnNum = card_battle_stage.turnNum - 1;
    local pic = GetPictureByAni( "card_battle.turn_num", turnNum); 
    card_battle_mainui.turnNumNode:SetPicture( pic );
    card_battle_mainui.turnNumNode:AddActionEffect("card_battle.blow_up");
end

--英雄队伍发动技能
function p.HeroTeamSkill()
    if p.heroRageNum == MAX_RAGE_NUM then
        p.heroRageNum = MIN_RAGE_NUM;
        card_battle_show.DoEffectHeroTeamSkill();
    	card_battle_mainui.heroRage:SetValue( MIN_RAGE_NUM, MAX_RAGE_NUM, p.heroRageNum );
    end
end

--敌方队伍发动技能
function p.EnemyTeamSkill()
    if p.enemyRageNum == MAX_RAGE_NUM then
        p.enemyRageNum = MIN_RAGE_NUM;
        card_battle_show.DoEffectEnemyTeamSkill();
    	card_battle_mainui.enemyRage:SetValue( MIN_RAGE_NUM, MAX_RAGE_NUM, p.enemyRageNum );
    end
end

--更新队伍的怒气值
function p.UpdateTeamRage( camp, num )
    --英雄方
    if camp == E_CARD_CAMP_HERO then
        p.heroRageNum = p.heroRageNum + num;
        if p.heroRageNum >= MAX_RAGE_NUM then
        	p.heroRageNum = MAX_RAGE_NUM;
        end
        card_battle_mainui.heroRage:SetValue( MIN_RAGE_NUM, MAX_RAGE_NUM, p.heroRageNum );
    
    --敌方
    elseif camp == E_CARD_CAMP_ENEMY then   
        p.enemyRageNum = p.enemyRageNum + num;
        if p.enemyRageNum >= MAX_RAGE_NUM then
            p.enemyRageNum = MAX_RAGE_NUM;
        end
        card_battle_mainui.enemyRage:SetValue( MIN_RAGE_NUM, MAX_RAGE_NUM, p.enemyRageNum );
    end
end

--取战斗层
function p:GetBattleLayer()
	if not isPVE then
		return card_battle_pvp.battleLayer;
	end
	return nil;
end

function p.SendStartBattleReq( battleType )
    local battleType = battleType;
    local userTeamId = 0; 
    local targetUserId = 246390;
	local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    local param = string.format("&battle_type=%d&user_team_id=%d&target_id=%d", battleType, userTeamId, targetUserId);
    SendReq("Battle","Start",uid,param);
end

--请求战士数据的响应
function p.ReceiveFightersRes( msg )
    --dump_obj( msg );
	p.heroes = msg.user_team.user_cards;
	p.enemies = msg.target_team.user_cards;
	p.heroRage = tonumber( msg.user_team.rage_num )
	p.enemyRage = tonumber( msg.target_team.rage_num );
	
	p.createHeroCamp();
	p.createEnemyCamp();
	card_battle_server.InitDB();
	card_battle_stage.EnterBattle_Stage_Hand();
	SetTimerOnce( p.EnterBattle_Stage_Hand, 1.5 );
end

function p.ReceiveBattle_Stage_HandRes( msg )
    p.Battle_Stage_Hand_Skill_hero = msg.pre_battle;
end

--请求响应:DOT数据
function p.ReceiveBattle_SubTurnStage_Dot( msg )
    --dump_obj( msg );
end

--进入起手阶段
function p.EnterBattle_Stage_Hand()
    --起手阶段表现
    p.Battle_Stage_Hand_Skill_hero = card_battle_server.GetHandStageData( E_CARD_CAMP_HERO );
    p.Battle_Stage_Hand_Skill_enemy = card_battle_server.GetHandStageData( E_CARD_CAMP_ENEMY );
	card_battle_show.DoEffectBattle_Stage_Hand();
	
	--card_battle_mainui.OnBattleShowFinished();
end

--进入子回合阶段：DOT表现
function p.EnterBattle_SubTurnStage_Dot()
    card_battle_mainui.OnBattleShowFinished();
	--card_battle_show.DoEffectBattle_SubTurnStage_Dot();
end

--进入子回合阶段：英雄方SKILL表现：由用户手动触发时表现
function p.HeroTriggerSkills( heroId )
    p.SendBattle_Hero_SkillReq( heroId );
end

--进入子回合阶段：敌方SKILL表现：自动触发技能
function p.EnemyTriggerSkills()
	--敌方技能表现
	--card_battle_show.DoEffectBattle_Enemy_SubTurnStage_Skill();
	--card_battle_mainui.OnBattleShowFinished();
	local skillData 
    skillData = card_battle_server.GetSkillData( E_CARD_CAMP_ENEMY );
    if #skillData > 0 then
    	card_battle_show.DoEffectBattle_SubTurnStage_Skill( E_CARD_CAMP_ENEMY, skillData );
    else
        card_battle_mainui.OnBattleShowFinished();	
    end
end

--进入子回合阶段：Atk表现
function p.EnterBattle_SubTurnStage_Atk()
    --请求数据
    p.SendBattle_SubTurnStage_AtkReq();
end

--回合阶段结束
function p.EnterBattle_TurnStage_End()
    p.SendBattle_TurnStage_EndReq();
end

--SKILL发动请求
function p.SendBattle_Hero_SkillReq( heroId )
    --[[
    local skillResult = msg_battle_turn_skill:new();
    skillResult:Process();
    --]]
    p.ReceiveBattle_Hero_SkillRes( heroId );
end

--SKILL发动响应
function p.ReceiveBattle_Hero_SkillRes( heroId )
    --[[
    if msg ~= nil and card_battle_stage.IsBattle_TurnStage_Hero() then
        --进入子回合阶段：SKILL表现
        card_battle_show.DoEffectBattle_SubTurnStage_Skill( msg.event );
    end
    --]]
    local skillData 
    if card_battle_stage.IsBattle_TurnStage_Hero() then
    	--skillData = card_battle_server.GetSkillData( E_CARD_CAMP_HERO, heroId );
    	--card_battle_show.DoEffectBattle_SubTurnStage_Skill( E_CARD_CAMP_HERO, skillData );
    	local batch = battle_show.GetNewBatch();
    	local atkFighter = p.heroCamp:FindFighter( heroId );
    	card_battle_skill.AtkSkillOneToCamp( atkFighter, batch );
    end
end

--ATK数据请求
function p.SendBattle_SubTurnStage_AtkReq()
	local turnAtk = msg_battle_turn_atk:new();
    turnAtk:Process();
end

--ATK请求响应
function p.ReceiveBattle_SubTurnStage_AtkRes( msg )
    --进入子回合阶段：ATK表现
    local atkData;
    if card_battle_stage.IsBattle_TurnStage_Hero() then
    	atkData = card_battle_server.GetAtkData( E_CARD_CAMP_HERO );
    elseif card_battle_stage.IsBattle_TurnStage_Enemy() then	
        atkData = card_battle_server.GetAtkData( E_CARD_CAMP_ENEMY );
    end
    card_battle_show.DoEffectBattle_SubTurnStage_Atk( atkData );
end

--对战回合结束请求
function p.SendBattle_TurnStage_EndReq()
	local turnEnd = msg_battle_turn_end:new();
    turnEnd:Process();
end

--对战回合结束响应
function p.ReceiveBattle_TurnStage_EndRes()
    --进入下一个回合
    card_battle_stage.NextTurn();
    card_battle_stage.EnterBattle_TurnStage_Hero();
    card_battle_stage.EnterBattle_SubTurnStage_Dot();
    
    p.ShowTurnNum();
    
    card_battle_show.UpdateSkillNum();
    
    --子回合阶段：DOT表现
    p.EnterBattle_SubTurnStage_Dot();
end

--获取英雄
function p.GetHeroes( fighters )
	local t = {};
	for k, v in ipairs(fighters) do
		if v.id_camp == 1 then
			t[#t+1] = v;
		end
	end
	return t;
end

--获取敌人
function p.GetEnemies( fighters )
	local t = {};
	for k, v in ipairs(fighters) do
		if v.id_camp == 2 then
			t[#t+1] = v;
		end
	end
	return t;
end

--点击英雄：触发技能使用
function p.OnClickFighter( uiNode, uiEventType, param )
    if p.waitingSelectTarge then
        local targetfighterId = uiNode:GetId();
        local targetfighter = p.enemyCamp:FindFighter( targetfighterId );
        if targetfighter ~= nil then
            card_battle_show.DoEffectCloseSelectTargetEnemy();
            card_battle_show.DoEffectOneToOne(p.tempSkillHero, targetfighter );
            p.waitingSelectTarge = false;
            p.tempSkillHero = nil;
        end
    
    elseif card_battle_stage.IsBattleTurnHeroSkill() then
        local heroId = uiNode:GetId();
        local hero = p.heroCamp:FindFighter( heroId );
        if hero == nil then
        	return ;
        end
         --是否可以发动技能
        if hero.skillnum == 0 then
            if true and math.random( 1, 2 ) == 1 then
                --需要选择目标攻击
                p.tempSkillHero = hero;
                p.waitingSelectTarge = true;
                card_battle_show.DoEffectSelectTargetEnemy();
            else
            	--发动技能
                p.HeroTriggerSkills( hero.idFighter );
            end
        end
    end
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
	p.heroCamp = card_battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray, p.heroes );
end

--创建敌对阵营
function p.createEnemyCamp()
	p.enemyCamp = card_battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	p.enemyCamp:AddFighters( p.enemyUIArray, p.enemies );
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
	WriteCon( "card_battle_mgr.EnterBattle()" );
	
	--隐藏地图和任务UI
	if GetTileMap() ~= nil then
		GetTileMap():SetVisible( false );
	end
	task_map_mainui.HideUI();
	
	--enter PVP
	card_battle_mainui.ShowUI();
	card_battle_pvp.ShowUI();	
	
	--音乐
	PlayMusic_Battle();
	
	isActive = true;
end

--退出战斗
function p.QuitBattle()
	WriteCon( "card_battle_mgr.QuitBattle()" );
	
	--关闭战斗部分
	--card_battle_pve.CloseUI();
	card_battle_pvp.CloseUI();
	card_battle_mainui.CloseUI();
	
	--显示主界面和地图
	if GetTileMap() ~= nil then
	    GetTileMap():SetVisible( true );
    end
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
--[[
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
					attacker:AtkSkillNearOneToOne(defenseCampAliveFighter[defenderId], batch, 2, i ,skillType);
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
--]]