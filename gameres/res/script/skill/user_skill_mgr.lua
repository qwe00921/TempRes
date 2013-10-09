--------------------------------------------------------------
-- FileName: 	user_skill_mgr.lua
-- author:		xyd, 2013/08/05
-- purpose:		������--�����ܿ������ݼ���
--------------------------------------------------------------

user_skill_mgr = {}
local p = user_skill_mgr;

p.cardList = nil;
p.intent = nil;
p.selectCardList = {};          -- �زĿ��б�
p.masterCardId = nil;           -- ����ID
p.singleCard = nil;       -- ���ſ�

-- ���ؿ�����Ϣ
function p.LoadCard( )
    p.intent = dlg_user_skill.intent;
    WriteCon("**�����ܿ�������**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    SendReq("Skill","GetSkillInfo",uid,"");
end

-- ����UI
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


--���ؿ�ǿ���Ŀ���
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


--�����زĿ�
function p.LoadSelectCardList ( cardList )

    if cardList =="" or cardList == nil then
        return nil;
    end

    --����ָ������
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



--�Ƿ�����
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

--��ʾ���п���
function p.ShowAllCards()
    dlg_user_skill.ShowCardList( p.cardList );
end

--����ĳһ����Ŀ���
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


--��ȡĳһ���༼�ܿ���
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

--��ȡ���鿨��
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

-- ��������
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

-- �ȼ�����
function p.sortLevelDes(a,b)
    if tonumber(a.level) == tonumber(b.level) then
        return tonumber(a.id) > tonumber(b.id);
    else
        return tonumber(a.level) > tonumber(b.level);
    end
end

-- ϡ�ж�����
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

-- ͨ��cardID��ȡ������Ϣ
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

--ɾ���б��е�ĳ�ſ��ƣ��������α�ѡ��
function p.SetDelCardById(cardId)
    if cardId == nil then
        return;
    end
    p.masterCardId = tonumber( cardId );
end

--��ȡ��ѡ��Ŀ����б�
function p.GetSelectCardList()
    local t = {};
    for k, v in ipairs(p.selectCardList) do
        t[#t+1] = p.GetCardById( v:GetId() );
    end
    return t;
end

--��ȡ��ѡ��Ŀ����б�ID
function p.GetSelectCardIdList()
    local t = {};
    for k, v in ipairs(p.selectCardList) do
        t[#t+1] = v:GetId();
    end
    return t;
end

-- ��ȡ���ܿ���ͼƬ
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

-- У�鿨���Ƿ�ѡ��
function p.CheckCardIsSelect(cardId)
    for k, v in ipairs(p.selectCardList) do
        if tonumber(v:GetId()) == tonumber(cardId) then
            return k;
        end
    end
    return -1;
end

-- У���زĿ�ѡ������
function p.CheckSelectCardLimit()
    if #p.selectCardList >= MATERIAL_SELECT_MAX_NUM then
        return true;
    else
        return false;
    end
end

-- ��ȡ�زĿ�����
function p.GetSelectCardNum()
    return #p.selectCardList;
end

--�������
function p.ClearData()
    p.cardList = nil;
    p.intent = nil;
    p.selectCardList = {};
    p.masterCardId = nil;
end