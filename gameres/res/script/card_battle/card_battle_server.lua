--------------------------------------------------------------
-- FileName: 	card_battle_server.lua
-- author:		hst, 2013年9月6日
-- purpose:		卡牌对战数据模拟
--------------------------------------------------------------

card_battle_server = {}
local p = card_battle_server;

p.heroCamp = nil; --英雄方阵营数据
p.enemyCamp = nil;--敌方阵营数据

--初使化英雄、敌方 阵营数据
function p.InitDB()
	p.heroCamp = card_battle_mgr.heroCamp;
    p.enemyCamp = card_battle_mgr.enemyCamp;
end

--起手阶段数据
function p.GetHandStageData( camp )
	local t = {};
	local heroes = p.heroCamp:GetAliveFighters();
    local enemies = p.enemyCamp:GetAliveFighters();
    
    --英雄方起手阶段技能
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
	
	--敌方起手阶段技能
	
    return t;
end

--构造DOT伤害数据（英雄方和敌方）
function p.GetDotData( camp )
    --获取英雄方的DOT伤害数据
	if camp == E_CARD_CAMP_HERO then
	
	--获取敌方的DOT伤害数据
	elseif camp == E_CARD_CAMP_ENEMY then	
	
	end
end

--随机构造卡牌可以发动技能数据
function p.GetSkillData( camp, fighterId )
    local t = {};
    local atkFighters;   --发动技能阵营
    local defFighters;   --守方阵营
    
    --获取英雄方的skill数据
    if camp == E_CARD_CAMP_HERO then
        atkFighters = p.heroCamp:GetAliveFighters();
        defFighters = p.enemyCamp:GetAliveFighters();
        
    --获取敌方的skill数据
    elseif camp == E_CARD_CAMP_ENEMY then   
        atkFighters = p.enemyCamp:GetAliveFighters();
        defFighters = p.heroCamp:GetAliveFighters();
    end
    
    --如果是英雄方的手动触发
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


--构造卡牌普通攻击数据（英雄方和敌方）
function p.GetAtkData( camp )
    local t = {};
    local atkFighter;   --攻击方
    local defFighter;   --防守方
    
	--获取英雄方的atk数据
    if camp == E_CARD_CAMP_HERO then
        atkFighter = p.heroCamp:GetAliveFighters();
        defFighter = p.enemyCamp:GetAliveFighters();
        
    --获取敌方的atk数据
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

--构造敌方回合数据
function p.GetEnemyTurnData()
	
end



