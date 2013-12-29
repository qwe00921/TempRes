--------------------------------------------------------------
-- FileName:    w_battle_stage.lua
-- author:      hst, 2013年11月26日
-- purpose:     战斗状态
--------------------------------------------------------------

w_battle_stage = {}
local p = w_battle_stage;

p.roundNum = 0;                 --战斗回合数
p.battleStage = 0;              --对战阶段,共1~4个阶段:加载阶段,永久BUFF阶段,回合阶段,结束阶段
p.battleRoundStage = 0;         --回合阶段,共4个子阶段:召唤兽,BUFF表现,互殴，结算

--初使化
function p.Init()
    p.roundNum = 1;                  
    p.battleStage = 0;              
    p.battleRoundStage = 0;      
end

--进入下一个回合
function p.NextRound()
   p.roundNum = p.roundNum + 1;
end

--获取回合数
function p.GetRoundNum()
    return p.roundNum;
end

--------------------------------------------------------------
--对战的各种阶段管理
--------------------------------------------------------------

--战斗阶段->加载
function p.EnterBattle_Stage_Loading()
    p.battleStage = W_BATTLE_STAGE_LOADING;
end

--战斗阶段->永久BUFF表现
function p.EnterBattle_Stage_Permanent_Buff()
    p.battleStage = W_BATTLE_STAGE_PERMANENT_BUFF;
end

--战斗阶段->回合
function p.EnterBattle_Stage_Round()
    p.battleStage = W_BATTLE_STAGE_ROUND;
end

--战斗阶段->结束
function p.EnterBattle_Stage_End()
    p.battleStage = W_BATTLE_STAGE_END;
end

--------------------------------------------------------------
--进入互殴阶段的回合阶段管理
--------------------------------------------------------------

--回合阶段->召唤兽 
function p.EnterBattle_RoundStage_Pet()
    p.battleRoundStage = W_BATTLE_ROUND_STAGE_PET;
end

--回合阶段->BUFF表现
function p.EnterBattle_RoundStage_Buff()
    p.battleRoundStage = W_BATTLE_ROUND_STAGE_BUFF;
end

--回合阶段->互殴
function p.EnterBattle_RoundStage_Atk()
    p.battleRoundStage = W_BATTLE_ROUND_STAGE_ATK;
end

--回合阶段->结算
function p.EnterBattle_RoundStage_Clearing()
    p.battleRoundStage = W_BATTLE_ROUND_STAGE_CLEARING;
end

--------------------------------------------------------------
--对战的各种阶段的判断
--------------------------------------------------------------

--是否是战斗加载阶段
function p.IsBattle_Stage_Loading()
    if p.battleStage == W_BATTLE_STAGE_LOADING then
        return true;
    end
    return false;
end

--是否是战斗永久BUFF阶段
function p.IsBattle_Stage_Permanent_Buff()
    if p.battleStage == W_BATTLE_STAGE_PERMANENT_BUFF then
        return true;
    end
    return false;
end

--是否是战斗回合阶段
function p.IsBattle_Stage_Round()
    if p.battleStage == W_BATTLE_STAGE_ROUND then
        return true;
    end
    return false;
end

--是否是战斗结束阶段
function p.IsBattle_Stage_End()
    if p.battleStage == W_BATTLE_STAGE_END then
        return true;
    end
    return false;
end

--------------------------------------------------------------
--回合的各种阶段的判断
--------------------------------------------------------------

--是否是互殴阶段召唤兽表现
function p.IsBattle_RoundStage_Pet()
    if p.battleRoundStage == W_BATTLE_ROUND_STAGE_PET then
        return true;
    end
    return false;
end

--是否是互殴阶段BUFF表现
function p.IsBattle_RoundStage_Buff()
    if p.battleRoundStage == W_BATTLE_ROUND_STAGE_BUFF then
        return true;
    end
    return false;
end

--是否是互殴阶段BUFF表现
function p.IsBattle_RoundStage_Atk()
    if p.battleRoundStage == W_BATTLE_ROUND_STAGE_ATK then
        return true;
    end
    return false;
end

--是否是互殴阶段结算
function p.IsBattle_RoundStage_Clearing()
    if p.battleRoundStage == W_BATTLE_ROUND_STAGE_CLEARING then
        return true;
    end
    return false;
end

--选者结束
function p.SelOver(atkFighter, targetFighter, batch, damage, lIsJoinAtk, lIsCrit )
	--先播放攻击方动画
	if batch == nil then return end
    
    --[[local Damage = tonumber( target.Damage ); --扣除血量
    local RemainHp = tonumber( target.RemainHp ); --所剩血量
    local Crit = target.Crit ; --暴击
    local Dead = target.TargetDead;--死亡
    local Revive = target.Revive;--复活
    ]]--
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
    if isBullet == W_BATTLE_BULLET_1 then --远程攻击
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
		

		seqTarget:SetWaitEnd( cmd2 ); --受击开始同时播放动画
		--show的体力值减少,飘血,判断并设置受击动画
		atkFighter:cmdLua( "atk_damage",  targetFighter:GetId(), damage, seqTarget );
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
		
		
		--show的体力值减少,飘血,判断并设置受击动画
		atkFighter:cmdLua( "atk_damage",  targetFighter:GetId(), damage, seqAtk );
    end
    
    local cmdAtkEnd = createCommandInstant_Misc():SetZOrderAtTop( atkFighter:GetNode(), false );
    seqAtk:AddCommand( cmdAtkEnd );
    
	--攻击方动画播完, 攻击顺列次数减1,减为0时,判断是否继续站立还是阵亡.
	--将cmd命的执行压入seqAtk顺序执行
	atkFighter:cmdLua( "atk_hurt",  targetFighter:GetId(), "", seqAtk );
	

end;	






