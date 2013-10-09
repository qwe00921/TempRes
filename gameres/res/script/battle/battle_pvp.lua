--------------------------------------------------------------
-- FileName: 	battle_pvp.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		玩家对战
--------------------------------------------------------------

battle_pvp = {}
local p = battle_pvp;

p.heroUIArray = { 9, 10, 11, 12, 13, }
p.enemyUIArray = { 4, 5, 6, 7, 8 }

-----
p.battleLayer = nil;
p.heroFighter1 = nil;
p.actionEffectCombo = nil;
-----

--设置可见
function p.HideUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( false );
		GetBattleShow():EnableTick( false );
	end
end

--显示UI
function p.ShowUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( true );
		GetBattleShow():EnableTick( true );
		return;
	end

	local layer = createCardBattleUILayer();
    if layer == nil then
        return false;
    end

	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
	GetRunningScene():AddChild(layer);

    LoadUI("battle_vs.xui", layer, nil);

	layer:SetFramePosXY(0,0);
	p.battleLayer = layer;
	p.SetDelegate( layer );
	
	--添加战斗背景图片
	p.AddBattleBg();
	
	--战斗
	p.InitBattle();
	return true;
end

--设置事件回调
function p.SetDelegate( layer )
end

--添加战斗背景框
function p.AddBattleBg()
	local bg = createNDUIImage();
	bg:Init();
	bg:SetFrameRectFull();
	p.battleLayer:AddChildZTag( bg, E_BATTLE_Z_GROUND, E_BATTLE_TAG_GROUND );
	
	--获取ani配置中的图片
	local pic = GetPictureByAni("lancer.battle_bg", 0);
	bg:SetPicture( pic );
	--bg:SetVisible( false );
end


--初始化战斗
function p.InitBattle()
	battle_mgr.uiLayer = p.battleLayer;
	battle_mgr.heroUIArray = p.heroUIArray;
	battle_mgr.enemyUIArray = p.enemyUIArray;
	battle_mgr.play( false );
	
--	p.CreateAllFighters();
--	p.test();
--	p.TestBattleShow();
--	p.TestBullet();
--	p.TestMove();
end


--战斗秀
function p.TestBattleShow()
	-- test fighter
	if p.heroFighter1 == nil then
		WriteCon( "test fighter is nil");
		return false;
	end

	-- get node
	local node = p.heroFighter1:GetNode();
	if node == nil then
		WriteCon( "get fighter node failed");
		return false;
	end

	-- get default serial sequence
	local sequence = p.GetDefaultSerialSequence();

	-- add hud effect
	local cmd = createCommandEffect():AddHudEffect( 2, "sk_test.vs" );
	if cmd ~= nil then
		sequence:AddCommand( cmd );
	end

	-- create command
	cmd = createCommandEffect():AddFgEffect( 5, node, "sk_test.atk04" );
	if cmd == nil then
		WriteCon( "create cmd failed" );
		return false;
	end
	WriteCon( "create command ok");

	-- add command
	sequence:AddCommand( cmd );
	WriteCon( "add command ok" );

	return true;
end


--创建子弹
function p.MyCreateBullet()
	
	local bullet = CreateBullet();
	if bullet == nil then
		WriteCon( "create bullet failed" );
		return nil;
	end
	
	bullet:SetFramePosXY( 100, 100 );
	bullet:AddFgEffect( "effect.bullet" );
	return bullet;
end

--子弹测试
function p.TestBullet()
	-- create bullet
	local bullet = CreateBullet();
	if bullet == nil then
		WriteCon( "create bullet failed" );
		return
	end
	
	bullet:SetFramePosXY( 100, 100 );
	bullet:AddFgEffect( "effect.bullet" );
	
	-- add action effect
	local cmd = createCommandEffect():AddActionEffect( 2, bullet, "fighter_cmb.test_reverse" );
	if cmd ~= nil then
		local sequence = p.GetDefaultSerialSequence();
		sequence:AddCommand( cmd );
	end
end

--测试
function p.test()

	local bullet = p.MyCreateBullet();
	bullet:SetFramePosXY( 0, 0 );
	
	-- cmd with var
	local cmd = battle_show.AddActionEffect_ToSequence( 0, bullet, "test_cmb.move+var", nil );
	local varEnv = cmd:GetVarEnv();
	varEnv:SetFloat( "$1", 960 );
	varEnv:SetFloat( "$2", 640 );
	
	-- cmd with var
	cmd = battle_show.AddActionEffect_ToSequence( 0, bullet, "test_cmb.move+var" );
	varEnv = cmd:GetVarEnv();	
	varEnv:SetFloat( "$1", 960 );
	varEnv:SetFloat( "$2", 640 );
end

--测试移动
function p.TestMove()
	p.heroFighter1:AtkSkill( enemyFighter1 );
end
