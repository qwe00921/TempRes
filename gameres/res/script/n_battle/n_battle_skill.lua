--------------------------------------------------------------
-- FileName:    n_battle_skill.lua
-- author:      hst, 2013/11/26
-- purpose:     卡牌技能
--------------------------------------------------------------

n_battle_skill = {}
local p = n_battle_skill;

--创建新实例
function p:new()    
    o = {}
    setmetatable( o, self );
    self.__index = self;
    o:ctor(); return o;
end

--构造函数
function p:ctor()

    --单体技能配置
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
    --群体技能配置
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

--单体技能
function p:SkillSingle( atkFighter, targetfighter, hurt, batch )
    local seqSkill = batch:AddSerialSequence();     --攻击方特效
    local seqTarget = batch:AddSerialSequence();    --受击方特效
    local seqBullet = batch:AddSerialSequence();    --弹道特效
    local config = self.singleConfig;               --单体技能配置
    local bulletEnd = nil;                          --弹道特效完成指令
    
    --1:攻击方表现
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
    
    --2:技能特效：目前技能子弹特效
    if config.bulletConfig ~= nil then
        local deg = atkFighter:GetAngleByFighter( targetfighter );
        local bullet = bullet:new();
        bullet:AddToBattleLayer();
        bullet:UseConfig( config.bulletConfig );
        bullet:GetNode():SetRotationDeg( deg );
        local bullet1 = bullet:cmdSetVisible( true, seqBullet );
        local bullet2 = bullet:cmdShoot( atkFighter, targetfighter, seqBullet, false );
        bulletEnd = bullet:cmdSetVisible( false, seqBullet );
        
        --设置等待
        if cmdAni ~= nil then
            seqBullet:SetWaitEnd( cmdAni );
        elseif cmdAction ~= nil then
            seqBullet:SetWaitEnd( cmdAction );
        end
        
    end
    
    --3:受击方表现
    local cmd10;
    if config.targetAction ~= nil then
        cmd10 = createCommandEffect():AddActionEffect( config.targetActionTime, targetfighter:GetPlayerNode(), config.targetAction );
        seqTarget:AddCommand( cmd10 );
    end
    if config.targetAni ~= nil then
    	cmd10 = createCommandEffect():AddFgEffect( config.targetAniTime, targetfighter:GetPlayerNode(), config.targetAni );
        seqTarget:AddCommand( cmd10 );
    end
    
    --击退特效
    if config.backEffect then
    	local cmdBack = createCommandEffect():AddActionEffect( 0.01, targetfighter:GetPlayerNode(), "lancer.target_hurt_back" );
        seqTarget:AddCommand( cmdBack );
    end
                
    local cmd11 = targetfighter:cmdLua( "fighter_damage", tonumber( hurt ), "", seqTarget );
    
    --击退特效还原
    if config.backEffect then
        local cmdBackRset = createCommandEffect():AddActionEffect( 0, targetfighter:GetPlayerNode(), "lancer.target_hurt_back_reset" );
        seqTarget:AddCommand( cmdBackRset );
    end
                
    self:HurtResultAni( targetfighter, seqTarget );
    
    --设置等待
    if config.bulletConfig ~= nil then
        seqTarget:SetWaitEnd( bulletEnd );
    elseif cmdAni ~= nil then
        seqTarget:SetWaitEnd( cmdAni );    
    elseif cmdAction ~= nil then
        seqTarget:SetWaitEnd( cmdAction ); 
    end
end

--群体技能
function p:SkillAOE( atkFighter, targets, batch)
	if batch == nil then return end
	local config = self.aoeConfig;--群体技能配置
    local seqAtk    = batch:AddSerialSequence();
    if seqAtk == nil then
        WriteCon( "create seqAtk failed");
        return;
    end
    
    if targets == nil or #targets <= 0 then
    	WriteConErr("SkillAOE no target!");
    end
    
    --1:攻击方表现
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
    local cmd2 = createCommandEffect():AddFgEffect( 0.5, atkFighter:GetPlayerNode(), "card_battle."..atkFighter.UseConfig );
    seqAtk:AddCommand( cmd2 );
    
    --local targets = card_battle_mgr.enemyCamp:GetAliveFighters();
    for k, v in ipairs(targets) do
        local targetFighter = card_battle_mgr.FindFighter( v.index );
        
        local hurtValue = tonumber( v.hurt_value ); --伤害值
        local targetHP = tonumber( v.hp ); --伤害值
        local buffValue = tonumber( v.buff_value );
        local buffWorkTime = tonumber( v.buff_work_time );
        local buffEffect = tonumber( v.buff_effect );
        
        local seqBullet = batch:AddSerialSequence();
        local seqTarget = batch:AddSerialSequence();
        
        --2:技能特效：子弹特效
        local deg = atkFighter:GetAngleByFighter( targetFighter );
        local bullet = bullet:new();
        bullet:AddToBattleLayer();
        bullet:UseConfig(config.bulletConfig);
            
        bullet:GetNode():SetRotationDeg( deg );
        local bullet1 = bullet:cmdSetVisible( true, seqBullet );
        local bullet2 = bullet:cmdShoot( atkFighter, targetFighter, seqBullet, false );
        local bullet3 = bullet:cmdSetVisible( false, seqBullet );
        seqBullet:SetWaitEnd( cmd2 );
        
        --3:受击方表现
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
                    
         --受击者死亡
       if targetHP <= 0 and hurtValue ~= targetFighter.life then
            hurtValue = targetFighter.life;
            WriteConWarning("Mandatory death!");
            --target:Die();
       end
        
        --飘血
        local cmd12 = targetFighter:cmdLua( "fighter_damage", hurtValue, "", seqTarget );
        
        local cmdForward = createCommandEffect():AddActionEffect( 0, targetFighter:GetNode(), "card_battle.target_hurt_back_reset" );
        seqTarget:AddCommand( cmdForward ); 
        
        --受攻击的后续动画【死亡 OR 站立】
        self:HurtResultAni( targetFighter, seqTarget );
            
        --受击者序列等待子弹打到目标点
        seqTarget:SetWaitEnd( bullet3 );
    end
end

--受击结果：死亡动作或站立动画
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






