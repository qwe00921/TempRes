--------------------------------------------------------------
-- FileName:    n_battle_atk.lua
-- author:      hst, 2013年11月26日
-- purpose:     普通攻击
--------------------------------------------------------------

n_battle_atk = {}
local p = n_battle_atk;

--双方互殴
function p.Atk( atkFighter, targetFighter, batch, hurt )
    if batch == nil then return end
    
    local batch = batch;
    local targetFighter = targetFighter;
    local atkFighter = atkFighter;
    local hurt = hurt;
    
    --创建序列给攻击者、受击者
    local seqAtk    = batch:AddSerialSequence();
    local seqTarget = batch:AddParallelSequence();
    
    if (seqAtk == nil) or (seqTarget == nil) then
        WriteCon( "create 2 seq failed");
        return;
    end
    
    local playerNode = atkFighter:GetPlayerNode();
    
    --攻击者最初的位置
    local originPos = playerNode:GetCenterPos();

    --攻击目标的位置
    local enemyPos = targetFighter:GetFrontPos(playerNode);
    
    local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
    seqAtk:AddCommand( cmdAtkBegin );
    
    --奔跑动画
    local cmd1 = createCommandPlayer():Run( 0.1, playerNode, "" );
    seqAtk:AddCommand( cmd1 );
    
    --向攻击目标移动
    local cmd2 = p.JumpMoveTo(atkFighter, originPos, enemyPos, seqAtk, false);
    
    --攻击敌人动画
    local cmd3 = createCommandPlayer():Atk( 0, playerNode, "" );
    seqAtk:AddCommand( cmd3 );
    cmd3:SetDelay(0.2f); --设置攻击延迟
    
    --最初站立动画
    local cmd4 = createCommandPlayer():Standby( 0.01, playerNode, "" );
    seqAtk:AddCommand( cmd4 );
    
    --[[
    local cmdBack = createCommandEffect():AddActionEffect( 0, targetFighter:GetNode(), "lancer.target_hurt_back" );
    cmdBack:SetDelay(playerNode:GetSkillKeyTime_Atk(""));
    seqTarget:AddCommand( cmdBack );
    
    local cmdForward = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer.target_hurt_back_reset" );
    seqTarget:AddCommand( cmdForward ); 
    --]]
    
     --返回原来的位置
    local cmd5 = p.JumpMoveTo(atkFighter, enemyPos, originPos, seqAtk, false);
    
    local cmdAtkEnd = createCommandInstant_Misc():SetZOrderAtTop( atkFighter:GetNode(), false );
    seqAtk:AddCommand( cmdAtkEnd );
    
    --受击动画
    local cmd10 = createCommandPlayer():Hurt( 0, targetFighter:GetNode(), "" );
    seqTarget:AddCommand( cmd10 );
    --cmd10:SetDelay(0.5f);
    --cmd10:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
    
    local cmdBack = createCommandEffect():AddActionEffect( 0, targetFighter:GetPlayerNode(), "lancer.target_hurt_back" );
    seqTarget:AddCommand( cmdBack );
        
    local cmd11 = targetFighter:cmdLua( "fighter_damage",  hurt, "", seqTarget );
    
    local cmdBackRset = createCommandEffect():AddActionEffect( 0, targetFighter:GetPlayerNode(), "lancer.target_hurt_back_reset" );
    seqTarget:AddCommand( cmdBackRset ); 
    
    --[[    
    local Idle = createCommandInterval():Idle( 0.001 );
    if Idle ~= nil then
        seqTarget:AddCommand( Idle );
    end 
    --]]
    seqTarget:SetWaitEnd( cmd3 );
        
    --受攻击的后续动画【死亡 OR 站立】
    p.HurtResultAni( targetFighter, seqTarget );
    
end

function p.JumpMoveTo(atkFighter, fPos, tPos, pJumpSeq, isFallback)
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

    local pCmd = battle_show.AddActionEffect_ToSequence( 0, atkFighter:GetPlayerNode(), fx,pJumpSeq);
    
    local varEnv = pCmd:GetVarEnv();
    varEnv:SetFloat( "$1", x );
    varEnv:SetFloat( "$2", y );
    varEnv:SetFloat( "$3", 75 );
    
    return pCmd;
end

--受击结果：死亡动作或站立动画
function p.HurtResultAni( targetFighter, seqTarget )
    if targetFighter:CheckTmpLife() then
        --local cmdA = createCommandPlayer():Standby( 0, targetFighter:GetNode(), "" );
        --seqTarget:AddCommand( cmdA );
    else
        --local cmdB = createCommandPlayer():Dead( 0, targetFighter:GetNode(), "" );
        --seqTarget:AddCommand( cmdB );   
        local cmdC = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer_cmb.die_v2" );
        seqTarget:AddCommand( cmdC );
        local cmdD = createCommandEffect():AddActionEffect( 0.01, targetFighter.m_kShadow, "lancer_cmb.die_v2" );
        seqTarget:AddCommand( cmdD );
    end
end