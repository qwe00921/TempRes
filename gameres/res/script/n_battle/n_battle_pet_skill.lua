--------------------------------------------------------------
-- FileName:    n_battle_pet_skill.lua
-- author:      hst, 2013年12月1日
-- purpose:     宠物技能
--------------------------------------------------------------

n_battle_pet_skill = {}
local p = n_battle_pet_skill;

--宠物技能
function p.skill(UCamp, TCamp, Pos, SkillId, Targets, Rage, batch )
    if batch == nil then return end
    local batch = batch;
    local seqSkill  = batch:AddSerialSequence();
    local seqTarget = batch:AddParallelSequence();
    
    if seqSkill == nil then
        WriteCon( "create seqSkill failed");
        return;
    end
    if Targets == nil or #Targets <= 0 then
        WriteConErr("Skill no target!");
    end
    local petNode = n_battle_mgr.GetPetNode( Pos, UCamp );
    local petNameNode = n_battle_mgr.GetPetNameNode( Pos, UCamp );
    local hurtEffect = SelectCell( T_SKILL_RES, SkillId, "hurt_effect" );
    local skillType = tonumber( SelectCell( T_SKILL, SkillId, "Skill_type" ) );
    
    --初始化技能名称栏对应的ACTION特效
    local petInAction = nil;
    local petNameAction =  nil;
    local petOutAction = nil;
    local skillFx = nil;
    
    --宠物图片位置设置
    local cmd1;
    if UCamp == E_CARD_CAMP_HERO then
        petInAction = "n.pet_left_in";
        petNameAction ="n.pet_right_in";
        skillFx = "";
    else
        petInAction = "n.pet_right_in";
        petNameAction ="n.pet_left_in";
        skillFx = ""
    end
    local petIndex = Pos;
    if UCamp == E_CARD_CAMP_ENEMY then
    	petIndex = petIndex + N_BATTLE_CAMP_CARD_NUM;
    end
    local cmdUpDateRage = createCommandLua():SetCmd( "UpdatePetRage", petIndex, Rage, "" );
    seqSkill:AddCommand( cmdUpDateRage );
    
    --增加蒙版
    local cmdAddMask = createCommandLua():SetCmd( "AddMaskImage", 0, 0, "" );
    seqSkill:AddCommand( cmdAddMask );
    
    --1:设置模糊
    local cmdGsblur = createCommandEffect():AddActionEffect( 0.01, petNode, "n.gsblur5" );
    seqSkill:AddCommand( cmdGsblur );
    
    --宠物图片进场
    local cmdPetPicIn = createCommandEffect():AddActionEffect( 0.1, petNode, petInAction );
    seqSkill:AddCommand( cmdPetPicIn );   
    
    --宠物名称进场
    local cmdPetNameIn = createCommandEffect():AddActionEffect( 0.1, petNameNode, petNameAction );
    seqSkill:AddCommand( cmdPetNameIn );   
    
    --2:恢复清晰
    local cmdGsblurZero = createCommandEffect():AddActionEffect( 0, petNode, "n.gsblur_zero" );
    seqSkill:AddCommand( cmdGsblurZero );
    cmdGsblurZero:SetDelay(0.2); 
    
    
    local Idle = createCommandInterval():Idle( 0.5 );
    if Idle ~= nil then
        seqSkill:AddCommand( Idle );
    end 
    
    --还原位置
    local cmdReSet = createCommandLua():SetCmd( "ReSetPetNodePos", 0, 0, "" );
    seqSkill:AddCommand( cmdReSet );
    
    --隐藏蒙版
    local cmdHideMask = createCommandLua():SetCmd( "HideMaskImage", 0, 0, "" );
    seqSkill:AddCommand( cmdHideMask );
    
    for key, var in ipairs(Targets) do
    	local TPos = tonumber( var.TPos );
    	local Damage = tonumber( var.Damage );
    	local RemainHp = tonumber( var.RemainHp );
    	local Buff = tonumber( var.Buff );
    	local Dead = var.TargetDead;
    	
    	local targetF;
    	if TCamp == E_CARD_CAMP_HERO then
            targetF = n_battle_mgr.heroCamp:FindFighter( TPos );
        elseif TCamp == E_CARD_CAMP_ENEMY then
            targetF = n_battle_mgr.enemyCamp:FindFighter( TPos + N_BATTLE_CAMP_CARD_NUM );
        end
        
        --受击者死亡
        if Dead and Damage < targetF.life then
            Damage = targetF.life;
            WriteConWarning("the TargetFighter Mandatory death!");
        end
        
        --受击特效
        local cmd11 = createCommandEffect():AddFgEffect( 0, targetF:GetNode(), hurtEffect );
        seqTarget:AddCommand( cmd11 );
        
        if skillType == N_SKILL_TYPE_1 then
        	targetF:cmdLua( "fighter_damage",  Damage, "", seqTarget );
        elseif skillType == N_SKILL_TYPE_2 then	
            targetF:cmdLua( "fighter_addHp", Damage, "", seqTarget );
        elseif skillType == N_SKILL_TYPE_5 then
            --主动复活技能    
        end
        
        if Buff ~= N_BUFF_TYPE_0 then
        	local buffAni = GetBuffAniByType( Buff );
        	if not targetF:GetNode():HasAniEffect( buffAni ) then
        		local cmdBuff = createCommandEffect():AddFgEffect( 0, targetF:GetNode(), buffAni );
                seqTarget:AddCommand( cmdBuff );
                AddBuffObj( targetF, Buff, buffAni );
        	end
        end
    	HurtResultAni( targetF, seqTarget );
    end
    seqTarget:SetWaitEnd( cmdHideMask );
