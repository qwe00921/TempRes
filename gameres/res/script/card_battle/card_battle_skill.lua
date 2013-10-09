--------------------------------------------------------------
-- FileName: 	card_battle_skill.lua
-- author:		hst, 2013年9月8日
-- purpose:		卡牌技能类
--------------------------------------------------------------

card_battle_skill = {}
local p = card_battle_skill;

--起手阶段技能
function p.HeadSkill( batch, handSkill )
    if batch == nil or handSkill == nil then
        return ;
    end
    local prevCmd = nil;
    for k, v in ipairs(handSkill) do
        local seqFirstStage = batch:AddParallelSequence();
        local seqEndCmd = nil;

        local atkFighterId = tonumber( v.card_id );
        local camp = tonumber( v.camp );
        local targets = v.targets;
        local buffEffect = tonumber( v.buff_effect );--效果类型1-HP 2-防御 3-攻击 4-生命上限等
        local buffResult = tonumber( v.buff_result );--1:增益BUFF 2:减益BUFF
        local atkFighter;

        --卡牌技能特效
        if camp == E_CARD_CAMP_HERO then
            atkFighter = card_battle_mgr.heroCamp:FindFighter( atkFighterId );
        elseif camp == E_CARD_CAMP_ENEMY then
            atkFighter = card_battle_mgr.enemyCamp:FindFighter( atkFighterId );
        end
        local cmd1 = createCommandEffect():AddActionEffect( 0, atkFighter:GetPlayerNode(), "card_battle.blow_up" );
        seqFirstStage:AddCommand( cmd1 );
        --受击
        if targets ~= nil and #targets > 0 then
            for _k, _v in ipairs(targets) do
                local tar_camp = tonumber( _v.camp );
                local targetCardId = tonumber( _v.card_id );
                local targetCard;
                if tar_camp == E_CARD_CAMP_HERO then
                    targetCard = card_battle_mgr.heroCamp:FindFighter( targetCardId );
                elseif tar_camp == E_CARD_CAMP_ENEMY then
                    targetCard = card_battle_mgr.enemyCamp:FindFighter( targetCardId );
                end
                --增加特效
                local cmd10 = p.SetBuffEffect( targetCard, buffEffect, buffResult );
                cmd10:SetWaitEnd( cmd1 );
                seqFirstStage:AddCommand( cmd10 );
                seqEndCmd = targetCard:cmdIdle( 0.001, seqFirstStage );
                seqEndCmd:SetWaitEnd( cmd10 );
            end
        end
        if prevCmd ~= nil then
            seqFirstStage:SetWaitEnd( prevCmd );
        end
        prevCmd = seqEndCmd;
    end
end

--普通攻击（单攻:三个爪子效果）
function p.Atk( atkFighter, targetFighter, batch )
    if batch == nil then return end
    
    --创建序列给攻击者、受击者
    local seqAtk    = batch:AddSerialSequence();
    local seqTarget = batch:AddParallelSequence();
    
    if (seqAtk == nil) or (seqTarget == nil) then
        WriteCon( "create 2 seq failed");
        return;
    end
    
    --攻击者最初的位置
    local originalPos = atkFighter:GetNode():GetCenterPos();

    --攻击目标的位置
    local enemyPos = targetFighter:GetFrontPos(atkFighter:GetNode());
    
    --随机
    local atkType = 1;
    
    local cmdAtkBegin = createCommandInstant_Misc():SetZOrderAtTop( atkFighter:GetNode(), true );
    seqAtk:AddCommand( cmdAtkBegin );
    
    --向攻击目标移动
    local cmd1 = p.cmdMoveTo( atkFighter, originalPos, enemyPos, seqAtk);
    
    if atkType == 2 then
        --火攻音效
        local cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( "battle_fire_ball.mp3" );
        seqAtk:AddCommand( cmdMusic );
        --[[
        local cmd2 = createCommandEffect():AddFgEffect( 0.01, atkFighter:GetNode(), "lancer.hero_atk_fire" );      
        if cmd2 ~= nil then
            seqAtk:AddCommand( cmd2 );
        end 
        --]]
    else
        --三个爪子音效
        local cmd3 = createCommandSoundMusicVideo():PlaySoundByName( "battle_paw.mp3" );
        seqAtk:AddCommand( cmd3 );
    end
    
     --返回原来的位置
    local cmd4 = p.cmdMoveTo( atkFighter, enemyPos, originalPos, seqAtk );
    
    local cmdAtkEnd = createCommandInstant_Misc():SetZOrderAtTop( atkFighter:GetNode(), false );
    seqAtk:AddCommand( cmdAtkEnd );
    
    --受击者
    local cmd6 = targetFighter:BossAddHurtEffect( seqTarget, false, atkType );
    local cmd7 = targetFighter:cmdMoveBackward( atkFighter, seqTarget );  
    local cmd8 = targetFighter:cmdMoveForward( atkFighter, seqTarget );
    cmd8:SetWaitEnd( cmd7 );
        
    local cmd9 = targetFighter:cmdLua( "fighter_damage", math.random( 80, 180 ), "", seqTarget );
    local cmd10 = targetFighter:cmdLua( "update_team_rage", math.random( 5, 20 ), "", seqTarget );
    seqTarget:SetWaitEnd( cmd1 );
        
    --受攻击的后续动画【死亡 OR 站立】
    p.HurtResultAni( targetFighter, seqTarget );
    
