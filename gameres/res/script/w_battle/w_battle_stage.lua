--------------------------------------------------------------
-- FileName:    n_battle_stage.lua
-- author:      hst, 2013年11月26日
-- purpose:     战斗状态
--------------------------------------------------------------

n_battle_stage = {}
local p = n_battle_stage;

p.roundNum = 0;                 --战斗回合数
p.battleStage = 0;              --对战阶段,共1~4个阶段:加载阶段,永久BUFF阶段,回合阶段,结束阶段
p.battleRoundStage = 0;         --回合阶段,共4个子阶段:召唤兽,BUFF表现,互殴，结算

--初使化
function p.Init()
    p.roundNum = 1;                  
    p.battleStage = 0;              
    p.battleRoundStage = 0;      
end

--进入下一个回合
function p.NextRound()
   p.roundNum = p.roundNum + 1;
end

--获取回合数
function p.GetRoundNum()
    return p.roundNum;
end

--------------------------------------------------------------
--对战的各种阶段管理
--------------------------------------------------------------

--战斗阶段->加载
function p.EnterBattle_Stage_Loading()
    p.battleStage = N_BATTLE_STAGE_LOADING;
end

--战斗阶段->永久BUFF表现
function p.EnterBattle_Stage_Permanent_Buff()
    p.battleStage = N_BATTLE_STAGE_PERMANENT_BUFF;
end

--战斗阶段->回合
function p.EnterBattle_Stage_Round()
    p.battleStage = N_BATTLE_STAGE_ROUND;
end

--战斗阶段->结束
function p.EnterBattle_Stage_End()
    p.battleStage = N_BATTLE_STAGE_END;
end

--------------------------------------------------------------
--进入互殴阶段的回合阶段管理
--------------------------------------------------------------

--回合阶段->召唤兽 
function p.EnterBattle_RoundStage_Pet()
    p.battleRoundStage = N_BATTLE_ROUND_STAGE_PET;
end

--回合阶段->BUFF表现
function p.EnterBattle_RoundStage_Buff()
    p.battleRoundStage = N_BATTLE_ROUND_STAGE_BUFF;
end

--回合阶段->互殴
function p.EnterBattle_RoundStage_Atk()
    p.battleRoundStage = N_BATTLE_ROUND_STAGE_ATK;
end

--回合阶段->结算
function p.EnterBattle_RoundStage_Clearing()
    p.battleRoundStage = N_BATTLE_ROUND_STAGE_CLEARING;
end

--------------------------------------------------------------
--对战的各种阶段的判断
--------------------------------------------------------------

--是否是战斗加载阶段
function p.IsBattle_Stage_Loading()
    if p.battleStage == N_BATTLE_STAGE_LOADING then
        return true;
    end
    return false;
end

--是否是战斗永久BUFF阶段
function p.IsBattle_Stage_Permanent_Buff()
    if p.battleStage == N_BATTLE_STAGE_PERMANENT_BUFF then
        return true;
    end
    return false;
end

--是否是战斗回合阶段
function p.IsBattle_Stage_Round()
    if p.battleStage == N_BATTLE_STAGE_ROUND then
        return true;
    end
    return false;
end

--是否是战斗结束阶段
function p.IsBattle_Stage_End()
    if p.battleStage == N_BATTLE_STAGE_END then
        return true;
    end
    return false;
end

--------------------------------------------------------------
--回合的各种阶段的判断
--------------------------------------------------------------

--是否是互殴阶段召唤兽表现
function p.IsBattle_RoundStage_Pet()
    if p.battleRoundStage == N_BATTLE_ROUND_STAGE_PET then
        return true;
    end
    return false;
end

--是否是互殴阶段BUFF表现
function p.IsBattle_RoundStage_Buff()
    if p.battleRoundStage == N_BATTLE_ROUND_STAGE_BUFF then
        return true;
    end
    return false;
end

--是否是互殴阶段BUFF表现
function p.IsBattle_RoundStage_Atk()
    if p.battleRoundStage == N_BATTLE_ROUND_STAGE_ATK then
        return true;
    end
    return false;
end

--是否是互殴阶段结算
function p.IsBattle_RoundStage_Clearing()
    if p.battleRoundStage == N_BATTLE_ROUND_STAGE_CLEARING then
        return true;
    end
    return false;
end


