--------------------------------------------------------------
-- FileName: 	fighter.lua
-- author:		zhangwq, 2013/05/22
-- purpose:		սʿ�ࣨ��ʵ����
-- ע�⣺		�������ж��ʵ����ע���÷���
--------------------------------------------------------------

fighter = {}
local p = fighter;

E_DIR_LT = 1;
E_DIR_T  = 2;
E_DIR_RT = 3;
E_DIR_LB = 4;
E_DIR_B  = 5;
E_DIR_RB = 6;


--������ʵ��
function p:new()	
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	return o;
end

--���캯��
function p:ctor()
    self.node = nil; --��ӦNode
    self.hpbar = nil; --Ѫ��
    self.flynum_mgr = {}; --ƮѪ
    self.footNode = nil; --�ŵ׽ڵ�

    self.idFighter = 0;
    self.name = "";
    self.camp = 0;	--��Ӫ
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

--��ʼ��
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

--����Ѫ��
function p:CreateHpBar()
	if self.hpbar == nil then
	end
end

--����ƮѪ����
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

--��ȡ���õ�ƮѪ����
function p:GetFreeFlyNum(nType)
--[[	for _,v in ipairs(self.flynum_mgr) do
		if not v:GetNode():IsVisible() and v:GetType() == nType then
			return v;
		end
	end--]]
	return self:CreateFlyNum(nType);
end

--�����ŵ׽ڵ�
function p:CreateFootNode()
	if self.footNode == nil then
		self.footNode = createNDUINode();
		self.footNode:Init();
		self.footNode:SetFramePosXY(0,0);
		self.footNode:SetFrameSize(10,10);
		self.node:AddChildZ( self.footNode, 1 );
	end
end

--����fighterͼ��
function p:SetFighterPic()
	local pic = nil;
	if self.camp == E_CARD_CAMP_HERO then
		--�׹Ǿ�
		pic = GetPictureByAni("lancer.bai_gu_jing", 0);
		self.node:SetPicture( pic );
		
		--�ӽŵ׹�Ч
		self.node:AddBgEffect( "lancer_cmb.foot_fx" );
	else
		--����
		pic = GetPictureByAni("lancer.boss", 1);
		self.node:SetPicture( pic );
		
		--��Action��Ч
		--self.node:AddActionEffect( "lancer_cmb.fighter_scale" );		
	end	
end

--�Ƿ���Ч
function p:IsValid()
	if idFighter ~= 0 and cardFighter ~= nil and nodeFighter ~= nil then
		return true;
	end
	return false;
end

--ȡnode
function p:GetNode()
	return self.node;
end

--��ǰ�ƶ�
function p:cmdMoveForward( targetFighter, seq )
	local dir = battle_util.GetDir( self, targetFighter );
	return self:cmdDoMove( dir, seq );
end

--����ƶ�
function p:cmdMoveBackward( targetFighter, seq )
	local dir = battle_util.GetDir( targetFighter, self );
	return self:cmdDoMove( dir, seq );	
end


--�����ƶ�
function p:cmdMoveUp( targetFighter, seq )
	return self:cmdDoMove( E_DIR_T, seq );	
end

--�����ƶ�
function p:cmdMoveDown( targetFighter, seq )
	return self:cmdDoMove( E_DIR_B, seq );	
end

--��λ��
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

--�Ƿ�boss
function p:IsBoss()
	return self.isBoss;
end

--����boss���
function p:SetBossFlag( bossFlag )
	self.isBoss = bossFlag;
	
	--����ƮѪƫ��
	if self.isBoss then
		local flynum = self:GetFreeFlyNum();
		local pic = self.node:GetPicture();
		if flynum ~= nil and pic ~= nil then
			local size = pic:GetDrawSize();
			flynum:SetOffset( size.w * 0.4, size.h * 0.4 );
		end
	end
end

--���ÿɼ�
function p:SetVisible( in_visible )
	self.isVisible = in_visible;
end

