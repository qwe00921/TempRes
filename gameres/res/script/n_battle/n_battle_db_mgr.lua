--------------------------------------------------------------
-- FileName:    n_battle_db_mgr.lua
-- author:      hst, 2013年11月25日
-- purpose:     对战数据管理
--------------------------------------------------------------

n_battle_db_mgr = {}
local p = n_battle_db_mgr;

p.playerCardList = nil; --玩家卡牌数据
p.targetCardList = nil; --敌方卡牌数据

p.playerPetList = nil; --玩家宠物数据
p.targetPetList = nil; --敌方宠物数据

p.roundData = nil; --所有回合的对战数据
p.roundPetData = nil; --宠物所有回合的对战数据

p.battleResult = nil; --对战结果数据


--初使化对战数据
function p.Init( battleDB )
    if battleDB == nil then
    	WriteConWarning( "battle db is nill!" );
    end
    p.playerCardList = battleDB.fightinfo.Player;
    p.targetCardList = battleDB.fightinfo.Target;
    p.roundData = battleDB.fightinfo.RoundData;
    p.battleResult = battleDB.fightinfo.BattleResult;
    
    p.playerPetList = battleDB.fightinfo.PlayerPet; 
    p.targetPetList = battleDB.fightinfo.TargetPet;
    p.roundPetData = battleDB.fightinfo.PetRoundData;

    --dump_obj( p.playerPetList );
end

--获取指定回合对战数据
function p.GetRoundDB( roundIndex )
    if p.roundData == nil or N_BATTLE_MAX_ROUND < roundIndex then
    	return nil;
    end
    
    if roundIndex == N_BATTLE_ROUND_1 then
    	return p.roundData.round_1;
    elseif roundIndex == N_BATTLE_ROUND_2 then
        return p.roundData.round_2;	
    elseif roundIndex == N_BATTLE_ROUND_3 then
        return p.roundData.round_3;
    elseif roundIndex == N_BATTLE_ROUND_4 then
        return p.roundData.round_4; 
    elseif roundIndex == N_BATTLE_ROUND_5 then
        return p.roundData.round_5;
    elseif roundIndex == N_BATTLE_ROUND_6 then
        return p.roundData.round_6; 
    elseif roundIndex == N_BATTLE_ROUND_7 then
        return p.roundData.round_7; 
    elseif roundIndex == N_BATTLE_ROUND_8 then
        return p.roundData.round_8; 
    elseif roundIndex == N_BATTLE_ROUND_9 then
        return p.roundData.round_9; 
    elseif roundIndex == N_BATTLE_ROUND_10 then
        return p.roundData.round_10;   
    end
end

--获取指定回合宠物对战数据
function p.GetPetRoundDB( roundIndex )
    if p.roundPetData == nil or N_BATTLE_MAX_ROUND < roundIndex then
        return nil;
    end
    
    if roundIndex == N_BATTLE_ROUND_1 then
        return p.roundPetData.round_1;
    elseif roundIndex == N_BATTLE_ROUND_2 then
        return p.roundPetData.round_2; 
    elseif roundIndex == N_BATTLE_ROUND_3 then
        return p.roundPetData.round_3;
    elseif roundIndex == N_BATTLE_ROUND_4 then
        return p.roundPetData.round_4; 
    elseif roundIndex == N_BATTLE_ROUND_5 then
        return p.roundPetData.round_5;
    elseif roundIndex == N_BATTLE_ROUND_6 then
        return p.roundPetData.round_6; 
    elseif roundIndex == N_BATTLE_ROUND_7 then
        return p.roundPetData.round_7; 
    elseif roundIndex == N_BATTLE_ROUND_8 then
        return p.roundPetData.round_8; 
    elseif roundIndex == N_BATTLE_ROUND_9 then
        return p.roundPetData.round_9; 
    elseif roundIndex == N_BATTLE_ROUND_10 then
        return p.roundPetData.round_10;   
    end
end

--获取攻方卡牌列表
function p.GetPlayerCardList()
	return p.playerCardList;
end

--获取守方卡牌列表
function p.GetTargetCardList()
    return p.targetCardList;
end

--获取对战结果
function p.GetBattleResult()
    return p.battleResult;
end

--获取对战结果
function p.Clear()
    p.playerCardList = nil;
    p.targetCardList = nil;
    p.roundData = nil; 
    p.battleResult = nil;
end

