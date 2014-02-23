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
	p.substep = substep - 1;
	if p.substep == 1 then
		--maininterface.ShowUI(p.userData);
	elseif p.substep == 2 then
		p.nextGuidSubStep();
	elseif p.substep == 3 then
		w_battle_pve.setBtnClick(2);
		--w_battle_mgr.SetPVEAtkID(2); --2��λ����Ŀ���λ�� ״̬��ͣ������ʾ���� 
	elseif p.substep == 4 then
		w_battle_pve.setBtnClick(1);
		--w_battle_mgr.SetPVEAtkID(1);  
		local lstateMachine = w_battle_machinemgr.getAtkStateMachine(2); 		--��2��λ��״̬�������ж�(����)
		if lstateMachine ~= nil then
			lstateMachine:atk_startAtk();
		end; 
		--�ȹ�ȫ������һ����
	elseif p.substep == 5 then
		w_battle_mgr.FightWin();
		--�Ȳ����л��������һ����		
	elseif p.substep == 6 then
		--w_battle_pve.setBtnClick(6);
		w_battle_mgr.SetPVETargerID(3);
		p.nextGuidSubStep();
	elseif p.substep == 7 then
		w_battle_pve.setBtnClick(2);  --����һ���ҷ��غ�ʱ���� rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif p.substep == 8 then
		--w_battle_mgr.HeroTurnEnd();
		--��ս��ʤ��,1��λ���ܻ�ʱ,��HP��(��֮ˮ��),Ȼ�������һ����
	elseif p.substep == 9 then
	   w_battle_mgr.checkTurnEnd(); 
	--[[	local lstateMachine = w_battle_machinemgr.getTarStateMachine(W_BATTLE_ENEMY,1); 		--��1��λ��״̬���������������������
		if lstateMachine ~= nil then
			lstateMachine:tar_dieEnd();
		end;
		]]--
	    --BOSS������������ ������һ����
	elseif p.substep == 10 then
		local lfighter = w_battle_mgr.heroCamp:FindFighter(2);
		lfighter.nowlife = math.modf(lfighter.maxHp * 0.8)
		lfighter.Hp = lfighter.nowlife;
		w_battle_pve.SetHeroCardAttr(2, lfighter);
		w_battle_db_mgr.SetGuidItemList();
		p.nextGuidSubStep();
	elseif p.substep == 11 then
	   --ѡ����Ʒ
		w_battle_pve.GuidUseItem1();
		p.nextGuidSubStep();
	elseif p.substep == 12 then
		--ʹ����Ʒ
		w_battle_useitem.UseItem(2);
		--w_battle_mgr.UseItem(2);
		p.nextGuidSubStep();
	elseif p.substep == 13 then
		p.nextGuidSubStep();		
		--��ս������������� ������һ������
	elseif p.substep == 14 then
		--��������������ս������
		p.IsGuid = false;
		w_battle_pve.MissionOver(w_battle_mgr.MissionWin);  --�������,����������
	end
	
end

function p.fighterSecondGuid(substep)
	p.IsGuid = true;
	p.guidstep = 3;
	p.substep = substep;
	if substep == 1 then

	elseif substep == 2 then

	elseif substep == 3 then

	elseif substep == 4 then

	elseif substep == 5 then
		--�յ�ս�����𷵻���Ϣ�� rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 6 then
		--˫����������� rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 7 then
		p.nextGuidSubStep();
	elseif substep == 8 then
		p.nextGuidSubStep();
	elseif substep == 9 then
		p.SetPVETargerID(2);
		p.nextGuidSubStep();
	elseif substep == 10 then
		p.nextGuidSubStep();
	elseif substep == 11 then
		w_battle_mgr.SetPVEAtkID(3);
		p.nextGuidSubStep();
	elseif substep == 12 then
		p.nextGuidSubStep();
	elseif substep == 13 then
		p.nextGuidSubStep();
	elseif substep == 14 then
		--ս��ʤ����������һ�����˺� rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 15 then
		p.nextGuidSubStep();
	elseif substep == 16 then
		p.nextGuidSubStep();
	elseif substep == 17 then
	    --�������˺� SP��ص�, �����ָ��Ŀ��
		--rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 18 then
		p.nextGuidSubStep();
	elseif substep == 19 then
		p.nextGuidSubStep();
	elseif substep == 20 then
		w_battle_mgr.SetPVESkillAtkID(2);
		--���ܷ����� rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 21 then
	    --ս��ʧ�ܺ�
		--rookie_mask.ShowUI(p.step,p.substep + 1)
	elseif substep == 22 then
		p.IsGuid = false;
	end	
	
end

function p.nextGuidSubStep()
	rookie_mask.ShowUI(p.guidstep, p.substep + 1);
end