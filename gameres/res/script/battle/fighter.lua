--------------------------------------------------------------
-- FileName: 	fighter.lua
-- author:		zhangwq, 2013/05/22
-- purpose:		战士类（多实例）
-- 注意：		这个类会有多个实例，注意用法！
--------------------------------------------------------------

fighter = {}
local p = fighter;

E_DIR_LT = 1;
E_DIR_T  = 2;
E_DIR_RT = 3;
E_DIR_LB = 4;
E_DIR_B  = 5;
E_DIR_RB = 6;


--创建新实例
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	return o;
end

--构造函数
function p:ctor()
    self.node = nil; --对应Node
    self.hpbar = nil; --血条
    self.flynum_mgr = {}; --飘血
    self.footNode = nil; --脚底节点

    self.idFighter = 0;
    self.name = "";
    self.camp = 0;	--阵营
    self.life = 200;
    self.lifeMax = 200;
	self.strike_level = 100;
	self.defence = 5;
	self.attack_min = 0;
	self.attack_max = 100;
    self.isDead = false;
    self.isVisible = true;
    self.isBoss = false;
end

--初始化
function p:Init( idFighter, node, camp )
	if idFighter ~= 0 and node ~= nil then
		self.idFighter = idFighter;
		self.node = node;
		self.camp = camp;
	end
	
	self:CreateHpBar();
	self:CreateFlyNum();
	self:CreateFootNode();
end

--创建血条
function p:CreateHpBar()
	if self.hpbar == nil then
	end
end

