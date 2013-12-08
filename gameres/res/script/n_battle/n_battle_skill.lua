--------------------------------------------------------------
-- FileName:    n_battle_skill.lua
-- author:      hst, 2013/11/26
-- purpose:     ���Ƽ���
--------------------------------------------------------------

n_battle_skill = {}
local p = n_battle_skill;

--����
function p.Skill( hero, SkillId, distance, Targets, TCamp, batch )
    if hero == nil or SkillId == nil or distance == nil or Targets == nil or TCamp == nil or batch == nil then 
        WriteConWarning("n_battle_skill.Skill data err!");
        return false; 
    end
    
    --����3�����и������ߡ��ܻ��ߡ�ui
    local seqAtk    = batch:AddSerialSequence();
    local seqTarget = batch:AddParallelSequence();
    local seqUI = batch:AddSerialSequence();
    
    local playerNode = hero:GetPlayerNode();
    
    --�����������λ��
    local originPos = playerNode:GetCenterPos();
    
    --�ܻ�Ŀ������
    local targetType = tonumber( SelectCell( T_SKILL, SkillId, "Target_type" ) );
    local skillType = tonumber( SelectCell( T_SKILL, SkillId, "Skill_type" ) );
    local isSelfCamp = IsSkillTargetSelfCamp( targetType );
    
    --����Ŀ���λ��
    local enemyPos; 
    if IsAoeSkillByType( targetType ) then
       enemyPos = n_battle_pvp.GetScreenCenterPos();
    else
       enemyPos = GetBestTargetPos( hero, TCamp, Targets );    
    end
    
    local sing = SelectCell( T_SKILL_RES, SkillId, "sing_effect" );
    local hurt = SelectCell( T_SKILL_RES, SkillId, "hurt_effect" );
    local isBullet = tonumber( SelectCell( T_SKILL_RES, SkillId, "is_bullet" ) );
    local bulletAni;
    if isBullet == N_BATTLE_BULLET_1 then
    	bulletAni = "n_bullet."..tostring( hero.cardId );
    end
    
    local cmdSetPic = hero:cmdLua( "SetFighterPic",  0, "", seqAtk );
    
    local cmd1 = createCommandEffect():AddFgEffect( 0.1, hero:GetNode(), sing );
    seqAtk:AddCommand( cmd1 );
    
    --��ս����
    local cmdDoPos;
    if distance == N_BATTLE_DISTANCE_1 then
        cmdDoPos = JumpMoveTo(hero, originPos, enemyPos, seqAtk );
    end
    
    local cmd2 = createCommandPlayer():Atk( 0, hero:GetPlayerNode(), "" );
    seqAtk:AddCommand( cmd2 );
    
    local cmd3 = createCommandPlayer():Standby( 0.01, hero:GetPlayerNode(), "" );
    seqAtk:AddCommand( cmd3 );
    
    if distance == N_BATTLE_DISTANCE_1 then
        local cmd4 = JumpMoveTo(hero, enemyPos, originPos, seqAtk);
    end
           
    local cmdClearPic = hero:cmdLua( "ClearAllFighterPic",  0, "", seqAtk );
                            
    local cmd_ui = p.doUIEffect( hero.camp, seqUI, SkillId );
    
    seqUI:SetWaitEnd( cmd1 );
    if distance == N_BATTLE_DISTANCE_1 and cmdDoPos ~= nil then
        cmdDoPos:SetWaitEnd( cmd_ui );
    else
        cmd2:SetWaitEnd( cmd_ui );
    end
    
    for k, v in ipairs(Targets) do
        local enemy = nil; --�ܻ���
        if TCamp == E_CARD_CAMP_HERO then
            enemy = n_battle_mgr.heroCamp:FindFighter( tonumber( v.TPos ) );
        elseif TCamp == E_CARD_CAMP_ENEMY then
            enemy = n_battle_mgr.enemyCamp:FindFighter( tonumber( v.TPos ) + N_BATTLE_CAMP_CARD_NUM );
        end
        local Damage = tonumber( v.Damage ); --�۳�Ѫ��
        local RemainHp = tonumber( v.RemainHp ); --��ʣѪ��
        local Buff = tonumber( v.Buff );
        local Crit = v.Crit; --����
        local Dead = v.TargetDead;--����
        --�ܻ�������
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
            	--2:������Ч���ӵ���Ч
                local deg = hero:GetAngleByFighter( enemy );
                local bullet = n_bullet:new();
                bullet:AddToBattleLayer();
                bullet:SetEffectAni( bulletAni );
                    
                bullet:GetNode():SetRotationDeg( deg );
                local bullet1 = bullet:cmdSetVisible( true, seqBullet );
                local bullet2 = bullet:cmdShoot( hero, enemy, seqBullet, false );
                bulletend = bullet:cmdSetVisible( false, seqBullet );
                seqBullet:SetWaitEnd( cmd2 );
            end
        
            if seq1 ~= nil then
                --�ܻ���Ч
                local cmd11 = createCommandEffect():AddFgEffect( 0, enemy:GetNode(), hurt );
                seq1:AddCommand( cmd11 );
                
                local cmd12;
                if not isSelfCamp then
                	local cmdBackRset = createCommandEffect():AddActionEffect( 0.01, enemy:GetNode(), "lancer.target_hurt_back_reset" );
                    seq1:AddCommand( cmdBackRset ); 
                    cmdBackRset:SetWaitEnd( cmd11 );
                    
                    --�ܻ�����
                    cmd12 = createCommandPlayer():Hurt( 0, enemy:GetNode(), "" );
                    seq1:AddCommand( cmd12 );
                end
                
                --ƮѪ
                local cmd13;
                if skillType == N_SKILL_TYPE_1 then
                    cmd13 = enemy:cmdLua( "fighter_damage",  Damage, "", seq1 );
                elseif skillType == N_SKILL_TYPE_2 then 
                    cmd13 = enemy:cmdLua( "fighter_addHp", Damage, "", seq1 );
                elseif skillType == N_SKILL_TYPE_5 then
                    --���������    
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
                
                --���õȴ�
                if bulletend ~= nil then
                	seq1:SetWaitEnd( bulletend );
                else
                	seq1:SetWaitEnd( cmd3 );
                end
                
            end     
        end
    end 
