--------------------------------------------------------------
-- FileName:    n_battle_show.lua
-- author:      hst, 2013年11月26日
-- purpose:     卡牌对战表现展示
--------------------------------------------------------------

n_battle_show = {}
local p = n_battle_show;

--相方互殴表现
function p.DoEffectAtk( atkData )
    if atkData == nil and not n_battle_stage.IsBattle_RoundStage_Atk() then
        return false;
	end
    local prevBatch = nil;
    for k, v in ipairs(atkData) do
        local batch = battle_show.GetNewBatch();
            
        local UCamp = tonumber(v.UCamp); --攻方阵营
        local TCamp = tonumber(v.TCamp); --守方阵营
        local UPos = tonumber(v.UPos); --攻方卡牌的位置
        local Targets = v.TargetSet; --受击卡牌列表
        
        local hero = nil; --攻击者
        local enemy = nil; --受击者
            
        if UCamp == E_CARD_CAMP_HERO then
            hero = n_battle_mgr.heroCamp:FindFighter( UPos );
        elseif UCamp == E_CARD_CAMP_ENEMY then
            hero = n_battle_mgr.enemyCamp:FindFighter( UPos + N_BATTLE_CAMP_CARD_NUM );
        end
        
        --[[
        --群体技能
        local skillObj = n_battle_skill:new();
        skillObj:Init();
        skillObj:SkillAOE( hero, Targets, TCamp, batch );
        --设置批次等待
        if prevBatch ~= nil then
           local cmdSpecial = prevBatch:GetSpecialCmd( E_BATCH_STAGE_HURT_END );
           if cmdSpecial ~= nil then
               batch:SetWaitEnd( cmdSpecial );
           end
        end
        prevBatch = batch;
        --]]
        for key, var in ipairs(Targets) do
            if TCamp == E_CARD_CAMP_HERO then
                enemy = n_battle_mgr.heroCamp:FindFighter( tonumber( var.TPos ) );
            elseif TCamp == E_CARD_CAMP_ENEMY then
                enemy = n_battle_mgr.enemyCamp:FindFighter( tonumber( var.TPos ) + N_BATTLE_CAMP_CARD_NUM );
            end
            local Damage = tonumber( var.Damage ); --扣除血量
            local RemainHp = tonumber( var.RemainHp ); --所剩血量
            local Crit = tonumber( var.Crit ); --暴击
            local Dead = var.TargetDead;--死亡
            --受击者死亡
            if Dead and Damage < enemy.life then
                Damage = enemy.life;
                WriteConWarning("the TargetFighter Mandatory death!");
            end
                
            n_battle_atk.Atk( hero, enemy, batch, Damage );
            --local skillObj = n_battle_skill:new();
            --skillObj:Init();
            --skillObj:SkillSingle( hero, enemy, Damage, batch );
                
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

--双方宠物技能表现
function p.DoEffectPetSkill( petSkillData )
    if petSkillData == nil and not n_battle_stage.IsBattle_RoundStage_Pet() then
        return false;
    end
    local prevBatch = nil;
            
    for k, v in ipairs(petSkillData) do
        local batch = battle_show.GetNewBatch();
            
        local UCamp = tonumber(v.UCamp); --攻方阵营
        local TCamp = tonumber(v.TCamp); --守方阵营
        local PetId = tonumber(v.PetId); --宠物ID
        local SkillId = tonumber(v.SkillId); --宠物技能ID
        local Targets = v.TargetSet; --受击卡牌列表
        
        n_battle_pet_skill.skill(UCamp, TCamp, PetId, SkillId, Targets, batch);
        
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