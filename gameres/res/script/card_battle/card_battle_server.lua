--------------------------------------------------------------
-- FileName: 	card_battle_server.lua
-- author:		hst, 2013��9��6��
-- purpose:		���ƶ�ս����ģ��
--------------------------------------------------------------

card_battle_server = {}
local p = card_battle_server;

p.heroCamp = nil; --Ӣ�۷���Ӫ����
p.enemyCamp = nil;--�з���Ӫ����

--��ʹ��Ӣ�ۡ��з� ��Ӫ����
function p.InitDB()
	p.heroCamp = card_battle_mgr.heroCamp;
    p.enemyCamp = card_battle_mgr.enemyCamp;
end

--���ֽ׶�����
function p.GetHandStageData( camp )
	local t = {};
	local heroes = p.heroCamp:GetAliveFighters();
    local enemies = p.enemyCamp:GetAliveFighters();
    
    --Ӣ�۷����ֽ׶μ���
    if camp == E_CARD_CAMP_HERO then
    	for k, v in ipairs(heroes) do
            local tempT = {};
            if true and math.random( 1, 3 ) == 1 then
                tempT.card_id = v.idFighter;
                tempT.skill_id = math.random( 1, 3 );
                tempT.work_time = 3;
                tempT.camp = E_CARD_CAMP_HERO;
                tempT.buff_effect = math.random( 1, 3 );
                tempT.buff_result = 1;
                tempT.targets = {};
                local addValue = math.random( 50, 100 );
                for i=1, #heroes do
                    tempT.targets[i] = {};
                    tempT.targets[i].card_id = heroes[i].idFighter;
                    tempT.targets[i].value = addValue;
                    tempT.targets[i].camp = E_CARD_CAMP_HERO;
                end
                t[#t + 1] = tempT;
            end
        end
    end
    
    if camp == E_CARD_CAMP_ENEMY then
        for k, v in ipairs(enemies) do
            local tempT = {};
            if math.random( 1, 3 ) == 1 then
                tempT.card_id = v.idFighter;
                tempT.skill_id = math.random( 1, 3 );
                tempT.work_time = 3;
                tempT.camp = E_CARD_CAMP_ENEMY;
                tempT.buff_effect = math.random( 1, 3 );
                tempT.buff_result = 1;
                tempT.targets = {};
                local addValue = math.random( 50, 100 );
                for i=1, #enemies do
                    tempT.targets[i] = {};
                    tempT.targets[i].card_id = enemies[i].idFighter;
                    tempT.targets[i].value = addValue;
                    tempT.targets[i].camp = E_CARD_CAMP_ENEMY;
                end
                t[#t + 1] = tempT;
            end
        end
    end
	
	--�з����ֽ׶μ���
	
    return t;
end

--����DOT�˺����ݣ�Ӣ�۷��͵з���
function p.GetDotData( camp )
    --��ȡӢ�۷���DOT�˺�����
	if camp == E_CARD_CAMP_HERO then
	
	--��ȡ�з���DOT�˺�����
	elseif camp == E_CARD_CAMP_ENEMY then	
	
	end
end

--������쿨�ƿ��Է�����������
function p.GetSkillData( camp, fighterId )
    local t = {};
    local atkFighters;   --����������Ӫ
    local defFighters;   --�ط���Ӫ
    
    --��ȡӢ�۷���skill����
    if camp == E_CARD_CAMP_HERO then
        atkFighters = p.heroCamp:GetAliveFighters();
        defFighters = p.enemyCamp:GetAliveFighters();
        
    --��ȡ�з���skill����
    elseif camp == E_CARD_CAMP_ENEMY then   
        atkFighters = p.enemyCamp:GetAliveFighters();
        defFighters = p.heroCamp:GetAliveFighters();
    end
    
    --�����Ӣ�۷����ֶ�����
    if fighterId ~= nil then
        atkFighters = {};
        local skillFighter = p.heroCamp:FindFighter( fighterId );
        atkFighters[1] = skillFighter;
    end
    
    for k, v in ipairs(atkFighters) do
        if v.skillnum == 0 then
            local tempT = {};
        	tempT.card_id = v.idFighter;
            tempT.skill_id = math.random( 1, 3 );
            if camp == E_CARD_CAMP_HERO then
                tempT.camp = E_CARD_CAMP_HERO;
            elseif camp == E_CARD_CAMP_ENEMY then
                tempT.camp = E_CARD_CAMP_ENEMY;
            end
            tempT.targets = {};
            
            for j=1, math.random( 1, #defFighters ) do
                local _t = {};
                _t.card_id =defFighters[j].idFighter;
                _t.value = math.random( 120,200 );
                if camp == E_CARD_CAMP_HERO then
                    _t.camp = E_CARD_CAMP_ENEMY;
                elseif camp == E_CARD_CAMP_ENEMY then
                    _t.camp = E_CARD_CAMP_HERO;
                end
                
                tempT.targets[#tempT.targets+1] = _t;
            end
            t[#t+1] = tempT;
        end
    end
    return t;   
end


--���쿨����ͨ�������ݣ�Ӣ�۷��͵з���
function p.GetAtkData( camp )
    local t = {};
    local atkFighter;   --������
    local defFighter;   --���ط�
    
	--��ȡӢ�۷���atk����
    if camp == E_CARD_CAMP_HERO then
        atkFighter = p.heroCamp:GetAliveFighters();
        defFighter = p.enemyCamp:GetAliveFighters();
        
    --��ȡ�з���atk����
    elseif camp == E_CARD_CAMP_ENEMY then   
        atkFighter = p.enemyCamp:GetAliveFighters();
        defFighter = p.heroCamp:GetAliveFighters();
    end
    if #atkFighter <= 0 or #defFighter <= 0 then
    	return t;
    end
    for k, v in ipairs(atkFighter) do
        local tempT = {};
        local targetFighter = defFighter[ math.random( 1, #defFighter ) ];
        tempT.card_id = v.idFighter;
        tempT.target_id = targetFighter.idFighter;
        tempT.value = math.random( 70,150 );
        t[#t + 1] = tempT ;
    end
    return t;
end

--����з��غ�����
function p.GetEnemyTurnData()
	
end



