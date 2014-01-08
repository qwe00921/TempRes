--------------------------------------------------------------
-- FileName:    w_battle_atk.lua
-- author:      csd, 2013年12月28日
-- purpose:     普通攻击
--------------------------------------------------------------

w_battle_atkDamage = {}
local p = w_battle_atkDamage;


function p.SimpleDamage(atkFighter,tarFighter)

--计算属性相克    	
	local lisElement = p.IsElement(atkFighter,tarFighter);
	local lpropRate = 1;
	if lisElement == true then
		lpropRate = 1.2;
	end;
	
	--计算BUFF加成
	atkFighter.Buff = 1;	
	
	--合击加成
	local lIsJoinAtk = p.IsJoinAtk(tarFighter); 
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
	
	
	local damage = atkFighter.damage * atkFighter.Buff * lpropRate * (1+lAddCrit + lJoinAtkRate)
	             - tarFighter.Defence * tarFighter.Buff;
--普通攻击伤害 = （人物攻击力 + 装备攻击力）* BUFF百分比加成*属性克制关系加成*（暴击加成+合击加成）
--           –（对方人物防御值+对方装备防御值）* BUFF百分比加成
	if damage < 0 then
		damage = 1;
	end
	
	return damage,lIsJoinAtk,lIsCrit;  --返回伤害值,是否合击
	
end


--是否合击
function p.IsJoinAtk(tarFighter)

	local lIsResult = false;
	local lNowTime = os.time();
	
	if tarFighter.JoinAtkTime == nil then
		tarFighter.JoinAtkTime = lNowTime;
    elseif lNowTime - tarFighter.JoinAtkTime <= W_BATTLE_JOINATK_TIME then
	   lIsResult = true; 
    elseif lNowTime - tarFighter.JoinAtkTime > W_BATTLE_JOINATK_TIME then	
	   tarFighter.JoinAtkTime = lNowTime;	
	end
	
	return lIsResult;
end;

--判定是否出现暴击
function p.IsCrit(atkFighter,tarFighter)
	local lIsCrit = false;
	
	math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
    local lrandom = math.random(1,1000);
	if lrandom < atkFighter.Crit then  --暴击成功
		lIsCrit = true;
	end
		
	
	return lIsCrit;
end;


--属性是否相克,只有克制时,才有加成,被克无效果
function p.IsElement(atkFighter,tarFighter)
    local lresult = false;
    
	if     (atkFighter.prop == W_BATTLE_ELEMENT_LIGHT  and tarFighter.prop == W_BATTLE_ELEMENT_DARK)
		or (atkFighter.prop == W_BATTLE_ELEMENT_DARK   and tarFighter.prop == W_BATTLE_ELEMENT_LIGHT)
		or (atkFighter.prop == W_BATTLE_ELEMENT_GOLD 	and tarFighter.prop == W_BATTLE_ELEMENT_WOOD )	
		or (atkFighter.prop == W_BATTLE_ELEMENT_WOOD 	and tarFighter.prop == W_BATTLE_ELEMENT_EARTH)
		or (atkFighter.prop == W_BATTLE_ELEMENT_EARTH	and tarFighter.prop == W_BATTLE_ELEMENT_WATER)
		or (atkFighter.prop == W_BATTLE_ELEMENT_WATER	and tarFighter.prop == W_BATTLE_ELEMENT_FIRE )
		or (atkFighter.prop == W_BATTLE_ELEMENT_FIRE 	and tarFighter.prop == W_BATTLE_PROP_GOLD) then
		
		lresult = true;
	end
		
	return lresult;
end



