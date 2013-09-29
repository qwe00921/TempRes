--------------------------------------------------------------
-- FileName: 	test_button.lua
-- author:		hst, 2013/05/27
-- purpose:		左侧菜单测试
--------------------------------------------------------------

test_button = {}
local p = test_button;


p.layer = nil;

--显示UI
function p.ShowUI()	
	local layer = createNDUILayer();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	layer:SetSwallowTouch(false);
	layer:SetFrameRectFull();

	GetUIRoot():AddChildZTag(layer,999,999);
	
    LoadUI("test_button.xui", layer, nil);
	
	p.Init();
	p.SetDelegate(layer);
	p.layer = layer;
	
end

--设置事件处理
function p.SetDelegate(layer)
	local pMissionBossBtn01 = GetButton(layer,ui_test_button.ID_CTRL_BUTTON_1);
    pMissionBossBtn01:SetLuaDelegate(p.OnUIEventMission);
	
	local pMissionBossBtn02 = GetButton(layer,ui_test_button.ID_CTRL_BUTTON_2);
	pMissionBossBtn02:SetLuaDelegate(p.OnUIEventMission);
	
	local pMissionBossBtn03 = GetButton(layer,ui_test_button.ID_CTRL_BUTTON_3);
	pMissionBossBtn03:SetLuaDelegate(p.OnUIEventMission);
	
	local pMissionBossBtn04 = GetButton(layer,ui_test_button.ID_CTRL_BUTTON_4);
	pMissionBossBtn04:SetLuaDelegate(p.OnUIEventMission);
	
	local pMissionBossBtn05 = GetButton(layer,ui_test_button.ID_CTRL_BUTTON_5);
	pMissionBossBtn05:SetLuaDelegate(p.OnUIEventMission);
	
	local pMissionBossBtn06 = GetButton(layer,ui_test_button.ID_CTRL_BUTTON_6);
	pMissionBossBtn06:SetLuaDelegate(p.OnUIEventMission);
	
	local pMissionBossBtn07 = GetButton(layer,ui_test_button.ID_CTRL_BUTTON_7);
	pMissionBossBtn07:SetLuaDelegate(p.OnUIEventMission);
	
	local pMissionBossBtn08 = GetButton(layer,ui_test_button.ID_CTRL_BUTTON_8);
	pMissionBossBtn08:SetLuaDelegate(p.OnUIEventMission);		
end

function p.Init()	
end

--事件处理
function p.OnUIEventMission(uiNode, uiEventType, param)
	--p.layer:RemoveFromParent(true);
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
	
        if ( ui_test_button.ID_CTRL_BUTTON_1 == tag ) then	
			WriteCon("进入任务");

			p.HideAll();
			GetTileMap():SetVisible( true );
			task_map_mainui.ShowUI();
			
		elseif ( ui_test_button.ID_CTRL_BUTTON_2 == tag ) then
			WriteCon("进入PVP");
			
			--p.HideAll();
			--battle_pvp.ShowUI();
			
		elseif ( ui_test_button.ID_CTRL_BUTTON_3 == tag ) then
			WriteCon("进入PVE");
			
			if E_DEMO_VER == 1 then
				battle_mgr.EnterBattle();
			elseif E_DEMO_VER == 2 then	
				x_battle_mgr.EnterBattle();
			elseif E_DEMO_VER == 3 then
				card_battle_mgr.EnterBattle();		
			end
			
			
		elseif ( ui_test_button.ID_CTRL_BUTTON_4 == tag ) then
			WriteCon("第四个菜单");
			p.HideAll();
			open_box.ShowUI();
			
		elseif ( ui_test_button.ID_CTRL_BUTTON_5 == tag ) then
			WriteCon("第五个菜单");	
			p.HideAll();
			boss_out.ShowUI();

		elseif ( ui_test_button.ID_CTRL_BUTTON_6 == tag ) then
			WriteCon("第六个菜单");	
			p.HideAll();
			get_card.ShowUI();	
	
		elseif ( ui_test_button.ID_CTRL_BUTTON_7 == tag ) then		
			WriteCon("第七个菜单");	
			game_main.EnterWorldMap();
			
		elseif ( ui_test_button.ID_CTRL_BUTTON_8 == tag ) then
			WriteCon("第八个菜单");	
			game_main.EnterTaskMap( "travel_1_1_1.tmx", 1, 0 );
		end				
	end
end

--隐藏所有
function p.HideAll()
	GetTileMap():SetVisible( false );
	
	task_map_mainui.HideUI();
	
	open_box.HideUI();
	boss_out.HideUI();
	get_card.HideUI();
	
	battle_pvp.HideUI();
	battle_mainui.HideUI();
	
	x_battle_pvp.HideUI();
	x_battle_mainui.HideUI();
		
	StopJumpShow();
end

--测试移动场景
function p.testMoveScene()
    GetRunningScene():AddActionEffect( "test.move2" );
end

--测试飘血
function p.TestFlyNum()
	battle_mgr.GetFirstHero():SetLifeDamage( 20 );
end