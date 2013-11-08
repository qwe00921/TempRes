--------------------------------------------------------------
-- FileName: 	x_fighter.lua
-- BaseClass:   fighter
-- author:		zhangwq, 2013/06/20
-- purpose:		战士类（多实例）
--------------------------------------------------------------

x_fighter = fighter:new();
local p = x_fighter;
local super = fighter;

--创建新实例
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	o.m_kShadow = {};
	return o;
end

--构造函数
function p:ctor()
    super.ctor(self);
	self.tmplife = self.life;
	self.pPrePos = nil;
	self.pOriginPos = nil;
	self.m_kShadow = nil;
end

--初始化（重载）
function p:Init( idFighter, node, camp )
	super.Init( self, idFighter, node, camp );
	--self.hpbar:GetNode():SetVisible( false );
end

--创建血条
function p:CreateHpBar()
	if self.hpbar == nil or self.m_kShadow == nil then
		self.hpbar = x_hp_bar:new();
		--self.m_kShadow = shadow:new();
		self.hpbar:CreateExpNode();
		self.node:AddChildZ( self.hpbar:GetNode(), 1 );
		--self.node:AddChildZ(self.m_kShadow:GetNode(),200);
		self.hpbar:Init( self.node, self.life, self.lifeMax );
		self.hpbar:HideBar();
	--	local pShadow = self.m_kShadow:Init("lancer.shadow",self.node);
		--self.node:AddChildZ(pShadow,-1);
		--self.node:SetShadowImage(self.m_kShadow:GetNode());
	end	
end

--临时生命值
function p:SetTmpLife()
	self.tmplife = self.life;
end

function p:CheckTmpLife()
	return self.tmplife > 0;
end

function p:SetPosition(x,y)
	self.node:SetFramePosXY(x,y)
end

function p:SubTmpLife( val )
	self.tmplife = self.tmplife - val;
end

--加载配置
function p:UseConfig( config )
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:UseConfig( config );
    end	
end

--战备
function p:standby()
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:Standby("");
    end
end

--设置朝向
function p:SetLookAt( lookat )
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:SetLookAt( lookat );
    end
end

--获取朝向
function p:GetLookAt()
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        return playerNode:GetLookAt();
	else
		return E_PLAYER_LOOKAT_RIGHT;
    end
end

function p:JumpMoveTo(targetPos, pJumpSeq, isFallback)
	local fx = "lancer_cmb.begin_battle_jump";
	
	local atkPos = self.pOriginPos;
	
	local x = targetPos.x - atkPos.x;
	local y = targetPos.y - atkPos.y;
	local distance = (x ^ 2 + y ^ 2) ^ 0.75;
	
	-- calc start offset
	local startOffset = 0;
	local offsetX = x * startOffset / distance;
	local offsetY = y * startOffset / distance;
	--local pPos = CCPointMake(atkPos.x + offsetX, atkPos.y + offsetY );

	self.pOriginPos = CCPointMake(targetPos.x,targetPos.y);

	local pCmd = battle_show.AddActionEffect_ToSequence( 0, self:GetPlayerNode(), fx,pJumpSeq);
	
	local varEnv = pCmd:GetVarEnv();
	varEnv:SetFloat( "$1", x );
	varEnv:SetFloat( "$2", y );
	varEnv:SetFloat( "$3", 75 );
	
	return pCmd;
end

--取player节点
function p:GetPlayerNode()
    return ConverToPlayer(self:GetNode());
end

--做位移
function p:cmdMoveTo( playerNodePos, targetPos, seq, isEnemyCamp )
	if self.node == nil then
		WriteCon( "fighter node nil" );
		return nil;
	end
	
	local duration = 0;
	local cmd = nil;
	--local fx = "x.hero_atk";
	local fx = "x_cmb.hero_atk";
	
	local selfPos = playerNodePos;
	
	local x = targetPos.x - selfPos.x;
	local y = targetPos.y - selfPos.y;
		
	-- cmd with var
	cmd = battle_show.AddActionEffect_ToSequence( duration, self.node, fx, seq );
	local varEnv = cmd:GetVarEnv();
	varEnv:SetFloat( "$1", x );
	varEnv:SetFloat( "$2", y );
	
	return cmd;
