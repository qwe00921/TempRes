--------------------------------------------------------------
-- FileName:    n_battle_func.lua
-- author:      hst, 2013年12月13日
-- purpose:     对战辅助函数
--------------------------------------------------------------

--通过BUFF TYPE 获取ANI
function GetBuffAniByType( buffType )
    if buffType == nil then
    	return nil;
    end
    return "n_battle_buff.buff_type_"..buffType;
    --[[
    if buffType == N_BUFF_TYPE_1 then --晕眩冰冻
    elseif buffType == N_BUFF_TYPE_2 then--冰冻
    elseif buffType == N_BUFF_TYPE_3 then--缠绕
    elseif buffType == N_BUFF_TYPE_4 then--中毒
    elseif buffType == N_BUFF_TYPE_5 then--燃烧
    elseif buffType == N_BUFF_TYPE_9 then--恢复
    elseif buffType == N_BUFF_TYPE_101 then--攻击增强
    elseif buffType == N_BUFF_TYPE_102 then--防御增强
    elseif buffType == N_BUFF_TYPE_103 then--暴击增强
    elseif buffType == N_BUFF_TYPE_201 then--攻击减弱
    elseif buffType == N_BUFF_TYPE_202 then--防御减弱
    elseif buffType == N_BUFF_TYPE_203 then--暴击减弱
    end
    --]]
end

-------------------------------------
--是否为全体攻击 
--判断标准：目标类型为：敌方群体，敌方直线，己方群体   定为全体攻击，其它为单体攻击
-------------------------------------
function IsAoeSkillByType( targetType )
    if targetType == nil then
    	return false;
    elseif targetType == N_SKILL_TARGET_TYPE_2 or targetType == N_SKILL_TARGET_TYPE_4 or targetType == N_SKILL_TARGET_TYPE_12 then	
        return true;
    else
        return false;   
    end
end


--战士从一个点跳跃到另一个点
function JumpMoveTo(atkFighter, fPos, tPos, pJumpSeq)
    local fx = "lancer_cmb.begin_battle_jump";
    
    local atkPos = fPos;
    
    local x = tPos.x - atkPos.x;
    local y = tPos.y - atkPos.y;
    local distance = (x ^ 2 + y ^ 2) ^ 0.75;
    
    -- calc start offset
    local startOffset = 0;
    local offsetX = x * startOffset / distance;
    local offsetY = y * startOffset / distance;
    --local pPos = CCPointMake(atkPos.x + offsetX, atkPos.y + offsetY );

    --self.pOriginPos = CCPointMake(targetPos.x,targetPos.y);
	local pCmd = nil;
	pCmd = battle_show.AddActionEffect_ToSequence( 0, atkFighter:GetPlayerNode(), fx,pJumpSeq);

    local varEnv = pCmd:GetVarEnv();
    varEnv:SetFloat( "$1", x );
    varEnv:SetFloat( "$2", y );
    varEnv:SetFloat( "$3", 75 );
    
    return pCmd;
end

function OnlyMoveTo(atkFighter, fPos, tPos, pSeq, pIsBack)
	local fx = "lancer_cmb.begin_battle_move";
	if pIsBack == true then
		fx = "lancer_cmb.hurt_end_move";
	end
    local atkPos = fPos;
    
    local x = tPos.x - atkPos.x;
    local y = tPos.y - atkPos.y;
    local distance = (x ^ 2 + y ^ 2) ^ 0.75;
    
    -- calc start offset
    local startOffset = 0;
    local offsetX = x * startOffset / distance;
    local offsetY = y * startOffset / distance;
    --local pPos = CCPointMake(atkPos.x + offsetX, atkPos.y + offsetY );

    --self.pOriginPos = CCPointMake(targetPos.x,targetPos.y);
	--local pCmd = nil;
	local pCmd =	createCommandEffect():AddActionEffect( 0, atkFighter:GetPlayerNode(), fx );
	pSeq:AddCommand( pCmd );
	--pCmd = battle_show.AddActionEffect_ToSequence( 0, atkFighter:GetPlayerNode(), fx,pSeq);
	--pCmd = battle_show.AddActionEffect_ToParallelSequence( 0, atkFighter:GetPlayerNode(), fx,pSeq);
    local varEnv = pCmd:GetVarEnv();
    varEnv:SetFloat( "$1", x );
    varEnv:SetFloat( "$2", y );
    
    
    return pCmd;
