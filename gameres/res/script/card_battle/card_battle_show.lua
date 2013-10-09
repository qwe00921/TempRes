--------------------------------------------------------------
-- FileName: 	card_battle_show.lua
-- author:		hst, 2013年8月31日
-- purpose:		卡牌对战表现展示
--------------------------------------------------------------

card_battle_show = {}
local p = card_battle_show;

--起手阶段表现
function p.DoEffectBattle_Stage_Hand()
    local handSkillHero = card_battle_mgr.Battle_Stage_Hand_Skill_hero;
    local handSkillEnemy = card_battle_mgr.Battle_Stage_Hand_Skill_enemy;
    
    if handSkillHero == nil and handSkillHero == nil then
        card_battle_mainui.OnBattleShowFinished();
        return ;
    end
    local batch = battle_show.GetNewBatch();
    card_battle_skill.HeadSkill( batch, handSkillHero );
    card_battle_skill.HeadSkill( batch, handSkillEnemy );
end

--回合阶段DOT表现
function p.DoEffectBattle_SubTurnStage_Dot()
    local batch = battle_show.GetNewBatch();
    local seqDot = batch:AddParallelSequence();
    local fighters;

    --DOT->英雄方
    if card_battle_stage.IsBattle_TurnStage_Hero() then
        fighters = card_battle_mgr.heroCamp:GetAliveFighters();

    --DOT->敌对方
    elseif card_battle_stage.IsBattle_TurnStage_Enemy() then
        fighters = card_battle_mgr.enemyCamp:GetAliveFighters();
    end

    for k, v in ipairs(fighters) do
        --飘血
        local cmd11 = v:cmdLua( "fighter_damage", 80, "", seqDot );
    end
end

--回合阶段Skill表现：目前只有敌方在用
--@param events [array]卡牌发动的技能事件
function p.DoEffectBattle_SubTurnStage_Skill( camp, events )
    local batch = battle_show.GetNewBatch();
    local seqSkill = batch:AddSerialSequence();
    
    for k, v in ipairs(events) do
    	--攻击者
        local atkFighterId = tonumber( v.card_id );
        local atkFighter;
        
        if camp == E_CARD_CAMP_HERO then
            atkFighter = card_battle_mgr.heroCamp:FindFighter( atkFighterId );
        elseif camp == E_CARD_CAMP_ENEMY then
            atkFighter = card_battle_mgr.enemyCamp:FindFighter( atkFighterId );
        end
        
        if atkFighter:IsAlive() then
            local cmd1 = createCommandEffect():AddActionEffect( 0, atkFighter:GetPlayerNode(), "card_battle.blow_up" );
            seqSkill:AddCommand( cmd1 );
            for _k, _v in ipairs(v.targets) do
                local seqHurt =   batch:AddParallelSequence();
                --受击者
                local targetFighterId = tonumber( _v.card_id );
                local targetFighter;
                if camp == E_CARD_CAMP_HERO then
                    targetFighter = card_battle_mgr.enemyCamp:FindFighter( targetFighterId );
                elseif camp == E_CARD_CAMP_ENEMY then
                    targetFighter = card_battle_mgr.heroCamp:FindFighter( targetFighterId );
                end
    
                if targetFighter:IsAlive() and targetFighter:CheckTmpLife() then
                    local cmd10 = createCommandEffect():AddFgEffect( 0.01, targetFighter:GetPlayerNode(), "card_battle.b_z" );
                    seqHurt:AddCommand( cmd10 );
                    
                    --飘血
                    local cmd11 = targetFighter:cmdLua( "fighter_damage", 100, "", seqHurt );
                    card_battle_skill.HurtResultAni( targetFighter, seqSkill );
                end
                seqHurt:SetWaitEnd( cmd1 );
            end
            if camp == E_CARD_CAMP_HERO then
                atkFighter:GetPlayerNode():DelAniEffect("card_battle.card_border_fx");
            end
            atkFighter.skillnum = math.random( 1, 4 );
            local pic = GetPictureByAni("card_battle.skill_num", atkFighter.skillnum - 1); 
            atkFighter.skillbar:SetPicture( pic );
            atkFighter.skillbar:SetVisible( true );
        end
    end
	
	--开启Z排序
	--card_battle_zorder.SortZOrder();
end

--怒气值技能ONE TO ONE
function p.DoEffectOneToOne( atkFighter, targetfighter )
	local batch = battle_show.GetNewBatch();
    card_battle_skill.AtkSkillOneToOne( atkFighter, targetfighter, batch );
end

--开启选择要攻击的敌方卡牌
function p.DoEffectSelectTargetEnemy()
	local enemyCampAlive = card_battle_mgr.enemyCamp:GetAliveFighters();
	for k, v in ipairs(enemyCampAlive) do
		v:GetPlayerNode():AddFgEffect("card_battle.select_card_icon");
		--v:GetPlayerNode():AddActionEffect("ui_cmb.common_move");
	end
