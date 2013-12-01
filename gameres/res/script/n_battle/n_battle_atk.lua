--------------------------------------------------------------
-- FileName:    n_battle_atk.lua
-- author:      hst, 2013��11��26��
-- purpose:     ��ͨ����
--------------------------------------------------------------

n_battle_atk = {}
local p = n_battle_atk;

--˫����Ź
function p.Atk( atkFighter, targetFighter, batch, hurt )
    if batch == nil then return end
    
    local batch = batch;
    local targetFighter = targetFighter;
    local atkFighter = atkFighter;
    local hurt = hurt;
    
    --�������и������ߡ��ܻ���
    local seqAtk    = batch:AddSerialSequence();
    local seqTarget = batch:AddParallelSequence();
    
    if (seqAtk == nil) or (seqTarget == nil) then
        WriteCon( "create 2 seq failed");
        return;
    end
    
    local playerNode = atkFighter:GetPlayerNode();
    
    --�����������λ��
    local originPos = playerNode:GetCenterPos();

    --����Ŀ���λ��
    local enemyPos = targetFighter:GetFrontPos(playerNode);
    
    local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
    seqAtk:AddCommand( cmdAtkBegin );
    
    --���ܶ���
    local cmd1 = createCommandPlayer():Run( 0.1, playerNode, "" );
    seqAtk:AddCommand( cmd1 );
    
    --�򹥻�Ŀ���ƶ�
    local cmd2 = p.JumpMoveTo(atkFighter, originPos, enemyPos, seqAtk, false);
    
    --�������˶���
    local cmd3 = createCommandPlayer():Atk( 0, playerNode, "" );
    seqAtk:AddCommand( cmd3 );
    cmd3:SetDelay(0.2f); --���ù����ӳ�
    
    --���վ������
    local cmd4 = createCommandPlayer():Standby( 0.01, playerNode, "" );
    seqAtk:AddCommand( cmd4 );
    
    --[[
    local cmdBack = createCommandEffect():AddActionEffect( 0, targetFighter:GetNode(), "lancer.target_hurt_back" );
    cmdBack:SetDelay(playerNode:GetSkillKeyTime_Atk(""));
    seqTarget:AddCommand( cmdBack );
    
    local cmdForward = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer.target_hurt_back_reset" );
    seqTarget:AddCommand( cmdForward ); 
    --]]
    
     --����ԭ����λ��
    local cmd5 = p.JumpMoveTo(atkFighter, enemyPos, originPos, seqAtk, false);
    
    local cmdAtkEnd = createCommandInstant_Misc():SetZOrderAtTop( atkFighter:GetNode(), false );
    seqAtk:AddCommand( cmdAtkEnd );
    
    --�ܻ�����
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
        
    --�ܹ����ĺ������������� OR վ����
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

--�ܻ����������������վ������
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