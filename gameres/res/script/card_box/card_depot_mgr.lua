--------------------------------------------------------------
-- FileName:    card_box_mgr.lua
-- author:      hst, 2013/07/10
-- purpose:     仓库管理器--负责加载卡牌数据
--------------------------------------------------------------

card_depot_mgr = {}
local p = card_depot_mgr;
p.cardList = nil;
p.layer = nil;
p.storeSum = 0;--仓库可以放入的量
p.bagSum = 0;--可以放入卡包的数量
p.selectCardList = {};

--加载用户所有的卡牌信息
function p.LoadAllCard()
    --WriteCon("**请求卡包数据**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    SendReq("Card","GetUserCardsStore",uid,"");
end

--清空数据
function p.ClearData()
    p.cardList = nil;
    p.layer = nil;
    p.selectCardList = {};
    p.storeSum = 0;
    p.bagSum = 0;
end

--请求回调，显示卡牌列表
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
    --WriteCon( string.format("还可以存入仓库数量:%d", p.storeSum) );
    --WriteCon( string.format("可以放入卡包的数量:%d", p.bagSum) );
    dlg_card_depot.UpdateDepotInfo();
    dlg_card_depot.ShowCardList( p.cardList );
end

--显示所有卡牌
function p.ShowAllCards()
    dlg_card_depot.ShowCardList( p.cardList );
end

--加载某一分类的卡牌
function p.LoadCardByCategory( category )
    if category == nil then
        --WriteCon("loadCardByCategory():category is null");
        return ;
    end
    local cardList = p.GetCardList( category );
    dlg_card_depot.ShowCardList( cardList );
end

--获取某一分类卡牌
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

--获取己选择的卡牌列表
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

--按等级排序
function p.SortByLevelDes()
    if p.cardList == nil or #p.cardList <= 0 then
        return ;
    end
    table.sort(p.cardList, p.sortLevelDes);
    p.ShowAllCards();
end

--按星级排序
function p.SortByRareDes()
    if p.cardList == nil or #p.cardList <= 0 then
    	return ;
    end
    table.sort(p.cardList, p.sortRareDes);
    p.ShowAllCards();
end

-- 等级排序
function p.sortLevelDes(a,b)
    if tonumber(a.level) == tonumber(b.level) then
        return tonumber(a.id) < tonumber(b.id);
    else
        return tonumber(a.level) < tonumber(b.level);
    end
end

-- 稀有度排序
function p.sortRareDes(a,b)
    if tonumber(a.rare) == tonumber(b.rare) then
        return tonumber(a.id) < tonumber(b.id);
    else
        return tonumber(a.rare) < tonumber(b.rare);
    end
end