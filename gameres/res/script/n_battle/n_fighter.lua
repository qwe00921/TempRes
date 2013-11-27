--------------------------------------------------------------
-- FileName: 	n_fighter.lua
-- BaseClass:   fighter
-- author:		zhangwq, 2013/06/20
-- purpose:		սʿ�ࣨ��ʵ����
--------------------------------------------------------------

n_fighter = fighter:new();
local p = n_fighter;
local super = fighter;

--������ʵ��
function p:new()
	o = {}
	setmetatable( o, self );
	self.__index = self;
	o:ctor();
	o.m_kShadow = {};
	return o;
end

--���캯��
function p:ctor()
    super.ctor(self);
	self.tmplife = self.life;
	self.pPrePos = nil;
	self.pOriginPos = nil;
	self.m_kShadow = nil;
	self.m_kCurrentBatch = nil;
end

--��ʼ�������أ�
function p:Init( idFighter, node, camp )
	super.Init( self, idFighter, node, camp );
	--self.hpbar:GetNode():SetVisible( false );
	self.tmplife = self.life;
	self:CreateHpBar();
end

--����Ѫ��
function p:CreateHpBar()
	if self.hpbar == nil or self.m_kShadow == nil then
		self.hpbar = n_hp_bar:new();
		self.hpbar:CreateExpNode();
		self.node:AddChildZ( self.hpbar:GetNode(), 1 );
		self.hpbar:Init( self.node, self.life, self.lifeMax );
		--self.hpbar:HideBar();
	end	
end

--��ʱ����ֵ
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

function p:SubTmpLifeHeal( val )
	self.tmplife = self.tmplife + val;
	
	if self.tmplife > self.lifeMax then
		self.tmplife = self.lifeMax;
	end
end

--��������
function p:UseConfig( config )
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:UseConfig( config );
    end	
end

--ս��
function p:standby()
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:Standby("");
    end
end

--���ó���
function p:SetLookAt( lookat )
    local playerNode = self:GetPlayerNode();
    if playerNode ~= nil then
        playerNode:SetLookAt( lookat );
    end
end

--��ȡ����
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

--ȡplayer�ڵ�
function p:GetPlayerNode()
    return ConverToPlayer(self:GetNode());
end

--��λ��
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

function p:HurtResultAni( targetFighter, seqTarget,seqShadow)
	--����������վ������
	if targetFighter:CheckTmpLife() then
		self:standby();
		--local cmdA = createCommandPlayer():Standby( 0, targetFighter:GetNode(), "" );
		--seqTarget:AddCommand( cmdA );
	else
		local cmdB = createCommandPlayer():Dead( 0, targetFighter:GetNode(), "" );
		seqTarget:AddCommand( cmdB );	
		
		local cmdC = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer_cmb.die_v2" );
		seqTarget:AddCommand( cmdC );
		
		if nil ~= seqShadow then
			local cmdD = createCommandEffect():AddActionEffect( 0.01, targetFighter.m_kShadow, "lancer_cmb.die_v2" );
			seqShadow:AddCommand(cmdD);
			cmdD:SetWaitBegin(cmdC);
		end
		
		--local kPlayerNode = targetFighter:GetPlayerNode();
		--kPlayerNode:SetShadowVisible(false);
	end
end