end

function p:HurtResultAni( targetFighter, seqTarget )
	--死亡动作或站立动画
	if targetFighter:CheckTmpLife() then
		self:standby();
		--local cmdA = createCommandPlayer():Standby( 0, targetFighter:GetNode(), "" );
		--seqTarget:AddCommand( cmdA );
	else
		local cmdB = createCommandPlayer():Dead( 0, targetFighter:GetNode(), "" );
		seqTarget:AddCommand( cmdB );	
		
		local cmdC = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer_cmb.die_v2" );
		seqTarget:AddCommand( cmdC );
		
	end
end

--普通攻击（单攻）
function p:Atk( targetFighter, batch)
	if batch == nil or targetFighter == nil then return end
	
	--创建序列给攻击者、受击者
	local seqAtk 	= batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence();
	local seqMisc =   batch:AddSerialSequence();
	local seqMusic =   batch:AddSerialSequence();
	
	local targetNode = targetFighter:GetNode();
	
	--攻击者最初的位置
	local originalPos = self:GetNode():GetCenterPos();
	local ox = originalPos.x;
	local oy = originalPos.y
	
	self.pOriginPos = CCPointMake(ox,oy);

	--攻击目标的位置
	--local enemyPos = targetNode:GetCenterPos();

	local enemyPos = nil;

	if self.idCamp == E_CARD_CAMP_ENEMY then
		enemyPos = originalPos;
	else
		enemyPos = targetFighter:GetFrontPos(self:GetNode());
	end

	
	--if self.atkType==RANGED_ATTACK then
	--	enemyPos.x=enemyPos.x -200;
	--end
	
	if (seqAtk == nil) or (seqTarget == nil) then
		WriteCon( "create 2 seq failed");
		return;
	end
	
	local playerNode = self:GetPlayerNode();
	
	--奔跑动画
	local cmd1 = createCommandPlayer():Run( 0.1, playerNode, "" );
	seqAtk:AddCommand( cmd1 );
	
	--向攻击目标移动
	local cmd2 = self:JumpMoveTo(enemyPos,seqAtk,false);
	--local cmd2 = self:cmdMoveTo( originalPos, enemyPos, seqAtk, isEnemyCamp );
	
--	self.m_kShadow:MoveTo(originalPos,enemyPos);
	
	originalPos = self:GetNode():GetCenterPos();
	
	--攻击敌人动画
	local cmd3 = createCommandPlayer():Atk( 0, playerNode, "" );
	seqAtk:AddCommand( cmd3 );
	
	--设置攻击特效
	self:setAtkFx( seqMisc );
	seqMisc:SetWaitBegin( cmd3 );
	
	--设置音乐特效
	self:setAtkMusic( seqMusic )
	seqMusic:SetWaitBegin( cmd3 );
	
	--最初站立动画
	local cmd4 = createCommandPlayer():Standby( 0.01, playerNode, "" );
	seqAtk:AddCommand( cmd4 );
	
	--返回原来的位置
	local cmd5 = self:JumpMoveTo(originalPos, seqAtk, true );
	
	------------受击者-----------------------
	
	--受击动画
	local cmd10 = createCommandPlayer():Hurt( 0, targetNode, "" );
	seqTarget:AddCommand( cmd10 );
	cmd10:SetDelay( playerNode:GetAtkKeyTime_Hurt(""));
	cmd10:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
	
	--飘血
	local cmd11 = targetFighter:cmdLua( "fighter_damage", 30, "", seqTarget );
	local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", 80, "", seqTarget );
	--local cmd22 = targetFighter:cmdLua( "AddMaskImage", 0, "", seqTarget );
	
	--受攻击的后续动画【死亡 OR 站立】
	self:HurtResultAni( targetFighter, seqTarget );
	
	--受击等待攻击动画
	seqTarget:SetWaitBegin( cmd5 );
	
end

