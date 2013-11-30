--------------------------------------------------------------
-- FileName:    n_battle_db_mgr.lua
-- author:      hst, 2013��11��25��
-- purpose:     ��ս���ݹ���
--------------------------------------------------------------

n_battle_db_mgr = {}
local p = n_battle_db_mgr;

p.playerCardList = nil; --��ҿ�������
p.targetCardList = nil; --��ҿ�������
p.roundData = nil; --���лغϵĶ�ս����
p.battleResult = nil; --��ս�������


--��ʹ����ս����
function p.Init( battleDB )
    if battleDB == nil then
    	WriteConWarning( "battle db is nill!" );
    end
    p.playerCardList = battleDB.fightinfo.Player;
    p.targetCardList = battleDB.fightinfo.Target;
    p.roundData = battleDB.fightinfo.RoundData;
    p.battleResult = battleDB.fightinfo.BattleResult;
    --dump_obj( p.playerCardList );
end

--��ȡ��һ�غ϶�ս����
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

--��ȡ���������б�
function p.GetPlayerCardList()
	return p.playerCardList;
end

--��ȡ�ط������б�
function p.GetTargetCardList()
    return p.targetCardList;
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



