--------------------------------------------------------------
-- FileName: 	battle_pve.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		Boss战
--------------------------------------------------------------

battle_pve = {}
local p = battle_pve;

p.heroUIArray = { 1, 2, 3, 4, 5 }
p.enemyUIArray = { 11 };

-----
p.battleLayer = nil;
p.heroFighter1 = nil;
-----

--设置可见
function p.HideUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( false );
		GetBattleShow():EnableTick( false );
	end
end

--关闭
function p.CloseUI()
	if p.battleLayer ~= nil then	
		p.battleLayer:LazyClose();
		p.battleLayer = nil;
	end
	GetBattleShow():EnableTick( false );
end

--显示UI
function p.ShowUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( true );
		GetBattleShow():EnableTick( true );
		return true;
	end
	
	local layer = createCardBattleUILayer();
    if layer == nil then
        return false;
    end

	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();
	GetRunningScene():AddChild(layer);

    LoadUI("battle_boss.xui", layer, nil);

	layer:SetFramePosXY(0,0);
	p.battleLayer = layer;
	p.SetDelegate( layer );
	
	--添加战斗背景图片
	--p.AddBattleBg();
			
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
	battle_mgr.play( true );
end