--设置攻击特效
function p:setAtkFx( seqMisc )
	local cmdMisc = nil;
	if self.petTag == PET_BLUE_DEVIL_TAG then
		cmdMisc = createCommandEffect():AddFgEffect( 0, self:GetPlayerNode(), "x.blue_devil_fx_atk" );
		cmdMisc:SetDelay(self:GetPlayerNode():GetAtkKeyTime_Atk(""));
	elseif self.petTag == PET_FLY_DRAGON_TAG then
		cmdMisc = createCommandEffect():AddFgEffect( 0, self:GetPlayerNode(), "x.dragon_fx_atk" );
		cmdMisc:SetDelay(self:GetPlayerNode():GetAtkKeyTime_Atk(""));	
	elseif self.petTag == PET_MINING_TAG then	
		cmdMisc = createCommandEffect():AddFgEffect( 0, self:GetPlayerNode(), "x.mining_fx_atk" );
		cmdMisc:SetDelay(self:GetPlayerNode():GetAtkKeyTime_Atk(""));	
	else
		cmdMisc = nil;
	end
	if cmdMisc ~= nil then
		seqMisc:AddCommand( cmdMisc );
		return cmdMisc;
	end
end

--设置普通攻击音乐
function p:setAtkMusic( seqMusic )
	local cmdMusic = nil;
	local src = nil;
	if self.petTag == PET_BLUE_DEVIL_TAG then
		src = "blue_devil_atk.mp3";
	elseif self.petTag == PET_FLY_DRAGON_TAG then
		src = "fly_dragon_atk.mp3";
	elseif self.petTag == PET_MINING_TAG then	
		src = "mining_atk.mp3";
	end		
	if src ~= nil then
		cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( src );
		cmdMusic:SetDelay(self:GetPlayerNode():GetAtkKeyTime_Atk(""));
		seqMusic:AddCommand( cmdMusic );
		return cmdMusic;
	else
		return nil;
	end
end

--设置技能攻击音乐
function p:setAtkSkillMusic( seqMusic )
	local cmdMusic = nil;
	local src = nil;
	if self.petTag == PET_BLUE_DEVIL_TAG then
		src = "blue_devil_skill.mp3";
	elseif self.petTag == PET_FLY_DRAGON_TAG then
		src = "fly_dragon_skill.mp3";
	elseif self.petTag == PET_MINING_TAG then	
		src = "mining_skill.mp3";
	end		
	if src ~= nil then
		cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( src );
		cmdMusic:SetDelay(self:GetPlayerNode():GetAtkKeyTime_Atk(""));
		seqMusic:AddCommand( cmdMusic );
		return cmdMusic;
	else
		return nil;
	end
end

--设置攻击特效
function p:setAtkSkillFx( seqMisc )
	local cmdMisc = nil;
	if self.petTag == PET_BLUE_DEVIL_TAG then
		cmdMisc = createCommandEffect():AddFgEffect( 0, self:GetPlayerNode(), "x.blue_devil_fx_cast" );
		cmdMisc:SetDelay(self:GetPlayerNode():GetSkillKeyTime_Atk(""));	
	elseif self.petTag == PET_FLY_DRAGON_TAG then
		cmdMisc = createCommandEffect():AddFgEffect( 0, self:GetPlayerNode(), "x.dragon_fx_cast" );
		cmdMisc:SetDelay(self:GetPlayerNode():GetSkillKeyTime_Atk(""));	
	elseif self.petTag == PET_MINING_TAG then
		cmdMisc = createCommandEffect():AddFgEffect( 0, self:GetPlayerNode(), "x.mining_fx_cast" );
		cmdMisc:SetDelay(self:GetPlayerNode():GetSkillKeyTime_Atk(""));		
	else
		cmdMisc = nil;
	end
	if cmdMisc ~= nil then
		seqMisc:AddCommand( cmdMisc );
		return cmdMisc;
	end
end