--��ͨ������������
function p:Atk( targetFighter, batch, damage)
	if batch == nil or targetFighter == nil then return end
	
	--�������и������ߡ��ܻ���
	local seqAtk 	= batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence();
	local seqShadow = batch:AddSerialSequence();
	local seqMisc =   batch:AddSerialSequence();
	local seqMusic =   batch:AddSerialSequence();
	
	self.m_kCurrentBatch = batch;
	
	local targetNode = targetFighter:GetNode();
	
	--�����������λ��
	local originalPos = self:GetNode():GetCenterPos();
	local ox = originalPos.x;
	local oy = originalPos.y
	
	self.pOriginPos = CCPointMake(ox,oy);

	--����Ŀ���λ��
	--local enemyPos = targetNode:GetCenterPos();

	local enemyPos = nil;

	if self.idCamp == E_CARD_CAMP_ENEMY then
		enemyPos = originalPos;
	else
		enemyPos = targetFighter:GetFrontPos(self:GetNode());
	end
	
	if (seqAtk == nil) or (seqTarget == nil) then
		WriteCon( "create 2 seq failed");
		return;
	end
	
	local playerNode = self:GetPlayerNode();
	
	--���ܶ���
	local cmd1 = createCommandPlayer():Run( 0.1, playerNode, "" );
	seqAtk:AddCommand( cmd1 );
	
	--�򹥻�Ŀ���ƶ�
	local cmd2 = self:JumpMoveTo(enemyPos,seqAtk,false);
	
	originalPos = self:GetNode():GetCenterPos();
	
	--�������˶���
	local cmd3 = createCommandPlayer():Atk( 0, playerNode, "" );
	seqAtk:AddCommand( cmd3 );
	cmd3:SetDelay(0.2f); --���ù����ӳ�
	
	local cmdBack = createCommandEffect():AddActionEffect( 0, targetFighter:GetNode(), "lancer.target_hurt_back" );
	cmdBack:SetDelay(playerNode:GetSkillKeyTime_Atk(""));
	seqTarget:AddCommand( cmdBack );
	
	--���ù�����Ч
	self:setAtkFx( seqMisc );
	seqMisc:SetWaitBegin(cmd3);
	
	local cmdForward = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer.target_hurt_back_reset" );
	seqTarget:AddCommand( cmdForward );	
	
	--����������Ч
	self:setAtkMusic( seqMusic )
	seqMusic:SetWaitBegin( cmd3 );
	
	--���վ������
	local cmd4 = createCommandPlayer():Standby( 0.01, playerNode, "" );
	seqAtk:AddCommand( cmd4 );
	
	--����ԭ����λ��
	local cmd5 = self:JumpMoveTo(originalPos, seqAtk, true );
	cmd5:SetDelay(0.5f);
	
	------------�ܻ���-----------------------
	
	--�ܻ�����
	local cmd10 = createCommandPlayer():Hurt( 0, targetNode, "" );
	seqTarget:AddCommand( cmd10 );
	--cmd10:SetDelay(0.5f);
	cmd10:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
	
	--ƮѪ
	local fDamage = battle_compute.DamageFromNormalAttack(self,targetFighter,damage);
	local cmd11 = nil;
	if bStrike then
		cmd11 = targetFighter:cmdLua( "fighter_strike_damage", fDamage, "", seqTarget );
	else
		cmd11 = targetFighter:cmdLua( "fighter_damage", fDamage, "", seqTarget );
	end
	local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", fDamage, "", seqTarget );
	--local cmd22 = targetFighter:cmdLua( "AddMaskImage", 0, "", seqTarget );
	
	--�ܹ����ĺ������������� OR վ����
	self:HurtResultAni( targetFighter, seqTarget,seqShadow);
	
	--�ܻ��ȴ���������
	seqTarget:SetWaitEnd(cmd2 );
	
end

--���ù�����Ч
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

--������ͨ��������
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

--���ü��ܹ�������
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

--���ù�����Ч
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

