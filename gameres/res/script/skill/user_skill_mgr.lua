--------------------------------------------------------------
-- FileName: 	user_skill_mgr.lua
-- author:		xyd, 2013/08/05
-- purpose:		管理器--负责技能卡牌数据加载
--------------------------------------------------------------

user_skill_mgr = {}
local p = user_skill_mgr;

p.cardList = nil;
p.intent = nil;
p.selectCardList = {};          -- 素材卡列表
p.masterCardId = nil;           -- 主卡ID
p.singleCard = nil;       -- 单张卡

-- 加载卡牌信息
function p.LoadCard( )
    p.intent = dlg_user_skill.intent;
    WriteCon("**请求技能卡包数据**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    SendReq("Skill","GetSkillInfo",uid,"");
end

-- 加载UI
function p.RefreshUI(dataList)

    if dataList == nil then
        WriteCon("RefreshUI():dataList is null");
        return ;
    end
    
    p.cardList = {};
    if SKILL_INTENT_PREVIEW == p.intent then
        p.cardList = p.LoadIntensifyCard( dataList );
    elseif SKILL_INTENT_GETLIST == p.intent then
        p.selectCardList = {};
        p.cardList = p.LoadSelectCardList( dataList );
    elseif SKILL_INTENT_GETONE == p.intent then
        p.cardList = dataList;
    end
    
    if p.cardList ~= nil and #p.cardList > 0 then
        dlg_user_skill.ShowCardList( p.cardList );
    end
   
end


--加载可强化的卡牌
function p.LoadIntensifyCard( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    local t = {};
    for k, v in ipairs(cardList) do
        local rare = tonumber( v.rare );
        local level = tonumber( v.level );
        if p.IsMaxLevel( rare, level ) == false then
            t[#t+1] = v;
        end
    end
    return t;
end


--加载素材卡
function p.LoadSelectCardList ( cardList )

    if cardList =="" or cardList == nil then
        return nil;
    end

    --屏蔽指定卡牌
    if p.masterCardId ~= nil then
        for k, v in ipairs(cardList) do
            if tonumber( v.id ) == p.masterCardId then
                table.remove( cardList, k);
                break ;
            end
        end
    end

    return cardList;
end



--是否满级
function p.IsMaxLevel( rare, level )
    local flag = false;
    if rare == 1 and level == 20 then
        flag = true;
    elseif rare == 2 and level == 30 then
        flag = true;
    elseif rare == 3 and level == 40 then
        flag = true;
    elseif rare == 4 and level == 50 then
        flag = true;
    elseif rare == 5 and level == 60 then
        flag = true;
    elseif rare == 6 and level == 60 then
        flag = true;
    elseif rare == 7 and level == 60 then
        flag = true;
    else
        flag = false;
    end
    return flag;
end

--显示所有卡牌
function p.ShowAllCards()
    dlg_user_skill.ShowCardList( p.cardList );
end

--加载某一分类的卡牌
function p.LoadCardByCategory( category )
    if category == nil then
        WriteCon("loadCardByCategory():category is null");
        return ;
    end
    
    local cardList = nil;
    if (category == SKILL_PIERCE_1 or category == SKILL_PIERCE_2) then
        cardList = p.GetCardList( category );
    elseif (category == SKILL_PIERCE_3) then
        cardList = p.GetEXPCardList( category );
    end
    
    dlg_user_skill.ShowCardList( cardList );
end


--获取某一分类技能卡牌
function p.GetCardList( category )
    if p.cardList == nil or #p.cardList <= 0 then
        return nil;
    end
    local t = {};
    for k,v in ipairs(p.cardList) do
                
        if tonumber(v.skill_type) == category then
            t[#t+1] = v;
        end
    end
    
    return t;
end

--获取经验卡牌
function p.GetEXPCardList( category )
    if p.cardList == nil or #p.cardList <= 0 then
        return nil;
    end
    local t = {};
    for k,v in ipairs(p.cardList) do
        if tonumber(v.skill_owner ) == category then
            t[#t+1] = v;
        end
    end
    return t;
end

-- 卡牌排序
function p.sortCardList( sort_flag , category)
    
    if category == nil then
        WriteCon("sortCardList():category is null");
        return ;
    end
    
    local cardList = nil;
    if (category == SKILL_PIERCE_1 or category == SKILL_PIERCE_2) then
        cardList = p.GetCardList( category );
    elseif (category == SKILL_PIERCE_3) then
        cardList = p.GetEXPCardList( category );
    elseif (category == SKILL_PIERCE_4) then
        cardList = p.cardList;
    end
    
    if cardList == nil or #cardList <= 0 then
        WriteCon("sortCardList():cardList is null");
        return nil;
    end
    
    if (sort_flag == SKILL_SORT_LEVEL) then
        table.sort(cardList, p.sortLevelDes);
    elseif (sort_flag == SKILL_SORT_RARE) then
        table.sort(cardList, p.sortRareDes);
    end
    dlg_user_skill.ShowCardList( cardList );
end

-- 等级排序
function p.sortLevelDes(a,b)
    if tonumber(a.level) == tonumber(b.level) then
        return tonumber(a.id) > tonumber(b.id);
    else
        return tonumber(a.level) > tonumber(b.level);
    end
end

-- 稀有度排序
function p.sortRareDes(a,b)
    if tonumber(a.rare) == tonumber(b.rare) then
        return tonumber(a.id) > tonumber(b.id);
    else
        return tonumber(a.rare) > tonumber(b.rare);
    end
end


function p.ClearSelectList()
    for k, v in ipairs(p.selectCardList) do
        v:DelAniEffect("ui.card_select_fx");
    end
    p.selectCardList={};
end

-- 通过cardID获取卡牌信息
function p.GetCardById( cardId )
    if cardId == nil then
        return nil;
    end
    for i=1, #p.cardList do
        local card = p.cardList[i];
        if tonumber( card.id ) == cardId then
            return card;
        end
    end
end

--删除列表中的某张卡牌，用于屏蔽被选择。
function p.SetDelCardById(cardId)
    if cardId == nil then
        return;
    end
    p.masterCardId = tonumber( cardId );
end

--获取己选择的卡牌列表
function p.GetSelectCardList()
    local t = {};
    for k, v in ipairs(p.selectCardList) do
        t[#t+1] = p.GetCardById( v:GetId() );
    end
    return t;
end

--获取已选择的卡牌列表ID
function p.GetSelectCardIdList()
    local t = {};
    for k, v in ipairs(p.selectCardList) do
        t[#t+1] = v:GetId();
    end
    return t;
end

-- 获取技能卡牌图片
function p.GetCardPicture(skill_id)
    --WriteCon("skill_id = "..skill_id);
    --local skill_id = SelectCell( T_SKILL, skill_id, "picPath" )
    --return GetPictureByAni("card.card_box_db", 0);  
    local pic = GetPictureByAni("card.skill_"..skill_id, 0);
    if pic == nil then
    	pic = GetPictureByAni("card.card_box_db_new", 0);
    end
    return pic;
end

-- 校验卡牌是否选中
function p.CheckCardIsSelect(cardId)
    for k, v in ipairs(p.selectCardList) do
        if tonumber(v:GetId()) == tonumber(cardId) then
            return k;
        end
    end
    return -1;
end

-- 校验素材卡选择上限
function p.CheckSelectCardLimit()
    if #p.selectCardList >= MATERIAL_SELECT_MAX_NUM then
        return true;
    else
        return false;
    end
end

-- 获取素材卡数量
function p.GetSelectCardNum()
    return #p.selectCardList;
end

--清空数据
function p.ClearData()
    p.cardList = nil;
    p.intent = nil;
    p.selectCardList = {};
    p.masterCardId = nil;
end