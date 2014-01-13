--------------------------------------------------------------
-- FileName:    w_battle_atk.lua
-- author:      csd, 2013��12��28��
-- purpose:     ��ͨ����
--------------------------------------------------------------

w_battle_atkDamage = {}
local p = w_battle_atkDamage;


function p.SimpleDamage(atkFighter,tarFighter)

--�����������    	
	local lisElement = p.IsElement(atkFighter,tarFighter);
	local lpropRate = 1;
	if lisElement == true then
		lpropRate = 1.2;
	end;
	
	--����BUFF�ӳ�
	atkFighter.Buff = 1;	
	
	--�ϻ��ӳ�
	local lIsJoinAtk = p.IsJoinAtk(atkFighter,tarFighter); 
	local lJoinAtkRate = 0;
	if lIsJoinAtk == true then
		lJoinAtkRate = 0.5
	end
	
	--���㱩���ӳ�
	local lIsCrit = p.IsCrit(atkFighter,tarFighter);
	local lAddCrit = 0;	
	if lIsCrit == true then
		lAddCrit = 1;
	end;
	
	
	local damage = atkFighter.damage * atkFighter.Buff * lpropRate * (1+lAddCrit + lJoinAtkRate)
	             - tarFighter.Defence * tarFighter.Buff;
--��ͨ�����˺� = �����﹥���� + װ����������* BUFF�ٷֱȼӳ�*���Կ��ƹ�ϵ�ӳ�*�������ӳ�+�ϻ��ӳɣ�
--           �C���Է��������ֵ+�Է�װ������ֵ��* BUFF�ٷֱȼӳ�
	if damage < 0 then
		damage = 1;
	end
	
	return damage,lIsJoinAtk,lIsCrit;  --�����˺�ֵ,�Ƿ�ϻ�
	
end

--�����˺����ܼ�Ѫ
function p.SkillDamage(skillID,atkFighter,tarFighter)

--�����������    	
	local lisElement = p.IsElement(atkFighter,tarFighter);
	local lpropRate = 1;
	if lisElement == true then
		lpropRate = 1.2;
	end;
	
	--����BUFF�ӳ�
	atkFighter.Buff = 1;	
	
	--�ϻ��ӳ�
	local lIsJoinAtk = p.IsJoinAtk(atkFighter,tarFighter); 
	local lJoinAtkRate = 0;
	if lIsJoinAtk == true then
		lJoinAtkRate = 0.5
	end
	

	--��ɫ������*�˺��ٷֱ�
    local damage_percent   = tonumber( SelectCell( T_SKILL, skillID, "damage_percent" ) )/100;	
	local skillType = tonumber( SelectCell( T_SKILL, skillID, "Skill_type" ) );	
	local damage = 0;
	if skillType == W_SKILL_TYPE_1 then --�˺���
		 damage= atkFighter.damage * atkFighter.Buff * lpropRate * (1+lJoinAtkRate) * (1 + damage_percent)
					 - tarFighter.Defence * tarFighter.Buff;
	--��ͨ�����˺� = �����﹥���� + װ����������* BUFF�ٷֱȼӳ�*���Կ��ƹ�ϵ�ӳ�*�������ӳ�+�ϻ��ӳɣ�
	--           �C���Է��������ֵ+�Է�װ������ֵ��* BUFF�ٷֱȼӳ�
    elseif skillType == W_SKILL_TYPE_2 then --�ָ���
		damage= atkFighter.damage * atkFighter.Buff * (1 + damage_percent)
	end;

	if damage < 0 then
		damage = 1;
	end
	
	return damage,lIsJoinAtk;  --�����˺�ֵ,�Ƿ�ϻ�
	
end


--BUFF�˺�
function p.buffDamage(skillID,atkFighter,tarFighter)
	local buffType = tonumber( SelectCell( T_SKILL, skillID, "buff_type" ) );	
	local param = tonumber( SelectCell( T_SKILL, skillID, "param" ) )/100;	
	local damage = 0;
	if buffType == W_BUFF_TYPE_6 then --�ж�
		damage = tarFighter.maxHp * param;
	elseif buffType == W_BUFF_TYPE_7 then --ȼ��
		damage = tarFighter.maxHp * param;
	elseif buffType == W_BUFF_TYPE_9 then  --�ָ�
		damage = tarFighter.maxHp * param;
	end
	
	return damage;
	
end;

--�Ƿ�ϻ�
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

--�ж��Ƿ���ֱ���
function p.IsCrit(atkFighter,tarFighter)
	local lIsCrit = false;
	
	math.randomseed(tostring(os.time()):reverse():sub(1, 6)) 
    local lrandom = math.random(1,1000);
	if lrandom < atkFighter.Crit then  --�����ɹ�
		lIsCrit = true;
	end
		
	
	return lIsCrit;
end;


--�����Ƿ����,ֻ�п���ʱ,���мӳ�,������Ч��
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



