--------------------------------------------------------------
-- FileName:    card_box_mgr.lua
-- author:      hst, 2013/07/10
-- purpose:     �ֿ������--������ؿ�������
--------------------------------------------------------------

card_depot_mgr = {}
local p = card_depot_mgr;
p.cardList = nil;
p.layer = nil;
p.storeSum = 0;--�ֿ���Է������
p.bagSum = 0;--���Է��뿨��������
p.selectCardList = {};

--�����û����еĿ�����Ϣ
function p.LoadAllCard()
    --WriteCon("**���󿨰�����**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    SendReq("Card","GetUserCardsStore",uid,"");
end

--�������
function p.ClearData()
    p.cardList = nil;
    p.layer = nil;
    p.selectCardList = {};
    p.storeSum = 0;
    p.bagSum = 0;
end

--����ص�����ʾ�����б�
function p.RefreshUI( result )
    if result == nil then
        WriteCon("RefreshUI():result is null");
        return ;
    else
        p.cardList = result.user_cards_store;
        if p.cardList == nil then
            p.cardList = {};
        end
        p.storeSum = tonumber( result.store_max ) - #p.cardList;
        p.bagSum = tonumber( result.bag_max ) - tonumber( result.user_cards_sum );  
    end
    --WriteCon( string.format("�����Դ���ֿ�����:%d", p.storeSum) );
    --WriteCon( string.format("���Է��뿨��������:%d", p.bagSum) );
    dlg_card_depot.UpdateDepotInfo();
    dlg_card_depot.ShowCardList( p.cardList );
end

--��ʾ���п���
function p.ShowAllCards()
    dlg_card_depot.ShowCardList( p.cardList );
end

--����ĳһ����Ŀ���
function p.LoadCardByCategory( category )
    if category == nil then
        --WriteCon("loadCardByCategory():category is null");
        return ;
    end
    local cardList = p.GetCardList( category );
    dlg_card_depot.ShowCardList( cardList );
end

--��ȡĳһ���࿨��
function p.GetCardList( category )
    if p.cardList == nil or #p.cardList <= 0 then
        return nil;
    end
    local t = {};
    for k,v in ipairs(p.cardList) do
        if tonumber(v.pierce) == category then
            t[#t+1] = v;
        end
    end
    return t;
end

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

--��ȡ��ѡ��Ŀ����б�
function p.GetSelectCardList()
    if p.selectCardList == nil or #p.selectCardList <= 0 then
        return nil;
    end
    
    local t = {};
    for k, v in ipairs(p.selectCardList) do
        t[#t+1] = p.GetCardById( v:GetId() );
    end
    return t;
end

function p.ClearSelectList()
    for k, v in ipairs(p.selectCardList) do
        v:DelAniEffect("ui.card_select_fx");
    end
    p.selectCardList={};
end

--���ȼ�����
function p.SortByLevelDes()
    if p.cardList == nil or #p.cardList <= 0 then
        return ;
    end
    table.sort(p.cardList, p.sortLevelDes);
    p.ShowAllCards();
end

--���Ǽ�����
function p.SortByRareDes()
    if p.cardList == nil or #p.cardList <= 0 then
    	return ;
    end
    table.sort(p.cardList, p.sortRareDes);
    p.ShowAllCards();
end

-- �ȼ�����
function p.sortLevelDes(a,b)
    if tonumber(a.level) == tonumber(b.level) then
        return tonumber(a.id) < tonumber(b.id);
    else
        return tonumber(a.level) < tonumber(b.level);
    end
end

-- ϡ�ж�����
function p.sortRareDes(a,b)
    if tonumber(a.rare) == tonumber(b.rare) then
        return tonumber(a.id) < tonumber(b.id);
    else
        return tonumber(a.rare) < tonumber(b.rare);
    end
end