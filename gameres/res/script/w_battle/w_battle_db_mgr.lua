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
p.roundBuffEffectData = nil; --BUFF特O效数据

p.battleResult = nil; --对战结果数据
p.rewardData = nil;
p.step = 0;      --回合结束时, 当前波次+1,调用过场动画
p.maxStep = 2;  --
p.IsDebug = false;
p.DropRandom = 0;

p.enemyStepList = {
	{
	{
	element = 1,
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
	Hp= 230,
	maxHp= 240,
	Attack= 300,
	Defence= 1,
	Speed= 26,
	Skill= 1,
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
	element = 2,
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
	Hp= 190,
	maxHp= 200,
	Attack= 1,
	Defence= 2,
	Speed= 23,
	Skill= 2,
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
	maxSp = 100,
	},

	{
	element = 3,
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
	Hp= 190,
	maxHp= 200,
	Attack= 1,
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
	element = 4,
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
	Hp= 290,
	maxHp= 300,
	Attack= 1,
	Defence= 2,
	Speed= 32,
	Skill= 1008,
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
	Hp= 290,
	maxHp= 300,
	Attack= 1,
	Defence= 1,
	Speed= 41,
	Skill= 1008,
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
	},
{
	{
	element = 1,
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
	Hp= 230,
	maxHp= 240,
	Attack= 30,
	Defence= 1,
	Speed= 26,
	Skill= 1001,
	Crit= 5,
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
	maxSp = 100,
	},
	{
	element = 2,
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
	Hp= 190,
	maxHp= 200,
	Attack= 30,
	Defence= 2,
	Speed= 23,
	Skill= 1006,
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
	element = 3,
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
	Hp= 190,
	maxHp= 200,
	Attack= 30,
	Defence= 1,
	Speed= 35,
	Skill= 1008,
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
	element = 4,
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
	Hp= 290,
	maxHp= 300,
	Attack= 30,
	Defence= 2,
	Speed= 32,
	Skill= 1002,
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
	Hp= 290,
	maxHp= 300,
	Attack= 30,
	Defence= 1,
	Speed= 41,
	Skill= 1003,
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
}
  
p.playerCardList = {
	
	{
	element = 1,
	UniqueId= 10000722,
	CardID= 10000,
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
	Hp= 190,
	maxHp= 200,
	Attack= 60,
	Defence= 2,
	Speed= 23,
	Skill= 1,
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
	Sp = 100,
	maxSp = 100
	},

	{
	element = 1,
	UniqueId= 10000723,
	CardID= 10001,
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
	Hp= 190,
	maxHp= 200,
	Attack= 60,
	Defence= 1,
	Speed= 35,
	Skill= 2,
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
	Sp = 100,
	maxSp = 100,
	},

	{
	element = 1,
	Sp = 100,
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
	Hp= 290,
	maxHp= 300,
	Attack= 60,
	Defence= 2,
	Speed= 32,
	Skill= 1001,
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
	element = 1,
	Sp = 100,
	maxSp = 100,
	UniqueId= 10000725,
	CardID= 10007,
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
	Hp= 290,
	maxHp= 300,
	Attack= 60,
	Defence= 1,
	Speed= 41,
	Skill= 1008,
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
	element = 1,
	UniqueId= 7,
	CardID= 10000,
	Level= 10,
	Race= 0,
	Class= 2,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 100,
	maxHp= 100,
	Attack= 1,
	Defence= 20,
	Speed= 23,
	Skill= 1,
	Crit= 3,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Position= 1
	},	
	
	{
	element = 2,
	UniqueId= 3,
	CardID= 10001,
	Level= 10,
	Race= 0,
	Class= 4,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 300,
	maxHp= 300,
	Attack= 1,
	Defence= 10,
	Speed= 32,
	Skill= 2,
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
	element = 3,
	UniqueId= 4,
	CardID= 10003,
	Level= 10,
	Race= 0,
	Class= 2,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 290,
	maxHp= 290,
	Attack= 1,
	Defence= 10,
	Speed= 20,
	Skill= 1001,
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
	element = 4,
	UniqueId= 5,
	CardID= 10007,
	Level= 10,
	Race= 0,
	Class= 2,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 288,
	maxHp= 288,
	Attack= 1,
	Defence= 10,
	Speed= 23,
	Skill= 1008,
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
	CardID= 10008,
	Level= 10,
	Race= 0,
	Class= 1,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 279,
	maxHp= 279,
	Attack= 1,
	Defence= 10,
	Speed= 34,
	Skill= 1001,
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
	element = 5,
	UniqueId= 2,
	CardID= 10010,
	Level= 10,
	Race= 0,
	Class= 4,
	Damage_type= 1,
	Exp= 0,
	Rare= 5,
	Rare_max= 5,
	Hp= 280,
	maxHp= 280,
	Attack= 1,
	Defence= 10,
	Speed= 31,
	Skill= 1001,
	Crit= 6,
	Item_Id1= 0,
	Item_Id2= 0,
	Item_Id3= 0,
	Gem1= 0,
	Gem2= 0,
	Gem3= 0,
	Position= 6
	},

}

p.useItemData= {}
p.ItemList = {
	{item_id = 101015, num = 5, location = 1},
	{item_id = 101016, num = 5, location = 2},
	{item_id = 101017, num = 5, location = 3},
	{item_id = 101018, num = 5, location = 4},
	{item_id = 101019, num = 5, location = 5},
}

p.Reward= {
	item= {
		item_id= 111001,
		item_type= 3,
		num= 1
	},
	mission_id= 101011,
	result= 1,
	difficulty= 1,
	exp= 100,
	money= 20,
	soul= 100,
	story= 0
}

p.Drop = { {id=1,step=1,group_id=1},
			{id=9,step=2,group_id=1},
           }

p.StepDrop = {}

function p.initUseItem(pItemList)
	for k,v in ipairs(pItemList) do
		p.useItemData[k] = 0;
	end
end;

function p.CalUseItem(pPos)
--	if p.useItemData[pPos] ~= nil then
--		p.useItemData[pPos] = p.useItemData[pPos] +1
--	end;
	
	for k,v in ipairs(p.ItemList) do
		if v.location == pPos then
			v.num = v.num - 1;
			if v.num < 0 then
				v.num = 0;
				WriteConErr("useitem error! pos="..tostring(pPos))
			end
			break;
		end
	end
	
end;

function p.GetItemId(pos)
	local litemID = nil;
	for k,v in ipairs(p.ItemList) do
		if v.location == pos then
			litemID = v.item_id;
			break;
		end
	end
	return litemID;
end;

function p.GetBattleItem()
	local itemLst = {}
--[[	if p.useItemData ~= {} then
		for k,v in ipairs(p.useItemData) do
			if v ~= 0 then
				local item_id = p.GetItemId(k);
				local lnum = v;
				local lRecord = {id=item_id, num=lnum}
				itemLst[#itemLst + 1] = lRecord
			end
		end;
	end
	]]--
	return itemLst;
end;

function p.GetBattleEndItem()
	local itemLst = {}
	local tmpLst = p.GetItemList();
	for k,v in ipairs(tmpLst) do
--		if v.num == 0 then
--			v.item_id = 0;
--		end;
		if v.item_id ~= 0 then
			local lRecord = {id=v.item_id, num=v.num}
			itemLst[#itemLst + 1] = lRecord
		end;
		
	end;
	return itemLst;
end;

function p.nextStep()
	p.step = p.step + 1;
	p.targetCardList = p.enemyStepList[p.step];
	--p.StepDrop = {};
	
--[[
    local StepDropTab = {}  
	if (w_battle_mgr.MissionDropTab ~= nil) and (#w_battle_mgr.MissionDropTab > 0) then
		for k,v in ipairs(w_battle_mgr.MissionDropTab) do  --取这一波次可能掉落的物品
			if tonumber(v.step) == p.step then
				StepDropTab[#StepDropTab + 1] = v;
			end
		end;	
	end;
	]]--
	
	
	if p.Drop ~= nil then
		local EquipDrop = {};
		local ItemDrop = {};
		local CardDrop = {};
		--local lstep = ;
		local dropItemLst = p.Drop["step"..tostring(p.step)];
		if dropItemLst ~= nil then
			for k,v in ipairs(dropItemLst) do
				if tonumber(v.item_type) == 1 then
					for i=1,v.num do
						ItemDrop[#ItemDrop + 1] = tonumber(v.item_id)
					end;
				elseif tonumber(v.item_type) == 2 then
					for i=1,v.num do
						CardDrop[#CardDrop + 1] = tonumber(v.item_id)
					end;
				elseif tonumber(v.item_type) == 3 then
					for i=1,v.num do
						EquipDrop[#EquipDrop + 1] = tonumber(v.item_id)
					end;
				end
			end
		end;
		--[[
		for i=1, #p.Drop do
			local dropItem = p.Drop[i];
			if dropItem.step == p.step then  --取出服务端下发的某个波次要掉落的groupid
				for k,v in ipairs(StepDropTab) do  --取出本地的这个次波可能掉落的东西
					if(tonumber(v.drop_group_id) == dropItem.group_id) then  --
						EquipDrop[#EquipDrop + 1] = tonumber(v.equip_drop1)
						EquipDrop[#EquipDrop + 1] = tonumber(v.equip_drop2)
						ItemDrop[#ItemDrop +1] = tonumber(v.item_drop1)
						ItemDrop[#ItemDrop +1] = tonumber(v.item_drop2)
						CardDrop[#CardDrop + 1] = tonumber(v.card_drop1)
						CardDrop[#CardDrop + 1] = tonumber(v.card_drop2)
					end;
				end
				--p.StepDrop[#p.StepDrop + 1] = dropItem.group_id;
				--SelectRowList();
			end;
		end;
]]--
		local monsterMax = #p.targetCardList;
		
		for k,v in ipairs(EquipDrop) do
			local itemid = v;
			p.DropRandom = p.DropRandom + 1
			local lrandom = w_battle_atkDamage.getRandom(p.DropRandom ,monsterMax);
			WriteCon("dropItem EquipDrop lrandom=="..tostring(lrandom));
			local lCardInfo = p.targetCardList[lrandom];
			lCardInfo.dropLst[#lCardInfo.dropLst + 1] = {dropType = E_DROP_EQUIP, id = itemid};
		end
		local lEquipDropNum = #EquipDrop * 10000;

		for k,v in ipairs(ItemDrop) do
			local itemid = v;
			p.DropRandom = p.DropRandom + 1
			local lrandom = w_battle_atkDamage.getRandom(p.DropRandom, monsterMax);
			WriteCon("dropItem ItemDrop lrandom=="..tostring(lrandom));
			local lCardInfo = p.targetCardList[lrandom];
			lCardInfo.dropLst[#lCardInfo.dropLst + 1] = {dropType = E_DROP_MATERIAL, id = itemid};
		end
		local lItemDropNum = #ItemDrop * 10000;
		
		for k,v in ipairs(CardDrop) do
			local itemid = v;
			p.DropRandom = p.DropRandom + 1
			local lrandom = w_battle_atkDamage.getRandom(p.DropRandom, monsterMax);
			WriteCon("dropItem CardDrop lrandom=="..tostring(lrandom));
			local lCardInfo = p.targetCardList[lrandom];
			lCardInfo.dropLst[#lCardInfo.dropLst + 1] = {dropType = E_DROP_CARD, id = itemid};
		end
	end;
end;

function p.initFighterDB(fighterInfo,IsHero)
	fighterInfo.maxHp = fighterInfo.Hp;
	fighterInfo.maxSp = 100;
	fighterInfo.Sp = 0;	
	fighterInfo.dropLst = {}; --掉落的物品列表
	if fighterInfo.Position == nil then
		fighterInfo.Position = fighterInfo.position;
		fighterInfo.position = nil;
	end;
end;

function p.initItem(pItemLst)
	--local litemLst = {}
	p.ItemList = {}
	for i=1,5 do
		local lrecord = {item_id = 101001, num = 0, location = i}
		p.ItemList[i] = lrecord;
	end
	
	for k,v in ipairs(pItemLst) do
		local pos = v.location;
		if pos > 0 then
			local lrecord = p.ItemList[pos];
			lrecord.item_id = v.item_id
			lrecord.num = v.num 
			lrecord.location = v.location
		end;
	end
	--return litemLst;
end;

--初使化对战数据
function p.Init( battleDB )
    if battleDB == nil then
    	WriteConWarning( "battle db is nill!" );
    end
	
	p.useItemData = {}

	--携带的物品列表
	if battleDB.fightinfo.Item ~= nil then
		p.initItem(battleDB.fightinfo.Item);
	else
		p.ItemList = {};
	end;
	p.initUseItem(p.ItemList);
	--掉落的物品
	p.Drop = battleDB.fightinfo.Drop;
	
	--玩家列表
	
	p.playerCardList = battleDB.fightinfo.Player; 


	for i=1,#p.playerCardList do
		p.initFighterDB(p.playerCardList[i],true);
	end;
	
	--怪物列表
	p.maxStep = #(battleDB.fightinfo.Target);
	p.enemyStepList = {}
	for i=1,p.maxStep do
	   local lTargetLst = battleDB.fightinfo.Target[i]; 
	   local lenemyList = {}
	   if lTargetLst.pos1 ~= nil then
			p.initFighterDB(lTargetLst.pos1);
			lenemyList[#lenemyList + 1] = lTargetLst.pos1
	   end;
	   if lTargetLst.pos2 ~= nil then
			p.initFighterDB(lTargetLst.pos2);
			lenemyList[#lenemyList + 1] = lTargetLst.pos2
	   end;
	   if lTargetLst.pos3 ~= nil then
			p.initFighterDB(lTargetLst.pos3);
			
			lenemyList[#lenemyList + 1] = lTargetLst.pos3
	   end;	
	   if lTargetLst.pos4 ~= nil then
			p.initFighterDB(lTargetLst.pos4);
			lenemyList[#lenemyList + 1] = lTargetLst.pos4
	   end;
	   if lTargetLst.pos5 ~= nil then
			p.initFighterDB(lTargetLst.pos5);
			lenemyList[#lenemyList + 1] = lTargetLst.pos5
	   end;
	   if lTargetLst.pos6 ~= nil then
			p.initFighterDB(lTargetLst.pos6);
			lenemyList[#lenemyList + 1] = lTargetLst.pos6
	   end;	
	   p.enemyStepList[i] = lenemyList;
	end
	
	p.step = 0;
	p.DropRandom = 0;
	p.nextStep();
	--p.targetCardList = enemyStepList[p.step];
   
    
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

function p.GetItemList()
	table.sort( p.ItemList, function(a,b) return a.location<b.location; end );
	return p.ItemList;
end;

function p.GetItemid(pPos)
	local lid = nil;
	for k,v in ipairs(p.ItemList) do
		if(v.location == pPos) then
			lid = v.item_id;
			break;
		end;
	end
	
	return lid;
end;

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