--��ͨ������������
function p:AtkSkillNearOneToOne( targetFighter, batch, bulletType, bulletRotation, fighterIndex)
	if batch == nil then return end
	
	--����4�����и������ߡ��ܻ��ߡ��ӵ�������
	local seqAtk 	= batch:AddSerialSequence();
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence();
	local seqGround = batch:AddSerialSequence();
	local seqMisc =   batch:AddSerialSequence();
	local seqMiscHurt =   batch:AddParallelSequence();
	local seqMusic =   batch:AddSerialSequence();
	local seqShadow =   batch:AddSerialSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) or (seqBullet == nil) or (seqGround == nil) then
		WriteCon( "create 3 seq failed");
		return;
	end
	
	--�����������λ��
	local originalPos = self:GetNode():GetCenterPos();

	--����Ŀ���λ��
	local enemyPos = nil;
	
	if self.idCamp == E_CARD_CAMP_ENEMY then
		enemyPos = originalPos;	
	else
		enemyPos = targetFighter:GetFrontPos(self:GetNode());	
	end

	--��������λ
	local cmd1 = nil;
	--if self.petTag ~= PET_MINING_TAG then
		--cmd1 = self:cmdMoveTo( originalPos, enemyPos, seqAtk );
	--end
	--���ܹ�������
	local playerNode = self:GetPlayerNode();
	local cmd2 = createCommandPlayer():Skill( 0, playerNode, "" );
	seqAtk:AddCommand( cmd2 );
	
	--���ü��ܹ�����Ч
	--self:setAtkSkillFx( seqMisc );  --�˴���������Ч
	--seqMisc:SetWaitBegin( cmd2 );
	
	--����������Ч
	self:setAtkSkillMusic( seqMusic )
	seqMusic:SetWaitBegin( cmd2 );

	if self.idCamp == E_CARD_CAMP_ENEMY then
		local myNode = self:GetPlayerNode();
		local cmd_buff = createCommandEffect():AddFgEffect( 0.5, myNode, "x.boss_cast_buff" );
		seqAtk:AddCommand( cmd_buff );	
	end
	
	--���վ������
	local cmd3 = createCommandPlayer():Standby( 0, playerNode, "" );
	seqAtk:AddCommand( cmd3 );
	
	--����ԭ����λ��
	--local cmd4;
	--if self.petTag ~= PET_MINING_TAG then
	--	cmd4= self:cmdMoveTo( enemyPos, originalPos, seqAtk );
	--end
	
	--�������˶���
	local cmd9 = createCommandPlayer():Hurt( 0, targetFighter:GetNode(), "" );
	cmd9:SetDelay( playerNode:GetSkillKeyTime_Hurt(""));
	cmd9:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
	seqMiscHurt:AddCommand( cmd9 );
	
	--�ܻ���Ч
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
	
	--����Ч��
	if self.petTag == PET_BLUE_DEVIL_TAG then
		--local cmdBack = createCommandEffect():AddActionEffect( 0, targetFighter:GetNode(), "lancer.target_hurt_back" );
		--seqMiscHurt:AddCommand( cmdBack );
	--	cmdBack:SetDelay(playerNode:GetSkillKeyTime_Atk(""));
	end
	seqMiscHurt:SetWaitBegin(cmd2);
	
	--ƮѪ
	local cmd12 = targetFighter:cmdLua( "fighter_damage", 80, "", seqTarget );
	local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", 80, "", seqTarget );
	
	if self.petTag == PET_BLUE_DEVIL_TAG then
		local cmdForward = createCommandEffect():AddActionEffect( 0.01, targetFighter:GetNode(), "lancer.target_hurt_back_reset" );
		seqTarget:AddCommand( cmdForward );	
	end
	
	--�ܹ����ĺ������������� OR վ����
	self:HurtResultAni( targetFighter, seqTarget,seqShadow);
		
	--�ܻ������еȴ��ӵ���Ŀ���
	seqTarget:SetWaitEnd( cmd2 );
end

--Ⱥ��
function p:AtkSkillOneToCamp( camp, batch,bHeal)
	WriteCon( ".............AtkAOE.............");
	
	if camp == nil or batch == nil then 
		WriteCon( ".............AtkAOE ERROR.............");
		return 
	end
	
	--ȡ�м�Ŀ����Ϊ�ο�����
--	local refTarget = camp:GetFighterAt(3);
	
	--�������и�������
	local seqAtk = batch:AddSerialSequence();
	local seqShadow = batch:AddSerialSequence();
	if seqAtk == nil then return end;
	
	local playerNode = self:GetPlayerNode();
	
	--���ܹ�������
	local cmd1 = createCommandPlayer():Skill( 0, playerNode, "" );
	seqAtk:AddCommand( cmd1 );
	
	--���վ������
	local cmd3 = createCommandPlayer():Standby( 0, playerNode, "" );
	seqAtk:AddCommand( cmd3 );
	
	--��
	local bStrike = battle_compute.IsFighterStrike(self);	
	local targetAlive = camp:GetAliveFighters();
	for i = 1, #targetAlive do
		local target = targetAlive[i];
		if target ~= nil then
		
			local seq1 = batch:AddSerialSequence();
			if seq1 ~= nil then
				--�ܻ���Ч
				local cmd11 = nil;
				--if self.petTag == PET_BLUE_DEVIL_TAG then
				--	cmd11 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "x.blue_devil_fx_target_hurt" );
				--elseif self.petTag == PET_FLY_DRAGON_TAG then
					--cmd11 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "x.dragon_fx_target_hurt" );
				--else
				if bHeal then
					cmd11 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "x.heal_skill" );
				else
					cmd11 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "x.dings" );
				end
				--end
				seq1:AddCommand( cmd11 );
				
				--�ܻ�����
				local cmd12 = createCommandPlayer():Hurt( 0, target:GetNode(), "" );
				seq1:AddCommand( cmd12 );
				cmd12:SetDelay( playerNode:GetSkillKeyTime_Hurt(""));
				cmd12:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
				local fValue = battle_compute.DamageFromNormalAttack(self,target,bStrike) * 0.5f;
				
				--ƮѪ
				if bHeal then
					local cmd13 = target:cmdLua( "fighter_heal", fValue, "", seq1 );
				elseif bStrike then
					local cmd13 = target:cmdLua( "fighter_strike_damage", fValue, "", seq1 );
				else
					local cmd13 = target:cmdLua( "fighter_damage", fValue, "", seq1 );
				end
				
				local cmd_showbar = target:cmdLua( "fighter_showbar", 80, "", seq1 );
				
				--�ܹ����ĺ������������� OR վ����
				self:HurtResultAni( target, seq1,seqShadow);
				
				--target:cmdIdle( 1, seq1 );
				
				--���õȴ�
				seq1:SetWaitEnd( cmd1 );
			end		
		end
	end	
end

function p:doUIEffect( seqUI )
	--��ʼ��������������Ӧ��ACTION��Ч
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
	
	--���ü�����������λ��
	local cmd1;
	if self.camp == E_CARD_CAMP_HERO then
		cmd1 = self:cmdLua( "SetSkillNameBarToLeft", 0, "", seqUI );
	else
		cmd1 = self:cmdLua( "SetSkillNameBarToRight", 0, "", seqUI );
	end
	
	--�����ɰ�
	local cmd2 = self:cmdLua( "AddMaskImage", 0, "", seqUI );
	
	--����������Ч
	--0:��ʼ����Ч
	local skillNameBar = GetImage( n_battle_pvp.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_13 )
	local cmd3 = createCommandEffect():AddFgEffect( 0.01, skillNameBar, skillFx );
	seqUI:AddCommand( cmd3 );	
	
	--1:����ģ��
	local cmd4 = createCommandEffect():AddActionEffect( 0.01, skillNameBar, "x.gsblur5" );
	seqUI:AddCommand( cmd4 );
	
	--2:������Ļ
	local cmd5 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarInAction );
	seqUI:AddCommand( cmd5 );	
	
	--2:�ָ�����
	local cmd6 = createCommandEffect():AddActionEffect( 0, skillNameBar, "x.gsblur_zero" );
	seqUI:AddCommand( cmd6 );
	cmd6:SetDelay(0.5);	
	
	--4:�Ƴ���Ļ
	local cmd7 = createCommandEffect():AddActionEffect( 0, skillNameBar, skillNameBarOutAction );
	seqUI:AddCommand( cmd7 );	
	cmd7:SetDelay(0.3);		
		
	--�����ɰ�
	local cmd8 = self:cmdLua( "HideMaskImage", 0, "", seqUI );
	
	--��ԭ������������λ��
	local cmd9 = self:cmdLua( "ReSetSkillNameBarPos", 0, "", seqUI );
	
	local cmd_dumb = self:cmdDumb( seqUI );
	return cmd_dumb;
