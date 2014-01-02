--------------------------------------------------------------
-- FileName:    w_battle_db_mgr.lua
-- author:      hst, 2013年11月25日
-- purpose:     对战数据管理
--------------------------------------------------------------

w_battle_db_mgr = {}
local p = w_battle_db_mgr;

--p.playerCardList = nil; --玩家卡牌数据
--p.targetCardList = nil; --敌方卡牌数据

p.playerPetList = nil; --玩家宠物数据
p.targetPetList = nil; --敌方宠物数据

p.roundData = nil; --所有回合的对战数据
p.roundPetData = nil; --宠物所有回合的对战数据
p.roundBuffData = nil; --战士Buff数据
p.roundBuffEffectData = nil; --BUFF特效数据

p.battleResult = nil; --对战结果数据
p.rewardData = nil;

  
p.playerCardList = {
	{
	element = 0,
	UniqueId= 10000721,
	CardID= 10017,
	Level= 1,
	Level_max= 0,
	Race= 0,
	Class= 1,
	Damage_type= 1,
	Exp= 0,
	Time= 1386594904,
	Bind= 0,
	Team_marks= 0,
	Rare= 1,
	Rare_max= 0,
	Hp= 150,
	maxHp= 150,
	Attack= 30,
	Defence= 1,
	Speed= 26,
	Skill= 1007,
	Crit= 5,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Price= 0,
	Source= 0,
	Position= 1,
	Sp = 0,
	maxSp = 100;
	},
	{
	element = 0,
	UniqueId= 10000722,
	CardID= 10012,
	Level= 1,
	Level_max= 0,
	Race= 0,
	Class= 2,
	Damage_type= 1,
	Exp= 0,
	Time= 1386594904,
	Bind= 0,
	Team_marks= 0,
	Rare= 1,
	Rare_max= 0,
	Hp= 150,
	maxHp= 150,
	Attack= 30,
	Defence= 2,
	Speed= 23,
	Skill= 1008,
	Crit= 3,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Price= 0,
	Source= 0,
	Position= 2,
	Sp = 0,
	maxSp = 100
	},

	{
	element = 0,
	UniqueId= 10000723,
	CardID= 10021,
	Level= 1,
	Level_max= 0,
	Race= 0,
	Class= 3,
	Damage_type= 2,
	Exp= 0,
	Time= 1386594904,
	Bind= 0,
	Team_marks= 0,
	Rare= 1,
	Rare_max= 0,
	Hp= 150,
	maxHp= 150,
	Attack= 30,
	Defence= 1,
	Speed= 35,
	Skill= 1001,
	Crit= 12,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Price= 0,
	Source= 0,
	Position= 3,
	Sp = 0,
	maxSp = 100,
	},

	{
	element = 0,
		Sp = 0,
	maxSp = 100,
	UniqueId= 10000724,
	CardID= 10003,
	Level= 1,
	Level_max= 0,
	Race= 0,
	Class= 4,
	Damage_type= 2,
	Exp= 0,
	Time= 1386594904,
	Bind= 0,
	Team_marks= 0,
	Rare= 1,
	Rare_max= 0,
	Hp= 300,
	maxHp= 300,
	Attack= 30,
	Defence= 2,
	Speed= 32,
	Skill= 1005,
	Crit= 8,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Price= 0,
	Source= 0,
	Position= 4
	},
	{
	element = 0,
		Sp = 0,
	maxSp = 100,
	UniqueId= 10000725,
	CardID= 10022,
	Level= 1,
	Level_max= 0,
	Race= 0,
	Class= 5,
	Damage_type= 2,
	Exp= 0,
	Time= 1386594904,
	Bind= 0,
	Team_marks= 1,
	Rare= 1,
	Rare_max= 0,
	Hp= 300,
	maxHp= 300,
	Attack= 30,
	Defence= 1,
	Speed= 41,
	Skill= 1010,
	Crit= 10,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Price= 0,
	Source= 0,
	Position= 5
	}
}

p.targetCardList = {
	{
	element = 0,
	UniqueId= 2,
	CardID= 10001,
	Level= 10,
	Race= 0,
	Class= 4,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 280,
	maxHp= 280,
	Attack= 70,
	Defence= 10,
	Speed= 31,
	Skill= 0,
	Crit= 6,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Position= 1
	},
	{
	element = 0,
	UniqueId= 3,
	CardID= 10003,
	Level= 10,
	Race= 0,
	Class= 4,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 300,
	maxHp= 300,
	Attack= 70,
	Defence= 10,
	Speed= 32,
	Skill= 0,
	Crit= 8,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Position= 2
	},
	{
	element = 0,
	UniqueId= 4,
	CardID= 10004,
	Level= 10,
	Race= 0,
	Class= 2,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 290,
	maxHp= 290,
	Attack= 70,
	Defence= 10,
	Speed= 20,
	Skill= 0,
	Crit= 1,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Position= 3
	},
	{
	element = 0,
	UniqueId= 5,
	CardID= 10005,
	Level= 10,
	Race= 0,
	Class= 2,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 288,
	maxHp= 288,
	Attack= 70,
	Defence= 10,
	Speed= 23,
	Skill= 0,
	Crit= 1,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Position= 4
	},
	{
	element = 0,
	UniqueId= 6,
	CardID= 10009,
	Level= 10,
	Race= 0,
	Class= 1,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 279,
	maxHp= 279,
	Attack= 70,
	Defence= 10,
	Speed= 34,
	Skill= 0,
	Crit= 4,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Position= 5
	},
	{
	element = 0,
	UniqueId= 7,
	CardID= 10012,
	Level= 10,
	Race= 0,
	Class= 2,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 100,
	maxHp= 100,
	Attack= 70,
	Defence= 20,
	Speed= 23,
	Skill= 0,
	Crit= 3,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Position= 6
	}

}

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
    
    p.roundBuffData = battleDB.fightinfo.BuffList;
    p.roundBuffEffectData = battleDB.fightinfo.BuffEffect;
    p.rewardData = battleDB.fightinfo.Reward;

    --dump_obj( p.playerPetList );
end

--获取指定回合对战数据
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

--获取指定回合宠物对战数据
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

--获取攻方卡牌列表
function p.GetPlayerCardList()
	return p.playerCardList;
end

--获取守方卡牌列表
function p.GetTargetCardList()
    return p.targetCardList;
end

--获取攻方宠物列表
function p.GetPlayerPetList()
    return p.playerPetList;
end

--获取守方宠物列表
function p.GetTargetPetList()
    return p.targetPetList;
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

