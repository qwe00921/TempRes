--------------------------------------------------------------
-- FileName: 	game_main.lua
-- author:		zhangwq, 2013/05/16
-- purpose:		������Ϸ�������
--------------------------------------------------------------

game_main = {}
local p = game_main;

math.randomseed(os.time());

--main���
function p.main()
	WriteCon( "*** game_main.main() ***\r\n")
	
	if true and GetUID() == 0 then
		dlg_create_player:ShowUI();--�½���ɫ
	else
	    if false then
	        --�����ʱ�����а·
		    --p.EnterWorldMap();
		    p.EnterTaskMap( "travel_1_1_1.tmx", 1, 1, 1 );
		    task_map_mainui.HideUI();
		else
		    --�������������������
		    --��ʾ������
		    mainui.ShowUI();
        end
	end
	
	--����
	test.test();
end

--���������ͼ
function p.EnterWorldMap()	

	--��������������
	task_map_mainui.HideUI();
	
	--�ر������ͼ
	task_map.CloseMap();
	
	--�������ͼ
	world_map.OpenMap();
	
	--�رձ�������
	StopMusic();
end

--���������ͼ
function p.EnterTaskMap( mapName, chapterId, stageId, stageType, difficulty )
    
    if chapterId == nil then
    	WriteCon("chapterId is nil");
    end
    
    if stageId == nil then
        WriteCon("stageId is nil");
    end
    
	--�ر������ͼ
	world_map.CloseMap();
	
	--�������ͼ
	task_map.OpenMap( mapName, chapterId, stageId, stageType, difficulty );
	
	--������������
	PlayMusic_Task();
	
	--��ʾ���˵�
	task_map_mainui.ShowUI();
	
	--��ʾ���˵�
	--test_button.ShowUI();

	--ֱ�ӽ�ս��
	if true then
--[[		if E_DEMO_VER == 2 then
			x_battle_mgr.EnterBattle();
		elseif E_DEMO_VER == 3 then	
			card_battle_mgr.EnterBattle();
		elseif E_DEMO_VER == 1 then
			battle_mgr.EnterBattle();
		end--]]
		
		x_battle_mgr.EnterBattle();
	end
end
