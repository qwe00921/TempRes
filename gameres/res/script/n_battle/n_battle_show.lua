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
        	p.SimpleAtk( hero, TCamp, Targets, batch );
        else	
            n_battle_skill.Skill( hero, SkillId, distance, Targets, TCamp, batch );
        end
        
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

--��ͨ����
function p.SimpleAtk( hero, TCamp, Targets, batch )
	for key, var in ipairs(Targets) do
        local enemy = nil; --�ܻ���
        if TCamp == E_CARD_CAMP_HERO then
            enemy = n_battle_mgr.heroCamp:FindFighter( tonumber( var.TPos ) );
        elseif TCamp == E_CARD_CAMP_ENEMY then
            enemy = n_battle_mgr.enemyCamp:FindFighter( tonumber( var.TPos ) + N_BATTLE_CAMP_CARD_NUM );
        end
        local Damage = tonumber( var.Damage ); --�۳�Ѫ��
        local RemainHp = tonumber( var.RemainHp ); --��ʣѪ��
        local Crit = var.Crit ; --����
        local Dead = var.TargetDead;--����
        local distance = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", hero.cardId, "distance" ) );
        --�ܻ�������
        --[[
        if Dead and Damage < enemy.life then
            Damage = enemy.life;
            WriteConWarning("the TargetFighter Mandatory death!");
        end
        --]]
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
        
        n_battle_pet_skill.skill( UCamp, TCamp, Pos, SkillId, Targets, Rage, batch);
        
    end
end

--BUFF����
function p.DoEffectBuff( buffData )
	if buffData == nil then
		return false;
	end
	local batch = battle_show.GetNewBatch();
	for key, var in ipairs( buffData ) do
	   local seqTarget = batch:AddParallelSequence();
	   
	   local Camp = tonumber( var.Camp );
	   local Pos = tonumber( var.Pos );
	   local BuffType = tonumber( var.Buff_type );
	   local Damage = tonumber( var.Damage );
	   local RemainHp = tonumber( var.RemainHp );
	   
	   local targetF;
       if Camp == E_CARD_CAMP_HERO then
           targetF = n_battle_mgr.heroCamp:FindFighter( Pos );
       elseif Camp == E_CARD_CAMP_ENEMY then
           targetF = n_battle_mgr.enemyCamp:FindFighter( Pos + N_BATTLE_CAMP_CARD_NUM );
       end
	   
	   local cmdBuffEffect;
	   if BuffType == N_BUFF_TYPE_4 or BuffType == N_BUFF_TYPE_5 then
            targetF:cmdLua( "fighter_damage",  Damage, "", seqTarget );
       elseif BuffType == N_BUFF_TYPE_9 then 
            targetF:cmdLua( "fighter_addHp", Damage, "", seqTarget );
       end
	   local cmdBuffIcon = p.UpdateBuffIcon( targetF, BuffType, seqTarget );
	   if cmdBuffEffect ~= nil then
	   	   cmdBuffIcon:SetWaitEnd( cmdBuffEffect );
	   end
	end
end

function p.UpdateBuffIcon( target, BuffType, seq )
    if target == nil or BuffType == nil then
    	return nil;
    end
    local cmd;
    local isDel = true;
    local targetPos = target.idFighter;
    local buffAni = GetBuffAniByType( BuffType );
	local rounds = n_battle_stage.GetRoundNum();
    local buffData = n_battle_db_mgr.GetBuffRoundDB( rounds );
    if buffData ~= nil and #buffData > 0 and rounds <= N_BATTLE_MAX_ROUND then
        for key, var in ipairs(buffData) do
        	local camp = tonumber( var.Camp );
        	local pos = tonumber( var.Pos );
        	local btype = tonumber( var.Buff_type );
        	if camp == E_CARD_CAMP_ENEMY then
        		pos = pos + N_BATTLE_CAMP_CARD_NUM;
        	end
        	if targetPos == pos and BuffType == btype then
        		isDel = false;
        		break;
        	end
        end
    end
    if isDel then
    	cmd = createCommandEffect():DelEffect( 0, target:GetNode(), buffAni );
        seq:AddCommand( cmd );
    end
    return cmd;
end