--普通攻击（单攻）
function p:AtkSkillNearOneToOne( targetFighter, batch, bulletType, bulletRotation, fighterIndex)
	if batch == nil then return end
	
	--创建4个序列给攻击者、受击者、子弹、地裂
	local seqAtk 	= batch:AddSerialSequence();
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence();
	local seqGround = batch:AddSerialSequence();
	local seqMisc =   batch:AddSerialSequence();
	local seqMiscHurt =   batch:AddParallelSequence();
	local seqMusic =   batch:AddSerialSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) or (seqBullet == nil) or (seqGround == nil) then
		WriteCon( "create 3 seq failed");
		return;
	end
	
	--攻击者最初的位置
	local originalPos = self:GetNode():GetCenterPos();

	--攻击目标的位置
	local enemyPos = nil;
	
	if self.idCamp == E_CARD_CAMP_ENEMY then
		enemyPos = originalPos;	
	else
		enemyPos = targetFighter:GetFrontPos(self:GetNode());	
	end

	--攻击者跑位
	local cmd1 = nil;
	--if self.petTag ~= PET_MINING_TAG then
		--cmd1 = self:cmdMoveTo( originalPos, enemyPos, seqAtk );
	--end
	--技能攻击动画
	local playerNode = self:GetPlayerNode();
	local cmd2 = createCommandPlayer():Skill( 0, playerNode, "" );
	seqAtk:AddCommand( cmd2 );
	
	--设置技能攻击特效
	--self:setAtkSkillFx( seqMisc );  --此处是喷火的特效
	--seqMisc:SetWaitBegin( cmd2 );
	
	--设置音乐特效
	self:setAtkSkillMusic( seqMusic )
	seqMusic:SetWaitBegin( cmd2 );

	if self.idCamp == E_CARD_CAMP_ENEMY then
		local myNode = self:GetPlayerNode();
		local cmd_buff = createCommandEffect():AddFgEffect( 0.5, myNode, "x.boss_cast_buff" );
		seqAtk:AddCommand( cmd_buff );	
	end
	
	--最初站立动画
	local cmd3 = createCommandPlayer():Standby( 0, playerNode, "" );
	seqAtk:AddCommand( cmd3 );
	
	--返回原来的位置
	--local cmd4;
	--if self.petTag ~= PET_MINING_TAG then
	--	cmd4= self:cmdMoveTo( enemyPos, originalPos, seqAtk );
	--end
	
	--攻击敌人动画
	local cmd9 = createCommandPlayer():Hurt( 0, targetFighter:GetNode(), "" );
	cmd9:SetDelay( playerNode:GetSkillKeyTime_Hurt(""));
	cmd9:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
	seqMiscHurt:AddCommand( cmd9 );
	
	--受击特效
	local cmd10 = nil;
	--if self.petTag == PET_BLUE_DEVIL_TAG then
		--cmd10 = createCommandEffect():AddFgEffect( 0.01, targetFighter:GetNode(), "x.blue_devil_fx_target_hurt" );
	--elseif self.petTag == PET_FLY_DRAGON_TAG then
		--cmd10 = createCommandEffect():AddFgEffect( 0.01, targetFighter:GetNode(), "x.dragon_fx_target_hurt" );
	--elseif self.petTag == PET_MINING_TAG then
	--	cmd10 = createCommandEffect():AddFgEffect( 0.01, targetFighter:GetNode(), "x.mining_fx_target_hurt" );	
	--else
	--	cmd10 = createCommandEffect():AddFgEffect( 0.01, targetFighter:GetNode(), "x.feilong" );
	--end
				
	if cmd10 ~= nil then
		seqMiscHurt:AddCommand( cmd10 );
		cmd10:SetDelay(1);		
	end
	
	--击退效果
	if self.petTag == PET_BLUE_DEVIL_TAG then
		--local cmdBack = createCommandEffect():AddActionEffect( 0, targetFighter:GetNode(), "lancer.target_hurt_back" );
		--seqMiscHurt:AddCommand( cmdBack );
	--	cmdBack:SetDelay(playerNode:GetSkillKeyTime_Atk(""));
	end
	seqMiscHurt:SetWaitBegin( cmd2 );
	
	--飘血
	local cmd12 = targetFighter:cmdLua( "fighter_damage", 80, "", seqTarget );
	local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", 80, "", seqTarget );
	
	if self.petTag == PET_BLUE_DEVIL_TAG then
		local cmdForward = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer.target_hurt_back_reset" );
		seqTarget:AddCommand( cmdForward );	
	end
	
	--受攻击的后续动画【死亡 OR 站立】
	self:HurtResultAni( targetFighter, seqTarget );
		
	--受击者序列等待子弹打到目标点
	seqTarget:SetWaitEnd( cmd2 );