end

--移到屏幕左边
function p.SetToScreenLeft( node )
    local tempPos = node:GetFramePos();
    node:SetFramePosXY( -256, GetScreenHeight()/2 - 128 );
end

--移到屏幕右边
function p.SetToScreenRight( node )
    local tempPos = node:GetFramePos();
    node:SetFramePosXY( -640, GetScreenHeight()/2 - 128 );
end

function p.doUIEffect( UCamp, seqUI )
    --初始化技能名称栏对应的ACTION特效
    local skillNameBarInAction = nil;
    local skillNameBarOutAction = nil;
    local skillFx = nil;
    if UCamp == E_CARD_CAMP_HERO then
        skillNameBarInAction = "n.skill_name_move_left_in";
        skillNameBarOutAction = "n.skill_name_move_right_out";
        skillFx = "n_cmb.skill_name_fx"
    else
        skillNameBarInAction = "n.skill_name_move_right_in";
        skillNameBarOutAction = "n.skill_name_move_left_out";
        skillFx = "n_cmb.skill_name_fx_reverse"
    end
    
    --设置技能名称栏的位置
    local cmd1;
    if UCamp == E_CARD_CAMP_HERO then
        cmd1 = createCommandLua():SetCmd( "SetSkillNameBarToLeft", 0, 0, "" );
    else
        cmd1 = createCommandLua():SetCmd( "SetSkillNameBarToRight", 0, 0, "" );
    end
    seqUI:AddCommand( cmd1 );
    
    --增加蒙版
    local cmd2 = createCommandLua():SetCmd( "AddMaskImage", 0, 0, "" );
    seqUI:AddCommand( cmd2 );
    
    --大招名称特效
    --0:初始化特效
    local skillNameBar = GetImage( n_battle_pvp.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 )
    local cmd3 = createCommandEffect():AddFgEffect( 0.01, skillNameBar, skillFx );
    seqUI:AddCommand( cmd3 );   
    
    --1:设置模糊
    local cmd4 = createCommandEffect():AddActionEffect( 0.01, skillNameBar, "n.gsblur5" );
    seqUI:AddCommand( cmd4 );
    
    --2:进入屏幕
    local cmd5 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarInAction );
    seqUI:AddCommand( cmd5 );   
    
    --2:恢复清晰
    local cmd6 = createCommandEffect():AddActionEffect( 0, skillNameBar, "n.gsblur_zero" );
    seqUI:AddCommand( cmd6 );
    cmd6:SetDelay(0.5); 
    
    --4:移出屏幕
    local cmd7 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarOutAction );
    seqUI:AddCommand( cmd7 );   
    cmd7:SetDelay(0.3);     
        
    --隐藏蒙版
    local cmd8 = createCommandLua():SetCmd( "HideMaskImage", 0, 0, "" );
    seqUI:AddCommand( cmd8 );
    
    --还原技能名称栏的位置
    local cmd9 = createCommandLua():SetCmd( "ReSetSkillNameBarPos", 0, 0, "" );
    seqUI:AddCommand( cmd9 );
    
    local cmd_dumb = createCommandInstant():Dumb( 0 );
    seqUI:AddCommand( cmd_dumb );
    return cmd_dumb;
end