end

--卡牌队伍技能
function p.TeamSkill( camp, batch )
    local targetCamp;
    local atkCamp;
	if camp == E_CARD_CAMP_HERO then
	   targetCamp = card_battle_mgr.enemyCamp;
	   atkCamp = card_battle_mgr.heroCamp;
	elseif camp == E_CARD_CAMP_ENEMY then	
	   targetCamp = card_battle_mgr.heroCamp;
	   atkCamp = card_battle_mgr.enemyCamp;
	end
    
    if camp == nil or batch == nil then 
        WriteCon( ".............AtkAOE ERROR.............");
        return 
    end
    
    local targetAlive = targetCamp:GetAliveFighters();
    local atkFighter = atkCamp:GetAliveFighters();
    p.UltimateSkill( atkFighter[1], camp, batch )
end

--怒气值技能ONE TO ONE
function p.AtkSkillOneToOne( atkFighter, targetfighter, batch )
    local seqSkill = batch:AddSerialSequence();
    local cmd1 = createCommandEffect():AddActionEffect( 0, atkFighter:GetPlayerNode(), "card_battle.blow_up" );
    seqSkill:AddCommand( cmd1 );
    
    --受击者
    local cmd10 = createCommandEffect():AddFgEffect( 0.01, targetfighter:GetPlayerNode(), "card_battle.b_z" );
    seqSkill:AddCommand( cmd10 );
    
    --飘血
    local cmd11 = targetfighter:cmdLua( "fighter_damage", 100, "", seqSkill );
    p.HurtResultAni( targetfighter, seqSkill );
    
    atkFighter:GetPlayerNode():DelAniEffect("card_battle.card_border_fx");
    atkFighter.skillnum = math.random( 1, 4 );
    local pic = GetPictureByAni("card_battle.skill_num", atkFighter.skillnum - 1); 
    atkFighter.skillbar:SetPicture( pic );
    atkFighter.skillbar:SetVisible( true );
end

--怒气值技能（群攻）
function p.AtkSkillOneToCamp( atkFighter, batch )
    if batch == nil then return end
    
    --创建4个序列给攻击者、受击者、子弹、地裂
    local seqAtk    = batch:AddSerialSequence();
    
    local seqMisc =   batch:AddSerialSequence();
    local seqMiscHurt =   batch:AddParallelSequence();
    local seqMusic =   batch:AddSerialSequence();
    
    if seqAtk == nil then
        WriteCon( "create seqAtk failed");
        return;
    end
    
    local cmd1 = createCommandEffect():AddFgEffect( 0, atkFighter:GetPlayerNode(), "card_battle_cmb.x_w" );
    seqAtk:AddCommand( cmd1 );
    
    local cmd2 = createCommandEffect():AddFgEffect( 0.5, atkFighter:GetPlayerNode(), "card_battle."..atkFighter.UseConfig );
    seqAtk:AddCommand( cmd2 );
    
    local targets = card_battle_mgr.enemyCamp:GetAliveFighters();
    for k, v in ipairs(targets) do
        local seqBullet = batch:AddSerialSequence();
        local seqTarget = batch:AddSerialSequence();
        
        local deg = atkFighter:GetAngleByFighter( v );
    
        --子弹
        local bullet = bullet:new();
        bullet:AddToBattleLayer();
        bullet:UseConfig("bullet.bullet1");
            
        bullet:GetNode():SetRotationDeg( deg );
        local bullet1 = bullet:cmdSetVisible( true, seqBullet );
        local bullet2 = bullet:cmdShoot( atkFighter, v, seqBullet, false );
        local bullet3 = bullet:cmdSetVisible( false, seqBullet );
        seqBullet:SetWaitEnd( cmd2 );
        
        --受击特效
        local cmd3 = createCommandEffect():AddFgEffect( 0.1, v:GetNode(), "card_battle.b_z" );
        seqTarget:AddCommand( cmd3 );
        --cmd3:SetWaitEnd( bullet3 )
        
       local cmdBack = createCommandEffect():AddActionEffect( 0, v:GetNode(), "card_battle.target_hurt_back" );
        seqTarget:AddCommand( cmdBack );
                    
        --飘血
        local cmd12 = v:cmdLua( "fighter_damage", math.random( 90, 180 ), "", seqTarget );
        
        local cmdForward = createCommandEffect():AddActionEffect( 0, v:GetNode(), "card_battle.target_hurt_back_reset" );
        seqTarget:AddCommand( cmdForward ); 
        
        --受攻击的后续动画【死亡 OR 站立】
        p.HurtResultAni( v, seqTarget );
            
        --受击者序列等待子弹打到目标点
        seqTarget:SetWaitEnd( bullet3 );
    end
    atkFighter:GetPlayerNode():DelAniEffect("card_battle.card_border_fx");
    atkFighter.skillnum = math.random( 1, 4 );
    local pic = GetPictureByAni("card_battle.skill_num", atkFighter.skillnum - 1); 
    atkFighter.skillbar:SetPicture( pic );
    atkFighter.skillbar:SetVisible( true );
