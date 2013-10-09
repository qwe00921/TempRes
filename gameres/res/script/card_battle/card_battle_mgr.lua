--------------------------------------------------------------
-- FileName: 	card_battle_mgr.lua
-- author:		zhangwq, 2013/08/14
-- purpose:		����ս������������ʵ����
--------------------------------------------------------------

card_battle_mgr = {}
local p = card_battle_mgr;

p.heroCamp = nil;			--�����Ӫ
p.enemyCamp = nil;			--�ж���Ӫ
p.heroes = nil;				--��ҿ�������
p.enemies = nil;			--�з���������
p.heroRageNum = 0;          --Ӣ�۷������ŭ��ֵ
p.enemyRageNum = 0;         --�з������ŭ��ֵ
p.tempSkillHero = nil;      --��ʱ���棬����Ҫѡ��Ŀ��ʱʹ��
p.waitingSelectTarge = false;

p.Battle_Stage_Hand_Skill_hero = nil; --���ֽ׶μ����б�
p.Battle_Stage_Hand_Skill_enemy = nil; --���ֽ׶μ����б�

p.uiLayer = nil;			--ս����
p.heroUIArray = nil;		--�����ӪվλUITag��
p.enemyUIArray = nil;		--�ж���ӪվλUITag��

p.imageMask = nil			--�����ɰ���Ч

local isPVE = false;
local isActive = false;
local useParallelBatch = true; --�Ƿ�ʹ�ò�������

local BATTLE_PVE = 1;
local BATTLE_PVP = 2;
local MIN_RAGE_NUM = 0;     --ŭ��ֵ��Сֵ
local MAX_RAGE_NUM = 100;   --ŭ��ֵ���ֵ

--��ʼս������:pve
function p.play_pve()
	isPVE = true;	
	p.createHeroCamp();
	p.createEnemyCamp();
	p.GetBoss():SetBossFlag( true );	
end

--��ʼս������:pvp
function p.play_pvp()
	isPVE = false;
	card_battle_stage.Init();
	p.ShowTurnNum();
	card_battle_stage.EnterBattle_Stage_Loading();
	p.SendStartBattleReq( BATTLE_PVP );
end

--��ʾ�غ���
function p.ShowTurnNum()
    local turnNum = card_battle_stage.turnNum - 1;
    local pic = GetPictureByAni( "card_battle.turn_num", turnNum); 
    card_battle_mainui.turnNumNode:SetPicture( pic );
    card_battle_mainui.turnNumNode:AddActionEffect("card_battle.blow_up");
end

--Ӣ�۶��鷢������
function p.HeroTeamSkill()
    if p.heroRageNum == MAX_RAGE_NUM then
        p.heroRageNum = MIN_RAGE_NUM;
        card_battle_show.DoEffectHeroTeamSkill();
    	card_battle_mainui.heroRage:SetValue( MIN_RAGE_NUM, MAX_RAGE_NUM, p.heroRageNum );
    end
end

--�з����鷢������
function p.EnemyTeamSkill()
    if p.enemyRageNum == MAX_RAGE_NUM then
        p.enemyRageNum = MIN_RAGE_NUM;
        card_battle_show.DoEffectEnemyTeamSkill();
    	card_battle_mainui.enemyRage:SetValue( MIN_RAGE_NUM, MAX_RAGE_NUM, p.enemyRageNum );
    end
end

--���¶����ŭ��ֵ
function p.UpdateTeamRage( camp, num )
    --Ӣ�۷�
    if camp == E_CARD_CAMP_HERO then
        p.heroRageNum = p.heroRageNum + num;
        if p.heroRageNum >= MAX_RAGE_NUM then
        	p.heroRageNum = MAX_RAGE_NUM;
        end
        card_battle_mainui.heroRage:SetValue( MIN_RAGE_NUM, MAX_RAGE_NUM, p.heroRageNum );
    
    --�з�
    elseif camp == E_CARD_CAMP_ENEMY then   
        p.enemyRageNum = p.enemyRageNum + num;
        if p.enemyRageNum >= MAX_RAGE_NUM then
            p.enemyRageNum = MAX_RAGE_NUM;
        end
        card_battle_mainui.enemyRage:SetValue( MIN_RAGE_NUM, MAX_RAGE_NUM, p.enemyRageNum );
    end
end

--ȡս����
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

--����սʿ���ݵ���Ӧ
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

--������Ӧ:DOT����
function p.ReceiveBattle_SubTurnStage_Dot( msg )
    --dump_obj( msg );
end