end

--�ռ���ɱ����Ŀǰֻ����ħ��ӵ�С�
function p:UltimateSkill( camp, batch )
	WriteCon( ".............Ultimate Skill.............");
	
	if camp == nil or batch == nil then 
		WriteCon( ".............Ultimate Skill ERROR.............");
		return 
	end
	
	--����3�����и������ߡ��ܻ��ߡ�ui
	local seqAtk 	= batch:AddParallelSequence();
	local seqTarget = batch:AddParallelSequence();
	local seqUI = batch:AddSerialSequence();
	
	--�����������λ��
	local originalPos = self:GetNode():GetCenterPos();
	
	--ȡ��Ӫ���ĵ�λ��
	local campCenterPos = originalPos;--GetImage( n_battle_pvp.battleLayer ,ui_n_battle_pvp.ID_CTRL_PICTURE_12 ):GetCenterPos();
	
	--��������
	local cmd1 = createCommandPlayer():Sing( 0, self:GetPlayerNode(), "" );
	seqAtk:AddCommand( cmd1 );
	
	--����������Ч
	local cmdFX = createCommandEffect():AddFgEffect( 0, self:GetPlayerNode(), "x.pet_fx_ultimate_skill" );
	seqAtk:AddCommand( cmdFX );
	
	--������������
	local cmdSingMusic = createCommandSoundMusicVideo():PlaySoundByName( "blue_devil_sing.mp3" );
	seqAtk:AddCommand( cmdSingMusic );
	cmdSingMusic:SetWaitBegin( cmd1 );
	
	local cmd_ui= self:doUIEffect( seqUI );
	--seqUI:SetWaitEnd( cmd1 );
	
	--�ƶ�����Ӫ����λ��
	local cmd2 = self:cmdMoveTo( originalPos, campCenterPos, seqAtk );
	cmd2:SetWaitEnd( cmd_ui );
	
	--���ܹ�������
	local cmd3 = createCommandPlayer():Skill( 0, self:GetPlayerNode(), "" );
	seqAtk:AddCommand( cmd3 );
	
	cmd3:SetWaitEnd( cmd2 );
	
	--���ü��ܹ�����Ч
	local cmd4 = self:setAtkSkillFx( seqAtk );
	cmd4:SetWaitBegin( cmd3 );
	
	--��������
	local cmdSkillMusic = createCommandSoundMusicVideo():PlaySoundByName( "blue_devil_skill.mp3" );
	cmdSkillMusic:SetDelay( self:GetPlayerNode():GetSkillKeyTime_Atk(""));
	seqAtk:AddCommand( cmdSkillMusic );
	cmdSkillMusic:SetWaitBegin( cmd3 );
	
	--���վ������
	local cmd5 = createCommandPlayer():Standby( 0, self:GetPlayerNode(), "" );
	seqAtk:AddCommand( cmd5 );
	cmd5:SetWaitEnd( cmd3 );
	
	--�ص�ԭ��λ��
	local cmd6 = self:cmdMoveTo( campCenterPos, originalPos, seqAtk );
	cmd6:SetWaitBegin( cmd5 );
	
	--��
	local targetAlive = camp:GetAliveFighters();
	for i = 1, #targetAlive do
		local target = targetAlive[i];
		if target ~= nil then
		
			local seq1 = batch:AddParallelSequence();
			if seq1 ~= nil then
				--�ܻ���Ч
				--[[
				local cmd11 = createCommandEffect():AddFgEffect( 0.01, target:GetNode(), "x.blue_devil_fx_target_hurt" );
				cmd11:SetDelay( self:GetPlayerNode():GetSkillKeyTime_Hurt(""));
				seq1:AddCommand( cmd11 );
				--]]
				
				--����Ч��
				--local cmdBack = createCommandEffect():AddActionEffect( 0, target:GetNode(), "lancer.target_hurt_back" );
				--seq1:AddCommand( cmdBack );
			--	cmdBack:SetDelay(self:GetPlayerNode():GetSkillKeyTime_Atk(""));
				
				--�ܻ�����
				local cmd12 = createCommandPlayer():Hurt( 0, target:GetNode(), "" );
				seq1:AddCommand( cmd12 );
				cmd12:SetDelay( self:GetPlayerNode():GetSkillKeyTime_Hurt(""));
				cmd12:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
				
				--ƮѪ
				local cmd13 = target:cmdLua( "fighter_damage", 80, "", seq1 );
				local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", 80, "", seqTarget );
				cmd13:SetWaitEnd( cmd12 );
				
				--���˻�ԭ
				local cmdBackRset = createCommandEffect():AddActionEffect( 0.01, target:GetNode(), "lancer.target_hurt_back_reset" );
				seq1:AddCommand( cmdBackRset );	
				cmdBackRset:SetWaitEnd( cmd13 );
				
				--�ܹ����ĺ������������� OR վ����
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
				
				--���õȴ�
				seq1:SetWaitBegin( cmd3 );
			end		
		end
	end	
