--------------------------------------------------------------
-- FileName:    n_battle_pet_skill.lua
-- author:      hst, 2013年12月1日
-- purpose:     宠物技能
--------------------------------------------------------------

n_battle_pet_skill = {}
local p = n_battle_pet_skill;

--宠物技能
function p.skill( UCamp, TCamp, PetId, SkillId, Targets, batch )
    if batch == nil then return end
    local seqSkill    = batch:AddSerialSequence();
    if seqSkill == nil then
        WriteCon( "create seqAtk failed");
        return;
    end
    
    if Targets == nil or #Targets <= 0 then
        WriteConErr("Skill no target!");
    end
    
    --local uiEffectCmd = p.doUIEffect( UCamp, seqSkill );
    local petPic = createNDUIImage();
    petPic:Init();
    b_battle_mgr.uiLayer:AddChildZ( p.imageMask,101);
    
    local petAni = 
    
    
    --[[
    if self.footNode == nil then
        self.footNode = createNDUINode();
        self.footNode:Init();
        self.footNode:SetFramePosXY(0,0);
        self.footNode:SetFrameSize(10,10);
        self.node:AddChildZ( self.footNode, 1 );
    end
    --]]
    
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

--受击结果：死亡动作或站立动画
function p.HurtResultAni( targetFighter, seqTarget )
    if targetFighter:CheckTmpLife() then
        --local cmdA = createCommandPlayer():Standby( 0, targetFighter:GetNode(), "" );
        --seqTarget:AddCommand( cmdA );
    else
        --local cmdB = createCommandPlayer():Dead( 0, targetFighter:GetNode(), "" );
        --seqTarget:AddCommand( cmdB );   
        
        local cmdC = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer_cmb.die_v2" );
        seqTarget:AddCommand( cmdC );
    end
end
    