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
    
    local seqAtk    = batch:AddSerialSequence();
    local seqTarget = batch:AddSerialSequence();
    local seqBullet = batch:AddSerialSequence();
    
    if (seqAtk == nil) or (seqTarget == nil) then
        WriteCon( "create 2 seq failed");
        return;
    end
    
    local isBullet = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "is_bullet" ) );
    local bulletAni;
    if isBullet == N_BATTLE_BULLET_1 then
        bulletAni = "n_bullet."..tostring( atkFighter.cardId );
    end
    
    local playerNode = atkFighter:GetPlayerNode();
    
    --�����������λ��
    local originPos = playerNode:GetCenterPos();

    --����Ŀ���λ��
    local enemyPos = targetFighter:GetFrontPos(playerNode);
    
    local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
    seqAtk:AddCommand( cmdAtkBegin );
    
    local cmdSetPic = atkFighter:cmdLua( "SetFighterPic",  0, "", seqAtk );
    
    if distance == N_BATTLE_DISTANCE_1 then
        --�򹥻�Ŀ���ƶ�
        local cmd2 = JumpMoveTo(atkFighter, originPos, enemyPos, seqAtk, false);
    end
    
    --�������˶���
    local cmdAtk = createCommandPlayer():Atk( 0, playerNode, "" );
    seqAtk:AddCommand( cmdAtk );
    --cmdAtk:SetDelay(0.2f); --���ù����ӳ�
    
    --���վ������
    local cmd4 = createCommandPlayer():Standby( 0.01, playerNode, "" );
    seqAtk:AddCommand( cmd4 );
    
    if distance == N_BATTLE_DISTANCE_1 then
        --����ԭ����λ��
        local cmd5 = JumpMoveTo(atkFighter, enemyPos, originPos, seqAtk, false);
    end
    
    local bulletend;
    if bulletAni ~= nil then
        local deg = atkFighter:GetAngleByFighter( targetFighter );
        local bullet = n_bullet:new();
        bullet:AddToBattleLayer();
        bullet:SetEffectAni( bulletAni );
                    
        bullet:GetNode():SetRotationDeg( deg );
        local bullet1 = bullet:cmdSetVisible( true, seqBullet );
        local bullet2 = bullet:cmdShoot( atkFighter, targetFighter, seqBullet, false );
        bulletend = bullet:cmdSetVisible( false, seqBullet );
        seqBullet:SetWaitEnd( cmdAtk );
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
    
    local cmdClearPic = atkFighter:cmdLua( "ClearAllFighterPic",  0, "", seqAtk );
    --cmdClearPic:SetWaitEnd( seqTarget );
    
    if bulletend ~= nil then
    	seqTarget:SetWaitEnd( bulletend );
    else
        seqTarget:SetWaitBegin( cmdAtk );	
    end
        
    --�ܹ����ĺ������������� OR վ����
    HurtResultAni( targetFighter, seqTarget );
    
end