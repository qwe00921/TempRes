--------------------------------------------------------------
-- FileName: 	x_battle_mgr.lua
-- author:		zhangwq, 2013/06/20
-- purpose:		ս������������ʵ����demo v2.0
--------------------------------------------------------------

x_battle_mgr = {}
local p = x_battle_mgr;

p.heroCamp = nil;			--�����Ӫ
p.enemyCamp = nil;			--�ж���Ӫ
p.uiLayer = nil;			--ս����
p.heroUIArray = nil;		--�����ӪվλUITag��
p.enemyUIArray = nil;		--�ж���ӪվλUITag��

p.imageMask = nil			--�����ɰ���Ч

local isPVE = false;
local isActive = false;
local useParallelBatch = true; --�Ƿ�ʹ�ò�������

--��ʼս������:pve
function p.play_pve()
	isPVE = true;	
	p.createHeroCamp();
	p.createEnemyCamp();
	p.GetBoss():SetBossFlag( true );	
end

--��ʼս������:pvp
function p.play_pvp()
	isPVE = false;
	p.createHeroCamp();
	p.createEnemyCamp();
end

--ȡս����
function p:GetBattleLayer()
	if not isPVE then
		return x_battle_pvp.battleLayer;
	end
	return nil;
end

--����ɰ�ͼƬ
function p.AddMaskImage()
	if p.imageMask == nil then
		p.imageMask = createNDUIImage();
		p.imageMask:Init();
		p.imageMask:SetFrameRectFull();
		
		local pic = GetPictureByAni("lancer.mask", 0); 
		p.imageMask:SetPicture( pic );
		p.uiLayer:AddChildZ( p.imageMask, 99 );
	else
		p.ShowMaskImage();
	end
end

--��ʾ�ɰ�
function p.ShowMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(true);
		p.imageMask:AddActionEffect("x.imageMask_fadein");
	end
end

--����ʾ�ɰ�
function p.HideMaskImage()
	if p.imageMask ~= nil then
		--p.imageMask:SetVisible(false);
		p.imageMask:AddActionEffect("x.imageMask_fadeout");
	end
end

--[[
--ȡboss
function p.GetBoss()
	return p.enemyCamp:GetFirstFighter();
end
--]]

--�Ƿ�active
function p.IsActive()
    return isActive;
end

--ȡ��һ��hero
function p.GetFirstHero()
	return p.heroCamp:GetFirstFighter();
end

--ȡ��һ��enemy
function p.GetFirstEnemy()
	return p.enemyCamp:GetFirstFighter();
end

--���������Ӫ
function p.createHeroCamp()
	p.heroCamp = x_battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray );
end

--�����ж���Ӫ
function p.createEnemyCamp()
	p.enemyCamp = x_battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	--p.enemyCamp:AddFighters( p.enemyUIArray );
	p.enemyCamp:AddBoss( );
end

--����PVP
function p.TestPVP()
	for i=1,100 do
		p.FightOnce_PVP( true );
		p.FightOnce_PVP( false );
	end
end

--���������һ��(PVP)
function p.FightOnce_PVP( flag )
	local batch = battle_show.GetNewBatch();
	local f1 = p.heroCamp:GetRandomFighter();
	local f2 = p.enemyCamp:GetRandomFighter();
	local f3,f4 = p.enemyCamp:GetRandomFighter_2();
	
--	f1:AtkSkillMul( f3, f4, batch );
--	do return end
	
	if flag then
		if math.random(1,3) == 2 then
			f1:AtkSkillMul( f3, f4, batch );
		else
			f1:AtkSkill( f2, batch );
		end
	else
		f2:AtkSkill( f1, batch );
	end
end

