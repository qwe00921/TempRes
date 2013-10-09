--------------------------------------------------------------
-- FileName: 	dlg_battle_lose.lua
-- author:		zjj, 2013/05/31
-- purpose:		ս��ʧ�ܽ���
--------------------------------------------------------------

dlg_battle_lose = {}
local p = dlg_battle_lose;
p.layer = nil;

--��ʾUI
function p.ShowUI()
	if p.layer ~= nil then
		p.layer:SetVisible( true );
		return;
	end
		
	local layer = createNDUIDialog();
    if layer == nil then
        return false;
    end
	
	layer:Init();
	GetUIRoot():AddDlg(layer);
    LoadDlg( "dlg_battle_lose.xui", layer, nil );
	
	p.Init();
	p.layer = layer;
	
	--�Ӹ��رհ�ť
	local closeBtn = createNDUIButton();
	closeBtn:Init();
	closeBtn:SetFrameRectFull();
	layer:AddChildZ(closeBtn,5);
	closeBtn:SetLuaDelegate(p.OnUIEventBtn);

	--��Ч
	--layer:SetVisible(false);
	--layer:AddActionEffect( "engine.open_dlg" );
end

function p.OnUIEventBtn(uiNode, uiEventType, param)	
	if p.layer ~= nil then
		p.layer:LazyClose();
		p.layer = nil;
	end
	
	if E_DEMO_VER == 2 then
	    x_battle_mgr.QuitBattle();
	elseif E_DEMO_VER == 3 then 
		card_battle_mgr.QuitBattle();    
	elseif E_DEMO_VER == 1 then 
	    battle_mgr.QuitBattle();
    end
end

--[[--�����¼�����
function p.SetDelegate(layer)
	local pMissionBossBtn01 = GetButton(layer,ui_mission_boss.ID_CTRL_BUTTON_6);
    pMissionBossBtn01:SetLuaDelegate(p.OnUIEventMission);
	
	local pMissionBossBtn02 = GetButton(layer,ui_mission_boss.ID_CTRL_BUTTON_7);
	pMissionBossBtn02:SetLuaDelegate(p.OnUIEventMission);
	
	local pMissionBossBtn03 = GetButton(layer,ui_mission_boss.ID_CTRL_BUTTON_8);
	pMissionBossBtn03:SetLuaDelegate(p.OnUIEventMission);
	
end--]]

function p.Init()	
end

--[[--�¼�����
function p.OnUIEventMission(uiNode, uiEventType, param)
	--p.layer:RemoveFromParent(true);
	local tag = uiNode:GetTag();
	if IsClickEvent( uiEventType ) then
        if ( ui_mission_boss.ID_CTRL_BUTTON_6 == tag ) then	
			WriteCon("��ť1");
			p.layer:LazyClose();
			
		elseif ( ui_mission_boss.ID_CTRL_BUTTON_7 == tag ) then
			WriteCon("��ť2");
		elseif ( ui_mission_boss.ID_CTRL_BUTTON_8 == tag ) then
			WriteCon("��ť3");
		end
	end

end--]]