--��ͨ������������
function p:Atk( targetFighter, batch )
	if batch == nil then return end
	
	--�������и������ߡ��ܻ���
	local seqAtk 	= batch:AddSerialSequence();
	local seqTarget = batch:AddParallelSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) then
		WriteCon( "create 2 seq failed");
		return;
	end
	
	--���
	local atkType = math.random(1,2);
	
	--������
	local cmd1 = self:cmdMoveForward( targetFighter, seqAtk );
	
	if atkType == 2 then
		--����Ч
		local cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( "battle_fire_ball.mp3" );
		seqAtk:AddCommand( cmdMusic );
		
		local cmd2 = createCommandEffect():AddFgEffect( 0.01, self.node, "lancer.hero_atk_fire" );		
		if cmd2 ~= nil then
			seqAtk:AddCommand( cmd2 );
		end	
	else
		--����צ����Ч
		local cmd3 = createCommandSoundMusicVideo():PlaySoundByName( "battle_paw.mp3" );
		seqAtk:AddCommand( cmd3 );
	end
	
	local cmd4 = self:cmdMoveBackward( targetFighter, seqAtk );
	
	--�ܻ���
	local cmd6 = targetFighter:BossAddHurtEffect( seqTarget, false, atkType );
	local cmd7 = targetFighter:cmdMoveBackward( self, seqTarget );	
	local cmd8 = targetFighter:cmdMoveForward( self, seqTarget );
	local cmd9 = targetFighter:cmdLua( "fighter_damage", 30, "", seqTarget );
	cmd8:SetWaitEnd( cmd7 );

	--�ܻ������еȴ�������
	--if atkType == 2 and cmd2 ~= nil then
		--seqTarget:SetWaitEnd( cmd2 );
	--else
		seqTarget:SetWaitEnd( cmd1 );
	--end
	
end

--���ܻ���Ч
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

--���ܻ���Ч
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

--���ܹ�����������
function p:AtkSkill( targetFighter, batch, bulletType, bulletRotation, fighterIndex )
	if batch == nil then		
		return;
	end
	
	--�����������и������ߡ��ܻ��ߡ��ӵ�
	local seqAtk 	= batch:AddSerialSequence();
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddParallelSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) or (seqBullet == nil) then
		WriteCon( "create 3 seq failed");
		return;
	end
	
	--������
	local cmd1 = self:cmdMoveForward( targetFighter, seqAtk );
	local cmd2 = self:cmdMoveBackward( targetFighter, seqAtk );
	
	--�ӵ�
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
	
	--�ܻ���
	local cmd6 = targetFighter:cmdAddExplosion( seqTarget, bulletType );
	local cmd7 = targetFighter:cmdMoveBackward( self, seqTarget );	
	local cmd8 = targetFighter:cmdMoveForward( self, seqTarget );
	local cmd9 = targetFighter:cmdLua( "fighter_damage", 80, "", seqTarget );
	cmd8:SetWaitEnd( cmd7 );
	
	--�ӵ����еȴ�cmd1���
	seqBullet:SetWaitEnd( cmd1 );
	
	--�ܻ������еȴ��ӵ���Ŀ���
	seqTarget:SetWaitEnd( cmd5 );
end

--���ܹ����������������
function p:AtkSkillTornado( targetFighter, batch, bulletType, bulletRotation, fighterIndex )
	if batch == nil then return end
	
	--����4�����и������ߡ��ܻ��ߡ��ӵ�������
	local seqAtk 	= batch:AddSerialSequence();
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence();
	local seqGround = batch:AddSerialSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) or (seqBullet == nil) or (seqGround == nil) then
		WriteCon( "create 3 seq failed");
		return;
	end
	
	--������
	local cmd1 = self:cmdMoveForward( targetFighter, seqAtk );
	local cmd2 = self:cmdMoveBackward( targetFighter, seqAtk );
	
	--����米����ת
	--local tornadoRotation = { 0, 0, 0, 0, 0 };

	--�ӵ�
	local bullet = bullet:new();
	bullet:AddToBattleLayer();
	bullet:SetEffect(3);
	local cmd3 = bullet:cmdSetVisible( true, seqBullet );	
	
	--�������Ч
	local cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( "battle_long_juan_feng.mp3" );
	seqBullet:AddCommand( cmdMusic );
	
	local cmd4 = bullet:cmdShoot( self, targetFighter, seqBullet, false );
	local cmd5 = bullet:cmdSetVisible( false, seqBullet );
	
	--����
--	local cmd_x1 = createCommandEffect():AddFgEffect( 0, self.footNode, "lancer.hero_bullet7" );
--	seqGround:AddCommand( cmd_x1 );	
--	seqGround:SetWaitBegin( cmd3 );
	
	--�ܻ���
	cmd6 = createCommandEffect():AddFgEffect( 0.01, targetFighter.node, "lancer.hero_skill_tornado" );
	seqTarget:AddCommand( cmd6 );	
	local cmd7 = targetFighter:cmdMoveBackward( self, seqTarget );	
	local cmd8 = targetFighter:cmdMoveForward( self, seqTarget );
	local cmd9 = targetFighter:cmdLua( "fighter_damage", 80, "", seqTarget );
	
	--�ӵ����еȴ�cmd1���
	seqBullet:SetWaitEnd( cmd1 );
	
	--�ܻ������еȴ��ӵ���Ŀ���
	seqTarget:SetWaitEnd( cmd5 );
end