end

--���ܹ���������������
function p:AtkSkillFeilong( targetFighter, batch, bulletType, bulletRotation, fighterIndex )
	if batch == nil then return end
	
	--����4�����и������ߡ��ܻ��ߡ��ӵ�������
	local seqAtk 	= batch:AddSerialSequence();
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence();
	local seqGround = batch:AddSerialSequence();
	local seqShadow = batch:AddSerialSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) or (seqBullet == nil) or (seqGround == nil) then
		WriteCon( "create 3 seq failed");
		return;
	end
	
	local playerNode = self:GetPlayerNode();
	
	--���ܹ�������
	local cmd1 = createCommandPlayer():Skill( 0, playerNode, "" );
	seqAtk:AddCommand( cmd1 );
	
	--���վ������
	local cmd2 = createCommandPlayer():Standby( 0, playerNode, "" );
	seqAtk:AddCommand( cmd2 );
	
		
	--�ܻ���
	cmd6 = createCommandEffect():AddFgEffect( 0.5, targetFighter.node, "x.feilong" );
	seqTarget:AddCommand( cmd6 );	
	
	--�������˶���
	local cmd7 = createCommandPlayer():Hurt( 0, targetFighter.node, "" );
	seqTarget:AddCommand( cmd7 );
	cmd7:SetDelay( playerNode:GetSkillKeyTime_Hurt(""));
	cmd7:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
	
	local bStrike = battle_compute.IsFighterStrike(self);
	local fDamage = battle_compute.DamageFromNormalAttack(self,targetFighter,bStrike);
	
	--ƮѪ
	local cmd8 = nil;

	if false == bStrike then
		targetFighter:cmdLua( "fighter_damage", fDamage, "", seqTarget );
	else
		targetFighter:cmdLua( "fighter_strike_damage", fDamage, "", seqTarget );
	end

	local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", 80, "", seqTarget );
	
	--�ܹ����ĺ������������� OR վ����
	self:HurtResultAni( targetFighter, seqTarget,seqShadow);
		
	--�ܻ������еȴ��ӵ���Ŀ���
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