end

--关闭敌方卡牌选择
function p.DoEffectCloseSelectTargetEnemy()
    local enemyCampAlive = card_battle_mgr.enemyCamp:GetAliveFighters();
    for k, v in ipairs(enemyCampAlive) do
        v:GetPlayerNode():DelAniEffect("card_battle.select_card_icon");
    end
end

--回合阶段ATK表现
--@param events [array]卡牌发动的ATk事件
function p.DoEffectBattle_SubTurnStage_Atk( events )
    --临时使用：原因msg_battle_turn_atk.lua写死为英雄打敌方数据
    --[[
    if card_battle_stage.IsBattle_TurnStage_Enemy() then
        p.DoEffectSubTurnStageAtkByEnemy();--临时方法
        return ;
    end
    ]]

    if events ~= nil and card_battle_stage.IsBattle_SubTurnStage_Atk() then
        local prevBatch = nil;
        for k, v in ipairs(events) do
            local batch = battle_show.GetNewBatch();
            local atkFighterId = tonumber( v.card_id );
            local targetFighterId = tonumber( v.target_id );
            local atkFighter;
            local targetFighter;
            
            --ATK->英雄方
            if card_battle_stage.IsBattle_TurnStage_Hero() then
                --攻击者
                atkFighter = card_battle_mgr.heroCamp:FindFighter( atkFighterId );

                --受击者
                targetFighter = card_battle_mgr.enemyCamp:FindFighter( targetFighterId );

            --ATK->敌对方
            elseif card_battle_stage.IsBattle_TurnStage_Enemy() then
                --攻击者
                atkFighter = card_battle_mgr.enemyCamp:FindFighter( atkFighterId );

                --受击者
                targetFighter = card_battle_mgr.heroCamp:FindFighter( targetFighterId );
            end
            if targetFighter:CheckTmpLife() then
                card_battle_skill.Atk( atkFighter, targetFighter, batch );
                
                 --设置批次等待
                if prevBatch ~= nil then
                    local cmdSpecial = prevBatch:GetSpecialCmd( E_BATCH_STAGE_HURT_END );
                    if cmdSpecial ~= nil then
                        batch:SetWaitEnd( cmdSpecial );
                    end
                end
                prevBatch = batch;
            
            end
        end
    end
end

--英雄队伍怒气技能
function p.DoEffectHeroTeamSkill()
    local batch = battle_show.GetNewBatch();
	card_battle_skill.TeamSkill( E_CARD_CAMP_HERO, batch );
end

--敌方队伍怒气技能
function p.DoEffectEnemyTeamSkill()
    local batch = battle_show.GetNewBatch();
	card_battle_skill.TeamSkill( E_CARD_CAMP_ENEMY, batch );
end

--更新技能冷却时间
function p.UpdateSkillNum()
    local heroCampAlive = card_battle_mgr.heroCamp:GetAliveFighters();
    local enemyCampAlive = card_battle_mgr.enemyCamp:GetAliveFighters();
    for k, v in ipairs(heroCampAlive) do
        v.skillnum = v.skillnum - 1;
        local pic = GetPictureByAni("card_battle.skill_num", v.skillnum - 1); 
        v.skillbar:SetPicture( pic );
        
        if v.skillnum <= 0 then
            v.skillnum = 0;
            v:GetPlayerNode():AddFgEffect("card_battle.card_border_fx");
            v.skillbar:SetVisible( false );
        end
    end
    for _k, _v in ipairs(enemyCampAlive) do
        _v.skillnum = _v.skillnum - 1;
        local pic = GetPictureByAni("card_battle.skill_num", _v.skillnum - 1); 
        _v.skillbar:SetPicture( pic );
        if _v.skillnum <= 0 then
            _v.skillnum = 0;
            --_v:GetPlayerNode():AddFgEffect("card_battle.card_border_fx");
            _v.skillbar:SetVisible( false );
        end
    end
    
end

--敌方技能SKILL表现：自动触发
function p.DoEffectBattle_Enemy_SubTurnStage_Skill()
    local batch = battle_show.GetNewBatch();
    local seqSkill = batch:AddSerialSequence();

    --攻击者
    local atkFighter = card_battle_mgr.enemyCamp:FindFighter( 201 );

    local cmd1 = createCommandEffect():AddActionEffect( 0, atkFighter:GetPlayerNode(), "card_battle.blow_up" );
    seqSkill:AddCommand( cmd1 );

    --受击者
    local targetFighter = card_battle_mgr.heroCamp:FindFighter( 101 );

    --飘血
    local cmd2 = targetFighter:cmdLua( "fighter_damage", 80, "", seqSkill );
end