--创建飘血数字
function p:CreateFlyNum(nType)
	local flynum = fly_num:new();
	flynum:SetOwnerNode( self.node );
	flynum:Init(nType);
	flynum:SetOffset(30,-50);
	
	self.node:AddChildZ( flynum:GetNode(), 2 );
	self.flynum_mgr[#self.flynum_mgr + 1] = flynum;
	
	if #self.flynum_mgr > 3 then
		WriteConErr( string.format("too many flynum: %s", #self.flynum_mgr));
	end
	return flynum;
end

--获取可用的飘血对象
function p:GetFreeFlyNum(nType)
--[[	for _,v in ipairs(self.flynum_mgr) do
		if not v:GetNode():IsVisible() and v:GetType() == nType then
			return v;
		end
	end--]]
	return self:CreateFlyNum(nType);
end

--创建脚底节点
function p:CreateFootNode()
	if self.footNode == nil then
		self.footNode = createNDUINode();
		self.footNode:Init();
		self.footNode:SetFramePosXY(0,0);
		self.footNode:SetFrameSize(10,10);
		self.node:AddChildZ( self.footNode, 1 );
	end
end

--设置fighter图像
function p:SetFighterPic()
	local pic = nil;
	if self.camp == E_CARD_CAMP_HERO then
		--白骨精
		pic = GetPictureByAni("lancer.bai_gu_jing", 0);
		self.node:SetPicture( pic );
		
		--加脚底光效
		self.node:AddBgEffect( "lancer_cmb.foot_fx" );
	else
		--穷奇
		pic = GetPictureByAni("lancer.boss", 1);
		self.node:SetPicture( pic );
		
		--加Action特效
		--self.node:AddActionEffect( "lancer_cmb.fighter_scale" );		
	end	
end

--是否有效
function p:IsValid()
	if idFighter ~= 0 and cardFighter ~= nil and nodeFighter ~= nil then
		return true;
	end
	return false;
end

--取node
function p:GetNode()
	return self.node;
end

--向前移动
function p:cmdMoveForward( targetFighter, seq )
	local dir = battle_util.GetDir( self, targetFighter );
	return self:cmdDoMove( dir, seq );
end

--向后移动
function p:cmdMoveBackward( targetFighter, seq )
	local dir = battle_util.GetDir( targetFighter, self );
	return self:cmdDoMove( dir, seq );	
end


--向上移动
function p:cmdMoveUp( targetFighter, seq )
	return self:cmdDoMove( E_DIR_T, seq );	
end

--向下移动
function p:cmdMoveDown( targetFighter, seq )
	return self:cmdDoMove( E_DIR_B, seq );	
end

--做位移
function p:cmdDoMove( dir, seq )
	if self.node == nil then
		WriteCon( "fighter node nil" );
		return nil;
	end
	
	local duration = 0;
	local cmd = nil;
	if dir == E_DIR_LT then
		cmd = battle_show.AddActionEffect_ToSequence( duration, self.node, "fighter.move_lt", seq );
	
	elseif dir == E_DIR_T then
		cmd = battle_show.AddActionEffect_ToSequence( duration, self.node, "fighter.move_t", seq );
		
	elseif dir == E_DIR_RT then
		cmd = battle_show.AddActionEffect_ToSequence( duration, self.node, "fighter.move_rt", seq );
		
	elseif dir == E_DIR_LB then
		cmd = battle_show.AddActionEffect_ToSequence( duration, self.node, "fighter.move_lb", seq );
		
	elseif dir == E_DIR_B then
		cmd = battle_show.AddActionEffect_ToSequence( duration, self.node, "fighter.move_b", seq );
		
	elseif dir == E_DIR_RB then
		cmd = battle_show.AddActionEffect_ToSequence( duration, self.node, "fighter.move_rb", seq );
	end	
	return cmd;
end

--是否boss
function p:IsBoss()
	return self.isBoss;
end

--设置boss标记
function p:SetBossFlag( bossFlag )
	self.isBoss = bossFlag;
	
	--设置飘血偏移
	if self.isBoss then
		local flynum = self:GetFreeFlyNum();
		local pic = self.node:GetPicture();
		if flynum ~= nil and pic ~= nil then
			local size = pic:GetDrawSize();
			flynum:SetOffset( size.w * 0.4, size.h * 0.4 );
		end
	end
end

--设置可见
function p:SetVisible( in_visible )
	self.isVisible = in_visible;
end

--普通攻击（单攻）
function p:Atk( targetFighter, batch )
	if batch == nil then return end
	
	--创建序列给攻击者、受击者
	local seqAtk 	= batch:AddSerialSequence();
	local seqTarget = batch:AddParallelSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) then
		WriteCon( "create 2 seq failed");
		return;
	end
	
	--随机
	local atkType = math.random(1,2);
	
	--攻击者
	local cmd1 = self:cmdMoveForward( targetFighter, seqAtk );
	
	if atkType == 2 then
		--火攻音效
		local cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( "battle_fire_ball.mp3" );
		seqAtk:AddCommand( cmdMusic );
		
		local cmd2 = createCommandEffect():AddFgEffect( 0.01, self.node, "lancer.hero_atk_fire" );		
		if cmd2 ~= nil then
			seqAtk:AddCommand( cmd2 );
		end	
	else
		--三个爪子音效
		local cmd3 = createCommandSoundMusicVideo():PlaySoundByName( "battle_paw.mp3" );
		seqAtk:AddCommand( cmd3 );
	end
	
	local cmd4 = self:cmdMoveBackward( targetFighter, seqAtk );
	
	--受击者
	local cmd6 = targetFighter:BossAddHurtEffect( seqTarget, false, atkType );
	local cmd7 = targetFighter:cmdMoveBackward( self, seqTarget );	
	local cmd8 = targetFighter:cmdMoveForward( self, seqTarget );
	local cmd9 = targetFighter:cmdLua( "fighter_damage", 30, "", seqTarget );
	cmd8:SetWaitEnd( cmd7 );

	--受击者序列等待攻击者
	--if atkType == 2 and cmd2 ~= nil then
		--seqTarget:SetWaitEnd( cmd2 );
	--else
		seqTarget:SetWaitEnd( cmd1 );
	--end
	
end

--加受击光效
function p:HeroAddHurtEffect( seq, bySkill )
	local cmd = nil;
	
	if bySkill then
		cmd = createCommandEffect():AddFgEffect( 0, self.node, "lancer.boss_skill_result" );
	else
		cmd = createCommandEffect():AddFgEffect( 0, self.node, "lancer.boss_atk_result" );
	end
	
	if cmd ~= nil and seq ~= nil then
		seq:AddCommand( cmd );
	end	
	return cmd;
end

--加受击光效
function p:BossAddHurtEffect( seq, bySkill, atkType ) 
	local cmd = nil;
	
	if bySkill then
		cmd = createCommandEffect():AddFgEffect( 0, self.node, "lancer.hero_skill_result" );
	else
		if atkType == 1 then
			cmd = createCommandEffect():AddFgEffect( 0, self.node, "lancer.hero_atk_result" );
		else
			cmd = createCommandEffect():AddFgEffect( 0, self.node, "lancer.hero_atk_result_fire" );
		end
	end
	
	if cmd ~= nil and seq ~= nil then
		seq:AddCommand( cmd );
	end	
	return cmd;
end

--技能攻击（单攻）
function p:AtkSkill( targetFighter, batch, bulletType, bulletRotation, fighterIndex )
	if batch == nil then		
		return;
	end
	
	--创建三个序列给攻击者、受击者、子弹
	local seqAtk 	= batch:AddSerialSequence();
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddParallelSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) or (seqBullet == nil) then
		WriteCon( "create 3 seq failed");
		return;
	end
	
	--攻击者
	local cmd1 = self:cmdMoveForward( targetFighter, seqAtk );
	local cmd2 = self:cmdMoveBackward( targetFighter, seqAtk );
	
	--子弹
	local bullet = bullet:new();
	bullet:AddToBattleLayer();
	
	if fighterIndex ~= nil then
		bullet:SetEffectEx( fighterIndex );
	else
		bullet:SetEffect(1);
	end	
	bullet:GetNode():SetRotationDeg( bulletRotation );

	local cmd3 = bullet:cmdSetVisible( true, seqBullet );
	local cmd4 = bullet:cmdShoot( self, targetFighter, seqBullet, false );
	local cmd5 = bullet:cmdSetVisible( false, seqBullet );
	
	--受击者
	local cmd6 = targetFighter:cmdAddExplosion( seqTarget, bulletType );
	local cmd7 = targetFighter:cmdMoveBackward( self, seqTarget );	
	local cmd8 = targetFighter:cmdMoveForward( self, seqTarget );
	local cmd9 = targetFighter:cmdLua( "fighter_damage", 80, "", seqTarget );
	cmd8:SetWaitEnd( cmd7 );
	
	--子弹序列等待cmd1完毕
	seqBullet:SetWaitEnd( cmd1 );
	
	--受击者序列等待子弹打到目标点
	seqTarget:SetWaitEnd( cmd5 );
end

--技能攻击（单攻）龙卷风
function p:AtkSkillTornado( targetFighter, batch, bulletType, bulletRotation, fighterIndex )
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
	
	--攻击者
	local cmd1 = self:cmdMoveForward( targetFighter, seqAtk );
	local cmd2 = self:cmdMoveBackward( targetFighter, seqAtk );
	
	--龙卷风背景旋转
	--local tornadoRotation = { 0, 0, 0, 0, 0 };

	--子弹
	local bullet = bullet:new();
	bullet:AddToBattleLayer();
	bullet:SetEffect(3);
	local cmd3 = bullet:cmdSetVisible( true, seqBullet );	
	
	--龙卷风音效
	local cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( "battle_long_juan_feng.mp3" );
	seqBullet:AddCommand( cmdMusic );
	
	local cmd4 = bullet:cmdShoot( self, targetFighter, seqBullet, false );
	local cmd5 = bullet:cmdSetVisible( false, seqBullet );
	
	--地裂
--	local cmd_x1 = createCommandEffect():AddFgEffect( 0, self.footNode, "lancer.hero_bullet7" );
--	seqGround:AddCommand( cmd_x1 );	
--	seqGround:SetWaitBegin( cmd3 );
	
	--受击者
	cmd6 = createCommandEffect():AddFgEffect( 0.01, targetFighter.node, "lancer.hero_skill_tornado" );
	seqTarget:AddCommand( cmd6 );	
	local cmd7 = targetFighter:cmdMoveBackward( self, seqTarget );	
	local cmd8 = targetFighter:cmdMoveForward( self, seqTarget );
	local cmd9 = targetFighter:cmdLua( "fighter_damage", 80, "", seqTarget );
	
	--子弹序列等待cmd1完毕
	seqBullet:SetWaitEnd( cmd1 );
	
	--受击者序列等待子弹打到目标点
	seqTarget:SetWaitEnd( cmd5 );
end


--攻击（群攻）
function p:AtkSkillMul( targetFighter1, targetFighter2, batch )
	if batch == nil then return end
	if targetFighter1 == nil or targetFighter2 == nil then return end
	
	--创建序列给攻击者
	local seqAtk = batch:AddSerialSequence();
	if seqAtk == nil then return end;
	
	--攻击者（方向仅参考第一个受击者）
	local cmd1 = self:cmdMoveForward( targetFighter1, seqAtk );
	local cmd_idle1 = self:cmdIdle( 0.001, seqAtk ); --place holder
	local cmd_idle2 = self:cmdIdle( 0.001, seqAtk ); --place holder		
	local cmd2 = self:cmdMoveBackward( targetFighter1, seqAtk );

	--受
	self:BulletToTarget( cmd_idle1, targetFighter1, batch );
	self:BulletToTarget( cmd_idle2, targetFighter2, batch );
end


--受的表现
function p:BulletToTarget( cmdWait, targetFighter, batch )
	
	if cmdWait == nil then return end;
	
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddParallelSequence();
	if seqBullet == nil or seqTarget == nil then return end;	
	
	--子弹
	local bullet = bullet:new();
	bullet:AddToBattleLayer();
	bullet:SetEffect(1);
	local cmd1 = bullet:cmdSetVisible( true, seqBullet );
	local cmd2 = bullet:cmdShoot( self, targetFighter, seqBullet, true );
	local cmd3 = bullet:cmdSetVisible( false, seqBullet );
	cmd1:SetWaitEnd( cmdWait );
		
	--受击者
	local cmd4  = targetFighter:cmdAddExplosion( seqTarget );
	local cmd5 = targetFighter:cmdMoveBackward( self, seqTarget );	
	local cmd6 = targetFighter:cmdMoveForward( self, seqTarget );
	cmd6:SetWaitEnd( cmd5 );
	seqTarget:SetWaitEnd( cmd3 );
end

--取fighter中心位置
function p:GetFighterCenterPos()
	local targetRect = self.node:GetFrameRect();	
	local org = targetRect.origin;
	local size = targetRect.size;
	local centerX = org.x + size.w * 0.5;
	local centerY = org.y + size.h * 0.5;
	return centerX,centerY;
end

--脚底加子弹爆炸特效
function p:cmdAddExplosion( seq, bulletType )
	local fx;
	if bulletType == 1 then
		fx = "effect.explosion";
	elseif bulletType == 2 then
		fx = "lancer.hero_skill_result";
	end
	
	local cmd = createCommandEffect():AddFgEffect( 0, self.node, fx );
	if cmd ~= nil and seq ~= nil then
		seq:AddCommand( cmd );
	end	
	return cmd;
end

--哑命令
function p:cmdDumb( seq )
	if seq == nil then return nil end
	local cmd = createCommandInstant():Dumb( duration );
	if cmd ~= nil then
		seq:AddCommand( cmd );
	end	
	return cmd;
end

--空闲命令
function p:cmdIdle( duration, seq )
	if seq == nil then return nil end
	local cmd = createCommandInterval():Idle( duration );
	if cmd ~= nil then
		seq:AddCommand( cmd );
	end	
	return cmd;
end

--Boss攻击整个阵营（用普通攻击）
function p:BossAtkCamp( camp, batch )
	if camp == nil or batch == nil then return end
	
	--取中间目标作为参考方向
	local refTarget = camp:GetFighterAt(3);
	
	--创建序列给攻击者
	local seqAtk = batch:AddSerialSequence();
	if seqAtk == nil then return end;
	
	--攻击者（方向仅参考第一个受击者）
	local cmd1 = self:cmdMoveForward( refTarget, seqAtk );
	--BOSS撞击音效
	local cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( "battle_boss_crack.mp3" );
	seqAtk:AddCommand( cmdMusic );
	
	--占位，用来被等待
	local cmd_dumb = {};
	for i = 1, 5 do
		cmd_dumb[i] = self:cmdDumb( seqAtk );
	end
	local cmd2 = self:cmdMoveBackward( refTarget, seqAtk );
	
	--受
	local targetCount = camp:GetFighterCount();
	for i = 1, targetCount do
		local target = camp:GetFighterAt(i);
		if target ~= nil then
			local seq = batch:AddSerialSequence();
			if seq ~= nil then				
				--播放受击特效
				local cmd1 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "lancer.boss_atk_result" );
				seq:AddCommand( cmd1 );
				
				--击退效果
				local cmd2 = target:cmdMoveBackward( self, seq );
				local cmd3 = target:cmdMoveForward( self, seq );
				local cmd4 = target:cmdLua( "fighter_damage", 100, "", seq );
				
				--设置等待
				cmd3:SetWaitEnd( cmd2 );
				seq:SetWaitEnd( cmd_dumb[i] );
			end				
		end
	end