--�������ֽ׶�
function p.EnterBattle_Stage_Hand()
    --���ֽ׶α���
    p.Battle_Stage_Hand_Skill_hero = card_battle_server.GetHandStageData( E_CARD_CAMP_HERO );
    p.Battle_Stage_Hand_Skill_enemy = card_battle_server.GetHandStageData( E_CARD_CAMP_ENEMY );
	card_battle_show.DoEffectBattle_Stage_Hand();
	
	--card_battle_mainui.OnBattleShowFinished();
end

--�����ӻغϽ׶Σ�DOT����
function p.EnterBattle_SubTurnStage_Dot()
    card_battle_mainui.OnBattleShowFinished();
	--card_battle_show.DoEffectBattle_SubTurnStage_Dot();
end

--�����ӻغϽ׶Σ�Ӣ�۷�SKILL���֣����û��ֶ�����ʱ����
function p.HeroTriggerSkills( heroId )
    p.SendBattle_Hero_SkillReq( heroId );
end

--�����ӻغϽ׶Σ��з�SKILL���֣��Զ���������
function p.EnemyTriggerSkills()
	--�з����ܱ���
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

--�����ӻغϽ׶Σ�Atk����
function p.EnterBattle_SubTurnStage_Atk()
    --��������
    p.SendBattle_SubTurnStage_AtkReq();
end

--�غϽ׶ν���
function p.EnterBattle_TurnStage_End()
    p.SendBattle_TurnStage_EndReq();
end

--SKILL��������
function p.SendBattle_Hero_SkillReq( heroId )
    --[[
    local skillResult = msg_battle_turn_skill:new();
    skillResult:Process();
    --]]
    p.ReceiveBattle_Hero_SkillRes( heroId );
end

