--------------------------------------------------------------
-- FileName:    w_battle_atk.lua
-- author:      hst, 2013年11月26日
-- purpose:     普通攻击
--------------------------------------------------------------

w_battle_atk = {}
local p = w_battle_atk;

--选者结束阶断
function p.AtkPVE_NPC(atkFighter, targetFighter, batch, damage )
	--先播放攻击方动画
	local batch = battle_show.GetNewBatch();  
    
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

    --受击目标的位置
    local enemyPos = targetFighter:GetFrontPos(playerNode);
    
	--攻击音乐
    local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( playerNode, true );
    seqAtk:AddCommand( cmdAtkBegin );
    
    local cmdSetPic = atkFighter:cmdLua( "SetFighterPic",  0, "", seqAtk );
    
    if distance == W_BATTLE_DISTANCE_NoArcher then  --近战攻击
        --向攻击目标移动
        local cmd2 = JumpMoveTo(atkFighter, originPos, enemyPos, seqAtk, false);
		
		--show的体力值减少,飘血
		atkFighter:cmdLua( "atk_damage",  targetFighter:GetId(), damage, seqAtk );
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
    
    if distance == W_BATTLE_DISTANCE_1 then
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
    
	--攻击方动画播完, 攻击顺列次数减1,减为0时,判断是否继续站立还是阵亡.
	--将cmd命的执行压入seqAtk顺序执行
	atkFighter:cmdLua( "atk_hurt",  targetFighter:GetId(), "", seqAtk );
	

end;	


function p.AtkHurt(atkFighter, targetFighter)
	
	local batch = battle_show.GetNewBatch();
	local seqTarget = batch:AddSerialSequence();
 
    
    targetFighter:BeHitDec(atkFighter:GetId()); --受击次数减一
      
    if targetFighter.beHitTimes == 0 then --受击次数为0时
	    if targetFighter.showlife > 0 then  --还活着,继续播放站立	
			targetFighter:standby();
		elseif targetFighter.showlife <= 0 then
			targerFighter:die();  --死亡开始阶断动画
			
	--[[	if Dead then
				--BUFF复活技能  
				if Revive then
					targetFighter:cmdLua( "fighter_revive", RemainHp, "", seqTarget );  
				end
			end
			]]--
			
			--怪物死亡动画完成后的回调

            function p.dieEnd(atkFighter, targetFighter)  --死亡结束阶断加入队列seqTarget
			    
				    --对怪物对象释放
					if w_battle_atk.enemyCamp == nil then
						--执行此轮的战斗结束
						
						return;
					end;

                    --判断是否要切换怪物目标
					if p.LockEnemy == true then
						if(p.PVEEnemyID == lFighterID) then  --当前锁定的怪物已经挂了
							if p.enemyCamp:GetActiveFighterCount() > 0 then --换个怪物
								p.PVEEnemyID = p.enemyCamp:GetActiveFighterID(lFighterID); --除此ID外的活的怪物目标
								--p.LockEnemy = false  --只要选过怪物一直都是属于锁定的
							else  --没有活着的怪物可选
							   p.isCanSelFighter = false;
							end
						end;
					else
						--非锁定攻击的怪物,在选择我方人员时就完成了怪物的选择,无需处理
					end;
			end;	
end;
    
	
	
	
	  
    
	
end;

function p.atk_damage(atkFighter, targetFighter)

	--处于站立状态下
	if targetFighter:IsStandBy() then  --站立状态
		--播放受击动画
	   targerFighter:Hurt();	
	end;
end;

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