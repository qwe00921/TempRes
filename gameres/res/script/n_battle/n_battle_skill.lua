--------------------------------------------------------------
-- FileName:    n_battle_skill.lua
-- author:      hst, 2013/11/26
-- purpose:     ���Ƽ���
--------------------------------------------------------------

n_battle_skill = {}
local p = n_battle_skill;

--������ʵ��
function p:new()    
    o = {}
    setmetatable( o, self );
    self.__index = self;
    o:ctor(); return o;
end

--���캯��
function p:ctor()

    --���弼������
    self.singleConfig = {
        action = nil,
        actionTime = 0,
        ani = nil,
        aniTime = 0,
        bulletConfig = nil,
        targetAction = nil,
        targetactionTime = 0,
        targetAni = nil,
        targetAniTime = 0,
        backEffect = false
    };
    --Ⱥ�弼������
    self.aoeConfig = {
        action = nil,
        actionTime = 0,
        ani = nil,
        aniTime = 0,
        bulletConfig = nil,
        targetAction = nil,
        targetactionTime = 0,
        targetAni = nil,
        targetAniTime = 0,
    };
end

function p:Init()

    --���弼��Ĭ������
    self.singleConfig.action = "card_battle.blow_up";
    self.singleConfig.targetAni = "card_battle.b_z";
    self.singleConfig.targetAniTime = 0.01;
    
    --Ⱥ�弼��Ĭ������
    self.aoeConfig.ani = "card_battle_cmb.x_w";
    self.aoeConfig.targetAni = "card_battle.b_z";
    self.aoeConfig.targetAniTime = 0.1;
    self.aoeConfig.bulletConfig = "bullet.bullet1";
end

--���弼��
function p:SkillSingle( atkFighter, targetfighter, hurt, batch )
    local seqSkill = batch:AddSerialSequence();     --��������Ч
    local seqTarget = batch:AddSerialSequence();    --�ܻ�����Ч
    local seqBullet = batch:AddSerialSequence();    --������Ч
    local config = self.singleConfig;               --���弼������
    local bulletEnd = nil;                          --������Ч���ָ��
    
    --1:����������
    local cmdAction; 
    local cmdAni;
    if config.action ~= nil then
    	cmdAction = createCommandEffect():AddActionEffect( config.actionTime, atkFighter:GetPlayerNode(), config.action );
        seqSkill:AddCommand( cmdAction );
    end
    if config.ani ~= nil then
        cmdAni = createCommandEffect():AddFgEffect( config.aniTime, atkFighter:GetPlayerNode(), config.ani );
        seqSkill:AddCommand( cmdAni );
    end
    
    --2:������Ч��Ŀǰ�����ӵ���Ч
    if config.bulletConfig ~= nil then
        local deg = atkFighter:GetAngleByFighter( targetfighter );
        local bullet = bullet:new();
        bullet:AddToBattleLayer();
        bullet:UseConfig( config.bulletConfig );
        bullet:GetNode():SetRotationDeg( deg );
        local bullet1 = bullet:cmdSetVisible( true, seqBullet );
        local bullet2 = bullet:cmdShoot( atkFighter, targetfighter, seqBullet, false );
        bulletEnd = bullet:cmdSetVisible( false, seqBullet );
        
        --���õȴ�
        if cmdAni ~= nil then
            seqBullet:SetWaitEnd( cmdAni );
        elseif cmdAction ~= nil then
            seqBullet:SetWaitEnd( cmdAction );
        end
        
    end
    
    --3:�ܻ�������
    local cmd10;
    if config.targetAction ~= nil then
        cmd10 = createCommandEffect():AddActionEffect( config.targetActionTime, targetfighter:GetPlayerNode(), config.targetAction );
        seqTarget:AddCommand( cmd10 );
    end
    if config.targetAni ~= nil then
    	cmd10 = createCommandEffect():AddFgEffect( config.targetAniTime, targetfighter:GetPlayerNode(), config.targetAni );
        seqTarget:AddCommand( cmd10 );
    end
    
    --������Ч
    if config.backEffect then
    	local cmdBack = createCommandEffect():AddActionEffect( 0.01, targetfighter:GetPlayerNode(), "lancer.target_hurt_back" );
        seqTarget:AddCommand( cmdBack );
    end
                
    local cmd11 = targetfighter:cmdLua( "fighter_damage", tonumber( hurt ), "", seqTarget );
    
    --������Ч��ԭ
    if config.backEffect then
        local cmdBackRset = createCommandEffect():AddActionEffect( 0, targetfighter:GetPlayerNode(), "lancer.target_hurt_back_reset" );
        seqTarget:AddCommand( cmdBackRset );
    end
                
    self:HurtResultAni( targetfighter, seqTarget );
    
    --���õȴ�
    if config.bulletConfig ~= nil then
        seqTarget:SetWaitEnd( bulletEnd );
    elseif cmdAni ~= nil then
        seqTarget:SetWaitEnd( cmdAni );    
    elseif cmdAction ~= nil then
        seqTarget:SetWaitEnd( cmdAction ); 
    end
