--------------------------------------------------------------
-- FileName: 	card_battle_stage.lua
-- author:		hst, 2013��8��29��
-- purpose:		����ս����״̬
--------------------------------------------------------------

card_battle_stage = {}
local p = card_battle_stage;

p.turnNum = 0;                  --ս���غ���
p.battleStage = 0;              --��ս�׶�,��1~4���׶�:���ؽ׶�,���ֽ׶�,�غϽ׶�,�����׶�
p.battleTurnStage = 0;          --�غϽ׶�,��1~3���׶�:�ϰ볡,�°볡,����
p.battleTurnSubStage = 0;       --�غ��ӽ׶�,��1~3���׶�:dot,skill,atk

--��ʹ��
function p.Init()
	p.turnNum = 1;                  
    p.battleStage = 0;              
    p.battleTurnStage = 0;      
    p.battleTurnSubStage = 0;
end

--������һ���غ�
function p.NextTurn()
   p.turnNum = p.turnNum + 1;
end

--ս���׶�->����
function p.EnterBattle_Stage_Loading()
	p.battleStage = E_BATTLE_STAGE_LOADING;
end

--ս���׶�->����
function p.EnterBattle_Stage_Hand()
    p.battleStage = E_BATTLE_STAGE_INIT;
end

--ս���׶�->�غ�
function p.EnterBattle_Stage_Turn()
    p.battleStage = E_BATTLE_STAGE_TURN;
end

--ս���׶�->����
function p.EnterBattle_Stage_End()
    p.battleStage = E_BATTLE_STAGE_END;
end

--�غϽ׶�->�ϰ볡->Ӣ�ۻغ�
function p.EnterBattle_TurnStage_Hero()
    p.battleTurnStage = E_BATTLE_TURN_STAGE_HERO;
end

--�غϽ׶�->�°볡->�з��غ�
function p.EnterBattle_TurnStage_Enemy()
    p.battleTurnStage = E_BATTLE_TURN_STAGE_ENEMY;
end

--�غϽ׶�->�غϽ���
function p.EnterBattle_TurnStage_End()
    p.battleTurnStage = E_BATTLE_TURN_STAGE_END;
end

--�ӻغϽ׶�->DOT
function p.EnterBattle_SubTurnStage_Dot()
    p.battleTurnSubStage = E_BATTLE_TURN_SUBSTAGE_DOT;
end

--�ӻغϽ׶�->SKILL
function p.EnterBattle_SubTurnStage_Skill()
    p.battleTurnSubStage = E_BATTLE_TURN_SUBSTAGE_SKILL;
end

--�ӻغϽ׶�->ATK
function p.EnterBattle_SubTurnStage_Atk()
    p.battleTurnSubStage = E_BATTLE_TURN_SUBSTAGE_ATK;
end

--�Ƿ���ս�����ؽ׶�
function p.IsBattle_Stage_Loading()
    if p.battleStage == E_BATTLE_STAGE_LOADING then
    	return true;
    end
    return false;
end

--�Ƿ���ս�����ֽ׶�
function p.IsBattle_Stage_Hand()
	if p.battleStage == E_BATTLE_STAGE_INIT then
        return true;
    end
    return false;
end

--�Ƿ���ս���غϽ׶�
function p.IsBattle_Stage_Turn()
    if p.battleStage == E_BATTLE_STAGE_TURN then
        return true;
    end
    return false;
end

--�Ƿ���ս�������׶�
function p.IsBattle_Stage_End()
    if p.battleStage == E_BATTLE_STAGE_END then
        return true;
    end
    return false;
end

--�Ƿ����ϰ볡->Ӣ�ۻغ�
function p.IsBattle_TurnStage_Hero()
    if p.battleTurnStage == E_BATTLE_TURN_STAGE_HERO then
        return true;
    end
    return false;
end

--�Ƿ����°볡->�з��غ�
function p.IsBattle_TurnStage_Enemy()
    if p.battleTurnStage == E_BATTLE_TURN_STAGE_ENEMY then
        return true;
    end
    return false;
end

--�Ƿ��ǻغϽ׶ν���
function p.IsBattle_TurnStage_End()
    if p.battleTurnStage == E_BATTLE_TURN_STAGE_END then
        return true;
    end
    return false;
end

--�Ƿ����ӻغ�DOT�׶�
function p.IsBattle_SubTurnStage_Dot()
    if p.battleTurnSubStage == E_BATTLE_TURN_SUBSTAGE_DOT then
        return true;
    end
    return false;
end

--�Ƿ����ӻغ�SKILL�׶�
function p.IsBattle_SubTurnStage_Skill()
    if p.battleTurnSubStage == E_BATTLE_TURN_SUBSTAGE_SKILL then
        return true;
    end
    return false;
end

--�Ƿ����ӻغ�ATK�׶�
function p.IsBattle_SubTurnStage_Atk()
    if p.battleTurnSubStage == E_BATTLE_TURN_SUBSTAGE_ATK then
        return true;
    end
    return false;
end

--�Ƿ���Ӣ�ۻغϵ�DOT�׶�
function p.IsBattleTurnHeroDot()
	if p.IsBattle_TurnStage_Hero() and p.IsBattle_SubTurnStage_Dot() then
		return true;
	end
	return false;
end

--�Ƿ���Ӣ�ۻغϵ�SKILL�׶�
function p.IsBattleTurnHeroSkill()
    if p.IsBattle_TurnStage_Hero() and p.IsBattle_SubTurnStage_Skill() then
        return true;
    end
    return false;
end

--�Ƿ���Ӣ�ۻغϵ�ATK�׶�
function p.IsBattleTurnHeroAtk()
    if p.IsBattle_TurnStage_Hero() and p.IsBattle_SubTurnStage_Atk() then
        return true;
    end
    return false;
end

--�Ƿ��ǵз��غϵ�DOT�׶�
function p.IsBattleTurnEnemyDot()
    if p.IsBattle_TurnStage_Enemy() and p.IsBattle_SubTurnStage_Dot() then
        return true;
    end
    return false;
end

--�Ƿ��ǵз��غϵ�SKILL�׶�
function p.IsBattleTurnEnemySkill()
    if p.IsBattle_TurnStage_Enemy() and p.IsBattle_SubTurnStage_Skill() then
        return true;
    end
    return false;
end

--�Ƿ��ǵз��غϵ�ATK�׶�
function p.IsBattleTurnEnemyAtk()
    if p.IsBattle_TurnStage_Enemy() and p.IsBattle_SubTurnStage_Atk() then
        return true;
    end
    return false;
end

--��ȡ�غ���
function p.GetTurnNum()
    return p.turnNum;
end

