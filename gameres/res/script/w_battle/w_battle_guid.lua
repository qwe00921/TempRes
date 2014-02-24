w_battle_guid = {}
local p = w_battle_guid;

--ս�������Ŀ���

p.IsGuid = false;
p.guidstep = nil;
p.substep = nil;

--��һ�ֵ���������,�������¼�
function p.fighterGuid(substep)
	p.IsGuid = true;
	p.guidstep = 3;
	p.substep = substep;
	if p.substep == 1 then
		maininterface.ShowUI(rookie_main.userData);
		maininterface.HideUI();
		dlg_userinfo.HideUI();
		dlg_drama.ShowUI( 1, after_drama_data.ROOKIE, 0, 0);
	elseif p.substep == 2 then
		w_battle_mgr.EnterBattle(1,100011,1);
		--rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 3 then
		rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 4 then
		w_battle_pve.setBtnClick(2);
		--w_battle_mgr.SetPVEAtkID(2); --2��λ����Ŀ���λ�� ״̬��ͣ������ʾ���� 
	elseif p.substep == 5 then
		w_battle_pve.setBtnClick(1);
		--w_battle_mgr.SetPVEAtkID(1);  
		local lstateMachine = w_battle_machinemgr.getAtkStateMachine(2); 		--��2��λ��״̬�������ж�(����)
		if lstateMachine ~= nil then
			lstateMachine:atk_startAtk();
		end; 
		--�ȹ�ȫ������һ����
	elseif p.substep == 6 then
		w_battle_mgr.FightWin();
		--�Ȳ����л��������һ����		
	elseif p.substep == 7 then
		--w_battle_pve.setBtnClick(6);
		w_battle_mgr.SetPVETargerID(3);
		rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 8 then
		w_battle_pve.setBtnClick(2);  --����һ���ҷ��غ�ʱ���� rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif p.substep == 9 then
		--w_battle_mgr.HeroTurnEnd();
		--��ս��ʤ��,1��λ���ܻ�ʱ,��HP��(��֮ˮ��),Ȼ�������һ����
		--��ˮ��
		rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 10 then
	   --w_battle_mgr.FightWin(); 
	--[[	local lstateMachine = w_battle_machinemgr.getTarStateMachine(W_BATTLE_ENEMY,1); 		--��1��λ��״̬���������������������
		if lstateMachine ~= nil then
			lstateMachine:tar_dieEnd();
		end;
		]]--
	    --BOSS���������,�ҷ�����һ�غϵ��� ������һ����
	elseif p.substep == 11 then
		
	elseif p.substep == 12 then
	   --ѡ����Ʒ
		w_battle_pve.GuidUseItem1();
		rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 13 then
		--ʹ����Ʒ
		w_battle_useitem.UseItem(2);
		rookie_mask.ShowUI(p.guidstep, p.substep);
	elseif p.substep == 14 then
		--��ս��������� ���н���
		--quest_reward.CloseUI();
		--dlg_drama.ShowUI(2, after_drama_data.ROOKIE, 0, 0);
	elseif p.substep == 15 then
		p.IsGuid = false;
		quest_reward.CloseUI();
		dlg_drama.ShowUI(2, after_drama_data.ROOKIE, 0, 0);
		--��������������ս������
		--w_battle_mgr.MissionWin();  --�������,����������
	end
	
end

function p.fighterSecondGuid(substep)
	p.IsGuid = true;
	p.guidstep = 5;
	p.substep = substep;
	if substep == 1 then  --����
		dlg_drama.ShowUI( 4, after_drama_data.ROOKIE,0,0)
	elseif substep == 2 then 
		maininterface.ShowUI(rookie_main.userData);
		country_main.ShowUI();
		rookie_mask.ShowUI(p.guidstep,substep);
	elseif substep == 3 then  --ת����ҳ
		dlg_menu.HomeClick();
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 4 then --��������������
		stageMap_main.OpenWorldMap();
		PlayMusic_Task(1);
		maininterface.HideUI();
		
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 5 then --��ʾ��һ��
		stageMap_1.ChapterClick();
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 6 then --ѡ���һ������
		quest_main.FightMissionClick();
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 7 then --�����������ս��	
		dlg_drama.ShowUI( 5, after_drama_data.ROOKIE,0,0)
	elseif substep == 8 then
		--��ʱ������ѽ���
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 9 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 10 then
		rookie_mask.ShowUI(p.guidstep, substep);
		--p.nextGuidSubStep();
	elseif substep == 11 then  --ѡ����һ������
		w_battle_mgr.SetPVETargerID(3);  
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 12 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 13 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 14 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 15 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 16 then
		w_battle_pve.setBtnClick(3);--�ҷ�����λ���
	    --���Էſ�,����ս��ʤ��
		--��һ��ս��ʤ����������һ�����˽����� rookie_mask.ShowUI()
	elseif substep == 17 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 18 then
		rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 19 then
		--�ҷ�2��λ��SPֱ�Ӳ���
		local lfighter = w_battle_mgr.heroCamp:FindFighter(2);
		lfighter.Sp = 100;
		w_battle_pve.SetHeroCardAttr(2, lfighter);
	    rookie_mask.ShowUI(p.guidstep, substep);
	elseif substep == 20 then
		rookie_mask.ShowUI(p.guidstep, substep); --�������� ����Ϊ����
	elseif substep == 21 then
		--��������ʱ,�ȿ�ס,��������
		rookie_mask.ShowUI(p.guidstep, substep); --�������� ����Ϊ����
	elseif substep == 22 then
		rookie_mask.ShowUI(p.guidstep, substep); 
	elseif substep == 23 then
		w_battle_pve.setBtnSkillClick(2);
	    --�ſ�,����ս��,�ȵ�����ս��,ս�ܺ�,������һ����
		--rookie_mask.ShowUI(p.step,p.substep + 1)
		--rookie_mask.ShowUI(p.guidstep, substep); 
	elseif substep == 24 then		
		p.IsGuid = false;
		quest_reward.CloseUI();
		rookie_main.SendUpdateStep(5);
	end	
	
end

function p.nextGuidSubStep()
	rookie_mask.ShowUI(p.guidstep, p.substep);
end