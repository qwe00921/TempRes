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
        local SkillId = tonumber( v.SkillId );--发动技能的id
        local distance = tonumber( SelectCell( T_SKILL_RES, SkillId, "distance" ) );--远程与近战的判断
        
        local hero = nil; --攻击者
            
        if UCamp == E_CARD_CAMP_HERO then
            hero = n_battle_mgr.heroCamp:FindFighter( UPos );
        elseif UCamp == E_CARD_CAMP_ENEMY then
            hero = n_battle_mgr.enemyCamp:FindFighter( UPos + N_BATTLE_CAMP_CARD_NUM );
        end
        
        --普通攻击
        if SkillId == 0 then
        	p.SimpleAtk( hero, distance, TCamp, Targets, batch );
        else	
            n_battle_skill.Skill( hero, SkillId, distance, Targets, TCamp, batch );
        end
    end
end

--普通攻击
function p.SimpleAtk( hero, distance, TCamp, Targets, batch )
	for key, var in ipairs(Targets) do
        local enemy = nil; --受击者
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
        n_battle_atk.Atk( hero, distance, enemy, batch, Damage );
    end
end

--双方宠物技能表现
function p.DoEffectPetSkill( petSkillData )
    if petSkillData == nil and not n_battle_stage.IsBattle_RoundStage_Pet() then
        WriteConWarning("DoEffectPetSkill err!");
        return false;
    end
    --local prevBatch = nil;
    for k, v in ipairs(petSkillData) do
        local batch = battle_show.GetNewBatch();
            
        local UCamp = tonumber(v.UCamp); --攻方阵营
        local TCamp = tonumber(v.TCamp); --守方阵营
        local PetId = tonumber(v.PetId); --宠物ID
        local Pos = tonumber( v.Pos );--ui索引
        local SkillId = tonumber(v.SkillId); --宠物技能ID
        local Targets = v.TargetSet; --受击卡牌列表
        local Rage = tonumber( v.Rage ); --技能消耗怒气
        
        if Rage > 0 then
            local petRageUIId = Pos;
            if UCamp == E_CARD_CAMP_ENEMY then
            	petRageUIId = petRageUIId + N_BATTLE_CAMP_CARD_NUM;
            end
        	n_battle_pvp.UpdatePetRage( petRageUIId, -Rage );
        end
        
        n_battle_pet_skill.skill( UCamp, TCamp, Pos, SkillId, Targets, Rage, batch);
        
        --设置批次等待
        --[[
        if prevBatch ~= nil then
            local cmdSpecial = prevBatch:GetSpecialCmd( E_BATCH_STAGE_HURT_END );
            if cmdSpecial ~= nil then
               batch:SetWaitEnd( cmdSpecial );
            end
         end
         prevBatch = batch;
         --]]
    end
end