end

--Boss攻击整个阵营（用技能）
function p:BossAtkCamp_BySkill( camp, batch )
	if camp == nil or batch == nil then return end
	
	--取中间目标作为参考方向
	local refTarget = camp:GetFighterAt(3);
	
	--创建序列给攻击者
	local seqAtk = batch:AddSerialSequence();
	if seqAtk == nil then return end;
	
	--攻击者（方向仅参考第一个受击者）	
	local cmd1 = self:cmdMoveForward( refTarget, seqAtk );				
	local cmd2 = self:cmdMoveBackward( refTarget, seqAtk );
	
	--火雨音效
	local cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( "battle_fire_rain.mp3" );
	seqAtk:AddCommand( cmdMusic );
	
	--火燃烧音效
	--local cmdMusic2 = createCommandSoundMusicVideo():PlaySoundByName( "battle_fire_raging.mp3" );
	--seqAtk:AddCommand( cmdMusic2 );

	
	--占位，用来被等待
	local cmd_dumb = {};
	for i=1,10 do
		cmd_dumb[i] = self:cmdDumb( seqAtk );
	end
		
	--受
	local targetCount = camp:GetFighterCount();
	for i = 1, targetCount do
		local target = camp:GetFighterAt(i);
		if target ~= nil then
		
			local seq1 = batch:AddSerialSequence();
			if seq1 ~= nil then
				--受击特效
				local cmd = createCommandEffect():AddFgEffect( 0, target:GetNode(), "lancer_cmb.boss_skill_result" );
				seq1:AddCommand( cmd );
				
				--设置等待
				seq1:SetWaitEnd( cmd_dumb[i*2-1] );
			end
			
			--击退
			local seq2 = batch:AddSerialSequence();
			if seq2 ~= nil then
				--击退效果
				target:cmdIdle( 1.8, seq2 );
				target:cmdMoveBackward( self, seq2 );
				target:cmdMoveForward( self, seq2 );
				seq2:SetWaitEnd( cmd_dumb[i*2] );
				
				local cmd = target:cmdLua( "fighter_damage", 200, "", seq2 );
			end
		end
	end