end

--群攻
function p:AtkSkillOneToCamp( camp, batch )
	WriteCon( ".............AtkAOE.............");
	
	if camp == nil or batch == nil then 
		WriteCon( ".............AtkAOE ERROR.............");
		return 
	end
	
	--取中间目标作为参考方向
--	local refTarget = camp:GetFighterAt(3);
	
	--创建序列给攻击者
	local seqAtk = batch:AddSerialSequence();
	if seqAtk == nil then return end;
	
	local playerNode = self:GetPlayerNode();
	
	--技能攻击动画
	local cmd1 = createCommandPlayer():Skill( 0, playerNode, "" );
	seqAtk:AddCommand( cmd1 );
	
	--最初站立动画
	local cmd3 = createCommandPlayer():Standby( 0, playerNode, "" );
	seqAtk:AddCommand( cmd3 );
	
	--受
	local targetAlive = camp:GetAliveFighters();
	for i = 1, #targetAlive do
		local target = targetAlive[i];
		if target ~= nil then
		
			local seq1 = batch:AddSerialSequence();
			if seq1 ~= nil then
				--受击特效
				local cmd11;
				--if self.petTag == PET_BLUE_DEVIL_TAG then
				--	cmd11 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "x.blue_devil_fx_target_hurt" );
				--elseif self.petTag == PET_FLY_DRAGON_TAG then
					--cmd11 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "x.dragon_fx_target_hurt" );
				--else
					cmd11 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "x.dings" );
				--end
				seq1:AddCommand( cmd11 );
				
				--受击动画
				local cmd12 = createCommandPlayer():Hurt( 0, target:GetNode(), "" );
				seq1:AddCommand( cmd12 );
				cmd12:SetDelay( playerNode:GetSkillKeyTime_Hurt(""));
				cmd12:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
				
				--飘血
				local cmd13 = target:cmdLua( "fighter_damage", 80, "", seq1 );
				local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", 80, "", seqTarget );
				
				--受攻击的后续动画【死亡 OR 站立】
				self:HurtResultAni( target, seq1 );
				
				--target:cmdIdle( 1, seq1 );
				
				--设置等待
				seq1:SetWaitEnd( cmd1 );
			end		
		end
	end	
end

function p:doUIEffect( seqUI )
	--初始化技能名称栏对应的ACTION特效
	local skillNameBarInAction = nil;
	local skillNameBarOutAction = nil;
	local skillFx = nil;
	if self.camp == E_CARD_CAMP_HERO then
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
	if self.camp == E_CARD_CAMP_HERO then
		cmd1 = self:cmdLua( "SetSkillNameBarToLeft", 0, "", seqUI );
	else
		cmd1 = self:cmdLua( "SetSkillNameBarToRight", 0, "", seqUI );
	end
	
	--增加蒙版
	local cmd2 = self:cmdLua( "AddMaskImage", 0, "", seqUI );
	
	--大招名称特效
	--0:初始化特效
	local skillNameBar = GetImage( x_battle_pvp.battleLayer ,ui_x_battle_pvp.ID_CTRL_PICTURE_13 )
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
	local cmd8 = self:cmdLua( "HideMaskImage", 0, "", seqUI );
	
	--还原技能名称栏的位置
	local cmd9 = self:cmdLua( "ReSetSkillNameBarPos", 0, "", seqUI );
	
	local cmd_dumb = self:cmdDumb( seqUI );
	return cmd_dumb;
end

