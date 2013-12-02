card_bag_mgr = {}
local p = card_bag_mgr;

p.layer 		= nil;
p.cardList	 	= nil;	--总卡牌列表
p.cardListByProf = nil;	--按职业卡牌列表
p.delCardList 	= nil;	--删除卡牌列表

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
	SendReq("CardList","List",uid,"");
end

--请求回调，显示卡牌列表
function p.RefreshUI(dataList)
	if p.layer == nil or p.layer:IsVisible() ~= true then
		return;
	end
	card_bag_mian.sortByRuleV = CARD_BAG_SORT_BY_LEVEL;
	table.sort(dataList,p.sortByLevel);
	p.cardList = dataList;
	p.cardListByProf = dataList;
	card_bag_mian.ShowCardList(p.cardList);
end

--发送删除请求
function p.SendDelRequest(deleteList)
	p.delCardList = deleteList;
	local uid = GetUID();
	if uid == 0 or uid == nil then 
		return;
	end
	local param = nil;
	for k,v in pairs(deleteList) do
		if param == nil then
			param = v
		else
			param = param..","..v
		end
	end
	param = "id="..param;
	WriteCon("Send Delete Msg:param=="..param);
	SendReq("CardList","Sell",uid,param);
end

--删除请求回调
function p.DelCallBack(self)
	if self.result == true then
		p.RefreshCardList(p.delCardList)
		
		p.delCardList = nil;
		card_bag_mian.sellCardList = {};
		card_bag_mian.BatchSellMark = OFF;
		local btn = GetButton(p.layer, ui_card_main_view.ID_CTRL_BUTTON_SELL);
		btn:SetImage( GetPictureByAni("button.sell",1));
		dlg_msgbox.ShowOK(ToUtf8("确认提示框"),ToUtf8("出售卡牌获得 "..tostring(self.money.Add).."金币。"),nil,p.layer);
	else
		local messageText = self.message
		dlg_msgbox.ShowOK(ToUtf8("确认提示框"),messageText,nil,p.layer);
		card_bag_mian.sellCardList = {};
		p.delCardList = nil;
	end
end
--刷新卡牌列表
function p.RefreshCardList(delData)
	if type(delData) ~= "table"  then
		WriteCon("not table delete");
		for k,v in pairs(p.cardList) do
			if tonumber(v.UniqueId) == tonumber(delData) then 
				table.remove(p.cardList,k)
			end
		end
	elseif type(delData) == "table" then
		WriteCon("table delete");
		for k,v in pairs(p.cardList) do
			for j,h in pairs(delData) do
				if tonumber(v.UniqueId) == tonumber(h) then 
					table.remove(p.cardList,k)
				end
			end
		end
	end
	card_bag_mian.ShowCardList(p.cardList);
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
	if profType == PROFESSION_TYPE_0 then
		t = p.cardList;
	elseif profType == PROFESSION_TYPE_1 then 
		for k,v in pairs(p.cardList) do
			if tonumber(v.Class) == 1 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_2 then 
		for k,v in pairs(p.cardList) do
			if tonumber(v.Class) == 2 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_3 then 
		for k,v in pairs(p.cardList) do
			if tonumber(v.Class) == 3 then
				t[#t + 1] = v;
			end
		end
	elseif profType == PROFESSION_TYPE_4 then 
		for k,v in pairs(p.cardList) do
			if tonumber(v.Class) == 4 then
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

--情空数据
function p.ClearData()
	p.layer 		= nil;
	p.cardList	 	= nil;
	p.cardListByProf = nil;
	p.delCardList 	= nil;
end








