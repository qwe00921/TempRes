--------------------------------------------------------------
-- FileName:    n_battle_atk.lua
-- author:      hst, 2013��11��26��
-- purpose:     ��ͨ����
--------------------------------------------------------------

n_battle_atk = {}
local p = n_battle_atk;

--˫����Ź
function p.Atk( atkFighter, distance, targetFighter, batch, hurt )
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
    
    if distance == N_BATTLE_DISTANCE_1 then
        --�򹥻�Ŀ���ƶ�
        local cmd2 = JumpMoveTo(atkFighter, originPos, enemyPos, seqAtk, false);
    end
    
    --�������˶���
    local cmdAtk = createCommandPlayer():Atk( 0, playerNode, "" );
    seqAtk:AddCommand( cmdAtk );
    cmdAtk:SetDelay(0.2f); --���ù����ӳ�
    
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
    
    if distance == N_BATTLE_DISTANCE_1 then
        --����ԭ����λ��
        local cmd5 = JumpMoveTo(atkFighter, enemyPos, originPos, seqAtk, false);
    end
    
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
    HurtResultAni( targetFighter, seqTarget );
    
end