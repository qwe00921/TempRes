--------------------------------------------------------------
-- FileName: 	battle_compute.lua
-- author:		¹ùºÆ 2013/11/08
-- purpose:		¼ÆËãÀà£¨µ¥Àý£©
--------------------------------------------------------------

battle_compute = {}
local p = battle_compute;

function p.DamageFromNormalAttack(kFighter_A,kFighter_B)
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
	
	return fDamage;
end