end

--卡牌队伍技能:大招
function p.UltimateSkill( atkFighter, camp, batch )
    if atkFighter == nil or camp == nil or batch == nil then 
        WriteCon( ".............Ultimate Skill ERROR.............");
        return 
    end
    
    --创建3个序列给攻击者、受击者、ui
    local seqAtk    = batch:AddParallelSequence();
    local seqTarget = batch:AddParallelSequence();
    local seqUI = batch:AddSerialSequence();
    
    --吟唱动作音乐
    local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( "blue_devil_sing.mp3" );
    seqAtk:AddCommand( cmdSingMusic );
    
    local cmd_ui= p.doUIEffect( atkFighter, seqUI );
    
    --受
    local targetAlive;
    if camp == E_CARD_CAMP_HERO then
        targetAlive = card_battle_mgr.enemyCamp:GetAliveFighters();
    elseif camp == E_CARD_CAMP_ENEMY then 
        targetAlive = card_battle_mgr.heroCamp:GetAliveFighters();  
    end
    
    for i = 1, #targetAlive do
        local target = targetAlive[i];
        if target ~= nil then
        
            local seq1 = batch:AddParallelSequence();
            if seq1 ~= nil then
                --受击特效
                local cmd11 = createCommandEffect():AddFgEffect( 0, target:GetNode(), "x.dings" );
                seq1:AddCommand( cmd11 );
                
                local cmdBackRset = createCommandEffect():AddActionEffect( 0.01, target:GetNode(), "lancer.target_hurt_back_reset" );
                seq1:AddCommand( cmdBackRset ); 
                cmdBackRset:SetWaitEnd( cmd11 );
                
                
                --受击动画
                local cmd12 = createCommandPlayer():Hurt( 0, target:GetNode(), "" );
                seq1:AddCommand( cmd12 );
                --cmd12:SetDelay( self:GetPlayerNode():GetSkillKeyTime_Hurt(""));
                --cmd12:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
                
                --飘血
                local cmd13 = target:cmdLua( "fighter_damage", math.random( 120, 250 ), "", seq1 );
                cmd13:SetWaitEnd( cmd12 );
                
                local cmdBack = createCommandEffect():AddActionEffect( 0, target:GetNode(), "lancer.target_hurt_back" );
                seq1:AddCommand( cmdBack );
                cmdBack:SetWaitEnd( cmd13 );
                
                
                --受攻击的后续动画【死亡 OR 站立】
                if target:CheckTmpLife() then
                    local cmd14 = createCommandPlayer():Standby( 0, target:GetNode(), "" );
                    cmd14:SetWaitEnd( cmd13 );
                    seq1:AddCommand( cmd14 );
                else
                    local cmd15 = createCommandPlayer():Dead( 0, target:GetNode(), "" );
                    cmd15:SetWaitEnd( cmd13 );
                    seq1:AddCommand( cmd15 );   
                    
                    local cmd16 = createCommandEffect():AddActionEffect( 0.01, target:GetNode(), "lancer_cmb.die_v2" );
                    --cmd16:SetWaitEnd( cmd5 );
                    seq1:AddCommand( cmd16 );
                    
                end
                
                --设置等待
                seq1:SetWaitBegin( cmd_ui );
            end     
        end
    end 
end

