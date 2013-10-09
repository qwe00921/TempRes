--------------------------------------------------------------
-- FileName: 	card_box_mgr.lua
-- author:		hst, 2013/07/10
-- purpose:		卡箱管理器--负责加载卡牌数据
--------------------------------------------------------------

card_box_mgr = {}
local p = card_box_mgr;
p.cardList = nil;
p.layer = nil;
p.intent = nil;
p.selectCard = nil;
p.selectCardList = {};
p.bag_max = nil;

----------------卡牌列表的过滤-----------------------

--从列表中屏蔽指定的卡牌
p.delCardId = nil;

--记录融合卡牌的星级：仅融合功能使用
p.fuseCardRare = nil;

--过滤有装备的卡牌
p.isEquiped = false;

--从列表中屏蔽队伍的主卡牌
p.isDelLeader = false;

--从列表中屏蔽不可被选择为进化的副卡牌,需要指定"card_mate"的值。
p.isSelectEvolution = false;
p.cardMate = nil;

--可选择的数量【仅多选有效】
p.selectMaxNum = nil;
p.selectMaxNumMsg = nil;

p.titleText = nil;
p.tipText = nil;

--队伍中的卡牌不能放入仓库
p.isNoSelectInTeam = false;
p.noSelectInTeamMsg = nil;

--选择满级的卡牌
p.isSelectMaxLevel = false;

--加载用户所有的卡牌信息
function p.LoadAllCard()
    p.layer = dlg_card_box_mainui.layer;
    p.intent = dlg_card_box_mainui.intent;
    --WriteCon("**请求卡包数据**");
    local uid = GetUID();
    if uid == 0 or uid == nil then
        return ;
    end;
    SendReq("User","GetUserCardsInfo",uid,"");
end

--请求回调，显示卡牌列表
function p.RefreshUI( data )
    if data == nil then
        WriteCon("RefreshUI():dataList is null");
        return ;
    end
    local dataList = data.user_cards;
    p.bag_max = data.bag_max ;
    p.cardList = {};

    if p.intent == CARD_INTENT_INTENSIFY then
        p.cardList = p.LoadIntensifyCard( dataList );

    elseif p.intent == CARD_INTENT_EVOLUTION then
        p.cardList = p.LoadEvolutionCard( dataList );

    elseif p.intent == CARD_INTENT_GETLIST or p.intent == CARD_INTENT_GETONE then
        p.cardList = p.LoadSelectCardList( dataList );
        
    else
        p.cardList = dataList;
    end
 
    if p.cardList ~= nil and #p.cardList > 0 then
        dlg_card_box_mainui.ShowCardList( p.cardList );
    end
    
    dlg_card_box_mainui.UpdateDepotInfo();
end

