--------------------------------------------------------------
-- FileName: 	battle_mgr.lua
-- author:		zhangwq, 2013/05/22
-- purpose:		ս������������ʵ����
--------------------------------------------------------------

battle_mgr = {}
local p = battle_mgr;

p.heroCamp = nil;		--�����Ӫ
p.enemyCamp = nil;		--�ж���Ӫ
p.heroUIArray = nil;	--�����ӪվλUITag��
p.enemyUIArray = nil;	--�ж���ӪվλUITag��
p.uiLayer = nil;		--ս����

local isPVE = false;
local timerBattleWin;
local timerBattleLose;


--��ʼս������
function p.play( in_isPVE )	
	p.isPVE = in_isPVE;

	p.createHeroCamp();
	p.createEnemyCamp();
	p.GetBoss():SetBossFlag( true );
end

--ȡboss
function p.GetBoss()
	return p.enemyCamp:GetFirstFighter();
end

--ȡhero
function p.GetFirstHero()
	return p.heroCamp:GetFirstFighter();
end

--������
function p.test()
	if p.isPVE then
		p.TestPVE();
	else
		p.TestPVP();
	end
end

--���������Ӫ
function p.createHeroCamp()
	p.heroCamp = battle_camp:new();
	p.heroCamp.idCamp = E_CARD_CAMP_HERO;
	p.heroCamp:AddFighters( p.heroUIArray );
end

--�����ж���Ӫ
function p.createEnemyCamp()
	p.enemyCamp = battle_camp:new();
	p.enemyCamp.idCamp = E_CARD_CAMP_ENEMY;
	p.enemyCamp:AddFighters( p.enemyUIArray );
end

--��ȡ���սʿ
function p.GetTwoRandomFighters()

end

--����PVP
function p.TestPVP()
	for i=1,100 do
		p.FightOnce_PVP( true );
		p.FightOnce_PVP( false );
	end
end

--�����һ��(PVP)
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

--����PVE
function p.TestPVE()
	local boss = p.enemyCamp:GetFirstFighter();

--[[	
	--hero����
	local heroCount = heroCamp:GetFighterCount();
	for i = 1, heroCount do
		local batch = battle_show.GetNewBatch();
		local hero = heroCamp:GetFighterAt(i);
		hero:AtkSkill( boss, batch );
	end
--]]
	
	--boss����
	local batch = battle_show.GetNewBatch();
	boss:AtkCamp( p.heroCamp, batch );
end


--��Ҽ��ܹ���
function p.HeroAtkSkill()
	WriteCon( "HeroAtkSkill()");
	
	local boss = p.enemyCamp:GetFirstFighter();
	
	--�ӵ���ת
	local bulletRotation = { -50+180, -30+180, 0+180, 20+180, 25+180 };
	
	--hero����
	local heroCount = p.heroCamp:GetFighterCount();
	for i = 1, heroCount do
		local batch = battle_show.GetNewBatch();
		local hero = p.heroCamp:GetFighterAt(i);
		--hero:AtkSkill( boss, batch, 2, bulletRotation[i], i );
		hero:AtkSkillTornado( boss, batch, 2, bulletRotation[i], i );
	end	
end

--�����ͨ����
function p.HeroAtk()
	WriteCon( "HeroAtk()");
	
	local boss = p.enemyCamp:GetFirstFighter();
	
	--hero����
	local heroCount = p.heroCamp:GetFighterCount();
	for i = 1, heroCount do
		local batch = battle_show.GetNewBatch();
		local hero = p.heroCamp:GetFighterAt(i);
		hero:Atk( boss, batch );
	end	
end

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
	GetBattleShow():Stop();
	timerBattleWin = SetTimer( p.OpenBattleWin, 1.0f );
end

--��ս��ʤ������
function p.OpenBattleWin()
	PlayEffectSoundByName( "battle_win.mp3" );
	dlg_battle_win.ShowUI();
	KillTimer( timerBattleWin );
end

--ս��ʧ��
function p.OnBattleLose()
	--GetBattleShow():Stop();
	timerBattleLose = SetTimer( p.OpenBattleLose, 1.0f );
end

--��ս��ʧ�ܽ���
function p.OpenBattleLose()
	dlg_battle_lose.ShowUI();
	KillTimer( timerBattleLose );
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
	--hide 
	GetTileMap():SetVisible( false );
	task_map_mainui.HideUI();
	
	--enter PVE
	battle_pve.ShowUI();	
	battle_mainui.ShowUI();	
	
	--����
	PlayMusic_Battle();
end

--�˳�ս��
function p.QuitBattle()
	--�ر�ս������
	battle_pve.CloseUI();
	battle_mainui.CloseUI();
	
	--��ʾ������͵�ͼ
	GetTileMap():SetVisible( true );
	task_map_mainui.ShowUI();
	hud.FadeIn();
	
	--����
	PlayMusic_Task();
end

--���ս������
function p.IsBattleEnd()
	if p.heroCamp:IsAllFighterDead() then return true end
	if p.enemyCamp:IsAllFighterDead() then return true end
	return false;
end