--SKILL������Ӧ
function p.ReceiveBattle_Hero_SkillRes( heroId )
    --[[
    if msg ~= nil and card_battle_stage.IsBattle_TurnStage_Hero() then
        --�����ӻغϽ׶Σ�SKILL����
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

--ATK��������
function p.SendBattle_SubTurnStage_AtkReq()
	local turnAtk = msg_battle_turn_atk:new();
    turnAtk:Process();
end

--ATK������Ӧ
function p.ReceiveBattle_SubTurnStage_AtkRes( msg )
    --�����ӻغϽ׶Σ�ATK����
    local atkData;
    if card_battle_stage.IsBattle_TurnStage_Hero() then
    	atkData = card_battle_server.GetAtkData( E_CARD_CAMP_HERO );
    elseif card_battle_stage.IsBattle_TurnStage_Enemy() then	
        atkData = card_battle_server.GetAtkData( E_CARD_CAMP_ENEMY );
    end
    card_battle_show.DoEffectBattle_SubTurnStage_Atk( atkData );
end

--��ս�غϽ�������
function p.SendBattle_TurnStage_EndReq()
	local turnEnd = msg_battle_turn_end:new();
    turnEnd:Process();
end

--��ս�غϽ�����Ӧ
function p.ReceiveBattle_TurnStage_EndRes()
    --������һ���غ�
    card_battle_stage.NextTurn();
    card_battle_stage.EnterBattle_TurnStage_Hero();
    card_battle_stage.EnterBattle_SubTurnStage_Dot();
    
    p.ShowTurnNum();
    
    card_battle_show.UpdateSkillNum();
    
    --�ӻغϽ׶Σ�DOT����
    p.EnterBattle_SubTurnStage_Dot();
end

--��ȡӢ��
function p.GetHeroes( fighters )
	local t = {};
	for k, v in ipairs(fighters) do
		if v.id_camp == 1 then
			t[#t+1] = v;
		end
	end
	return t;
end

--��ȡ����
function p.GetEnemies( fighters )
	local t = {};
	for k, v in ipairs(fighters) do
		if v.id_camp == 2 then
			t[#t+1] = v;
		end
	end
	return t;
end

--���Ӣ�ۣ���������ʹ��
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
         --�Ƿ���Է�������
        if hero.skillnum == 0 then
            if true and math.random( 1, 2 ) == 1 then
                --��Ҫѡ��Ŀ�깥��
                p.tempSkillHero = hero;
                p.waitingSelectTarge = true;
                card_battle_show.DoEffectSelectTargetEnemy();
            else
            	--��������
                p.HeroTriggerSkills( hero.idFighter );
            end
        end
    end
end

--����ɰ�ͼƬ
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

--��ʾ�ɰ�
function p.ShowMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(true);
		p.imageMask:AddActionEffect("x.imageMask_fadein");
	end
end

--����ʾ�ɰ�
function p.HideMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(false);
		p.imageMask:AddActionEffect("x.imageMask_fadeout");
	end
end

--[[
--ȡboss
function p.GetBoss()
	return p.enemyCamp:GetFirstFighter();
end
--]]

--�Ƿ�active
function p.IsActive()
    return isActive;
end

--ȡ��һ��hero
function p.GetFirstHero()
	return p.heroCamp:GetFirstFighter();
end

--ȡ��һ��enemy
function p.GetFirstEnemy()
	return p.enemyCamp:GetFirstFighter();
end

--���������Ӫ
function p.createHeroCamp()
	p.heroCamp = card_battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray, p.heroes );
end

--�����ж���Ӫ
function p.createEnemyCamp()
	p.enemyCamp = card_battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	p.enemyCamp:AddFighters( p.enemyUIArray, p.enemies );
end

--����PVP
function p.TestPVP()
	for i=1,100 do
		p.FightOnce_PVP( true );
		p.FightOnce_PVP( false );
	end
end

--���������һ��(PVP)
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

--����fighter
function p.FindFighter(id)
	local f = p.heroCamp:FindFighter(id);
	if f == nil then
		f = p.enemyCamp:FindFighter(id);
	end
	return f;
end

--ս��ʤ��
function p.OnBattleWin()
	--GetBattleShow():Stop();
	SetTimerOnce( p.OpenBattleWin, 2.0f );
end

--��ս��ʤ������
function p.OpenBattleWin()
	PlayEffectSoundByName( "battle_win.mp3" );
	dlg_battle_win.ShowUI();
end

--ս��ʧ��
function p.OnBattleLose()
	--GetBattleShow():Stop();
	SetTimerOnce( p.OpenBattleLose, 2.0f );
end

--��ս��ʧ�ܽ���
function p.OpenBattleLose()
	dlg_battle_lose.ShowUI();
end

--����Ƿ�ս��ʤ��
function p.CheckBattleWin()
	if p.enemyCamp:IsAllFighterDead() then
		p.OnBattleWin();
		return true;
	end
	return false;
end

--����Ƿ�ս��ʧ��
function p.CheckBattleLose()
	if p.heroCamp:IsAllFighterDead() then
		p.OnBattleLose();
		return true;
	end
	return false;
end

--����ս��
function p.EnterBattle()
	WriteCon( "card_battle_mgr.EnterBattle()" );
	
	--���ص�ͼ������UI
	if GetTileMap() ~= nil then
		GetTileMap():SetVisible( false );
	end
	task_map_mainui.HideUI();
	
	--enter PVP
	card_battle_mainui.ShowUI();
	card_battle_pvp.ShowUI();	
	
	--����
	PlayMusic_Battle();
	
	isActive = true;
end

--�˳�ս��
function p.QuitBattle()
	WriteCon( "card_battle_mgr.QuitBattle()" );
	
	--�ر�ս������
	--card_battle_pve.CloseUI();
	card_battle_pvp.CloseUI();
	card_battle_mainui.CloseUI();
	
	--��ʾ������͵�ͼ
	if GetTileMap() ~= nil then
	    GetTileMap():SetVisible( true );
    end
	task_map_mainui.ShowUI();
	hud.FadeIn();
	
	--����
	PlayMusic_Task();
	
	isActive = false;
end

--���ս������
function p.IsBattleEnd()
	if p.heroCamp:IsAllFighterDead() then return true end
	if p.enemyCamp:IsAllFighterDead() then return true end
	return false;
end
--[[
--Ӣ�ۻغ�
function p.HeroTurn()
	p.CampBattle(E_CARD_CAMP_HERO);
end

--���˻غ�
function p.EnemyTurn()
	p.CampBattle(E_CARD_CAMP_ENEMY);
end

function p.CampBattle(campType)
	--������Ӫ
	local atkCamp;
	--������Ӫ
	local defenseCamp;
	
	if campType==E_CARD_CAMP_HERO then
		atkCamp = p.heroCamp;
		defenseCamp = p.enemyCamp;
	else
		atkCamp = p.enemyCamp;
		defenseCamp = p.heroCamp;
	end
	
	--�ȼ�¼��ʱѪ��
	local defenceFighters = defenseCamp:GetAliveFighters();
	for i=1, #defenceFighters do
		defenceFighters[i]:SetTmpLife();
	end
	
	--��ȡδ������սʿ
	local atkCampAliveFighter = atkCamp:GetAliveFighters();
	
	local prevBatch = nil;
	for i = 1, #atkCampAliveFighter do
		local batch = battle_show.GetNewBatch();
		local attacker = atkCampAliveFighter[i];
		
		--ÿ������ȡĿ��fighters��ȷ�����ǻ��
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
		
		--�������εȴ�
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