--终极必杀技【目前只有蓝魔鬼拥有】
function p:UltimateSkill( camp, batch )
	WriteCon( ".............Ultimate Skill.............");
	
	if camp == nil or batch == nil then 
		WriteCon( ".............Ultimate Skill ERROR.............");
		return 
	end
	
	--创建3个序列给攻击者、受击者、ui
	local seqAtk 	= batch:AddParallelSequence();
	local seqTarget = batch:AddParallelSequence();
	local seqUI = batch:AddSerialSequence();
	
	--攻击者最初的位置
	local originalPos = self:GetNode():GetCenterPos();
	
	--取阵营中心点位置
	local campCenterPos = originalPos;--GetImage( x_battle_pvp.battleLayer ,ui_x_battle_pvp.ID_CTRL_PICTURE_12 ):GetCenterPos();
	
	--吟唱动作
	local cmd1 = createCommandPlayer():Sing( 0, self:GetPlayerNode(), "" );
	seqAtk:AddCommand( cmd1 );
	
	--吟唱动作特效
	local cmdFX = createCommandEffect():AddFgEffect( 0, self:GetPlayerNode(), "x.pet_fx_ultimate_skill" );
	seqAtk:AddCommand( cmdFX );
	
	--吟唱动作音乐
	local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( "blue_devil_sing.mp3" );
	seqAtk:AddCommand( cmdSingMusic );
	cmdSingMusic:SetWaitBegin( cmd1 );
	
	local cmd_ui= self:doUIEffect( seqUI );
	--seqUI:SetWaitEnd( cmd1 );
	
	--移动到阵营中心位置
	local cmd2 = self:cmdMoveTo( originalPos, campCenterPos, seqAtk );
	cmd2:SetWaitEnd( cmd_ui );
	
	--技能攻击动画
	local cmd3 = createCommandPlayer():Skill( 0, self:GetPlayerNode(), "" );
	seqAtk:AddCommand( cmd3 );
	
	cmd3:SetWaitEnd( cmd2 );
	
	--设置技能攻击特效
	local cmd4 = self:setAtkSkillFx( seqAtk );
	cmd4:SetWaitBegin( cmd3 );
	
	--技能音乐
	local cmdSkillMusic = createCommandSoundMusicVideo():PlaySoundByName( "blue_devil_skill.mp3" );
	cmdSkillMusic:SetDelay( self:GetPlayerNode():GetSkillKeyTime_Atk(""));
	seqAtk:AddCommand( cmdSkillMusic );
	cmdSkillMusic:SetWaitBegin( cmd3 );
	
	--最初站立动画
	local cmd5 = createCommandPlayer():Standby( 0, self:GetPlayerNode(), "" );
	seqAtk:AddCommand( cmd5 );
	cmd5:SetWaitEnd( cmd3 );
	
	--回到原来位置
	local cmd6 = self:cmdMoveTo( campCenterPos, originalPos, seqAtk );
	cmd6:SetWaitBegin( cmd5 );
	
	--受
	local targetAlive = camp:GetAliveFighters();
	for i = 1, #targetAlive do
		local target = targetAlive[i];
		if target ~= nil then
		
			local seq1 = batch:AddParallelSequence();
			if seq1 ~= nil then
				--受击特效
				--[[
				local cmd11 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "x.blue_devil_fx_target_hurt" );
				cmd11:SetDelay( self:GetPlayerNode():GetSkillKeyTime_Hurt(""));
				seq1:AddCommand( cmd11 );
				--]]
				
				--击退效果
				--local cmdBack = createCommandEffect():AddActionEffect( 0, target:GetNode(), "lancer.target_hurt_back" );
				--seq1:AddCommand( cmdBack );
			--	cmdBack:SetDelay(self:GetPlayerNode():GetSkillKeyTime_Atk(""));
				
				--受击动画
				local cmd12 = createCommandPlayer():Hurt( 0, target:GetNode(), "" );
				seq1:AddCommand( cmd12 );
				cmd12:SetDelay( self:GetPlayerNode():GetSkillKeyTime_Hurt(""));
				cmd12:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
				
				--飘血
				local cmd13 = target:cmdLua( "fighter_damage", 80, "", seq1 );
				local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", 80, "", seqTarget );
				cmd13:SetWaitEnd( cmd12 );
				
				--击退还原
				local cmdBackRset = createCommandEffect():AddActionEffect( 0.01, target:GetNode(), "lancer.target_hurt_back_reset" );
				seq1:AddCommand( cmdBackRset );	
				cmdBackRset:SetWaitEnd( cmd13 );
				
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
					cmd16:SetWaitEnd( cmd5 );
					seq1:AddCommand( cmd16 );
					
				end
				
				--设置等待
				seq1:SetWaitBegin( cmd3 );
			end		
		end
	end	