--������Ⱥ����
function p:AtkSkillMul( targetFighter1, targetFighter2, batch )
	if batch == nil then return end
	if targetFighter1 == nil or targetFighter2 == nil then return end
	
	--�������и�������
	local seqAtk = batch:AddSerialSequence();
	if seqAtk == nil then return end;
	
	--�����ߣ�������ο���һ���ܻ��ߣ�
	local cmd1 = self:cmdMoveForward( targetFighter1, seqAtk );
	local cmd_idle1 = self:cmdIdle( 0.001, seqAtk ); --place holder
	local cmd_idle2 = self:cmdIdle( 0.001, seqAtk ); --place holder		
	local cmd2 = self:cmdMoveBackward( targetFighter1, seqAtk );

	--��
	self:BulletToTarget( cmd_idle1, targetFighter1, batch );
	self:BulletToTarget( cmd_idle2, targetFighter2, batch );
end


--�ܵı���
function p:BulletToTarget( cmdWait, targetFighter, batch )
	
	if cmdWait == nil then return end;
	
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddParallelSequence();
	if seqBullet == nil or seqTarget == nil then return end;	
	
	--�ӵ�
	local bullet = bullet:new();
	bullet:AddToBattleLayer();
	bullet:SetEffect(1);
	local cmd1 = bullet:cmdSetVisible( true, seqBullet );
	local cmd2 = bullet:cmdShoot( self, targetFighter, seqBullet, true );
	local cmd3 = bullet:cmdSetVisible( false, seqBullet );
	cmd1:SetWaitEnd( cmdWait );
		
	--�ܻ���
	local cmd4  = targetFighter:cmdAddExplosion( seqTarget );
	local cmd5 = targetFighter:cmdMoveBackward( self, seqTarget );	
	local cmd6 = targetFighter:cmdMoveForward( self, seqTarget );
	cmd6:SetWaitEnd( cmd5 );
	seqTarget:SetWaitEnd( cmd3 );
end

--ȡfighter����λ��
function p:GetFighterCenterPos()
	local targetRect = self.node:GetFrameRect();	
	local org = targetRect.origin;
	local size = targetRect.size;
	local centerX = org.x + size.w * 0.5;
	local centerY = org.y + size.h * 0.5;
	return centerX,centerY;
end

--�ŵ׼��ӵ���ը��Ч
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

--������
function p:cmdDumb( seq )
	if seq == nil then return nil end
	local cmd = createCommandInstant():Dumb( duration );
	if cmd ~= nil then
		seq:AddCommand( cmd );
	end	
	return cmd;
end

--��������
function p:cmdIdle( duration, seq )
	if seq == nil then return nil end
	local cmd = createCommandInterval():Idle( duration );
	if cmd ~= nil then
		seq:AddCommand( cmd );
	end	
	return cmd;
end

--Boss����������Ӫ������ͨ������
function p:BossAtkCamp( camp, batch )
	if camp == nil or batch == nil then return end
	
	--ȡ�м�Ŀ����Ϊ�ο�����
	local refTarget = camp:GetFighterAt(3);
	
	--�������и�������
	local seqAtk = batch:AddSerialSequence();
	if seqAtk == nil then return end;
	
	--�����ߣ�������ο���һ���ܻ��ߣ�
	local cmd1 = self:cmdMoveForward( refTarget, seqAtk );
	--BOSSײ����Ч
	local cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( "battle_boss_crack.mp3" );
	seqAtk:AddCommand( cmdMusic );
	
	--ռλ���������ȴ�
	local cmd_dumb = {};
	for i = 1, 5 do
		cmd_dumb[i] = self:cmdDumb( seqAtk );
	end
	local cmd2 = self:cmdMoveBackward( refTarget, seqAtk );
	
	--��
	local targetCount = camp:GetFighterCount();
	for i = 1, targetCount do
		local target = camp:GetFighterAt(i);
		if target ~= nil then
			local seq = batch:AddSerialSequence();
			if seq ~= nil then				
				--�����ܻ���Ч
				local cmd1 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "lancer.boss_atk_result" );
				seq:AddCommand( cmd1 );
				
				--����Ч��
				local cmd2 = target:cmdMoveBackward( self, seq );
				local cmd3 = target:cmdMoveForward( self, seq );
				local cmd4 = target:cmdLua( "fighter_damage", 100, "", seq );
				
				--���õȴ�
				cmd3:SetWaitEnd( cmd2 );
				seq:SetWaitEnd( cmd_dumb[i] );
			end				
		end
	end
end

