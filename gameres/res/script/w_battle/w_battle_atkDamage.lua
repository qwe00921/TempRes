--------------------------------------------------------------
-- FileName:    w_battle_atk.lua
-- author:      csd, 2013年12月28日
-- purpose:     普通攻击
--------------------------------------------------------------

w_battle_atkDamage = {}
local p = w_battle_atkDamage;


function p.SimpleDamage(atkFighter,tarFighter)
    	
	local lpropRate = p.CalProperty(atkFighter,tarFighter)

	
	local lIsJoinAtk = p.IsJoinAtk(tarFighter); 
	local lJoinAtkRate = 0;
	if lIsJoinAtk == true then
		lJoinAtkRate = 0.5
	end
	
	local lIsCrit = p.IsCrit(atkFighter,tarFighter);
	local lCrit = 0;
	
	
	local damage = atkFighter.damage * atkFighter.Buff * lpropRate * (1+lCrit + lJoinAtkRate)
	             - tarFighter.Defence * tarFighter.Buff;
--普通攻击伤害 = （人物攻击力 + 装备攻击力）* BUFF百分比加成*属性克制关系加成*（暴击加成+合击加成）
--           –（对方人物防御值+对方装备防御值）* BUFF百分比加成
	
	return damage,lIsJoinAtk,lIsCrit;  --返回伤害值,是否合击
	
end


--是否合击
function p.IsJoinAtk(tarFighter)

	local lIsResult = false;
	local lNowTime = os.time();
	
	if tarFighter.JoinAtkTime == nil then
		tarFighter.JoinAtkTime = lNowTime;
    elseif lNowTime - tarFighter.HitTime <= W_BATTLE_JOINATK_TIME then
	   lIsResult = true; 
    elseif lNowTime - tarFighter.HitTime > W_BATTLE_JOINATK_TIME then	
	   tarFighter.JoinAtkTime = lNowTime;	
	end
	
	return lIsResult;
end;

--判定是否出现暴击
function p.IsCrit(atkFighter,tarFighter)
	local lIsCrit = false;
	
	return lIsCrit;
end;


--计算属性克制 --金克木, 木克土, 土克水, 水克火, 火克金 ,光暗互克
function p.CalProperty(atkFighter,tarFighter)
    local lrate = 1;
    
	if     (atkFighter.prop == W_BATTLE_PROP_LIGHT  and tarFighter.prop == W_BATTLE_PROP_DARK)
		or (atkFighter.prop == W_BATTLE_PROP_DARK   and tarFighter.prop == W_BATTLE_PROP_LIGHT)
		or (atkFighter.prop == W_BATTLE_PROP_GOLD 	and tarFighter.prop == W_BATTLE_PROP_WOOD )	
		or (atkFighter.prop == W_BATTLE_PROP_WOOD 	and tarFighter.prop == W_BATTLE_PROP_WARTH)
		or (atkFighter.prop == W_BATTLE_PROP_WARTH	and tarFighter.prop == W_BATTLE_PROP_WATER)
		or (atkFighter.prop == W_BATTLE_PROP_WATER	and tarFighter.prop == W_BATTLE_PROP_FIRE )
		or (atkFighter.prop == W_BATTLE_PROP_FIRE 	and tarFighter.prop == W_BATTLE_PROP_GOLD) then
		
		lrate = 1.2
	end
		
	return lrate;
end