--[[
--��Ҽ��ܹ���
function p.HeroAtkSkill()
	WriteCon( "HeroAtkSkill()");
	
	local boss = p.enemyCamp:GetFirstFighter();
	
	--�ӵ���ת
	local bulletRotation = { -50+180, -30+180, 0+180, 20+180, 25+180 };
	
	--hero����
	local heroCount = p.heroCamp:GetFighterCount();
	local enemyCount = p.enemyCamp:GetFighterCount();
	
	for i = 1, heroCount do
		local batch = battle_show.GetNewBatch();
		local hero = p.heroCamp:GetFighterAt(i);
		
		--�����������
		local enemyId= math.random(1,enemyCount);
		local enemy = p.enemyCamp:GetFighterAt(enemyId);
		
		local skillId= math.random(1,3);
		if skillId==1 then
			hero:AtkSkillTuc( enemy, batch, 2, bulletRotation[i], i );
		elseif skillId==2 then
			hero:AtkSkillFeilong( enemy, batch, 2, bulletRotation[i], i );
		elseif skillId==3 then	
			hero:AtkAOE(p.enemyCamp, batch);
		end
		
	end	
end
--]]
--[[
--˫����Ӫ����ͨ����
function p.Atk(campType)
	WriteCon( "-------Atk-------");
	
	--������Ӫ
	local atkCamp;
	
	--������Ӫ
	local defenseCamp;
	
	if campType==E_CARD_CAMP_HERO then
		WriteCon( "-------E_CARD_CAMP_HERO Atk-------");
		atkCamp = p.heroCamp:GetAliveFighters();
		defenseCamp = p.enemyCamp:GetAliveFighters();
	else
		WriteCon( "-------E_CARD_CAMP_ENEMY Atk-------");
		atkCamp = p.enemyCamp:GetAliveFighters();
		defenseCamp = p.heroCamp:GetAliveFighters();
	end
		
	if #atkCamp==0 or #defenseCamp==0 then
		WriteCon( "-------Atk():not Alive fighter-------");
		return ;
	end
	
	for i = 1, #atkCamp do
		local batch = battle_show.GetNewBatch();
		local attacker = atkCamp[i];	
		local defender = defenseCamp[math.random(1,#defenseCamp)];
		attacker:Atk( defender, batch );
	end	
end
--]]
--[[
--�з����ܹ���
function p:EnemyAtkSkill()
	WriteCon( "EnemyAtkSkill()");

	--�ӵ���ת
	local bulletRotation = { -50+180, -30+180, 0+180, 20+180, 25+180 };
	
	
	local enemyCount = p.enemyCamp:GetFighterCount();
	local heroCount = p.heroCamp:GetFighterCount();
	for i = 1, enemyCount do
		local batch = battle_show.GetNewBatch();
		local enemy = p.enemyCamp:GetFighterAt(i);
		
		--���ȡ��������
		local heroId= math.random(1,heroCount);
		local hero = p.heroCamp:GetFighterAt(heroId);
		
		local skillId= math.random(1,3);
		if skillId==1 then
			enemy:AtkSkillTuc( hero, batch, 2, bulletRotation[i], i );
		elseif skillId==2 then
			enemy:AtkSkillFeilong( hero, batch, 2, bulletRotation[i], i );
		elseif skillId==3 then	
			enemy:AtkAOE(p.heroCamp, batch);
		end
	end	
end
--]]
--[[
--boss��ͨ������Ⱥ����
function p.BossAtk()
	WriteCon( "BossAtk()");
	
	local boss = p.enemyCamp:GetFirstFighter();
	local batch = battle_show.GetNewBatch();
	boss:BossAtkCamp( p.heroCamp, batch );
end

--boss���ܹ�����Ⱥ����
function p.BossAtkSkill()
	WriteCon( "BossAtkSkill()");
	
	local boss = p.enemyCamp:GetFirstFighter();
	local batch = battle_show.GetNewBatch();
	--�������
	--local skillType = math.random(1,2);
	local skillType = 1;
	boss:BossAtkCamp_BySkill( p.heroCamp, batch ,skillType);
end
--]]

--����fighter
function p.FindFighter(id)
	local f = p.heroCamp:FindFighter(id);
	if f == nil then
		f = p.enemyCamp:FindFighter(id);
	end
	return f;
end

--ս��ʤ��
function p.OnBattleWin()
	--GetBattleShow():Stop();
	SetTimerOnce( p.OpenBattleWin, 2.0f );
end

--��ս��ʤ������
function p.OpenBattleWin()
	PlayEffectSoundByName( "battle_win.mp3" );
	dlg_battle_win.ShowUI();
end

--ս��ʧ��
function p.OnBattleLose()
	--GetBattleShow():Stop();
	SetTimerOnce( p.OpenBattleLose, 2.0f );
end

--��ս��ʧ�ܽ���
function p.OpenBattleLose()
	dlg_battle_lose.ShowUI();
end

--����Ƿ�ս��ʤ��
function p.CheckBattleWin()
	if p.enemyCamp:IsAllFighterDead() then
		p.OnBattleWin();
		return true;
	end
	return false;
end

--����Ƿ�ս��ʧ��
function p.CheckBattleLose()
	if p.heroCamp:IsAllFighterDead() then
		p.OnBattleLose();
		return true;
	end
	return false;
end

--����ս��
function p.EnterBattle()
	WriteCon( "x_battle_mgr.EnterBattle()" );
	
	--hide 
	GetTileMap():SetVisible( false );
	task_map_mainui.HideUI();
	
	--enter PVP
	x_battle_pvp.ShowUI();	
	x_battle_mainui.ShowUI();
	
	--����
	PlayMusic_Battle();
	
	isActive = true;
end

--�˳�ս��
function p.QuitBattle()
	WriteCon( "x_battle_mgr.QuitBattle()" );
	
	--�ر�ս������
	--x_battle_pve.CloseUI();
	x_battle_pvp.CloseUI();
	x_battle_mainui.CloseUI();
	
	--��ʾ������͵�ͼ
	GetTileMap():SetVisible( true );
	task_map_mainui.ShowUI();
	hud.FadeIn();
	
	--����
	PlayMusic_Task();
	
	isActive = false;
end

--���ս������
function p.IsBattleEnd()
	if p.heroCamp:IsAllFighterDead() then return true end
	if p.enemyCamp:IsAllFighterDead() then return true end
	return false;
end

--Ӣ�ۻغ�
function p.HeroTurn()
	p.CampBattle(E_CARD_CAMP_HERO);
end

--���˻غ�
function p.EnemyTurn()
	p.CampBattle(E_CARD_CAMP_ENEMY);
end

function p.CampBattle(campType)
	--������Ӫ
	local atkCamp;
	--������Ӫ
	local defenseCamp;
	
	if campType==E_CARD_CAMP_HERO then
		atkCamp = p.heroCamp;
		defenseCamp = p.enemyCamp;
	else
		atkCamp = p.enemyCamp;
		defenseCamp = p.heroCamp;
	end
	
	--�ȼ�¼��ʱѪ��
	local defenceFighters = defenseCamp:GetAliveFighters();
	for i=1, #defenceFighters do
		defenceFighters[i]:SetTmpLife();
	end
	
	--��ȡδ������սʿ
	local atkCampAliveFighter = atkCamp:GetAliveFighters();
	
	local prevBatch = nil;
	for i = 1, #atkCampAliveFighter do
		local batch = battle_show.GetNewBatch();
		local attacker = atkCampAliveFighter[i];
		
		--ÿ������ȡĿ��fighters��ȷ�����ǻ��
		local defenseCampAliveFighter = defenseCamp:GetAliveFighters();
		if #defenseCampAliveFighter == 0 then break end
		
		local defenderId = 1;
		if #defenseCampAliveFighter > 1 then
			defenderId = math.random(1,#defenseCampAliveFighter);
		end

		--@override
		if true and math.random(1,2)==2 then
			local target = defenseCampAliveFighter[defenderId];
			attacker:Atk( target, batch );
		else
			--if math.random(1,2)==2 then
			--	local skillType = math.random(1,2);
			--	attacker:AtkSkill(defenseCampAliveFighter[defenderId], batch, 2, i ,skillType);
			--else
			--	attacker:AtkSkillAOE(defenseCamp, batch);
			--end
			--local atkSkill = math.random(1,2);
			local atkSkill = 1;
			if atkSkill == 1 then
				if attacker.petTag == PET_BLUE_DEVIL_TAG  then
					attacker:UltimateSkill(defenseCamp, batch);
				else
					if attacker.idCamp == E_CARD_CAMP_ENEMY then
						for d = 1, #defenseCampAliveFighter do
							attacker:AtkSkillNearOneToOne(defenseCampAliveFighter[d], batch, 2, i ,skillType);
						end
					else
						attacker:AtkSkillNearOneToOne(defenseCampAliveFighter[defenderId], batch, 2, i ,skillType);
					end		
				end
			else
				attacker:AtkSkillOneToCamp(defenseCamp, batch);
			end		
		end
		
		--�������εȴ�
		if useParallelBatch and (prevBatch ~= nil) then
			local cmdSpecial = prevBatch:GetSpecialCmd( E_BATCH_STAGE_HURT_END );
			if cmdSpecial ~= nil then
				batch:SetWaitEnd( cmdSpecial );
			end
		end
		prevBatch = batch;
	end
end