end

--技能攻击（单攻）飞龙
function p:AtkSkillFeilong( targetFighter, batch, bulletType, bulletRotation, fighterIndex )
	if batch == nil then return end
	
	--创建4个序列给攻击者、受击者、子弹、地裂
	local seqAtk 	= batch:AddSerialSequence();
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence();
	local seqGround = batch:AddSerialSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) or (seqBullet == nil) or (seqGround == nil) then
		WriteCon( "create 3 seq failed");
		return;
	end
	
	local playerNode = self:GetPlayerNode();
	
	--技能攻击动画
	local cmd1 = createCommandPlayer():Skill( 0, playerNode, "" );
	seqAtk:AddCommand( cmd1 );
	
	--最初站立动画
	local cmd2 = createCommandPlayer():Standby( 0, playerNode, "" );
	seqAtk:AddCommand( cmd2 );
	
		
	--受击者
	cmd6 = createCommandEffect():AddFgEffect( 0.5, targetFighter.node, "x.feilong" );
	seqTarget:AddCommand( cmd6 );	
	
	--攻击敌人动画
	local cmd7 = createCommandPlayer():Hurt( 0, targetFighter.node, "" );
	seqTarget:AddCommand( cmd7 );
	cmd7:SetDelay( playerNode:GetSkillKeyTime_Hurt(""));
	cmd7:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
	
	--飘血
	local cmd8 = targetFighter:cmdLua( "fighter_damage", 80, "", seqTarget );
	local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", 80, "", seqTarget );
	
	--受攻击的后续动画【死亡 OR 站立】
	self:HurtResultAni( targetFighter, seqTarget );
		
	--受击者序列等待子弹打到目标点
	seqTarget:SetWaitEnd( cmd1 );
end

function p:JumpToPosition(batch,pTargetPos,bParallelSequence)
	local pJumpSeq = batch:AddParallelSequence();
	local fx = "lancer_cmb.begin_battle_jump";
	
	local atkPos = self:GetPlayerNode():GetCenterPos();
	local targetPos = pTargetPos;
	
	local x = targetPos.x - atkPos.x;
	local y = targetPos.y - atkPos.y;
	local distance = (x ^ 2 + y ^ 2) ^ 0.5;
	
	-- calc start offset
	local startOffset = 0;
	local offsetX = x * startOffset / distance;
	local offsetY = y * startOffset / distance;
	local pPos = CCPointMake(atkPos.x + offsetX, atkPos.y + offsetY );
	self:GetNode():SetCenterPos( pPos);
	
	local pCmd = nil;
	--self.m_kShadow:MoveTo(pPos,targetPos);
	if false == bParallelSequence then
		pCmd = battle_show.AddActionEffect_ToSequence( 0, self:GetPlayerNode(), fx);
	else
		pCmd = battle_show.AddActionEffect_ToParallelSequence( 0, self:GetPlayerNode(), fx);
	end
	
	local varEnv = pCmd:GetVarEnv();
	varEnv:SetFloat( "$1", x );
	varEnv:SetFloat( "$2", y );
	varEnv:SetFloat( "$3", 50 );
	
	return pCmd;
end

