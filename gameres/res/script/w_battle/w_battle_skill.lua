--------------------------------------------------------------
-- FileName:    w_battle_skill.lua
-- author:      hst, 2013/11/26
-- purpose:     卡牌技能
--------------------------------------------------------------

w_battle_skill = {}
local p = w_battle_skill;

--技能
function p.Skill( hero, SkillId, distance, Targets, TCamp, batch )
    if hero == nil or SkillId == nil or distance == nil or Targets == nil or TCamp == nil or batch == nil then 
        WriteConWarning("w_battle_skill.Skill data err!");
        return false; 
    end
    
    --创建3个序列给攻击者、受击者、ui
    local seqAtk    = batch:AddSerialSequence();
    local seqTarget = batch:AddParallelSequence();
    local seqUI = batch:AddSerialSequence();
    
    local playerNode = hero:GetPlayerNode();
    
    --攻击者最初的位置
    local originPos = playerNode:GetCenterPos();
    
    --受击目标类型
    local targetType = tonumber( SelectCell( T_SKILL, SkillId, "Target_type" ) );
    local skillType = tonumber( SelectCell( T_SKILL, SkillId, "Skill_type" ) );
    local isSelfCamp = IsSkillTargetSelfCamp( targetType );
    local singSound = SelectCell( T_SKILL_SOUND, SkillId, "sing_sound" );
    local hurtSound = SelectCell( T_SKILL_SOUND, SkillId, "hurt_sound" );
    
    --攻击目标的位置
    local enemyPos; 
    if IsAoeSkillByType( targetType ) then
       enemyPos = w_battle_pvp.GetScreenCenterPos();
    else
       enemyPos = GetBestTargetPos( hero, TCamp, Targets );    
    end
    
    local sing = SelectCell( T_SKILL_RES, SkillId, "sing_effect" );
    local hurt = SelectCell( T_SKILL_RES, SkillId, "hurt_effect" );
    local isBullet = tonumber( SelectCell( T_SKILL_RES, SkillId, "is_bullet" ) );
    local bulletAni;
    if isBullet == W_BATTLE_BULLET_1 then
    	bulletAni = "w_bullet."..tostring( hero.cardId );
    end
    
    local cmdSetPic = hero:cmdLua( "SetFighterPic",  0, "", seqAtk );
    
    --吟唱动作音乐
    if singSound ~= nil then
    	local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( singSound );
        seqAtk:AddCommand( cmdSingMusic );
    end
    
    local cmd1 = createCommandEffect():AddFgEffect( 0.01, hero:GetNode(), sing );
    seqAtk:AddCommand( cmd1 );
    
    --近战攻击
    local cmdDoPos;
    if distance == W_BATTLE_DISTANCE_NoArcher then
        cmdDoPos = JumpMoveTo(hero, originPos, enemyPos, seqAtk );
    end
    
    local cmd2 = createCommandPlayer():Atk( 0.3, hero:GetPlayerNode(), "" );
    seqAtk:AddCommand( cmd2 );
    
    local cmd3 = createCommandPlayer():Standby( 0.01, hero:GetPlayerNode(), "" );
    seqAtk:AddCommand( cmd3 );
    
    if distance == W_BATTLE_DISTANCE_NoArcher then
        local cmd4 = JumpMoveTo(hero, enemyPos, originPos, seqAtk);
    end
           
    local cmdClearPic = hero:cmdLua( "ClearAllFighterPic",  0, "", seqAtk );
                            
    local cmd_ui = p.doUIEffect( hero.camp, seqUI, SkillId );
    
    seqUI:SetWaitEnd( cmd1 );
    if distance == W_BATTLE_DISTANCE_NoArcher and cmdDoPos ~= nil then
        cmdDoPos:SetWaitEnd( cmd_ui );
    else
        cmd2:SetWaitEnd( cmd_ui );
    end
    
    for k, v in ipairs(Targets) do
        local enemy = nil; --受击者
        if TCamp == E_CARD_CAMP_HERO then
            enemy = w_battle_mgr.heroCamp:FindFighter( tonumber( v.TPos ) );
        elseif TCamp == E_CARD_CAMP_ENEMY then
            enemy = w_battle_mgr.enemyCamp:FindFighter( tonumber( v.TPos ) + W_BATTLE_CAMP_CARD_NUM );
        end
        local Damage = tonumber( v.Damage ); --扣除血量
        local RemainHp = tonumber( v.RemainHp ); --所剩血量
        local Buff = tonumber( v.Buff );
        local Crit = v.Crit; --暴击
        local Dead = v.TargetDead;--死亡
        local Revive = v.Revive;--复活
        --受击者死亡
        --[[
        if Dead and Damage < enemy.life then
            Damage = enemy.life;
            WriteConWarning("the TargetFighter Mandatory death!");
        end
        ]]
        if enemy ~= nil then
            local seq1 = batch:AddParallelSequence();
            local seqBullet = batch:AddSerialSequence();
            local bulletend;
            
            if bulletAni ~= nil then
            	--2:技能特效：子弹特效
                local deg = hero:GetAngleByFighter( enemy );
                local bullet = w_bullet:new();
                bullet:AddToBattleLayer();
                bullet:SetEffectAni( bulletAni );
                    
                bullet:GetNode():SetRotationDeg( deg );
                local bullet1 = bullet:cmdSetVisible( true, seqBullet );
                bulletend = bullet:cmdShoot( hero, enemy, seqBullet, false );
                local bullet3 = bullet:cmdSetVisible( false, seqBullet );
                seqBullet:SetWaitEnd( cmd2 );
            end
        
            if seq1 ~= nil then
                --受击音乐
                if hurtSound ~= nil then
                	local cmdHurtMusic = createCommandSoundMusicVideo():PlaySoundByName( hurtSound );
                    seq1:AddCommand( cmdHurtMusic );
                end
    
                --受击特效
                local cmd11 = createCommandEffect():AddFgEffect( 0, enemy:GetNode(), hurt );
                seq1:AddCommand( cmd11 );
                
                local cmd12;
                if not isSelfCamp then
                	local cmdBackRset = createCommandEffect():AddActionEffect( 0, enemy:GetNode(), "lancer.target_hurt_back_reset" );
                    seq1:AddCommand( cmdBackRset ); 
                    cmdBackRset:SetWaitEnd( cmd11 );
                    
                    --受击动画
                    cmd12 = createCommandPlayer():Hurt( 0, enemy:GetNode(), "" );
                    seq1:AddCommand( cmd12 );
                end
                
                --飘血
                local cmd13;
                if skillType == N_SKILL_TYPE_1 then
                    cmd13 = enemy:cmdLua( "fighter_damage",  Damage, "", seq1 );
                elseif skillType == N_SKILL_TYPE_2 then 
                    cmd13 = enemy:cmdLua( "fighter_addHp", Damage, "", seq1 );
                elseif skillType == N_SKILL_TYPE_5 then
                    --主动复活技能  
                    if Revive then
                    	cmd13 = enemy:cmdLua( "fighter_revive", RemainHp, "", seq1 );  
                    	enemy.isDead = false;
                        enemy:SubTmpLifeHeal( RemainHp );   
                    end
                end
                if cmd13 ~= nil and cmd12 ~= nil then
                	cmd13:SetWaitEnd( cmd12 );
                end
                
                if Buff ~= N_BUFF_TYPE_0 then
                    local buffAni = GetBuffAniByType( Buff );
                    if not enemy:GetNode():HasAniEffect( buffAni ) then
                        local cmdBuff = createCommandEffect():AddFgEffect( 0, enemy:GetNode(), buffAni );
                        seq1:AddCommand( cmdBuff );
                        AddBuffObj( enemy, Buff, buffAni );
                    end
                end
                
                if not isSelfCamp then
                    local cmdBack = createCommandEffect():AddActionEffect( 0, enemy:GetNode(), "lancer.target_hurt_back" );
                    seq1:AddCommand( cmdBack );
                    cmdBack:SetWaitEnd( cmd13 );
                end
                
                HurtResultAni( enemy, seq1 );
                
                if Dead then
                	--BUGG复活技能  
                    if Revive then
                        enemy:cmdLua( "fighter_revive", RemainHp, "", seq1 );  
                    end
                end
                
                --设置等待
                if bulletend ~= nil then
                	seq1:SetWaitBegin( bulletend );
                else
                	seq1:SetWaitEnd( cmd3 );
                end
                
            end     
        end
    end 
