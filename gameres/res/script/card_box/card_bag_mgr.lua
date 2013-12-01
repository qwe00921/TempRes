card_bag_mgr = {}
local p = card_bag_mgr;

p.cardList = nil;
p.layer = nil


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
	p.cardList = dataList;
	card_bag_mian.ShowCardList(p.cardList);
end