function p.doUIEffect( atkFighter, seqUI )
    --初始化技能名称栏对应的ACTION特效
    local skillNameBarInAction = nil;
    local skillNameBarOutAction = nil;
    local skillFx = nil;
    if atkFighter.camp == E_CARD_CAMP_HERO then
        skillNameBarInAction = "x.skill_name_move_left_in";
        skillNameBarOutAction = "x.skill_name_move_right_out";
        skillFx = "x_cmb.skill_name_fx"
    else
        skillNameBarInAction = "x.skill_name_move_right_in";
        skillNameBarOutAction = "x.skill_name_move_left_out";
        skillFx = "x_cmb.skill_name_fx_reverse"
    end
    
    --设置技能名称栏的位置
    local cmd1;
    if atkFighter.camp == E_CARD_CAMP_HERO then
        cmd1 = atkFighter:cmdLua( "SetSkillNameBarToLeft", 0, "", seqUI );
    else
        cmd1 = atkFighter:cmdLua( "SetSkillNameBarToRight", 0, "", seqUI );
    end
    
    --增加蒙版
    local cmd2 = atkFighter:cmdLua( "AddMaskImage", 0, "", seqUI );
    
    --大招名称特效
    --0:初始化特效
    local skillNameBar = GetImage( card_battle_pvp.battleLayer ,ui_card_battle_pvp.ID_CTRL_PICTURE_13 )
    local cmd3 = createCommandEffect():AddFgEffect( 0.01, skillNameBar, skillFx );
    seqUI:AddCommand( cmd3 );   
    
    --1:设置模糊
    local cmd4 = createCommandEffect():AddActionEffect( 0.01, skillNameBar, "x.gsblur5" );
    seqUI:AddCommand( cmd4 );
    
    --2:进入屏幕
    local cmd5 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarInAction );
    seqUI:AddCommand( cmd5 );   
    
    --2:恢复清晰
    local cmd6 = createCommandEffect():AddActionEffect( 0, skillNameBar, "x.gsblur_zero" );
    seqUI:AddCommand( cmd6 );
    cmd6:SetDelay(0.5); 
    
    --4:移出屏幕
    local cmd7 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarOutAction );
    seqUI:AddCommand( cmd7 );   
    cmd7:SetDelay(0.3);     
        
    --隐藏蒙版
    local cmd8 = atkFighter:cmdLua( "HideMaskImage", 0, "", seqUI );
    
    --还原技能名称栏的位置
    local cmd9 = atkFighter:cmdLua( "ReSetSkillNameBarPos", 0, "", seqUI );
    
    local cmd_dumb = atkFighter:cmdDumb( seqUI );
    return cmd_dumb;
end

--受击结果：死亡动作或站立动画
function p.HurtResultAni( targetFighter, seqTarget )
    if targetFighter:CheckTmpLife() then
        local cmdA = createCommandPlayer():Standby( 0, targetFighter:GetNode(), "" );
        seqTarget:AddCommand( cmdA );
    else
        local cmdB = createCommandPlayer():Dead( 0, targetFighter:GetNode(), "" );
        seqTarget:AddCommand( cmdB );   
        
        local cmdC = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer_cmb.die_v2" );
        seqTarget:AddCommand( cmdC );
    end
end

--做位移
function p.cmdMoveTo( atkFighter, atkFighterPos, targetPos, seq )
    local duration = 0;
    local cmd = nil;
    local fx = "x_cmb.hero_atk";
    
    local selfPos = atkFighterPos;
    
    local x = targetPos.x - selfPos.x;
    local y = targetPos.y - selfPos.y;
        
    -- cmd with var
    cmd = battle_show.AddActionEffect_ToSequence( duration, atkFighter:GetNode(), fx, seq );
    local varEnv = cmd:GetVarEnv();
    varEnv:SetFloat( "$1", x );
    varEnv:SetFloat( "$2", y );
    
    return cmd;
end


--起手阶段技能效果
function p.SetBuffEffect( targetFighter, buffEffect, buffResult )
    local cmd1
    if buffEffect == BATTLE_BUFF_TYPE_LIFE then
        if buffResult == BATTLE_BUFF_EFFECT then
            cmd1 = createCommandEffect():AddFgEffect( 0, targetFighter:GetPlayerNode(), "card_battle.life_up" );
        elseif buffResult == BATTLE_DEBUFF_EFFECT then
            cmd1 = createCommandEffect():AddFgEffect( 0, targetFighter:GetPlayerNode(), "card_battle.life_down" );
        end
    elseif buffEffect == BATTLE_BUFF_TYPE_DEF then
        if buffResult == BATTLE_BUFF_EFFECT then
            cmd1 = createCommandEffect():AddFgEffect( 0, targetFighter:GetPlayerNode(), "card_battle.defense_up" );
        elseif buffResult == BATTLE_DEBUFF_EFFECT then
            cmd1 = createCommandEffect():AddFgEffect( 0, targetFighter:GetPlayerNode(), "card_battle.defense_down" );
        end
    elseif buffEffect == BATTLE_BUFF_TYPE_ATK then
        if buffResult == BATTLE_BUFF_EFFECT then
            cmd1 = createCommandEffect():AddFgEffect( 0, targetFighter:GetPlayerNode(), "card_battle.attack_up" );
        elseif buffResult == BATTLE_DEBUFF_EFFECT then
            cmd1 = createCommandEffect():AddFgEffect( 0, targetFighter:GetPlayerNode(), "card_battle.attack_down" );
        end
    end
    return cmd1;
end