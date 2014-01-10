--------------------------------------------------------------
-- FileName:    w_battle_atk.lua
-- author:      hst, 2013年11月26日
-- purpose:     普通攻击
--------------------------------------------------------------

w_battle_atk = {}
local p = w_battle_atk;
--双方互殴
function p.Atk( atkFighter, target, TCamp, batch )
    if batch == nil then return end
    
    local targetFighter = nil; --受击者
    if TCamp == E_CARD_CAMP_HERO then
        targetFighter = w_battle_mgr.heroCamp:FindFighter( tonumber( target.TPos ) );
    elseif TCamp == E_CARD_CAMP_ENEMY then
        targetFighter = w_battle_mgr.enemyCamp:FindFighter( tonumber( target.TPos ) + W_BATTLE_CAMP_CARD_NUM );
    end
    local Damage = tonumber( target.Damage ); --扣除血量
    local RemainHp = tonumber( target.RemainHp ); --所剩血量
    local Crit = target.Crit ; --暴击
    local Dead = target.TargetDead;--死亡
    local Revive = target.Revive;--复活
    local distance = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "distance" ) );
    local atkSound = SelectCell( T_CARD_ATK_SOUND, atkFighter.cardId, "atk_sound" );
    
    local seqAtk    = batch:AddSerialSequence();
    local seqTarget = batch:AddSerialSequence();
    local seqBullet = batch:AddSerialSequence();
    
    if (seqAtk == nil) or (seqTarget == nil) then
        WriteCon( "create 2 seq failed");
        return;
    end
    
    local isBullet = tonumber( SelectCellMatch( T_CHAR_RES, "card_id", atkFighter.cardId, "is_bullet" ) );
    local bulletAni;
    if isBullet == W_BATTLE_BULLET_1 then
        bulletAni = "w_bullet."..tostring( atkFighter.cardId );
    end
    
    local playerNode = atkFighter:GetPlayerNode();
    
    --攻击者最初的位置
    local originPos = playerNode:GetCenterPos();

    --攻击目标的位置
    local enemyPos = targetFighter:GetFrontPos(playerNode);
    
    local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
    seqAtk:AddCommand( cmdAtkBegin );
    
    local cmdSetPic = atkFighter:cmdLua( "SetFighterPic",  0, "", seqAtk );
    
    if distance == W_BATTLE_DISTANCE_NoArcher then
        --向攻击目标移动
        local cmd2 = JumpMoveTo(atkFighter, originPos, enemyPos, seqAtk, false);
    end
    
    --攻击敌人动画
    local cmdAtk = createCommandPlayer():Atk( 0.3, playerNode, "" );
    seqAtk:AddCommand( cmdAtk );
    --cmdAtk:SetDelay(0.2f); --设置攻击延迟
    
    --受击音乐
    if atkSound ~= nil then
        local cmdAtkMusic = createCommandSoundMusicVideo():PlaySoundByName( atkSound );
        seqAtk:AddCommand( cmdAtkMusic );
    end
    
    --最初站立动画
    local cmd4 = createCommandPlayer():Standby( 0.01, playerNode, "" );
    seqAtk:AddCommand( cmd4 );
    
    if distance == W_BATTLE_DISTANCE_NoArcher then
        --返回原来的位置
        local cmd5 = JumpMoveTo(atkFighter, enemyPos, originPos, seqAtk, false);
    end
    
    local bulletend;
    if bulletAni ~= nil then
        local deg = atkFighter:GetAngleByFighter( targetFighter );
        local bullet = w_bullet:new();
        bullet:AddToBattleLayer();
        bullet:SetEffectAni( bulletAni );
                    
        bullet:GetNode():SetRotationDeg( deg );
        local bullet1 = bullet:cmdSetVisible( true, seqBullet );
        bulletend = bullet:cmdShoot( atkFighter, targetFighter, seqBullet, false );
        local bullet3 = bullet:cmdSetVisible( false, seqBullet );
        seqBullet:SetWaitEnd( cmdAtk );
    end
    
    local cmdAtkEnd = createCommandInstant_Misc():SetZOrderAtTop( atkFighter:GetNode(), false );
    seqAtk:AddCommand( cmdAtkEnd );
    
    --受击动画
    local cmd10 = createCommandPlayer():Hurt( 0, targetFighter:GetNode(), "" );
    seqTarget:AddCommand( cmd10 );
    --cmd10:SetDelay(0.5f);
    --cmd10:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
    
    local cmdBack = createCommandEffect():AddActionEffect( 0, targetFighter:GetPlayerNode(), "lancer.target_hurt_back" );
    seqTarget:AddCommand( cmdBack );
        
    local cmd11 = targetFighter:cmdLua( "fighter_damage",  Damage, "", seqTarget );
    
    local cmdBackRset = createCommandEffect():AddActionEffect( 0, targetFighter:GetPlayerNode(), "lancer.target_hurt_back_reset" );
    seqTarget:AddCommand( cmdBackRset ); 
    
    local cmdClearPic = atkFighter:cmdLua( "ClearAllFighterPic",  0, "", seqAtk );
    --cmdClearPic:SetWaitEnd( seqTarget );
    
    if bulletend ~= nil then
    	seqTarget:SetWaitBegin( bulletend );
    else
        seqTarget:SetWaitBegin( cmdAtk );	
    end
        
    --受攻击的后续动画【死亡 OR 站立】
    HurtResultAni( targetFighter, seqTarget );
    
    if Dead then
        --BUGG复活技能  
        if Revive then
            targetFighter:cmdLua( "fighter_revive", RemainHp, "", seqTarget );  
        end
    end
    
end