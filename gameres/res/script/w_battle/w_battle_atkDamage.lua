--------------------------------------------------------------
-- FileName:    w_battle_atk.lua
-- author:      csd, 2013年12月28日
-- purpose:     普通攻击
--------------------------------------------------------------

w_battle_atkDamage = {}
local p = w_battle_atkDamage;


function p.SimpleDamage(atkFighter,tarFighter, IsMonster)

--计算属性相克    	
	local lisElement = p.IsElement(atkFighter,tarFighter);
	local lpropRate = 1;
	if lisElement == true then
		lpropRate = 1.2;
	end;
	
	--计算BUFF加成
	--atkFighter.Buff = 1;	
	
	--合击加成
	local lIsJoinAtk = false
	if IsMonster ~= true then
		lIsJoinAtk = p.IsJoinAtk(atkFighter,tarFighter); 
	end;
	local lJoinAtkRate = 0;
	if lIsJoinAtk == true then
		lJoinAtkRate = 0.5
	end
	
	--计算暴击加成
	local lIsCrit = p.IsCrit(atkFighter,tarFighter);
	local lAddCrit = 0;	
	if lIsCrit == true then
		lAddCrit = 1;
	end;
	
	
	local damage = atkFighter.damage * atkFighter.atkBuff * lpropRate * (1+lAddCrit + lJoinAtkRate)
	             - tarFighter.Defence * tarFighter.defBuff;
--普通攻击伤害 = （人物攻击力 + 装备攻击力）* BUFF百分比加成*属性克制关系加成*（暴击加成+合击加成）
--           –（对方人物防御值+对方装备防御值）* BUFF百分比加成
	if damage < 0 then
		damage = 1;
	end
	
	return damage,lIsJoinAtk,lIsCrit;  --返回伤害值,是否合击
	
end

--技能伤害或技能加血
function p.SkillDamage(skillID,atkFighter,tarFighter)

--计算属性相克    	
	local lisElement = p.IsElement(atkFighter,tarFighter);
	local lpropRate = 1;
	if lisElement == true then
		lpropRate = 1.2;
	end;
	
	--计算BUFF加成
	atkFighter.Buff = 1;	
	
	--合击加成
	local lIsJoinAtk = p.IsJoinAtk(atkFighter,tarFighter); 
	local lJoinAtkRate = 0;
	if lIsJoinAtk == true then
		lJoinAtkRate = 0.5
	end
	

	--角色攻击力*伤害百分比
    local damage_percent   = tonumber( SelectCell( T_SKILL, skillID, "damage_percent" ) )/100;	
	local skillType = tonumber( SelectCell( T_SKILL, skillID, "Skill_type" ) );	
	local damage = 0;
	if skillType == W_SKILL_TYPE_1 then --伤害类
		 damage= atkFighter.damage * atkFighter.atkBuff * lpropRate * (1+lJoinAtkRate) * (1 + damage_percent)
					 - tarFighter.Defence * tarFighter.defBuff;
	--普通攻击伤害 = （人物攻击力 + 装备攻击力）* BUFF百分比加成*属性克制关系加成*（暴击加成+合击加成）
	--           –（对方人物防御值+对方装备防御值）* BUFF百分比加成
    elseif skillType == W_SKILL_TYPE_2 then --恢复类
		damage= atkFighter.damage * (1 + damage_percent)
	end;

	if damage < 0 then
		damage = 1;
	end
	
	return damage,lIsJoinAtk;  --返回伤害值,是否合击
	
end

function p.SkillBuffDamage(skillID, atkFighter)
  local damage_percent   = tonumber( SelectCell( T_SKILL, skillID, "damage_percent" ) )/100;	
  local	damage= atkFighter.damage * (1 + damage_percent)	

  return damage;
end;

--BUFF伤害
function p.buffDamage(skillID,atkFighter,tarFighter)
	local buffType = tonumber( SelectCell( T_SKILL, skillID, "buff_type" ) );	
	local param = tonumber( SelectCell( T_SKILL, skillID, "param" ) )/100;	
	local damage = 0;
	if buffType == W_BUFF_TYPE_6 then --中毒
		damage = tarFighter.maxHp * param;
	elseif buffType == W_BUFF_TYPE_7 then --燃烧
		damage = tarFighter.maxHp * param;
	elseif buffType == W_BUFF_TYPE_9 then  --恢复
		damage = tarFighter.maxHp * param;
	end
	
	return damage;
	
end;

--是否合击
function p.IsJoinAtk(atkFighter,tarFighter)

	local lIsResult = false;
	local lNowTime = os.time();
	
	if tarFighter.JoinAtkTime == nil then
		tarFighter.JoinAtkTime = lNowTime;
		tarFighter.firstID = atkFighter:GetId();
    elseif lNowTime - tarFighter.JoinAtkTime <= W_BATTLE_JOINATK_TIME then
	   lIsResult = true; 
    elseif lNowTime - tarFighter.JoinAtkTime > W_BATTLE_JOINATK_TIME then	
	   tarFighter.JoinAtkTime = lNowTime;	
	   tarFighter.firstID = atkFighter:GetId();
	end
	
	return lIsResult;
end;



--判定是否出现暴击
function p.IsCrit(atkFighter,tarFighter)
	local lIsCrit = false;
	
    local lrandom = p.getRandom(atkFighter:GetId(),1000);
	if lrandom < atkFighter.Crit * atkFighter.critBuff then  --暴击成功
		lIsCrit = true;
	end
	
	return lIsCrit;
end;