--加载可强化的卡牌
function p.LoadIntensifyCard( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    local t = {};
    for k, v in ipairs(cardList) do
        if p.IsMaxLevel( v ) == false then
            t[#t+1] = v;
        end
    end
    return t;
end

--加载满级的卡牌
function p.LoadMaxLevelCard( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    local t = {};
    for k, v in ipairs(cardList) do
        if p.IsMaxLevel( v ) == true then
            t[#t+1] = v;
        end
    end
    return t;
end

--加载可进化的卡牌
function p.LoadEvolutionCard( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    local t = {};
    local tempCardList = cardList;
    for i=1, #tempCardList do
        local card = tempCardList[i];
        local cardMaxRare = SelectCell( T_CARD, card.card_id, "evolution_max" );
        if cardMaxRare ~= card.rare then
            local theSameCard = 0;
            local cardMate = SelectCell( T_CARD, card.card_id, "card_mate" );
            for k, v in ipairs(cardList) do
                local cardMate2 = SelectCell( T_CARD, v.card_id, "card_mate" );
                if cardMate == cardMate2 then
                    if theSameCard >= 2 then
                        break ;
                    end
                    local cardMaxRare2 = SelectCell( T_CARD, v.card_id, "evolution_max" );
                    if cardMaxRare2 ~= v.rare then
                        theSameCard = theSameCard + 1;
                    end
                end
            end
            if theSameCard >= 2 then
                t[#t+1] = card;
            end
        end
    end
    return t;
end

--加载可被选择的卡牌
function p.LoadSelectCardList ( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    --屏蔽指定卡牌
    if p.delCardId ~= nil then
        for k, v in ipairs(cardList) do
            if tonumber( v.id ) == p.delCardId then
                table.remove( cardList, k);
                break ;
            end
        end
    end

    --屏蔽队伍中的主卡牌
    if p.isDelLeader then
        cardList = p.LoadUnLeaderCard( cardList );
    end

    --屏蔽不可被指定为进化的副卡牌
    if p.isSelectEvolution and p.cardMate ~= nil then
        cardList = p.LoadSelectEvolutionCard ( cardList,p.cardMate );
    end
    
    --只加载满级的卡牌
    if p.isSelectMaxLevel == true then
        cardList = p.LoadMaxLevelCard ( cardList );
    end
	
	--屏蔽超出融合所需星级范围的卡牌
	if p.fuseCardRare ~= nil then
		cardList = p.LoadCanFuseCard(cardList);		
	end
	
	if p.isEquiped then
		cardList = p.LoadNoEquipCard(cardList);
	end
    
    return cardList;
end

--载入没有装备的卡牌
function p.LoadNoEquipCard(cardList)
	local t = {};	
	for k, v in ipairs(cardList) do
		if tonumber( v.armor ) == 0 and tonumber( v.jewelry ) == 0 and tonumber( v.weapon ) == 0 then
			t[#t+1] = v;
		end			
	end
	return t;
end
	
--载入可以融合的卡牌
function p.LoadCanFuseCard(cardList)
	
	local maxRare = p.fuseCardRare + 2;
	local minRare = p.fuseCardRare - 2;
	if minRare < 1 then minRare = 1 end
	if maxRare > 5 then maxRare = 5 end

	local t = {};	
	for k, v in ipairs(cardList) do
		if tonumber( v.rare ) <= maxRare and tonumber( v.rare ) >= minRare then
			t[#t+1] = v;	
		end	
	end
	return t;
end

--屏蔽主卡牌
function p.LoadUnLeaderCard( cardList )
    if cardList =="" or cardList == nil then
        return nil;
    end
    
    local t = {};
    for k, v in ipairs(cardList) do
        if not v.leader_check then
            t[#t+1] = v;
        end
    end
    return t;
end

--加载同一类别的卡牌以提供进化
function p.LoadSelectEvolutionCard ( cardList,cardMate )
    if cardList =="" or cardList == nil then
        return nil;
    end
    local t = {};
    for k, v in ipairs(cardList) do
        local cardMate2 = SelectCell( T_CARD, v.card_id, "card_mate" );
        if cardMate == cardMate2 then
            t[#t+1] = v;
        end
    end
    return t;
end

--是否满级
function p.IsMaxLevel( card )
    local level = tonumber( card.level );
    local maxLevel = SelectCell( T_CARD, card.card_id, "max_level" );
    
    if tonumber( maxLevel ) == level then
        return true;
    else
        return false;    
    end 
end

--显示所有卡牌
function p.ShowAllCards()
    dlg_card_box_mainui.ShowCardList( p.cardList );
end

--加载某一分类的卡牌
function p.LoadCardByCategory( category )
    if category == nil then
        --WriteCon("loadCardByCategory():category is null");
        return ;
    end
    local cardList = p.GetCardList( category );
    dlg_card_box_mainui.ShowCardList( cardList );
end

--按等级排序
function p.SortByLevelDes()
	table.sort(p.cardList, p.sortLevelDes);
	p.ShowAllCards();
end

--按星级排序
function p.SortByRareDes()
    table.sort(p.cardList, p.sortRareDes);
    p.ShowAllCards();
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

function p.ClearSelectList()
    for k, v in ipairs(p.selectCardList) do
        v:DelAniEffect("ui.card_select_fx");
    end
    p.selectCardList={};
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

--删除列表中的某张卡牌，用于屏蔽被选择。
function p.SetDelCardById(cardId)
    if cardId == nil then
        return;
    end
    p.delCardId = tonumber( cardId );
end

--从列表中屏蔽不可被选择为进化的副卡牌
function p.SetSelectEvolution( cardMate, bEnable )
    if bEnable == nil or cardMate == nil then
        return;
    end
    p.cardMate = cardMate;
    p.isSelectEvolution = bEnable;
end

--启用屏蔽主卡牌
function p.SetDelLeader( bEnable )
    if bEnable == nil then
        return;
    end
    p.isDelLeader = bEnable;
end

--获取己选择的卡牌
function p.GetSelectCard()
    return p.GetCardById( p.selectCard:GetId() );
end

--获取己选择的卡牌列表
function p.GetSelectCardList()
    local t = {};
    for k, v in ipairs(p.selectCardList) do
        t[#t+1] = p.GetCardById( v:GetId() );
    end
    return t;
end

function p.SetSelectMaxNum( num )
	if num ~= nil then
		p.selectMaxNum = tonumber( num );
	end 
end

function p.SetSelectMaxNumMsg( str )
    if str ~= nil then
        p.selectMaxNumMsg = tostring( str );
    end 
end

function p.SetTitleText( str )
	if str ~= nil then
		p.titleText = tostring( str );
	end
end

function p.SetTipText( str )
    if str ~= nil then
        p.tipText = tostring( str );
    end
end

function p.SetNoSelectInTeam( bEnable )
	if bEnable ~= nil then
		p.isNoSelectInTeam = bEnable;
	end
end

function p.SetNoSelectInTeamMsg( str )
    if str ~= nil then
        p.noSelectInTeamMsg = str;
    end
end

function p.SetEquiped( bEnable )
	if bEnable ~= nil then
		p.isEquiped = bEnable;
	end
end

--设置只显示满级的卡牌
function p.SetSelectMaxLevel( bEnable )
    if bEnable ~= nil then
        p.isSelectMaxLevel = bEnable;
    end
end

--设置融合卡牌的星级
function p.SetFuseCardRare( num )
	if num ~= nil then
		p.fuseCardRare = tonumber( num );
	end 
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


--清空数据
function p.ClearData()
    p.cardList = nil;
    p.layer = nil;
    p.intent = nil;
    p.selectCard = nil;
    p.selectCardList = {};
    p.delCardId = nil;
    p.isDelLeader = false;
    p.isDelUnEvolution = false;
    p.isSelectEvolution = false;
    p.cardMate = nil;
    p.selectMaxNum = nil;
    p.selectMaxNumMsg = nil;
    p.titleText = nil;
    p.tipText = nil;
    p.isNoSelectInTeam = false;
    p.noSelectInTeamMsg = nil;
    p.bag_max = nil;
    p.isSelectMaxLevel = false;
	p.fuseCardRare = nil;
	p.isEquiped = false;
end