--���ܹ�����������
function p:AtkSkillTuc( targetFighter, batch, bulletType, bulletRotation, fighterIndex )
	if batch == nil then return end
	
	--����4�����и������ߡ��ܻ��ߡ��ӵ�������
	local seqAtk 	= batch:AddSerialSequence();
	local seqBullet = batch:AddSerialSequence();
	local seqTarget = batch:AddSerialSequence();
	local seqGround = batch:AddSerialSequence();
	local seqShadow = batch:AddSerialSequence();
	
	if (seqAtk == nil) or (seqTarget == nil) or (seqBullet == nil) or (seqGround == nil) then
		WriteCon( "create 3 seq failed");
		return;
	end
	
	local playerNode = self:GetPlayerNode();
	
	--���ܹ�������

	if p.idCamp == E_CARD_CAMP_ENEMY then
		
	else
		local cmdA1 = createCommandPlayer():Skill( 0, playerNode, "" );
		seqAtk:AddCommand( cmdA1 );
	end
	
	--�ӵ�
	local bullet = bullet:new();
	bullet:AddToBattleLayer();
	bullet:UseConfig("bullet.bullet1");
		
	bullet:GetNode():SetRotationDeg( bulletRotation );
	local cmd2 = bullet:cmdSetVisible( true, seqBullet );
	local cmd3 = bullet:cmdShoot( self, targetFighter, seqBullet, false );
	local cmd4 = bullet:cmdSetVisible( false, seqBullet );
	
	
	--���վ������
	local cmdA2 = createCommandPlayer():Standby( 0, playerNode, "" );
	seqAtk:AddCommand( cmdA2 );
		
	--�ܻ���Ч
	local cmd7 = createCommandEffect():AddFgEffect( 0.01, targetFighter.node, bullet:GetConfig():GetExplodeAni() );
	seqTarget:AddCommand( cmd7 );
	
	--�ܻ�����
	local cmd8 = createCommandPlayer():Hurt( 0, targetFighter.node, "" );
	seqTarget:AddCommand( cmd8 );
	cmd8:SetDelay( playerNode:GetSkillKeyTime_Hurt(""));
	cmd8:SetSpecialFlag( E_BATCH_STAGE_HURT_END );
	
	--ƮѪ
	local bStrike = battle_compute.IsFighterStrike(self);
	local fDamage = battle_compute.DamageFromNormalAttack(self,targetFighter,bStrike);
	local cmd9 = nil;
	
	if false == bStrike then
		cmd9 = targetFighter:cmdLua( "fighter_damage", fDamage, "", seqTarget );
	else
		cmd9 = targetFighter:cmdLua( "fighter_strike_damage", fDamage, "", seqTarget );
	end
	
	local cmd_showbar = targetFighter:cmdLua( "fighter_showbar", fDamage, "", seqTarget );

	--�ܹ����ĺ������������� OR վ����
	self:HurtResultAni( targetFighter, seqTarget,seqShadow);
		
	--�ܻ������еȴ��ӵ���Ŀ���
	--seqTarget:SetWaitEnd(cmd_showbar);
	seqTarget:SetWaitEnd( cmd4 );
end

--���ܵ���
function p:AtkSkill(targetFighter, batch, bulletType, fighterIndex, skillType)
	local bulletRotation;
	self.m_kCurrentBatch = batch;
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

--��ȡ����սʿ֮��ĽǶ�
function p:GetAngleByFighter( targetFighter )
	local selfPos = self:GetNode():GetCenterPos();
	local targetPos = targetFighter:GetNode():GetCenterPos();
	
	local tang = (selfPos.y - targetPos.y) / (targetPos.x - selfPos.x);
	local radians = math.atan(tang);
	
	local degree = radians * 180 / math.pi;
	return degree;
end

--����Ⱥ��
function p:AtkSkillAOE(camp, batch )
	self:AtkAOE(camp, batch);
end

--��ȡսʿǰ������
function p:GetFrontPos(targetNode)
	local frontPos = self:GetNode():GetCenterPos();
    local halfWidthSum = self:GetNode():GetCurAnimRealSize().w/2 + targetNode:GetCurAnimRealSize().w/2;
    
    if self.camp == E_CARD_CAMP_HERO then
        frontPos.x = frontPos.x + halfWidthSum;
    else
        frontPos.x = frontPos.x - halfWidthSum;
    end
    return frontPos;
end

function p:SetShadow(kShadow)
	self.m_kShadow = kShadow;
	self.node:SetShadow(kShadow);
end

--��ȡսʿǰ������
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

--����lua����
function p:cmdLua( cmdtype, num, str, seq )
	--��ʱ��ʱ��Ѫ���浽tmplife
    if cmdtype == "fighter_damage" then
        self:SubTmpLife( num ); 
    end
    return super.cmdLua( self, cmdtype, num, str, seq );
    
end