--------------------------------------------------------------
-- FileName:    w_battle_atk.lua
-- author:      csd, 2013��12��28��
-- purpose:     ��ͨ����
--------------------------------------------------------------

w_battle_atkDamage = {}
local p = w_battle_atkDamage;


function p.SimpleDamage(atkFighter,tarFighter, IsMonster)

--�����������    	
	local lisElement = p.IsElement(atkFighter,tarFighter);
	local lpropRate = 1;
	if lisElement == true then
		lpropRate = 1.2;
	end;
	
	--����BUFF�ӳ�
	--atkFighter.Buff = 1;	
	
	--�ϻ��ӳ�
	local lIsJoinAtk = false
	if IsMonster ~= true then
		lIsJoinAtk = p.IsJoinAtk(atkFighter,tarFighter); 
	end;
	
	if w_battle_mgr.atkCampType == W_BATTLE_ENEMY then
		lIsJoinAtk = false;
	end;
	
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

	local latkDamage = atkFighter.damage;

	if (w_battle_guid.IsGuid == true) and (w_battle_guid.guidstep == 3) then
		if w_battle_db_mgr.step == 1 or w_battle_db_mgr.step == 2 then
			if w_battle_mgr.atkCampType == W_BATTLE_ENEMY then
				latkDamage = latkDamage/2;
			end;
		end;
	end 

	if (w_battle_guid.IsGuid == true) and (w_battle_guid.guidstep == 5) then
		if w_battle_db_mgr.step == 3 then
			if w_battle_mgr.atkCampType == W_BATTLE_ENEMY then
				latkDamage = latkDamage*4;
			else
				latkDamage = latkDamage/5
			end;
		end;
	end 
	

	
	
	local damage = latkDamage * atkFighter.atkBuff * lpropRate * (1+lAddCrit + lJoinAtkRate)
	             - tarFighter.Defence * tarFighter.defBuff;
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
	local skillType = tonumber( SelectCell( T_SKILL, skillID, "skill_type" ) );	
	local damage = 0;
	
	local latkDamage = atkFighter.damage;
	if (w_battle_guid.IsGuid == true) and (w_battle_guid.guidstep == 5) then
		if w_battle_db_mgr.step == 3 then
			if w_battle_mgr.atkCampType == W_BATTLE_ENEMY then
				latkDamage = latkDamage*10;
			else
				latkDamage = latkDamage/5
			end;
		end;
	end 	
	
	if skillType == W_SKILL_TYPE_1 then --�˺���
		 damage= latkDamage * atkFighter.atkBuff * lpropRate * (1+lJoinAtkRate) * (damage_percent)
					 - tarFighter.Defence * tarFighter.defBuff;
	--��ͨ�����˺� = �����﹥���� + װ����������* BUFF�ٷֱȼӳ�*���Կ��ƹ�ϵ�ӳ�*�������ӳ�+�ϻ��ӳɣ�
	--           �C���Է��������ֵ+�Է�װ������ֵ��* BUFF�ٷֱȼӳ�
    elseif skillType == W_SKILL_TYPE_2 then --�ָ���
		damage= latkDamage * (1 + damage_percent)
	end;

	if damage < 0 then
		damage = 1;
	end
	
	return damage,lIsJoinAtk;  --�����˺�ֵ,�Ƿ�ϻ�
	
end

function p.SkillBuffDamage(skillID, atkFighter)
  local damage_percent   = tonumber( SelectCell( T_SKILL, skillID, "damage_percent" ) )/100;	
  local	damage= atkFighter.damage * (1 + damage_percent)	

  return damage;
end;

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
	elseif (w_battle_guid.IsGuid == true) and (w_battle_guid.guidstep == 3) 
		and (w_battle_db_mgr.step == 1) and (w_battle_guid.substep == 5 ) then
		lIsResult = true;  --����ս���ĵ�һ���ĵ�һ������ʱ�䳤�̶��ܺϻ�
    elseif lNowTime - tarFighter.JoinAtkTime > W_BATTLE_JOINATK_TIME then	
	   tarFighter.JoinAtkTime = lNowTime;	
	   tarFighter.firstID = atkFighter:GetId();
	end
	
	return lIsResult;
end;



--�ж��Ƿ���ֱ���
function p.IsCrit(atkFighter,tarFighter)
	local lIsCrit = false;
	
    local lrandom = p.getRandom(atkFighter:GetId(),1000);
	if lrandom < atkFighter.Crit * atkFighter.critBuff then  --�����ɹ�
		lIsCrit = true;
	end
	
	return lIsCrit;
end;


--�����Ƿ����,ֻ�п���ʱ,���мӳ�,������Ч��
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

--��������,�������
function p.getRandom(seed,maxnum)
	local ptab= {2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,49};
	local lseednum = 0;
	local ptabNum = #ptab 
	if seed > #ptab then
		seed = math.mod(seed, ptabNum);
	end;
	
	lseednum = ptab[seed];		
	
	

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
	
	if (w_battle_guid.IsGuid == true) and (w_battle_guid.guidstep == 3) then
		lspnum = 0;
		if w_battle_guid.substep <= 9 then
			lhpnum = 0;
		end
	end;	
	--if w_battle_guid.IsGuid == false then
		if lhpnum > 0 then
			dropList[#dropList + 1] = {E_DROP_HPBALL , lhpnum, pos};
			w_battle_mgr.AddBall(E_DROP_HPBALL,lhpnum);
		end
		
		if lspnum > 0 then
			dropList[#dropList + 1] = {E_DROP_SPBALL , lspnum, pos};
			w_battle_mgr.AddBall(E_DROP_SPBALL,lspnum);
		end
		
		if lmoneynum > 0 then
			dropList[#dropList + 1] = {E_DROP_MONEY , lmoneynum, pos};
			w_battle_mgr.battleMoney = w_battle_mgr.battleMoney + lmoneynum
		end

		if lbluesoulnum > 0 then
			dropList[#dropList + 1] = {E_DROP_BLUESOUL , lbluesoulnum, pos};
			w_battle_mgr.battleSoul = w_battle_mgr.battleSoul + lbluesoulnum;
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