end

--[[
--Boss攻击整个阵营（用技能）满屏新技能
function p:BossAtkCamp_BySkill( camp, batch )
	if camp == nil or batch == nil then return end
	
	--取中间目标作为参考方向
	local refTarget = camp:GetFighterAt(3);
	
	--创建序列给攻击者
	local seqAtk = batch:AddSerialSequence();
	if seqAtk == nil then return end;
	
	--攻击者（方向仅参考第一个受击者）
	local cmd1 = self:cmdMoveForward( refTarget, seqAtk );
	
	local cmd2 = createCommandEffect():AddFgEffect( 0.01, self.node, "lancer_cmb.boss_skill_result_2" );
	seqAtk:AddCommand( cmd2 );
				
	local cmd3 = self:cmdMoveBackward( refTarget, seqAtk );
	
	--占位，用来被等待
	local cmd_dumb = {};
	for i=1,10 do
		cmd_dumb[i] = self:cmdDumb( seqAtk );
	end

	--受
	local targetCount = camp:GetFighterCount();
	for i = 1, targetCount do
		local target = camp:GetFighterAt(i);
		if target ~= nil then
		
			local seq1 = batch:AddSerialSequence();
			if seq1 ~= nil then
				--受击特效
				local cmd = createCommandEffect():AddFgEffect( 0, target:GetNode(), "lancer.boss_skill_result05" );
				seq1:AddCommand( cmd );
				
				--设置等待
				seq1:SetWaitEnd( cmd_dumb[i*2-1] );
			end
			
			--击退
			local seq2 = batch:AddSerialSequence();
			if seq2 ~= nil then
				--击退效果
				target:cmdIdle( 1.8, seq2 );
				target:cmdMoveBackward( self, seq2 );
				target:cmdMoveForward( self, seq2 );
				seq2:SetWaitEnd( cmd_dumb[i*2] );
				
				local cmd = target:cmdLua( "fighter_damage", 200, "", seq2 );
			end
		end
	end
end
--]]