end

function p.doUIEffect( camp, seqUI, SkillId )
    --��ʼ��������������Ӧ��ACTION��Ч
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
    
    --���ü�����������λ��
    local cmd1;
    if camp == E_CARD_CAMP_HERO then
        cmd1 = createCommandLua():SetCmd( "SetSkillNameBarToLeft", 0, 0, "" );
    else
        cmd1 = createCommandLua():SetCmd( "SetSkillNameBarToRight", 0, 0, "" );
    end
    if cmd1 ~= nil then
        seqUI:AddCommand( cmd1 );
    end 
    
    --�����ɰ�
    local cmd2 = createCommandLua():SetCmd( "AddMaskImage", 0, 0, "" );
    if cmd2 ~= nil then
        seqUI:AddCommand( cmd2 );
    end 
    
    --����������Ч
    --0:��ʼ����Ч
    local skillNameBar;
    if n_battle_mgr.isPVE then
        skillNameBar = GetImage( n_battle_pve.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 )
    else    
        skillNameBar = GetImage( n_battle_pvp.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 );
    end
    local cmdBor = createCommandEffect():AddFgEffect( 0.01, skillNameBar, skillFxBor );
    seqUI:AddCommand( cmd3 );   
    
    local cmdBg = createCommandEffect():AddFgEffect( 0.01, skillNameBar, skillFxBg );
    seqUI:AddCommand( cmdBg );   
    
    local cmdLightning = createCommandEffect():AddFgEffect( 0.01, skillNameBar, fx_lightning );
    seqUI:AddCommand( cmdLightning ); 
    
    local cmdFxPic = createCommandEffect():AddFgEffect( 0, skillNameBar, fx_pic );
    seqUI:AddCommand( cmdFxPic ); 
    
    local cmdFxTitle = createCommandEffect():AddFgEffect( 0, skillNameBar, fx_title );
    seqUI:AddCommand( cmdFxTitle ); 
    
    
    --1:����ģ��
    local cmd4 = createCommandEffect():AddActionEffect( 0.01, skillNameBar, "n.gsblur5" );
    seqUI:AddCommand( cmd4 );
    
    --2:������Ļ
    local cmd5 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarInAction );
    seqUI:AddCommand( cmd5 );   
    
    --2:�ָ�����
    local cmd6 = createCommandEffect():AddActionEffect( 0, skillNameBar, "n.gsblur_zero" );
    seqUI:AddCommand( cmd6 );
    cmd6:SetDelay(0.2); 
    
    --4:�Ƴ���Ļ
    local cmd7 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarOutAction );
    seqUI:AddCommand( cmd7 );   
    cmd7:SetDelay(0.3);     
        
    --�����ɰ�
    local cmd8 = createCommandLua():SetCmd( "HideMaskImage", 0, 0, "" );
    if cmd8 ~= nil then
        seqUI:AddCommand( cmd8 );
    end 
    
    --��ԭ������������λ��
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






