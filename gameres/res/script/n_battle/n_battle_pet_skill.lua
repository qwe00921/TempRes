--------------------------------------------------------------
-- FileName:    n_battle_pet_skill.lua
-- author:      hst, 2013��12��1��
-- purpose:     ���＼��
--------------------------------------------------------------

n_battle_pet_skill = {}
local p = n_battle_pet_skill;

--���＼��
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
    
    local petNode = n_battle_mgr.GetPetNode( PetId, UCamp );
    
    --��ʼ��������������Ӧ��ACTION��Ч
    local petInAction = nil;
    local petOutAction = nil;
    local skillFx = nil;
    
    --����ͼƬλ������
    local cmd1;
    if UCamp == E_CARD_CAMP_HERO then
        petInAction = "n.pet_left_in";
        petOutAction = "n.pet_right_out";
        skillFx = "";
        p.SetToScreenLeft( petNode );
    else
        petInAction = "n.pet_right_in";
        petOutAction = "n.pet_left_out";
        skillFx = ""
        p.SetToScreenRight( petNode );
    end
    --�����ɰ�
    --local cmdAddMask = createCommandLua():SetCmd( "AddMaskImage", 0, 0, "" );
    --seqSkill:AddCommand( cmdAddMask );
    
    --1:����ģ��
    --local cmdGsblur = createCommandEffect():AddActionEffect( 0.01, petNode, "n.gsblur5" );
    --seqSkill:AddCommand( cmdGsblur );
    
    local cmdIn = createCommandEffect():AddActionEffect( 0, petNode, petInAction );
    seqSkill:AddCommand( cmdIn );   
    
    --2:�ָ�����
    --local cmdGsblurZero = createCommandEffect():AddActionEffect( 0, petNode, "n.gsblur_zero" );
   -- seqSkill:AddCommand( cmdGsblurZero );
    --cmdGsblurZero:SetDelay(0.5); 
    
    local Idle = createCommandInterval():Idle( 1 );
    if Idle ~= nil then
        seqSkill:AddCommand( Idle );
    end 
    
    local cmdOut = createCommandEffect():AddActionEffect( 0, petNode, "n.n_fadeout" );
    seqSkill:AddCommand( cmdOut );
    
    --�����ɰ�
    --local cmdHideMask = createCommandLua():SetCmd( "HideMaskImage", 0, 0, "" );
    --seqSkill:AddCommand( cmdHideMask );
    
    
end

--�Ƶ���Ļ���
function p.SetToScreenLeft( node )
    local tempPos = node:GetFramePos();
    node:SetFramePosXY( -256, GetScreenHeight()/2 - 128 );
end

--�Ƶ���Ļ�ұ�
function p.SetToScreenRight( node )
    local tempPos = node:GetFramePos();
    node:SetFramePosXY( -640, GetScreenHeight()/2 - 128 );
end

function p.doUIEffect( UCamp, seqUI )
    --��ʼ��������������Ӧ��ACTION��Ч
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
    
    --���ü�����������λ��
    local cmd1;
    if UCamp == E_CARD_CAMP_HERO then
        cmd1 = createCommandLua():SetCmd( "SetSkillNameBarToLeft", 0, 0, "" );
    else
        cmd1 = createCommandLua():SetCmd( "SetSkillNameBarToRight", 0, 0, "" );
    end
    seqUI:AddCommand( cmd1 );
    
    --�����ɰ�
    local cmd2 = createCommandLua():SetCmd( "AddMaskImage", 0, 0, "" );
    seqUI:AddCommand( cmd2 );
    
    --����������Ч
    --0:��ʼ����Ч
    local skillNameBar = GetImage( n_battle_pvp.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 )
    local cmd3 = createCommandEffect():AddFgEffect( 0.01, skillNameBar, skillFx );
    seqUI:AddCommand( cmd3 );   
    
    --1:����ģ��
    local cmd4 = createCommandEffect():AddActionEffect( 0.01, skillNameBar, "n.gsblur5" );
    seqUI:AddCommand( cmd4 );
    
    --2:������Ļ
    local cmd5 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarInAction );
    seqUI:AddCommand( cmd5 );   
    
    --2:�ָ�����
    local cmd6 = createCommandEffect():AddActionEffect( 0, skillNameBar, "n.gsblur_zero" );
    seqUI:AddCommand( cmd6 );
    cmd6:SetDelay(0.5); 
    
    --4:�Ƴ���Ļ
    local cmd7 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarOutAction );
    seqUI:AddCommand( cmd7 );   
    cmd7:SetDelay(0.3);     
        
    --�����ɰ�
    local cmd8 = createCommandLua():SetCmd( "HideMaskImage", 0, 0, "" );
    seqUI:AddCommand( cmd8 );
    
    --��ԭ������������λ��
    local cmd9 = createCommandLua():SetCmd( "ReSetSkillNameBarPos", 0, 0, "" );
    seqUI:AddCommand( cmd9 );
    
    local cmd_dumb = createCommandInstant():Dumb( 0 );
    seqUI:AddCommand( cmd_dumb );
    return cmd_dumb;
end

--�ܻ����������������վ������
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
    