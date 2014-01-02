--------------------------------------------------------------
-- FileName:    w_battle_db_mgr.lua
-- author:      hst, 2013��11��25��
-- purpose:     ��ս���ݹ���
--------------------------------------------------------------

w_battle_db_mgr = {}
local p = w_battle_db_mgr;

p.playerCardList = nil; --��ҿ�������
p.targetCardList = nil; --�з���������

p.playerPetList = nil; --��ҳ�������
p.targetPetList = nil; --�з���������

p.roundData = nil; --���лغϵĶ�ս����
p.roundPetData = nil; --�������лغϵĶ�ս����
p.roundBuffData = nil; --սʿBuff����
p.roundBuffEffectData = nil; --BUFF��Ч����

p.battleResult = nil; --��ս�������
p.rewardData = nil;

--��ʹ����ս����
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
    
    p.roundBuffData = battleDB.fightinfo.BuffList;
    p.roundBuffEffectData = battleDB.fightinfo.BuffEffect;
    p.rewardData = battleDB.fightinfo.Reward;

    --dump_obj( p.playerPetList );
end

--��ȡָ���غ϶�ս����
function p.GetRoundDB( roundIndex )
    if p.roundData == nil or W_BATTLE_MAX_ROUND < roundIndex then
    	return nil;
    end
    
    if roundIndex == W_BATTLE_ROUND_1 then
    	return p.roundData.round_1;
    elseif roundIndex == W_BATTLE_ROUND_2 then
        return p.roundData.round_2;	
    elseif roundIndex == W_BATTLE_ROUND_3 then
        return p.roundData.round_3;
    elseif roundIndex == W_BATTLE_ROUND_4 then
        return p.roundData.round_4; 
    elseif roundIndex == W_BATTLE_ROUND_5 then
        return p.roundData.round_5;
    elseif roundIndex == W_BATTLE_ROUND_6 then
        return p.roundData.round_6; 
    elseif roundIndex == W_BATTLE_ROUND_7 then
        return p.roundData.round_7; 
    elseif roundIndex == W_BATTLE_ROUND_8 then
        return p.roundData.round_8; 
    elseif roundIndex == W_BATTLE_ROUND_9 then
        return p.roundData.round_9; 
    elseif roundIndex == W_BATTLE_ROUND_10 then
        return p.roundData.round_10;   
    end
end

--��ȡָ���غϳ����ս����
function p.GetPetRoundDB( roundIndex )
    if p.roundPetData == nil or W_BATTLE_MAX_ROUND < roundIndex then
        return nil;
    end
    
    if roundIndex == W_BATTLE_ROUND_1 then
        return p.roundPetData.round_1;
    elseif roundIndex == W_BATTLE_ROUND_2 then
        return p.roundPetData.round_2; 
    elseif roundIndex == W_BATTLE_ROUND_3 then
        return p.roundPetData.round_3;
    elseif roundIndex == W_BATTLE_ROUND_4 then
        return p.roundPetData.round_4; 
    elseif roundIndex == W_BATTLE_ROUND_5 then
        return p.roundPetData.round_5;
    elseif roundIndex == W_BATTLE_ROUND_6 then
        return p.roundPetData.round_6; 
    elseif roundIndex == W_BATTLE_ROUND_7 then
        return p.roundPetData.round_7; 
    elseif roundIndex == W_BATTLE_ROUND_8 then
        return p.roundPetData.round_8; 
    elseif roundIndex == W_BATTLE_ROUND_9 then
        return p.roundPetData.round_9; 
    elseif roundIndex == W_BATTLE_ROUND_10 then
        return p.roundPetData.round_10;   
    end
end

function p.GetBuffRoundDB( roundIndex)
    if p.roundBuffData == nil or W_BATTLE_MAX_ROUND < roundIndex then
        return nil;
    end
    if roundIndex == W_BATTLE_ROUND_1 then
        return p.roundBuffData.round_1;
    elseif roundIndex == W_BATTLE_ROUND_2 then
        return p.roundBuffData.round_2; 
    elseif roundIndex == W_BATTLE_ROUND_3 then
        return p.roundBuffData.round_3;
    elseif roundIndex == W_BATTLE_ROUND_4 then
        return p.roundBuffData.round_4; 
    elseif roundIndex == W_BATTLE_ROUND_5 then
        return p.roundBuffData.round_5;
    elseif roundIndex == W_BATTLE_ROUND_6 then
        return p.roundBuffData.round_6; 
    elseif roundIndex == W_BATTLE_ROUND_7 then
        return p.roundBuffData.round_7; 
    elseif roundIndex == W_BATTLE_ROUND_8 then
        return p.roundBuffData.round_8; 
    elseif roundIndex == W_BATTLE_ROUND_9 then
        return p.roundBuffData.round_9; 
    elseif roundIndex == W_BATTLE_ROUND_10 then
        return p.roundBuffData.round_10;   
    end
end

function p.GetBuffEffectRoundDB( roundIndex)
    if p.roundBuffEffectData == nil or W_BATTLE_MAX_ROUND < roundIndex then
        return nil;
    end
    if roundIndex == W_BATTLE_ROUND_1 then
        return p.roundBuffEffectData.round_1;
    elseif roundIndex == W_BATTLE_ROUND_2 then
        return p.roundBuffEffectData.round_2; 
    elseif roundIndex == W_BATTLE_ROUND_3 then
        return p.roundBuffEffectData.round_3;
    elseif roundIndex == W_BATTLE_ROUND_4 then
        return p.roundBuffEffectData.round_4; 
    elseif roundIndex == W_BATTLE_ROUND_5 then
        return p.roundBuffEffectData.round_5;
    elseif roundIndex == W_BATTLE_ROUND_6 then
        return p.roundBuffEffectData.round_6; 
    elseif roundIndex == W_BATTLE_ROUND_7 then
        return p.roundBuffEffectData.round_7; 
    elseif roundIndex == W_BATTLE_ROUND_8 then
        return p.roundBuffEffectData.round_8; 
    elseif roundIndex == W_BATTLE_ROUND_9 then
        return p.roundBuffEffectData.round_9; 
    elseif roundIndex == W_BATTLE_ROUND_10 then
        return p.roundBuffEffectData.round_10;   
    end
end

function p.GetRewardData()
	return p.rewardData;
end

--��ȡ���������б�
function p.GetPlayerCardList()
	return p.playerCardList;
end

--��ȡ�ط������б�
function p.GetTargetCardList()
    return p.targetCardList;
end

--��ȡ���������б�
function p.GetPlayerPetList()
    return p.playerPetList;
end

--��ȡ�ط������б�
function p.GetTargetPetList()
    return p.targetPetList;
end

--��ȡ��ս���
function p.GetBattleResult()
    return p.battleResult;
end

--��ȡ��ս���
function p.Clear()
    p.playerCardList = nil;
    p.targetCardList = nil;
    p.roundData = nil; 
    p.battleResult = nil;
end