--属性是否相克,只有克制时,才有加成,被克无效果
function p.IsElement(atkFighter,tarFighter)
    local lresult = false;
    
	if     ((atkFighter.element == W_BATTLE_ELEMENT_LIGHT)   and (tarFighter.element == W_BATTLE_ELEMENT_DARK) )
		or ((atkFighter.element == W_BATTLE_ELEMENT_DARK)    and (tarFighter.element == W_BATTLE_ELEMENT_LIGHT) )
		or ((atkFighter.element == W_BATTLE_ELEMENT_GOLD)    and (tarFighter.element == W_BATTLE_ELEMENT_WOOD ) )
		or ((atkFighter.element == W_BATTLE_ELEMENT_WOOD)    and (tarFighter.element == W_BATTLE_ELEMENT_EARTH) )
		or ((atkFighter.element == W_BATTLE_ELEMENT_EARTH)   and (tarFighter.element == W_BATTLE_ELEMENT_WATER) )
		or ((atkFighter.element == W_BATTLE_ELEMENT_WATER)   and (tarFighter.element == W_BATTLE_ELEMENT_FIRE ) )
		or ((atkFighter.element == W_BATTLE_ELEMENT_FIRE)    and (tarFighter.element == W_BATTLE_ELEMENT_GOLD) ) then
		
		lresult = true;
	end
		
	return lresult;
end

--传入质数,随机计算
function p.getRandom(seed,maxnum)
	local ptab= {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,49};
	local lseednum = ptab[seed];
	local lallseed = tonumber(tostring(os.time()):reverse():sub(1, 6)) + lseednum * 10000;
	
	math.randomseed(lallseed) 
	local lnum = math.random(1,maxnum);
	local lnum = math.random(1,maxnum);
	local lnum = math.random(1,maxnum);
	local lnum = math.random(1,maxnum);
	return lnum;
end;

function p.getdropitemNum(pTab,seed)
	local lrandomNum = p.getRandom(seed,100);
	--WriteCon("dropitemnum seed="..tostring(seed).." num="..tostring(lrandomNum));
	
	local lpro1 = 0;
	local lnum1 = 0;
	if pTab.probility1 ~= "" then
		lpro1 = tonumber(pTab.probility1)
		lnum1 = tonumber(pTab.drop_num1);	
	end;
	
	local lpro2 = 0;
	local lnum2 = 0;
	if pTab.probility2 ~= "" then
		lpro2 = tonumber(pTab.probility2) + lpro1;
		lnum2 = tonumber(pTab.drop_num2);	
    end;
	
	local lpro3 = 0;
	local lnum3 = 0;
	if pTab.probility3 ~= "" then
		lpro3 = tonumber(pTab.probility3) + lpro2;
		lnum3 = tonumber(pTab.drop_num3);	
    end;
	
	
	if (pTab.probility1 ~= "") and (lrandomNum <= lpro1) then
		return tonumber(pTab.drop_num1);
	elseif (pTab.probility2 ~= "") and (lrandomNum > lpro1) and (lrandomNum <= lpro2) then
		return tonumber(pTab.drop_num2);
	elseif (pTab.probility3 ~= "") and (lrandomNum > lpro2) and (lrandomNum <= lpro3) then
		return tonumber(pTab.drop_num3);
	else
		return 0
	end
	
end;


function p.getDropItem(dropList, pos, atktype)
	local lhpnum = 0;
	local lspnum = 0;
	local lmoneynum = 0;
	local lbluesoulnum = 0;
	local ldropTab = SelectRowList( T_DROP_POBILITY, "attack_type",  atktype);		
	for k,v in pairs(ldropTab) do
		if tonumber(v.drop_type) == E_DROP_HPBALL then
			lhpnum = p.getdropitemNum(v,pos );
		elseif tonumber(v.drop_type) == E_DROP_SPBALL then
			lspnum = p.getdropitemNum(v,pos + 1);
		elseif tonumber(v.drop_type) == E_DROP_MONEY then
			lmoneynum = p.getdropitemNum(v,pos + 2);
		elseif tonumber(v.drop_type) == E_DROP_BLUESOUL then
			lbluesoulnum = p.getdropitemNum(v,pos + 3) ;
		end
	end
	
	if lhpnum > 0 then
		dropList[#dropList + 1] = {E_DROP_HPBALL , lhpnum, pos};
		w_battle_mgr.AddBall(E_DROP_HPBALL,lhpnum);
	--	WriteCon("Hp ="..tostring(lhpnum));
	end
	
	if lspnum > 0 then
		dropList[#dropList + 1] = {E_DROP_SPBALL , lspnum, pos};
		w_battle_mgr.AddBall(E_DROP_SPBALL,lspnum);
	--	WriteCon("Sp ="..tostring(lspnum));
	end
	
	if lmoneynum > 0 then
		dropList[#dropList + 1] = {E_DROP_MONEY , lmoneynum, pos};
	--	WriteCon("Moneynum ="..tostring(lmoneynum));
	end

	if lbluesoulnum > 0 then
		dropList[#dropList + 1] = {E_DROP_BLUESOUL , lbluesoulnum, pos};
	--	WriteCon("bluesoul ="..tostring(lbluesoulnum));
	end	

	
end;


function p.getitem(pos, IsSkill, lIsCrit,lIsJoinAtk,lisMoredamage)
	
	local dropList = {}
	if IsSkill == false then
		p.getDropItem(dropList, pos, W_DROP_ATKTYPE1)
    else
		p.getDropItem(dropList, pos, W_DROP_ATKTYPE2)
	end; 

	if lIsCrit == true then
		p.getDropItem(dropList, pos, W_DROP_ATKTYPE3)
	end;
	
	if lIsJoinAtk == true then
		p.getDropItem(dropList, pos, W_DROP_ATKTYPE4)
	end;
	
	if lisMoredamage == true then
		p.getDropItem(dropList, pos, W_DROP_ATKTYPE5)
	end
	
	w_battle_pve.MonsterDrop(dropList)
	
end



