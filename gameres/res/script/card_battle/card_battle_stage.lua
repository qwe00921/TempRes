--------------------------------------------------------------
-- FileName: 	card_battle_stage.lua
-- author:		hst, 2013年8月29日
-- purpose:		卡牌战斗回状态
--------------------------------------------------------------

card_battle_stage = {}
local p = card_battle_stage;

p.turnNum = 0;                  --战斗回合数
p.battleStage = 0;              --对战阶段,共1~4个阶段:加载阶段,起手阶段,回合阶段,结束阶段
p.battleTurnStage = 0;          --回合阶段,共1~3个阶段:上半场,下半场,结束
p.battleTurnSubStage = 0;       --回合子阶段,共1~3个阶段:dot,skill,atk

--初使化
function p.Init()
	p.turnNum = 1;                  
    p.battleStage = 0;              
    p.battleTurnStage = 0;      
    p.battleTurnSubStage = 0;
end

--进入下一个回合
function p.NextTurn()
   p.turnNum = p.turnNum + 1;
end

--战斗阶段->加载
function p.EnterBattle_Stage_Loading()
	p.battleStage = E_BATTLE_STAGE_LOADING;
end

--战斗阶段->起手
function p.EnterBattle_Stage_Hand()
    p.battleStage = E_BATTLE_STAGE_INIT;
end

--战斗阶段->回合
function p.EnterBattle_Stage_Turn()
    p.battleStage = E_BATTLE_STAGE_TURN;
end

--战斗阶段->结束
function p.EnterBattle_Stage_End()
    p.battleStage = E_BATTLE_STAGE_END;
end

--回合阶段->上半场->英雄回合
function p.EnterBattle_TurnStage_Hero()
    p.battleTurnStage = E_BATTLE_TURN_STAGE_HERO;
end

--回合阶段->下半场->敌方回合
function p.EnterBattle_TurnStage_Enemy()
    p.battleTurnStage = E_BATTLE_TURN_STAGE_ENEMY;
end

--回合阶段->回合结束
function p.EnterBattle_TurnStage_End()
    p.battleTurnStage = E_BATTLE_TURN_STAGE_END;
end

--子回合阶段->DOT
function p.EnterBattle_SubTurnStage_Dot()
    p.battleTurnSubStage = E_BATTLE_TURN_SUBSTAGE_DOT;
end

--子回合阶段->SKILL
function p.EnterBattle_SubTurnStage_Skill()
    p.battleTurnSubStage = E_BATTLE_TURN_SUBSTAGE_SKILL;
end

--子回合阶段->ATK
function p.EnterBattle_SubTurnStage_Atk()
    p.battleTurnSubStage = E_BATTLE_TURN_SUBSTAGE_ATK;
end

--是否是战斗加载阶段
function p.IsBattle_Stage_Loading()
    if p.battleStage == E_BATTLE_STAGE_LOADING then
    	return true;
    end
    return false;
end

--是否是战斗起手阶段
function p.IsBattle_Stage_Hand()
	if p.battleStage == E_BATTLE_STAGE_INIT then
        return true;
    end
    return false;
end

--是否是战斗回合阶段
function p.IsBattle_Stage_Turn()
    if p.battleStage == E_BATTLE_STAGE_TURN then
        return true;
    end
    return false;
end

--是否是战斗结束阶段
function p.IsBattle_Stage_End()
    if p.battleStage == E_BATTLE_STAGE_END then
        return true;
    end
    return false;
end

--是否是上半场->英雄回合
function p.IsBattle_TurnStage_Hero()
    if p.battleTurnStage == E_BATTLE_TURN_STAGE_HERO then
        return true;
    end
    return false;
end

--是否是下半场->敌方回合
function p.IsBattle_TurnStage_Enemy()
    if p.battleTurnStage == E_BATTLE_TURN_STAGE_ENEMY then
        return true;
    end
    return false;
end

--是否是回合阶段结束
function p.IsBattle_TurnStage_End()
    if p.battleTurnStage == E_BATTLE_TURN_STAGE_END then
        return true;
    end
    return false;
end

--是否是子回合DOT阶段
function p.IsBattle_SubTurnStage_Dot()
    if p.battleTurnSubStage == E_BATTLE_TURN_SUBSTAGE_DOT then
        return true;
    end
    return false;
end

--是否是子回合SKILL阶段
function p.IsBattle_SubTurnStage_Skill()
    if p.battleTurnSubStage == E_BATTLE_TURN_SUBSTAGE_SKILL then
        return true;
    end
    return false;
end

--是否是子回合ATK阶段
function p.IsBattle_SubTurnStage_Atk()
    if p.battleTurnSubStage == E_BATTLE_TURN_SUBSTAGE_ATK then
        return true;
    end
    return false;
end

--是否是英雄回合的DOT阶段
function p.IsBattleTurnHeroDot()
	if p.IsBattle_TurnStage_Hero() and p.IsBattle_SubTurnStage_Dot() then
		return true;
	end
	return false;
end

--是否是英雄回合的SKILL阶段
function p.IsBattleTurnHeroSkill()
    if p.IsBattle_TurnStage_Hero() and p.IsBattle_SubTurnStage_Skill() then
        return true;
    end
    return false;
end

--是否是英雄回合的ATK阶段
function p.IsBattleTurnHeroAtk()
    if p.IsBattle_TurnStage_Hero() and p.IsBattle_SubTurnStage_Atk() then
        return true;
    end
    return false;
end

--是否是敌方回合的DOT阶段
function p.IsBattleTurnEnemyDot()
    if p.IsBattle_TurnStage_Enemy() and p.IsBattle_SubTurnStage_Dot() then
        return true;
    end
    return false;
end

--是否是敌方回合的SKILL阶段
function p.IsBattleTurnEnemySkill()
    if p.IsBattle_TurnStage_Enemy() and p.IsBattle_SubTurnStage_Skill() then
        return true;
    end
    return false;
end

--是否是敌方回合的ATK阶段
function p.IsBattleTurnEnemyAtk()
    if p.IsBattle_TurnStage_Enemy() and p.IsBattle_SubTurnStage_Atk() then
        return true;
    end
    return false;
end

--获取回合数
function p.GetTurnNum()
    return p.turnNum;
end

