--------------------------------------------------------------
-- FileName:    n_battle_show.lua
-- author:      hst, 2013��11��26��
-- purpose:     ���ƶ�ս����չʾ
--------------------------------------------------------------

n_battle_show = {}
local p = n_battle_show;

--�෽��Ź����
function p.DoEffectAtk( atkData )
    if atkData == nil and not n_battle_stage.IsBattle_RoundStage_Atk() then
        return false;
	end
    local prevBatch = nil;
    for k, v in ipairs(atkData) do
        local batch = battle_show.GetNewBatch();
            
        local UCamp = tonumber(v.UCamp); --������Ӫ
        local TCamp = tonumber(v.TCamp); --�ط���Ӫ
        local UPos = tonumber(v.UPos); --�������Ƶ�λ��
        local Targets = v.TargetSet; --�ܻ������б�
        local SkillId = tonumber( v.SkillId );--�������ܵ�id
        local distance = tonumber( SelectCell( T_SKILL_RES, SkillId, "distance" ) );--Զ�����ս���ж�
        
        local hero = nil; --������
            
        if UCamp == E_CARD_CAMP_HERO then
            hero = n_battle_mgr.heroCamp:FindFighter( UPos );
        elseif UCamp == E_CARD_CAMP_ENEMY then
            hero = n_battle_mgr.enemyCamp:FindFighter( UPos + N_BATTLE_CAMP_CARD_NUM );
        end
        
        --��ͨ����
        if SkillId == 0 then
        	p.SimpleAtk( hero, distance, TCamp, Targets, batch );
        else	
            n_battle_skill.Skill( hero, SkillId, distance, Targets, TCamp, batch );
        end
    end
end

--��ͨ����
function p.SimpleAtk( hero, distance, TCamp, Targets, batch )
	for key, var in ipairs(Targets) do
        local enemy = nil; --�ܻ���
        if TCamp == E_CARD_CAMP_HERO then
            enemy = n_battle_mgr.heroCamp:FindFighter( tonumber( var.TPos ) );
        elseif TCamp == E_CARD_CAMP_ENEMY then
            enemy = n_battle_mgr.enemyCamp:FindFighter( tonumber( var.TPos ) + N_BATTLE_CAMP_CARD_NUM );
        end
        local Damage = tonumber( var.Damage ); --�۳�Ѫ��
        local RemainHp = tonumber( var.RemainHp ); --��ʣѪ��
        local Crit = tonumber( var.Crit ); --����
        local Dead = var.TargetDead;--����
        --�ܻ�������
        if Dead and Damage < enemy.life then
            Damage = enemy.life;
            WriteConWarning("the TargetFighter Mandatory death!");
        end
        n_battle_atk.Atk( hero, distance, enemy, batch, Damage );
    end
end

--˫�����＼�ܱ���
function p.DoEffectPetSkill( petSkillData )
    if petSkillData == nil and not n_battle_stage.IsBattle_RoundStage_Pet() then
        WriteConWarning("DoEffectPetSkill err!");
        return false;
    end
    --local prevBatch = nil;
    for k, v in ipairs(petSkillData) do
        local batch = battle_show.GetNewBatch();
            
        local UCamp = tonumber(v.UCamp); --������Ӫ
        local TCamp = tonumber(v.TCamp); --�ط���Ӫ
        local PetId = tonumber(v.PetId); --����ID
        local Pos = tonumber( v.Pos );--ui����
        local SkillId = tonumber(v.SkillId); --���＼��ID
        local Targets = v.TargetSet; --�ܻ������б�
        local Rage = tonumber( v.Rage ); --��������ŭ��
        
        if Rage > 0 then
            local petRageUIId = Pos;
            if UCamp == E_CARD_CAMP_ENEMY then
            	petRageUIId = petRageUIId + N_BATTLE_CAMP_CARD_NUM;
            end
        	n_battle_pvp.UpdatePetRage( petRageUIId, -Rage );
        end
        
        n_battle_pet_skill.skill( UCamp, TCamp, Pos, SkillId, Targets, Rage, batch);
        
        --�������εȴ�
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