--受击
--将攻击者作为参数传进来方便判定方向
function p:Hurt( atkFighter )
end

--飘血
function p:PlayDamageNum( num )
end

function p:GetId()
	return self.idFighter;
end

function p:GetLife()
	return self.life;
end

function p:GetLifeMax()
	return self.lifeMax;
end

--设置血条
function p:GetHpBar()
	return self.hpbar;
end

--设置血量
function p:SetLife( num )
	self.life = num;
	if self.hpbar ~= nil then
		self.hpbar:SetLife( self.life );
	end	
end

--设置血量
function p:SetLifeMax( num )
	self.lifeMax = num;
	if self.hpbar ~= nil then
		self.hpbar:SetLifeMax( self.lifeMax );
	end	
end

--去血
function p:SetLifeDamage(num)	
	self.life = self.life - num;
	--WriteCon( string.format("%f", self.life ));
	if self.life <= 0 then
		self.life = 0;
		self:SetLife( 0 );
		self:Die();
		
		--死亡不显示血条
		self.hpbar:GetNode():SetVisible( false );
		
		if E_DEMO_VER == 2 then
			if not x_battle_mgr.CheckBattleWin() then
				x_battle_mgr.CheckBattleLose();
			end	
		elseif E_DEMO_VER == 3 then	
			if not card_battle_mgr.CheckBattleWin() then
				card_battle_mgr.CheckBattleLose();
			end			
		elseif E_DEMO_VER == 1 then	
			if self:IsBoss() then
				battle_mgr.OnBattleWin();
			else
				battle_mgr.CheckBattleLose();
			end		
		end
	else
		self:SetLife(self.life);
	end
	
	--表现飘血
	local flynum = self:GetFreeFlyNum(0);
	if flynum ~= nil then
		flynum:PlayNum( num );
	end
