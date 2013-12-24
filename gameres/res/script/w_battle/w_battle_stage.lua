--------------------------------------------------------------
-- FileName:    n_battle_stage.lua
-- author:      hst, 2013��11��26��
-- purpose:     ս��״̬
--------------------------------------------------------------

n_battle_stage = {}
local p = n_battle_stage;

p.roundNum = 0;                 --ս���غ���
p.battleStage = 0;              --��ս�׶�,��1~4���׶�:���ؽ׶�,����BUFF�׶�,�غϽ׶�,�����׶�
p.battleRoundStage = 0;         --�غϽ׶�,��4���ӽ׶�:�ٻ���,BUFF����,��Ź������

--��ʹ��
function p.Init()
    p.roundNum = 1;                  
    p.battleStage = 0;              
    p.battleRoundStage = 0;      
end

--������һ���غ�
function p.NextRound()
   p.roundNum = p.roundNum + 1;
end

--��ȡ�غ���
function p.GetRoundNum()
    return p.roundNum;
end

--------------------------------------------------------------
--��ս�ĸ��ֽ׶ι���
--------------------------------------------------------------

--ս���׶�->����
function p.EnterBattle_Stage_Loading()
    p.battleStage = N_BATTLE_STAGE_LOADING;
end

--ս���׶�->����BUFF����
function p.EnterBattle_Stage_Permanent_Buff()
    p.battleStage = N_BATTLE_STAGE_PERMANENT_BUFF;
end

--ս���׶�->�غ�
function p.EnterBattle_Stage_Round()
    p.battleStage = N_BATTLE_STAGE_ROUND;
end

--ս���׶�->����
function p.EnterBattle_Stage_End()
    p.battleStage = N_BATTLE_STAGE_END;
end

--------------------------------------------------------------
--���뻥Ź�׶εĻغϽ׶ι���
--------------------------------------------------------------

--�غϽ׶�->�ٻ��� 
function p.EnterBattle_RoundStage_Pet()
    p.battleRoundStage = N_BATTLE_ROUND_STAGE_PET;
end

--�غϽ׶�->BUFF����
function p.EnterBattle_RoundStage_Buff()
    p.battleRoundStage = N_BATTLE_ROUND_STAGE_BUFF;
end

--�غϽ׶�->��Ź
function p.EnterBattle_RoundStage_Atk()
    p.battleRoundStage = N_BATTLE_ROUND_STAGE_ATK;
end

--�غϽ׶�->����
function p.EnterBattle_RoundStage_Clearing()
    p.battleRoundStage = N_BATTLE_ROUND_STAGE_CLEARING;
end

--------------------------------------------------------------
--��ս�ĸ��ֽ׶ε��ж�
--------------------------------------------------------------

--�Ƿ���ս�����ؽ׶�
function p.IsBattle_Stage_Loading()
    if p.battleStage == N_BATTLE_STAGE_LOADING then
        return true;
    end
    return false;
end

--�Ƿ���ս������BUFF�׶�
function p.IsBattle_Stage_Permanent_Buff()
    if p.battleStage == N_BATTLE_STAGE_PERMANENT_BUFF then
        return true;
    end
    return false;
end

--�Ƿ���ս���غϽ׶�
function p.IsBattle_Stage_Round()
    if p.battleStage == N_BATTLE_STAGE_ROUND then
        return true;
    end
    return false;
end

--�Ƿ���ս�������׶�
function p.IsBattle_Stage_End()
    if p.battleStage == N_BATTLE_STAGE_END then
        return true;
    end
    return false;
end

--------------------------------------------------------------
--�غϵĸ��ֽ׶ε��ж�
--------------------------------------------------------------

--�Ƿ��ǻ�Ź�׶��ٻ��ޱ���
function p.IsBattle_RoundStage_Pet()
    if p.battleRoundStage == N_BATTLE_ROUND_STAGE_PET then
        return true;
    end
    return false;
end

--�Ƿ��ǻ�Ź�׶�BUFF����
function p.IsBattle_RoundStage_Buff()
    if p.battleRoundStage == N_BATTLE_ROUND_STAGE_BUFF then
        return true;
    end
    return false;
end

--�Ƿ��ǻ�Ź�׶�BUFF����
function p.IsBattle_RoundStage_Atk()
    if p.battleRoundStage == N_BATTLE_ROUND_STAGE_ATK then
        return true;
    end
    return false;
end

--�Ƿ��ǻ�Ź�׶ν���
function p.IsBattle_RoundStage_Clearing()
    if p.battleRoundStage == N_BATTLE_ROUND_STAGE_CLEARING then
        return true;
    end
    return false;
end