--技能攻击（单攻）
function p:AtkSkillTuc( targetFighter, batch, bulletType, bulletRotation, fighterIndex )
	if batch == nil then return end
	
	--创建4个序列给攻击者、受击者、子弹、地裂
	local seqAtk 	= batch:AddSerialSequence();
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence();
	local seqGround = batch:AddSerialSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) or (seqBullet == nil) or (seqGround == nil) then
		WriteCon( "create 3 seq failed");
		return;
	end
	
	local playerNode = self:GetPlayerNode();
	
	--技能攻击动画

	if p.idCamp == E_CARD_CAMP_ENEMY then
		
	else
		local cmdA1 = createCommandPlayer():Skill( 0, playerNode, "" );
		seqAtk:AddCommand( cmdA1 );
	end
	
	--子弹
	local bullet = bullet:new();
	bullet:AddToBattleLayer();
	bullet:UseConfig("bullet.bullet1");
		
	bullet:GetNode():SetRotationDeg( bulletRotation );
	local cmd2 = bullet:cmdSetVisible( true, seqBullet );
	local cmd3 = bullet:cmdShoot( self, targetFighter, seqBullet, false );
	local cmd4 = bullet:cmdSetVisible( false, seqBullet );
	
	
	--最初站立动画
	local cmdA2 = createCommandPlayer():Standby( 0, playerNode, "" );
	seqAtk:AddCommand( cmdA2 );
		
	--受击特效
	local cmd7 = createCommandEffect():AddFgEffect( 0.01, targetFighter.node, bullet:GetConfig():GetExplodeAni() );
	seqTarget:AddCommand( cmd7 );
	
	--受击动作
	local cmd8 = createCommandPlayer():Hurt( 0, targetFighter.node, "" );
	seqTarget:AddCommand( cmd8 );
	cmd8:SetDelay( playerNode:GetSkillKeyTime_Hurt(""));
	cmd8:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
	
	--飘血
	local cmd9 = targetFighter:cmdLua( "fighter_damage", 80, "", seqTarget );
	local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", 80, "", seqTarget );

	--受攻击的后续动画【死亡 OR 站立】
	self:HurtResultAni( targetFighter, seqTarget );
		
	--受击者序列等待子弹打到目标点
	--seqTarget:SetWaitEnd(cmd_showbar);
	seqTarget:SetWaitEnd( cmd4 );
end

--技能单攻
function p:AtkSkill(targetFighter, batch, bulletType, fighterIndex, skillType)
	local bulletRotation;
	bulletRotation = self:GetAngleByFighter( targetFighter );
	
	if self.camp == E_CARD_CAMP_ENEMY then
		bulletRotation = bulletRotation - 180;
	else

	if skillType == 1 then
		self:AtkSkillTuc( targetFighter, batch, bulletType, bulletRotation, fighterIndex );
	elseif skillType == 2 then
		self:AtkSkillFeilong( targetFighter, batch, bulletType, bulletRotation, fighterIndex );
	end	
	
	end
end

--获取两个战士之间的角度
function p:GetAngleByFighter( targetFighter )
	local selfPos = self:GetNode():GetCenterPos();
	local targetPos = targetFighter:GetNode():GetCenterPos();
	
	local tang = (selfPos.y - targetPos.y) / (targetPos.x - selfPos.x);
	local radians = math.atan(tang);
	
	local degree = radians * 180 / math.pi;
	return degree;
end

--技能群攻
function p:AtkSkillAOE(camp, batch )
	self:AtkAOE(camp, batch);
end

--获取战士前方坐标
function p:GetFrontPos(targetNode)
	local frontPos = self:GetNode():GetCenterPos();
	--local halfWidthSum = self:GetNode():GetCurAnimRealSize().w / 2 + targetNode:GetCurAnimRealSize().w / 2;
	
	if self.camp == E_CARD_CAMP_HERO then
		frontPos.x = frontPos.x;
		frontPos.y = frontPos.y + 25;
	else
		frontPos.x = frontPos.x;
		frontPos.y = frontPos.y - 28;
	end
	return frontPos;
end

function p:SetShadow(kShadow)
	self.node:SetShadow(kShadow);
end

--获取战士前方坐标
function p:GetFrontFarPos(targetNode)
	local farPos = self:GetFrontPos(targetNode);
	if self.camp == E_CARD_CAMP_HERO then
		farPos.x = farPos.x + 100;
	else
		farPos.x = farPos.x - 100;
	end
	return farPos;
end

function p:ShowHpBarMoment()
	self.hpbar:ShowBarMoment();
end

--添加lua命令
function p:cmdLua( cmdtype, num, str, seq )
	--暂时临时扣血保存到tmplife
	if cmdtype == "fighter_damage" then
		self:SubTmpLife(num);
	end
	return super.cmdLua( self, cmdtype,num, str, seq );
end