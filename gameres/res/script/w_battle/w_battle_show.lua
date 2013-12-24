--------------------------------------------------------------
-- FileName:    n_battle_show.lua
-- author:      hst, 2013年11月26日
-- purpose:     卡牌对战表现展示
--------------------------------------------------------------

n_battle_show = {}
local p = n_battle_show;
p.flyRoundNumNode = nil;

function p.DestroyAll()
	p.flyRoundNumNode = nil;
end

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
        	p.SimpleAtk( hero, TCamp, Targets, batch );
        else	
            n_battle_skill.Skill( hero, SkillId, distance, Targets, TCamp, batch );
        end
        
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

--普通攻击
function p.SimpleAtk( hero, TCamp, Targets, batch )
	for key, enemy in ipairs(Targets) do
        n_battle_atk.Atk( hero, enemy, TCamp, batch );
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
        
        n_battle_pet_skill.skill( UCamp, TCamp, Pos, SkillId, Targets, Rage, batch);
        
    end
end

--BUFF表现
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
            cmdBuffEffect = targetF:cmdLua( "fighter_damage",  Damage, "", seqTarget );
       elseif BuffType == N_BUFF_TYPE_9 then 
            cmdBuffEffect = targetF:cmdLua( "fighter_addHp", Damage, "", seqTarget );
       end
       --[[
	   local cmdBuffIcon = p.UpdateBuffIcon( targetF, BuffType, seqTarget );
	   if cmdBuffEffect ~= nil and cmdBuffIcon ~= nil then
	   	   cmdBuffIcon:SetWaitEnd( cmdBuffEffect );
	   end
	   --]]
	end
end

function p.UpdateBuffIcon( target, BuffType, seq )
    WriteConWarning("=================UpdateBuffIcon================");
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
        WriteConWarning("del effect id ====="..targetPos);
    	cmd = createCommandEffect():DelEffect( 0, target:GetNode(), buffAni );
        seq:AddCommand( cmd );
    end
    return cmd;
end

function p.DoEffectShowTurnNum()
	local roundNum = n_battle_stage.GetRoundNum();
    if p.flyRoundNumNode == nil then
        p.flyRoundNumNode = n_battle_round_num:new();
        p.flyRoundNumNode:InitWithImageNode( n_battle_mainui.roundNumNode );
    end
    p.flyRoundNumNode:PlayNum( roundNum );
end