--Boss����������Ӫ���ü��ܣ�
function p:BossAtkCamp_BySkill( camp, batch )
	if camp == nil or batch == nil then return end
	
	--ȡ�м�Ŀ����Ϊ�ο�����
	local refTarget = camp:GetFighterAt(3);
	
	--�������и�������
	local seqAtk = batch:AddSerialSequence();
	if seqAtk == nil then return end;
	
	--�����ߣ�������ο���һ���ܻ��ߣ�	
	local cmd1 = self:cmdMoveForward( refTarget, seqAtk );				
	local cmd2 = self:cmdMoveBackward( refTarget, seqAtk );
	
	--������Ч
	local cmdMusic = createCommandSoundMusicVideo():PlaySoundByName( "battle_fire_rain.mp3" );
	seqAtk:AddCommand( cmdMusic );
	
	--��ȼ����Ч
	--local cmdMusic2 = createCommandSoundMusicVideo():PlaySoundByName( "battle_fire_raging.mp3" );
	--seqAtk:AddCommand( cmdMusic2 );

	
	--ռλ���������ȴ�
	local cmd_dumb = {};
	for i=1,10 do
		cmd_dumb[i] = self:cmdDumb( seqAtk );
	end
		
	--��
	local targetCount = camp:GetFighterCount();
	for i = 1, targetCount do
		local target = camp:GetFighterAt(i);
		if target ~= nil then
		
			local seq1 = batch:AddSerialSequence();
			if seq1 ~= nil then
				--�ܻ���Ч
				local cmd = createCommandEffect():AddFgEffect( 0, target:GetNode(), "lancer_cmb.boss_skill_result" );
				seq1:AddCommand( cmd );
				
				--���õȴ�
				seq1:SetWaitEnd( cmd_dumb[i*2-1] );
			end
			
			--����
			local seq2 = batch:AddSerialSequence();
			if seq2 ~= nil then
				--����Ч��
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
--Boss����������Ӫ���ü��ܣ������¼���
function p:BossAtkCamp_BySkill( camp, batch )
	if camp == nil or batch == nil then return end
	
	--ȡ�м�Ŀ����Ϊ�ο�����
	local refTarget = camp:GetFighterAt(3);
	
	--�������и�������
	local seqAtk = batch:AddSerialSequence();
	if seqAtk == nil then return end;
	
	--�����ߣ�������ο���һ���ܻ��ߣ�
	local cmd1 = self:cmdMoveForward( refTarget, seqAtk );
	
	local cmd2 = createCommandEffect():AddFgEffect( 0.01, self.node, "lancer_cmb.boss_skill_result_2" );
	seqAtk:AddCommand( cmd2 );
				
	local cmd3 = self:cmdMoveBackward( refTarget, seqAtk );
	
	--ռλ���������ȴ�
	local cmd_dumb = {};
	for i=1,10 do
		cmd_dumb[i] = self:cmdDumb( seqAtk );
	end

	--��
	local targetCount = camp:GetFighterCount();
	for i = 1, targetCount do
		local target = camp:GetFighterAt(i);
		if target ~= nil then
		
			local seq1 = batch:AddSerialSequence();
			if seq1 ~= nil then
				--�ܻ���Ч
				local cmd = createCommandEffect():AddFgEffect( 0, target:GetNode(), "lancer.boss_skill_result05" );
				seq1:AddCommand( cmd );
				
				--���õȴ�
				seq1:SetWaitEnd( cmd_dumb[i*2-1] );
			end
			
			--����
			local seq2 = batch:AddSerialSequence();
			if seq2 ~= nil then
				--����Ч��
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

--�ܻ�
--����������Ϊ���������������ж�����
function p:Hurt( atkFighter )
end

--ƮѪ
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

--����Ѫ��
function p:GetHpBar()
	return self.hpbar;
end

--����Ѫ��
function p:SetLife( num )
	self.life = num;
	if self.hpbar ~= nil then
		self.hpbar:SetLife( self.life );
	end	
end

--����Ѫ��
function p:SetLifeMax( num )
	self.lifeMax = num;
	if self.hpbar ~= nil then
		self.hpbar:SetLifeMax( self.lifeMax );
	end	
end

--ȥѪ
function p:SetLifeDamage(num)	
	self.life = self.life - num;
	--WriteCon( string.format("%f", self.life ));
	if self.life <= 0 then
		self.life = 0;
		self:SetLife( 0 );
		self:Die();
		
		--��������ʾѪ��
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
	
	--����ƮѪ
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
		
		--��������ʾѪ��
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
	
	--����ƮѪ
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
		
		--��������ʾѪ��
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
	
	--����ƮѪ
	local flynum = self:GetFreeFlyNum(2);
	if flynum ~= nil then
		flynum:PlayNum( num );
	end
end

--����
function p:Die()
	self.isDead = true;
	--self:GetNode():AddActionEffect( "lancer_cmb.die_v2" );
end

--�Ƿ����
function p:IsAlive()
	return not self:IsDead();
end

--�Ƿ�����
function p:IsDead()
	return self.isDead;
end

--���lua����
function p:cmdLua( cmdtype, num, str, seq )
	if seq == nil then return nil end
	local cmd = createCommandLua():SetCmd( cmdtype, self:GetId(), num, str );
	if cmd ~= nil then
		seq:AddCommand( cmd );
	end	
	return cmd;	
end