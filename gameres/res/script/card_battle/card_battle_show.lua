--------------------------------------------------------------
-- FileName: 	card_battle_show.lua
-- author:		hst, 2013��8��31��
-- purpose:		���ƶ�ս����չʾ
--------------------------------------------------------------

card_battle_show = {}
local p = card_battle_show;

--���ֽ׶α���
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

--�غϽ׶�DOT����
function p.DoEffectBattle_SubTurnStage_Dot()
    local batch = battle_show.GetNewBatch();
    local seqDot = batch:AddParallelSequence();
    local fighters;

    --DOT->Ӣ�۷�
    if card_battle_stage.IsBattle_TurnStage_Hero() then
        fighters = card_battle_mgr.heroCamp:GetAliveFighters();

    --DOT->�жԷ�
    elseif card_battle_stage.IsBattle_TurnStage_Enemy() then
        fighters = card_battle_mgr.enemyCamp:GetAliveFighters();
    end

    for k, v in ipairs(fighters) do
        --ƮѪ
        local cmd11 = v:cmdLua( "fighter_damage", 80, "", seqDot );
    end
end

--�غϽ׶�Skill���֣�Ŀǰֻ�ез�����
--@param events [array]���Ʒ����ļ����¼�
function p.DoEffectBattle_SubTurnStage_Skill( camp, events )
    local batch = battle_show.GetNewBatch();
    local seqSkill = batch:AddSerialSequence();
    
    for k, v in ipairs(events) do
    	--������
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
                --�ܻ���
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
                    
                    --ƮѪ
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
	
	--����Z����
	--card_battle_zorder.SortZOrder();
end

--ŭ��ֵ����ONE TO ONE
function p.DoEffectOneToOne( atkFighter, targetfighter )
	local batch = battle_show.GetNewBatch();
    card_battle_skill.AtkSkillOneToOne( atkFighter, targetfighter, batch );
end

--����ѡ��Ҫ�����ĵз�����
function p.DoEffectSelectTargetEnemy()
	local enemyCampAlive = card_battle_mgr.enemyCamp:GetAliveFighters();
	for k, v in ipairs(enemyCampAlive) do
		v:GetPlayerNode():AddFgEffect("card_battle.select_card_icon");
		--v:GetPlayerNode():AddActionEffect("ui_cmb.common_move");
	end
end

--�رյз�����ѡ��
function p.DoEffectCloseSelectTargetEnemy()
    local enemyCampAlive = card_battle_mgr.enemyCamp:GetAliveFighters();
    for k, v in ipairs(enemyCampAlive) do
        v:GetPlayerNode():DelAniEffect("card_battle.select_card_icon");
    end
end

--�غϽ׶�ATK����
--@param events [array]���Ʒ�����ATk�¼�
function p.DoEffectBattle_SubTurnStage_Atk( events )
    --��ʱʹ�ã�ԭ��msg_battle_turn_atk.luaд��ΪӢ�۴�з�����
    --[[
    if card_battle_stage.IsBattle_TurnStage_Enemy() then
        p.DoEffectSubTurnStageAtkByEnemy();--��ʱ����
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
            
            --ATK->Ӣ�۷�
            if card_battle_stage.IsBattle_TurnStage_Hero() then
                --������
                atkFighter = card_battle_mgr.heroCamp:FindFighter( atkFighterId );

                --�ܻ���
                targetFighter = card_battle_mgr.enemyCamp:FindFighter( targetFighterId );

            --ATK->�жԷ�
            elseif card_battle_stage.IsBattle_TurnStage_Enemy() then
                --������
                atkFighter = card_battle_mgr.enemyCamp:FindFighter( atkFighterId );

                --�ܻ���
                targetFighter = card_battle_mgr.heroCamp:FindFighter( targetFighterId );
            end
            if targetFighter:CheckTmpLife() then
                card_battle_skill.Atk( atkFighter, targetFighter, batch );
                
                 --�������εȴ�
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

--Ӣ�۶���ŭ������
function p.DoEffectHeroTeamSkill()
    local batch = battle_show.GetNewBatch();
	card_battle_skill.TeamSkill( E_CARD_CAMP_HERO, batch );
end

--�з�����ŭ������
function p.DoEffectEnemyTeamSkill()
    local batch = battle_show.GetNewBatch();
	card_battle_skill.TeamSkill( E_CARD_CAMP_ENEMY, batch );
end

--���¼�����ȴʱ��
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

--�з�����SKILL���֣��Զ�����
function p.DoEffectBattle_Enemy_SubTurnStage_Skill()
    local batch = battle_show.GetNewBatch();
    local seqSkill = batch:AddSerialSequence();

    --������
    local atkFighter = card_battle_mgr.enemyCamp:FindFighter( 201 );

    local cmd1 = createCommandEffect():AddActionEffect( 0, atkFighter:GetPlayerNode(), "card_battle.blow_up" );
    seqSkill:AddCommand( cmd1 );

    --�ܻ���
    local targetFighter = card_battle_mgr.heroCamp:FindFighter( 101 );

    --ƮѪ
    local cmd2 = targetFighter:cmdLua( "fighter_damage", 80, "", seqSkill );
end
