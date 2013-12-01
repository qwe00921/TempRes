--------------------------------------------------------------
-- FileName: 	n_battle_mgr.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		战斗管理器（单实例）demo v2.0
--------------------------------------------------------------

n_battle_mgr = {}
local p = n_battle_mgr;

p.heroCamp = nil;			--玩家阵营
p.enemyCamp = nil;			--敌对阵营
p.uiLayer = nil;			--战斗层
p.heroUIArray = nil;		--玩家阵营站位UITag表
p.enemyUIArray = nil;		--敌对阵营站位UITag表

p.imageMask = nil			--增加蒙版特效

local isPVE = false;
local isActive = false;
local useParallelBatch = true; --是否使用并行批次

local BATTLE_PVE = 1;
local BATTLE_PVP = 2;

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
    n_battle_stage.Init();
    n_battle_stage.EnterBattle_Stage_Loading();
    p.SendStartPVPReq();
end

--显示回合数
function p.ShowRoundNum()
    local roundNum = n_battle_stage.GetRoundNum();
    n_battle_mainui.ShowRoundNum( roundNum );
end

--战斗阶段->加载->请求
function p.SendStartPVPReq()
    local UID = 10001; 
    local TID = 10002;
    local uid = GetUID();
    if UID == 0 or UID == nil then
        return ;
    end;
    local param = string.format("&target=%d", TID);
    SendReq("Fight","StartPvP",UID,param);
end

--战斗阶段->加载->响应
function p.ReceiveStartPVPRes( msg )
    n_battle_db_mgr.Init( msg );
    local UCardList = n_battle_db_mgr.GetPlayerCardList();
    local TCardList = n_battle_db_mgr.GetTargetCardList();
    if UCardList == nil or TCardList == nil or #UCardList == 0 or #TCardList == 0 then
    	WriteConErr(" battle data err! ");
    	return false;
    end
    p.createHeroCamp( UCardList );
    p.createEnemyCamp( TCardList );
    
    n_battle_pvp.ReadyGo();
    p.ShowRoundNum();
end

--战斗阶段->永久BUFF表现
function p.EnterBattle_Stage_Permanent_Buff()
	n_battle_mainui.OnBattleShowFinished();
end

--进入回合阶段->召唤兽表现
function p.EnterBattle_RoundStage_Pet()
    local rounds = n_battle_stage.GetRoundNum();
    local petData = n_battle_db_mgr.GetPetRoundDB( rounds );
    if petData ~= nil and #petData > 0 and rounds <= N_BATTLE_MAX_ROUND then
        n_battle_show.DoEffectPetSkill( petData );
    else
        n_battle_mainui.OnBattleShowFinished();    
    end
end

--进入回合阶段->BUFF表现
function p.EnterBattle_RoundStage_Buff()
    n_battle_mainui.OnBattleShowFinished();
end

--进入回合阶段->互殴
function p.EnterBattle_RoundStage_Atk()
    local rounds = n_battle_stage.GetRoundNum();
    local atkData = n_battle_db_mgr.GetRoundDB( rounds );
    if atkData ~= nil and #atkData > 0 and rounds <= N_BATTLE_MAX_ROUND then
    	n_battle_show.DoEffectAtk( atkData );
    end
end

--进入回合阶段->清算
function p.EnterBattle_RoundStage_Clearing()

    --进入下一个回合
    n_battle_stage.NextRound();
    p.ShowRoundNum();
    n_battle_mainui.OnBattleShowFinished();
end

--取战斗层
function p:GetBattleLayer()
	if not isPVE then
		return n_battle_pvp.battleLayer;
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
		p.uiLayer:AddChildZ( p.imageMask,100);
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
function p.createHeroCamp( fighters )
	p.heroCamp = n_battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray, fighters );
	p.heroCamp:AddShadows( p.heroUIArray, fighters );
	p.heroCamp:AddAllRandomTimeJumpEffect(true);
end

--创建敌对阵营
function p.createEnemyCamp( fighters )
	p.enemyCamp = n_battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	p.enemyCamp:AddFighters( p.enemyUIArray, fighters );
	p.enemyCamp:AddShadows( p.enemyUIArray, fighters );
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
	n_battle_ko.CloseUI();
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
	WriteCon( "n_battle_mgr.EnterBattle()" );
	
	--hide 
	--GetTileMap():SetVisible( false );
	task_map_mainui.HideUI();
	
	--隐藏按钮
--	dlg_userinfo2.HideUI();
--	dlg_menu.CloseUI();
	
	--enter PVP
	n_battle_pvp.ShowUI();	
	n_battle_mainui.ShowUI();
	
	--音乐
	PlayMusic_Battle();
	
	isActive = true;
end

--退出战斗
function p.QuitBattle()
	WriteCon( "n_battle_mgr.QuitBattle()" );

	n_battle_pvp.CloseUI();
	n_battle_mainui.CloseUI();

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