end

function p.doUIEffect( camp, seqUI, SkillId )
    --初始化技能名称栏对应的ACTION特效
    local skillNameBarInAction = nil;
    local skillNameBarOutAction = nil;
    local skillFxBor = nil;
    local skillFxBg = nil;
    local fx_lightning = nil;
    local fx_pic = nil;
    local fx_title = SelectCell( T_SKILL_RES, SkillId, "name_effect" );
    if camp == E_CARD_CAMP_HERO then
        skillNameBarInAction = "n.skill_name_move_left_in";
        skillNameBarOutAction = "n.skill_name_move_right_out";
        skillFxBor = "n.fx_skill_bar_border";
        skillFxBg = "n.fx_skill_bar_bg";
        fx_lightning = "n.fx_skill_bar_lightning";
        fx_pic = "n.fx_skill_bar_pet";
    else
        skillNameBarInAction = "n.skill_name_move_right_in";
        skillNameBarOutAction = "n.skill_name_move_left_out";
        skillFxBor = "n.fx_skill_bar_border_reverse";
        skillFxBg = "n.fx_skill_bar_bg_reverse";
        fx_lightning = "n.fx_skill_bar_lightning_reverse";
        fx_pic = "n.fx_skill_bar_pet_reverse";
    end
    
    --设置技能名称栏的位置
    local cmd1;
    if camp == E_CARD_CAMP_HERO then
        cmd1 = createCommandLua():SetCmd( "SetSkillNameBarToLeft", 0, 0, "" );
    else
        cmd1 = createCommandLua():SetCmd( "SetSkillNameBarToRight", 0, 0, "" );
    end
    if cmd1 ~= nil then
        seqUI:AddCommand( cmd1 );
    end 
    
    --增加蒙版
    local cmd2 = createCommandLua():SetCmd( "AddMaskImage", 0, 0, "" );
    if cmd2 ~= nil then
        seqUI:AddCommand( cmd2 );
    end 
    
    --大招名称特效
    --0:初始化特效
    local skillNameBar;
    if w_battle_mgr.isPVE then
        skillNameBar = GetImage( w_battle_pve.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 )
    else    
        skillNameBar = GetImage( w_battle_pvp.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 );
    end
    local cmdBor = createCommandEffect():AddFgEffect( 0.01, skillNameBar, skillFxBor );
    seqUI:AddCommand( cmd3 );   
    
    local cmdBg = createCommandEffect():AddFgEffect( 0.01, skillNameBar, skillFxBg );
    seqUI:AddCommand( cmdBg );   
    
    local cmdLightning = createCommandEffect():AddFgEffect( 0.01, skillNameBar, fx_lightning );
    seqUI:AddCommand( cmdLightning ); 
    
    local cmdFxPic = createCommandEffect():AddFgEffect( 0.01, skillNameBar, fx_pic );
    seqUI:AddCommand( cmdFxPic ); 
    
    local cmdFxTitle = createCommandEffect():AddFgEffect( 0.01, skillNameBar, fx_title );
    seqUI:AddCommand( cmdFxTitle ); 
    
    
    --1:设置模糊
    local cmd4 = createCommandEffect():AddActionEffect( 0.01, skillNameBar, "n.gsblur5" );
    seqUI:AddCommand( cmd4 );
    
    --2:进入屏幕
    local cmd5 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarInAction );
    seqUI:AddCommand( cmd5 );   
    
    --2:恢复清晰
    local cmd6 = createCommandEffect():AddActionEffect( 0.01, skillNameBar, "n.gsblur_zero" );
    seqUI:AddCommand( cmd6 );
    cmd6:SetDelay(0.2); 
    
    --4:移出屏幕
    local cmd7 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarOutAction );
    seqUI:AddCommand( cmd7 );   
    cmd7:SetDelay(0.3);     
        
    --隐藏蒙版
    local cmd8 = createCommandLua():SetCmd( "HideMaskImage", 0, 0, "" );
    if cmd8 ~= nil then
        seqUI:AddCommand( cmd8 );
    end 
    
    --还原技能名称栏的位置
    local cmd9 = createCommandLua():SetCmd( "ReSetSkillNameBarPos", 0, 0, "" );
    if cmd9 ~= nil then
        seqUI:AddCommand( cmd9 );
    end 
    
    local cmd_dumb = createCommandInstant():Dumb();
    if cmd_dumb ~= nil then
        seqUI:AddCommand( cmd_dumb );
    end 
    return cmd_dumb;
end






