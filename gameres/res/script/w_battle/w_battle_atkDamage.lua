--------------------------------------------------------------
-- FileName:    w_battle_atk.lua
-- author:      csd, 2013��12��28��
-- purpose:     ��ͨ����
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
--��ͨ�����˺� = �����﹥���� + װ����������* BUFF�ٷֱȼӳ�*���Կ��ƹ�ϵ�ӳ�*�������ӳ�+�ϻ��ӳɣ�
--           �C���Է��������ֵ+�Է�װ������ֵ��* BUFF�ٷֱȼӳ�
	
	return damage,lIsJoinAtk,lIsCrit;  --�����˺�ֵ,�Ƿ�ϻ�
	
end


--�Ƿ�ϻ�
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

--�ж��Ƿ���ֱ���
function p.IsCrit(atkFighter,tarFighter)
	local lIsCrit = false;
	
	return lIsCrit;
end;


--�������Կ��� --���ľ, ľ����, ����ˮ, ˮ�˻�, ��˽� ,�ⰵ����
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



