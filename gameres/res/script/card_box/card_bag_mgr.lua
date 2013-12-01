card_bag_mgr = {}
local p = card_bag_mgr;

p.cardList = nil;
p.layer = nil
p.cardListByProf = nil;

--加载用户所有道具
function p.LoadAllCard(layer)
	p.ClearData();
	if layer ~= nil then
		p.layer = layer;
	end
	WriteCon("====request card list");
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	SendReq("CardList","List",10001,"");
end

--情空数据
function p.ClearData()
    p.cardList = nil;
    p.layer = nil;
end

--请求回调，显示卡牌列表
function p.RefreshUI(dataList)
	p.sortByRuleV = CARD_BAG_SORT_BY_LEVEL;
	table.sort(dataList,p.sortByLevel);
	p.cardList = dataList;
	p.cardListByProf = dataList;
	card_bag_mian.ShowCardList(p.cardList);
end

--显示所有卡牌
function p.ShowAllCards()
	WriteCon("card_bag_mgr.ShowAllCards();");
	p.cardListByProf = p.cardList
	
	if card_bag_mian.sortByRuleV ~= nil then
		p.sortByRule(card_bag_mian.sortByRuleV)
	else
		card_bag_mian.ShowCardList(p.cardListByProf);
	end
end

--按职业显示卡牌
function p.ShowCardByProfession(profType)
	WriteCon("card_bag_mgr.ShowCardByProfession();");
	if profType == nil then
		WriteCon("ShowCardByProfession():profession Type is null");
		return;
	end 
	p.cardListByProf = p.GetCardList(profType);
	
	if card_bag_mian.sortByRuleV ~= nil then
		p.sortByRule(card_bag_mian.sortByRuleV)
	else
		card_bag_mian.ShowCardList(p.cardListByProf);
	end
end
--获取显示列表
function p.GetCardList(profType)
	local t = {};
	if p.cardList == nil then 
		return t;
	end
	
	if profType == PROFESSION_TYPE_1 then 
		for k,v in pairs(p.cardList) do
			if tonumber(v.Damage_type) == 1 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_2 then 
		for k,v in pairs(p.cardList) do
			if tonumber(v.Damage_type) == 2 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_3 then 
		for k,v in pairs(p.cardList) do
			if tonumber(v.Damage_type) == 3 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_4 then 
		for k,v in pairs(p.cardList) do
			if tonumber(v.Damage_type) == 4 then
				t[#t + 1] = v;
			end
		end
	end
	return t;
end

--按规则排序
function p.sortByRule(sortType)
	if sortType == nil or p.cardListByProf == nil then 
		return
	end
	if sortType == CARD_BAG_SORT_BY_LEVEL then
		WriteCon("========sort by level");
		table.sort(p.cardListByProf,p.sortByLevel);
	elseif sortType == CARD_BAG_SORT_BY_STAR then
		WriteCon("========sort by star");
		table.sort(p.cardListByProf,p.sortByStar);
	elseif sortType == CARD_BAG_SORT_BY_TIME then
		WriteCon("========sort by time");
		table.sort(p.cardListByProf,p.sortByTime);
	end
	card_bag_mian.ShowCardList(p.cardListByProf);
end

--按等级排序
function p.sortByLevel(a,b)
	return tonumber(a.Level) < tonumber(b.Level);
end
--按星级排序
function p.sortByStar(a,b)
	return tonumber(a.Rare) < tonumber(b.Rare);
end
--按时间排序
function p.sortByTime(a,b)
	return tonumber(a.Time) < tonumber(b.Time);
end
