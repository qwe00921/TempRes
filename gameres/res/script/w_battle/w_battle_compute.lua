--------------------------------------------------------------
-- FileName: 	battle_compute.lua
-- author:		¹ùºÆ 2013/11/08
-- purpose:		¼ÆËãÀà£¨µ¥Àý£©
--------------------------------------------------------------

battle_compute = {}
local p = battle_compute;

function p.GetFighterStrikeChance(kFighter)
	local fChance = 0.0f;
	local fLevel = kFighter.strike_level / 100.0f;

	if 0 > fLevel then
		return fChance;
	end
	
	fChance = (fLevel * 0.06f) / (fLevel * 0.06f + 1.0f);
	
	local strOut = string.format("This fighter strike chance is %f",fChance);
	WriteCon(strOut);
	
	return fChance;
end

function p.IsFighterStrike(kFighter)
	local fChance = p.GetFighterStrikeChance(kFighter);
	local nRoll = math.random(0,99);
	
	if nRoll > fChance * 100.0f then
		return false;
	end
	
	return true;
end


function p.DamageFromNormalAttack(kFighter_A,kFighter_B,bStrike)
	if nil == kFighter_A or nil == kFighter_B then
		WriteCon("kFighter_A or kFighter_B is nil");
		return 0.0f;
	end
	
	local fDamage = 0.0f;
	local fDef = kFighter_B.defence;
	local fAtk = math.random(kFighter_B.attack_min,kFighter_B.attack_max);
	
	fDamage = fAtk * (1.0f - (fDef * 0.06f) / (fDef * 0.06 + 1.0f));
	
	if 0.0f > fDamage then
		fDamage = 0.0f;
	end
	
	if bStrike then
		fDamage = fDamage * 2;
		local strOut = string.format("Strike!!Damage is %f",fDamage);
		WriteCon(strOut);
	end
	
	return math.floor(fDamage);
end