end;

--获取位置值最小的战士前面的坐标
function GetBestTargetPos( Hero, TCamp, Targets )
	if Targets == nil or Hero == nil or TCamp == nil then
		return nil;
	end
	local tempPosId;
	local figther;
	for key, var in ipairs(Targets) do
		local pos = tonumber( var.TPos );
		if tempPosId == nil then
		  tempPosId = pos;
		elseif tempPosId > pos then
		  tempPosId = pos;
		end
	end
	if tempPosId ~= nil then
		if TCamp == E_CARD_CAMP_HERO then
            figther = n_battle_mgr.heroCamp:FindFighter( tempPosId );
        elseif TCamp == E_CARD_CAMP_ENEMY then
            figther = n_battle_mgr.enemyCamp:FindFighter( tempPosId + N_BATTLE_CAMP_CARD_NUM );
        end
        return figther:GetFrontPos( Hero:GetPlayerNode() );
    else
        return nil;  
	end
end

--受击结果：死亡动作或站立动画
function HurtResultAni( targetFighter, seqTarget )
    if targetFighter:CheckTmpLife() then
        --local cmdA = createCommandPlayer():Standby( 0, targetFighter:GetNode(), "" );
        --seqTarget:AddCommand( cmdA );
    else
        --local cmdB = createCommandPlayer():Dead( 0, targetFighter:GetNode(), "" );
        --seqTarget:AddCommand( cmdB );   
        
        local cmdf = createCommandEffect():AddActionEffect( 0.01, targetFighter.m_kShadow, "lancer_cmb.die" );
        seqTarget:AddCommand( cmdf );
        local cmdC = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer_cmb.die" );
        seqTarget:AddCommand( cmdC );
        
    end
end

function IsSkillTargetSelfCamp( targetType )
	if targetType == nil then
		return false;
	end
	if targetType == N_SKILL_TARGET_TYPE_11 or targetType == N_SKILL_TARGET_TYPE_12 or targetType == N_SKILL_TARGET_TYPE_13 then
		return true;
	else
	   return false;	
	end
end

function AddBuffObj( target, buffType, buffAni )
    if target == nil or buffType == nil or buffAni == nil then
        return false;
    end
    local isIn = false;
    for key, var in ipairs( target.buffList ) do
        if var.id == tonumber( buffType ) then
            var.isDel = false;
            isIn = true;
        end
    end
    if not isIn then
        local t = {};
        t.id = tonumber( buffType );
        t.buttType = tonumber( buffType );
        t.buffAni = buffAni;
        t.isDel = false;
        target.buffList[ #target.buffList + 1 ] = t;
    end
end

function HasBuffType( fighter, buffType )
    if fighter == nil or buffType == nil then
    	WriteConErr("HasBuffType err!");
    	return nil;
    end
    local buffList = n_battle_db_mgr.GetBuffRoundDB( n_battle_stage.GetRoundNum() );
    if buffList == nil or #buffList <= 0 then
    	return false;
    end
	local pos = fighter.idFighter;
	local camp = fighter.camp;
	if camp == E_CARD_CAMP_ENEMY then
		pos = pos - N_BATTLE_CAMP_CARD_NUM;
	end
	for bk, buff in ipairs( buffList ) do
		local bCamp = tonumber( buff.Camp );
		local bPos = tonumber( buff.Pos );
		local bBuffType = tonumber( buff.Buff_type );
		if bCamp == camp and pos == bPos and buffType == bBuffType then
			return true;
		end
	end
	return false;
end

--复活战士
function FighterRevive( fighter, hp)
    fighter.hpbar:GetNode():SetVisible( true );
    fighter:SetLifeAdd( hp );
    --fighter:SubTmpLifeHeal( hp );
    fighter.isDead = false;
    fighter:standby();
    fighter:GetNode():AddActionEffect("lancer_cmb.revive");
    fighter.m_kShadow:AddActionEffect("lancer_cmb.revive");
    fighter:GetNode():ClearAllAniEffect();
    fighter.buffList = {};
end




