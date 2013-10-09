--------------------------------------------------------------
-- FileName: 	battle_pve.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		Bossս
--------------------------------------------------------------

battle_pve = {}
local p = battle_pve;

p.heroUIArray = { 1, 2, 3, 4, 5 }
p.enemyUIArray = { 11 };

-----
p.battleLayer = nil;
p.heroFighter1 = nil;
-----

--���ÿɼ�
function p.HideUI()
	if p.battleLayer ~= nil then
		p.battleLayer:SetVisible( false );
		GetBattleShow():EnableTick( false );
	end
end

--�ر�
function p.CloseUI()
	if p.battleLayer ~= nil then	
		p.battleLayer:LazyClose();
		p.battleLayer = nil;
	end
	GetBattleShow():EnableTick( false );
end

--��ʾUI
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
	
	--���ս������ͼƬ
	--p.AddBattleBg();
			
	--ս��
	p.InitBattle();
	return true;
end

--�����¼��ص�
function p.SetDelegate( layer )
end

--���ս��������
function p.AddBattleBg()
	local bg = createNDUIImage();
	bg:Init();
	bg:SetFrameRectFull();
	p.battleLayer:AddChildZTag( bg, E_BATTLE_Z_GROUND, E_BATTLE_TAG_GROUND );
	
	--��ȡani�����е�ͼƬ
	local pic = GetPictureByAni("lancer.battle_bg", 0);
	bg:SetPicture( pic );
	--bg:SetVisible( false );
end


--��ʼ��ս��
function p.InitBattle()
	battle_mgr.uiLayer = p.battleLayer;
	battle_mgr.heroUIArray = p.heroUIArray;
	battle_mgr.enemyUIArray = p.enemyUIArray;
	battle_mgr.play( true );
end