end

--Ⱥ�弼��
function p:SkillAOE( atkFighter, targets, tCamp, batch)
	if batch == nil then return end
	local config = self.aoeConfig;--Ⱥ�弼������
    local seqAtk    = batch:AddSerialSequence();
    if seqAtk == nil then
        WriteCon( "create seqAtk failed");
        return;
    end
    
    if targets == nil or #targets <= 0 then
    	WriteConErr("SkillAOE no target!");
    end
    
    --�з���������ʼ��Ϊ����ǰ����+Ӣ�۷�����
    local basePos = 0;
    if tCamp == E_CARD_CAMP_ENEMY then
        basePos = basePos + N_BATTLE_CAMP_CARD_NUM;
    end  
    
    --1:����������
    local cmdAction; 
    local cmdAni;
    if config.action ~= nil then
        cmdAction = createCommandEffect():AddActionEffect( config.actionTime, atkFighter:GetPlayerNode(), config.action );
        seqAtk:AddCommand( cmdAction );
    end
    if config.ani ~= nil then
        cmdAni = createCommandEffect():AddFgEffect( config.aniTime, atkFighter:GetPlayerNode(), config.ani );
        seqAtk:AddCommand( cmdAni );
    end
    --local cmd2 = createCommandEffect():AddFgEffect( 0.5, atkFighter:GetPlayerNode(), "card_battle."..atkFighter.UseConfig );
    --seqAtk:AddCommand( cmd2 );
    
    --local targets = card_battle_mgr.enemyCamp:GetAliveFighters();
    for k, v in ipairs(targets) do
        local targetFighter = n_battle_mgr.FindFighter( tonumber( v.TPos ) + basePos );
        
        local Damage = tonumber( v.Damage ); --�˺�ֵ
        local Dead = v.TargetDead;--����
        
        --local buffValue = tonumber( v.buff_value );
        --local buffWorkTime = tonumber( v.buff_work_time );
        --local buffEffect = tonumber( v.buff_effect );
        
        local seqBullet = batch:AddSerialSequence();
        local seqTarget = batch:AddSerialSequence();
        
        --2:������Ч���ӵ���Ч
        local deg = atkFighter:GetAngleByFighter( targetFighter );
        local bullet = n_bullet:new();
        bullet:AddToBattleLayer();
        bullet:UseConfig(config.bulletConfig);
            
        bullet:GetNode():SetRotationDeg( deg );
        local bullet1 = bullet:cmdSetVisible( true, seqBullet );
        local bullet2 = bullet:cmdShoot( atkFighter, targetFighter, seqBullet, false );
        local bullet3 = bullet:cmdSetVisible( false, seqBullet );
        seqBullet:SetWaitEnd( cmd2 );
        
        --3:�ܻ�������
        local cmd3;
        if config.targetAction ~= nil then
            cmd3 = createCommandEffect():AddActionEffect( config.targetActionTime, targetFighter:GetPlayerNode(), config.targetAction );
            seqTarget:AddCommand( cmd3 );
        end
        if config.targetAni ~= nil then
            cmd3 = createCommandEffect():AddFgEffect( config.targetAniTime, targetFighter:GetPlayerNode(), config.targetAni );
            seqTarget:AddCommand( cmd3 );
        end
        
        local cmdBack = createCommandEffect():AddActionEffect( 0, targetFighter:GetNode(), "card_battle.target_hurt_back" );
        seqTarget:AddCommand( cmdBack );
                    
        --�ܻ�������
        if Dead and Damage ~= targetFighter.life then
            Damage = targetFighter.life;
            WriteConWarning("the TargetFighter Mandatory death!");
        end
        
        --ƮѪ
        local cmd12 = targetFighter:cmdLua( "fighter_damage", Damage, "", seqTarget );
        
        local cmdForward = createCommandEffect():AddActionEffect( 0, targetFighter:GetNode(), "card_battle.target_hurt_back_reset" );
        seqTarget:AddCommand( cmdForward ); 
        
        --�ܹ����ĺ������������� OR վ����
        self:HurtResultAni( targetFighter, seqTarget );
            
        --�ܻ������еȴ��ӵ���Ŀ���
        seqTarget:SetWaitEnd( bullet3 );
    end
end

--�ܻ����������������վ������
function p:HurtResultAni( targetFighter, seqTarget )
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