end

function p:SetLifeStrikeDamage(num)
	self.life = self.life - num;
	--WriteCon( string.format("%f", self.life ));
	if self.life <= 0 then
		self.life = 0;
		self:SetLife( 0 );
		self:Die();
		
		--死亡不显示血条
		self.hpbar:GetNode():SetVisible( false );
		
		if E_DEMO_VER == 2 then
			if not x_battle_mgr.CheckBattleWin() then
				x_battle_mgr.CheckBattleLose();
			end	
		elseif E_DEMO_VER == 3 then	
			if not card_battle_mgr.CheckBattleWin() then
				card_battle_mgr.CheckBattleLose();
			end			
		elseif E_DEMO_VER == 1 then	
			if self:IsBoss() then
				battle_mgr.OnBattleWin();
			else
				battle_mgr.CheckBattleLose();
			end		
		end
	else
		self:SetLife(self.life);
	end
	
	--表现飘血
	local flynum = self:GetFreeFlyNum(1);
	if flynum ~= nil then
		flynum:PlayNum( num );
	end
end

function p:SetLifeHeal(num)
	self.life = self.life + num;

	if self.life > self.lifeMax then
		self.life = self.lifeMax
	end
	
	--WriteCon( string.format("%f", self.life ));
	if self.life <= 0 then
		self.life = 0;
		self:SetLife( 0 );
		self:Die();
		
		--死亡不显示血条
		self.hpbar:GetNode():SetVisible( false );
		
		if E_DEMO_VER == 2 then
			if not x_battle_mgr.CheckBattleWin() then
				x_battle_mgr.CheckBattleLose();
			end	
		elseif E_DEMO_VER == 3 then	
			if not card_battle_mgr.CheckBattleWin() then
				card_battle_mgr.CheckBattleLose();
			end			
		elseif E_DEMO_VER == 1 then	
			if self:IsBoss() then
				battle_mgr.OnBattleWin();
			else
				battle_mgr.CheckBattleLose();
			end		
		end
	else
		self:SetLife(self.life);
	end
	
	--表现飘血
	local flynum = self:GetFreeFlyNum(2);
	if flynum ~= nil then
		flynum:PlayNum( num );
	end
end

--死亡
function p:Die()
	self.isDead = true;
	--self:GetNode():AddActionEffect( "lancer_cmb.die_v2" );
end

--是否活着
function p:IsAlive()
	return not self:IsDead();
end

--是否死亡
function p:IsDead()
	return self.isDead;
end

--添加lua命令
function p:cmdLua( cmdtype, num, str, seq )
	if seq == nil then return nil end
	local cmd = createCommandLua():SetCmd( cmdtype, self:GetId(), num, str );
	if cmd ~= nil then
		seq:AddCommand( cmd );
	end	
	return cmd;	
end